# frozen_string_literal: true

require "fileutils"
require "logger"

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
