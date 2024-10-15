# frozen_string_literal: true

require "fileutils"
require "logger"
require "down"
require "zip"
require "ffi"
require "wav-file"

module Workflows
  # VoskModelAdaptationWorkflow
  # This class outlines the workflow for adapting an existing VOSK language model
  # based on the guide at https://alphacephei.com/vosk/adaptation
  #
  # Usage:
  #   workflow = Workflows::VoskModelAdaptationWorkflow.new('/path/to/vosk/model')
  #   workflow.run_workflow(
  #     ['new', 'words', 'to', 'add'],
  #     '/path/to/new/text.txt',
  #     '/path/to/lexicon.txt',
  #     '/path/to/language_model.arpa',
  #     '/path/to/finetuning/data'
  #   )
  #
  # You can also run individual steps if needed:
  #   workflow.update_runtime_vocabulary(['new', 'words'])
  #   workflow.update_language_model('/path/to/new/text.txt')
  #   workflow.update_big_model_vocabulary('/path/to/lexicon.txt', '/path/to/language_model.arpa')
  #   workflow.finetune_acoustic_model('/path/to/finetuning/data')
  class VoskModelAdaptationWorkflow
    # VOSK FFI bindings
    module VOSK
      extend FFI::Library
      ffi_lib "libvosk.so"

      attach_function :vosk_model_new, [:string], :pointer
      attach_function :vosk_recognizer_new, %i[pointer float], :pointer
      attach_function :vosk_recognizer_accept_waveform, %i[pointer pointer int], :int
      attach_function :vosk_recognizer_result, [:pointer], :string
      attach_function :vosk_recognizer_free, [:pointer], :void
      attach_function :vosk_model_free, [:pointer], :void
    end

    # Manages downloading and extracting VOSK models
    class VOSKModelManager
      VOSK_MODEL_URL = "https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip"
      MODEL_DIR = "vosk_model"

      def download_and_extract
        return if Dir.exist?(MODEL_DIR)

        Down.download(VOSK_MODEL_URL, destination: "vosk_model.zip")
        Zip::File.open("vosk_model.zip") do |zip_file|
          zip_file.each do |f|
            fpath = File.join(MODEL_DIR, f.name)
            zip_file.extract(f, fpath) unless File.exist?(fpath)
          end
        end
        File.delete("vosk_model.zip")
      end
    end

    # Manages downloading and loading example sentences
    class SentenceManager
      SENTENCES_URL = "https://example.com/sentences.txt" # Replace with actual URL
      SENTENCES_FILE = "sentences.txt"

      def download_sentences
        return if File.exist?(SENTENCES_FILE)

        Down.download(SENTENCES_URL, destination: SENTENCES_FILE)
      end

      def load_sentences
        File.readlines(SENTENCES_FILE).map(&:chomp)
      end
    end

    # Records audio for sentences
    class AudioRecorder
      def record_sentence(sentence_number)
        puts "Press Enter to start recording sentence #{sentence_number}, then speak."
        gets
        system("arecord -d 5 -f S16_LE -r 16000 sentence_#{sentence_number}.wav")
        puts "Recording complete."
      end

      def record_all_sentences(sentences)
        sentences.each_with_index do |sentence, index|
          puts "Sentence #{index + 1}: #{sentence}"
          record_sentence(index + 1)
        end
      end
    end

    # Decodes audio files and scores the results
    class Decoder
      def initialize(model_path)
        @model = VOSK.vosk_model_new(model_path)
      end

      def decode_file(file_path)
        recognizer = VOSK.vosk_recognizer_new(@model, 16_000.0)
        File.open(file_path, "rb") do |file|
          while (data = file.read(4096))
            VOSK.vosk_recognizer_accept_waveform(recognizer, data, data.size)
          end
        end
        result = VOSK.vosk_recognizer_result(recognizer)
        VOSK.vosk_recognizer_free(recognizer)
        JSON.parse(result)["text"]
      end

      def score_sentences(sentences, decoded_sentences)
        correct_words = sentences.zip(decoded_sentences).sum do |original, decoded|
          original.split.zip(decoded.split).count { |a, b| a.downcase == b.downcase }
        end
        total_words = sentences.sum { |s| s.split.size }
        (correct_words.to_f / total_words * 100).round(2)
      end
    end

    # Adapts the acoustic model using recorded audio
    class ModelAdapter
      def adapt_model(base_model_path, adapted_model_path, audio_files)
        # This is a placeholder. Actual implementation will depend on VOSK's adaptation API
        # You might need to use system calls to run external tools for adaptation
        system("vosk-adapt #{base_model_path} #{adapted_model_path} #{audio_files.join(' ')}")
      end
    end

    def initialize(model_path)
      @model_path = model_path
      @temp_dir = File.join(Dir.tmpdir, "vosk_adaptation")
      FileUtils.mkdir_p(@temp_dir)
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end

    # Run the entire workflow
    def run_workflow(word_list, text_file, lexicon_file, lm_file, data_dir)
      @logger.info("Starting VOSK model adaptation workflow")
      update_runtime_vocabulary(word_list)
      update_language_model(text_file)
      update_big_model_vocabulary(lexicon_file, lm_file)
      finetune_acoustic_model(data_dir)
      @logger.info("VOSK model adaptation workflow completed")
    end

    # Step 1: Update recognizer vocabulary in runtime
    # Requires: A list of words to add to the vocabulary
    def update_runtime_vocabulary(word_list)
      @logger.info("Updating runtime vocabulary with #{word_list.size} words")
      begin
        # Implementation would depend on the Vosk-API
        # Refer to https://github.com/alphacep/vosk-api/blob/master/python/example/test_words.py
        # Placeholder implementation:
        File.write(File.join(@temp_dir, "runtime_vocabulary.txt"), word_list.join("\n"))
        @logger.info("Runtime vocabulary updated successfully")
      rescue StandardError => e
        @logger.error("Error updating runtime vocabulary: #{e.message}")
      end
    end

    # Step 2: Update the language model
    # Requires: A text file containing the new language data
    def update_language_model(text_file)
      @logger.info("Updating language model using text from: #{text_file}")
      begin
        preprocessed_text = preprocess_text(text_file)
        build_grammar(preprocessed_text)
        @logger.info("New Gr.fst file created and replaced in the model")
      rescue StandardError => e
        @logger.error("Error updating language model: #{e.message}")
      end
    end

    # Step 3: Update words and vocabulary in big models
    # Requires: A lexicon file and a language model file
    def update_big_model_vocabulary(lexicon_file, lm_file)
      @logger.info("Updating big model vocabulary and language model")
      begin
        compile_lexicon(lexicon_file)
        compile_graph(lm_file)
        replace_graph
        @logger.info("Big model vocabulary and language model updated successfully")
      rescue StandardError => e
        @logger.error("Error updating big model vocabulary: #{e.message}")
      end
    end

    # Step 4: Adapt acoustic model with finetuning
    # Requires: A directory containing the finetuning data
    def finetune_acoustic_model(data_dir)
      @logger.info("Finetuning acoustic model with data from: #{data_dir}")
      begin
        prepared_data = prepare_data(data_dir)
        run_kaldi_finetuning(prepared_data)
        @logger.info("Acoustic model finetuned successfully")
      rescue StandardError => e
        @logger.error("Error finetuning acoustic model: #{e.message}")
      end
    end

    # Orchestrates the entire workflow
    def run
      model_manager = VOSKModelManager.new
      model_manager.download_and_extract

      sentence_manager = SentenceManager.new
      sentence_manager.download_sentences
      sentences = sentence_manager.load_sentences

      recorder = AudioRecorder.new
      recorder.record_all_sentences(sentences)

      base_decoder = Decoder.new("vosk_model")
      base_decoded = sentences.map.with_index(1) do |_, i|
        base_decoder.decode_file("sentence_#{i}.wav")
      end
      base_score = base_decoder.score_sentences(sentences, base_decoded)
      puts "Base model score: #{base_score}%"

      adapter = ModelAdapter.new
      adapter.adapt_model("vosk_model", "adapted_model", Dir["sentence_*.wav"])

      adapted_decoder = Decoder.new("adapted_model")
      adapted_decoded = sentences.map.with_index(1) do |_, i|
        adapted_decoder.decode_file("sentence_#{i}.wav")
      end
      adapted_score = adapted_decoder.score_sentences(sentences, adapted_decoded)
      puts "Adapted model score: #{adapted_score}%"
    end

    private

    def preprocess_text(text_file)
      @logger.debug("Preprocessing text from #{text_file}")
      text = File.read(text_file)
      processed_text = text.downcase.gsub(/[^\w\s]/, "")
      File.write(File.join(@temp_dir, "preprocessed_text.txt"), processed_text)
      File.join(@temp_dir, "preprocessed_text.txt")
    end

    def build_grammar(preprocessed_text_file)
      @logger.debug("Building grammar using OpenFST and OpenGRM")
      # Placeholder implementation:
      system("fstcompile --isymbols=#{@model_path}/words.txt --osymbols=#{@model_path}/words.txt #{preprocessed_text_file} | fstarcsort > #{@model_path}/Gr.fst")
    end

    def compile_lexicon(lexicon_file)
      @logger.debug("Compiling lexicon from #{lexicon_file}")
      # Placeholder implementation:
      system("fstcompile --isymbols=#{@model_path}/phones.txt --osymbols=#{@model_path}/words.txt #{lexicon_file} | fstarcsort > #{@model_path}/L.fst")
    end

    def compile_graph(lm_file)
      @logger.debug("Compiling graph using language model from #{lm_file}")
      # Placeholder implementation:
      system("fstcompile --isymbols=#{@model_path}/words.txt --osymbols=#{@model_path}/words.txt #{lm_file} | fstarcsort > #{@model_path}/G.fst")
    end

    def replace_graph
      @logger.debug("Replacing graph in the model")
      # Placeholder implementation:
      FileUtils.cp(File.join(@model_path, "G.fst"), File.join(@model_path, "HCLG.fst"))
    end

    def prepare_data(data_dir)
      @logger.debug("Preparing data from #{data_dir} in Kaldi format")
      # Placeholder implementation:
      prepared_data_dir = File.join(@temp_dir, "prepared_data")
      FileUtils.cp_r(data_dir, prepared_data_dir)
      prepared_data_dir
    end

    def run_kaldi_finetuning(prepared_data_dir)
      @logger.debug("Running Kaldi finetuning script on data in #{prepared_data_dir}")
      # Placeholder implementation:
      system("kaldi-finetuning-script.sh #{prepared_data_dir} #{@model_path}")
    end
  end
end
