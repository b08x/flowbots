#!/usr/bin/env ruby

lib_dir = File.expand_path(File.join(__dir__, "lib"))
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)

APP_ROOT = __dir__

OWNER = "b08x".freeze
ALL_IMAGES = %w[
  flowbots
].each(&:freeze).freeze

BASE_IMAGES = ALL_IMAGES.map do |name|
  base_image_name, base_image_tag = nil
  IO.foreach("Dockerfile") do |line|
    break if base_image_name && base_image_tag

    case line
    when /BASE_IMAGE_TAG=(\h+)/
      base_image_tag = Regexp.last_match(1)
    when /BASE_IMAGE_TAG=latest/
      base_image_tag = "latest"
    when /\AFROM\s+([^:]+)/
      base_image_name = Regexp.last_match(1)
    end
  end
  [
    name,
    [base_image_name, base_image_tag].join(":")
  ]
end.to_h

DOCKER_FLAGS = ENV.fetch("DOCKER_FLAGS", nil)

TAG_LENGTH = 12

def git_revision
  `git rev-parse HEAD`.chomp
end

def tag_from_commit_sha1
  git_revision[...TAG_LENGTH]
end

ALL_IMAGES.each do |image|
  revision_tag = tag_from_commit_sha1

  desc "Pull the base image for #{OWNER}/#{image} image"
  task "pull/base_image/#{image}" do
    base_image = BASE_IMAGES[image]
    sh "docker pull #{base_image}"
  end

  desc "Build #{OWNER}/#{image} image"
  task "build/#{image}" => "pull/base_image/#{image}" do
    sh "docker build #{DOCKER_FLAGS} --rm --force-rm -t #{OWNER}/notebook-#{image}:latest ."
  end

  desc "Make #{OWNER}/#{image} image"
  task "make/#{image}" do
    sh "docker build #{DOCKER_FLAGS} --rm --force-rm -t #{OWNER}/notebook-#{image}:latest ."
  end

  desc "Tag #{OWNER}/#{image} image"
  task "tag/#{image}" => "build/#{image}" do
    sh "docker tag #{OWNER}/notebook-#{image}:latest #{OWNER}/notebook-#{image}:#{revision_tag}"
  end

  desc "Push #{OWNER}/#{image} image"
  task "push/#{image}" => "tag/#{image}" do
    sh "docker push #{OWNER}/notebook-#{image}:latest"
    sh "docker push #{OWNER}/notebook-#{image}:#{revision_tag}"
  end
end

desc "Build all images"
task "build-all" do
  ALL_IMAGES.each do |image|
    Rake::Task["build/#{image}"].invoke
  end
end

desc "Tag all images"
task "tag-all" do
  ALL_IMAGES.each do |image|
    Rake::Task["tag/#{image}"].invoke
  end
end

desc "Push all images"
task "push-all" do
  ALL_IMAGES.each do |image|
    Rake::Task["push/#{image}"].invoke
  end
end

### Task: rdoc
require "rake"
require "rake/testtask"
require "rdoc/task"

Rake::RDocTask.new do |rdoc|
  rdoc.title    = "flowbots v0.1"
  rdoc.rdoc_dir = "#{APP_ROOT}/doc"
  rdoc.options += [
    "-w",
    "2",
    "-H",
    "-A",
    "-f",
    "darkfish", # This bit
    "-m",
    "README.md",
    "--visibility",
    "nodoc",
    "--markup",
    "markdown"
  ]
  rdoc.rdoc_files.include "README.md"
  rdoc.rdoc_files.include "LICENSE"
  rdoc.rdoc_files.include "exe/flowbots"

  rdoc.rdoc_files.include "lib/api.rb"
  rdoc.rdoc_files.include "lib/cli.rb"
  rdoc.rdoc_files.include "lib/example.rb"
  rdoc.rdoc_files.include "lib/flowbots.rb"
  rdoc.rdoc_files.include "lib/general_task_agent.rb"
  rdoc.rdoc_files.include "lib/helper.rb"
  rdoc.rdoc_files.include "lib/logging.rb"
  rdoc.rdoc_files.include "lib/tasks.rb"
  rdoc.rdoc_files.include "lib/ui.rb"
  rdoc.rdoc_files.include "lib/workflows.rb"

  rdoc.rdoc_files.include "lib/components/BatchProcessor.rb"
  rdoc.rdoc_files.include "lib/components/ExceptionAgent.rb"
  rdoc.rdoc_files.include "lib/components/ExceptionHandler.rb"
  rdoc.rdoc_files.include "lib/components/FileDiscovery.rb"
  rdoc.rdoc_files.include "lib/components/FileLoader.rb"
  rdoc.rdoc_files.include "lib/components/InputRetrieval.rb"
  rdoc.rdoc_files.include "lib/components/OhmModels.rb"
  rdoc.rdoc_files.include "lib/components/RedisKeys.rb"
  rdoc.rdoc_files.include "lib/components/WorkflowAgent.rb"
  rdoc.rdoc_files.include "lib/components/WorkflowOrchestrator.rb"

  rdoc.rdoc_files.include "lib/flowbots/errors.rb"

  rdoc.rdoc_files.include "lib/grammars/markdown_yaml.rb"

  rdoc.rdoc_files.include "lib/integrations/flowise.rb"

  rdoc.rdoc_files.include "lib/pipelines/unified_file_processing.rb"

  rdoc.rdoc_files.include "lib/processors/GrammarProcessor.rb"
  rdoc.rdoc_files.include "lib/processors/NLPProcessor.rb"
  rdoc.rdoc_files.include "lib/processors/TextProcessor.rb"
  rdoc.rdoc_files.include "lib/processors/TextSegmentProcessor.rb"
  rdoc.rdoc_files.include "lib/processors/TextTaggerProcessor.rb"
  rdoc.rdoc_files.include "lib/processors/TextTokenizeProcessor.rb"
  rdoc.rdoc_files.include "lib/processors/TopicModelProcessor.rb"

  rdoc.rdoc_files.include "lib/tasks/accumulate_filtered_segments_task.rb"
  rdoc.rdoc_files.include "lib/tasks/base_task.rb"
  rdoc.rdoc_files.include "lib/tasks/batch_completion_task.rb"
  rdoc.rdoc_files.include "lib/tasks/display_results_task.rb"
  rdoc.rdoc_files.include "lib/tasks/file_loader_task.rb"
  rdoc.rdoc_files.include "lib/tasks/filter_segments_task.rb"
  rdoc.rdoc_files.include "lib/tasks/llm_analysis_task.rb"
  rdoc.rdoc_files.include "lib/tasks/load_file_object_task.rb"
  rdoc.rdoc_files.include "lib/tasks/load_text_files_task.rb"
  rdoc.rdoc_files.include "lib/tasks/nlp_analysis_task.rb"
  rdoc.rdoc_files.include "lib/tasks/preprocess_file_object_task.rb"
  rdoc.rdoc_files.include "lib/tasks/preprocess_text_file_task.rb"
  rdoc.rdoc_files.include "lib/tasks/text_segment_task.rb"
  rdoc.rdoc_files.include "lib/tasks/text_tagger_task.rb"
  rdoc.rdoc_files.include "lib/tasks/text_tokenize_task.rb"
  rdoc.rdoc_files.include "lib/tasks/tokenize_segments_task.rb"
  rdoc.rdoc_files.include "lib/tasks/topic_modeling_task.rb"
  rdoc.rdoc_files.include "lib/tasks/train_topic_model_task.rb"
  rdoc.rdoc_files.include "lib/tasks/workflow_initializer_task.rb"

  rdoc.rdoc_files.include "lib/ui/base.rb"
  rdoc.rdoc_files.include "lib/ui/box.rb"
  rdoc.rdoc_files.include "lib/ui/scrollable_box.rb"

  rdoc.rdoc_files.include "lib/utils/command.rb"
  rdoc.rdoc_files.include "lib/utils/transcribe.rb"
  rdoc.rdoc_files.include "lib/utils/tts.rb"
  rdoc.rdoc_files.include "lib/utils/writefile.rb"

  rdoc.rdoc_files.include "lib/workflows/text_processing_workflow.rb"
  rdoc.rdoc_files.include "lib/workflows/topic_model_trainer_workflow.rb"
  rdoc.rdoc_files.include "lib/workflows/topic_model_trainer_workflowtest.rb"
end

namespace :docs do
  desc "Convert RDoc HTML to Markdown"
  task :markdown => :rdoc do
    require 'nokogiri'
    require 'fileutils'
    
    doc_dir = File.join(APP_ROOT, 'doc')
    markdown_dir = File.join(doc_dir, 'markdown')
    FileUtils.mkdir_p(markdown_dir)
    
    puts "Converting HTML documentation to Markdown..."
    
    def clean_code_block(code)
      # Remove extra whitespace but preserve indentation
      lines = code.split("\n")
      # Find minimum indentation (excluding empty lines)
      min_indent = lines.reject(&:empty?).map { |l| l[/^\s*/].length }.min || 0
      # Remove common indentation and cleanup
      lines.map { |line| line.empty? ? line : line[min_indent..-1] }.join("\n")
    end
    
    def process_html_file(file, output_dir)
      basename = File.basename(file, '.html')
      output_file = File.join(output_dir, "#{basename}.md")
      
      puts "Processing #{basename}..."
      
      doc = File.open(file) { |f| Nokogiri::HTML(f) }
      
      # Remove navigation elements
      doc.css('.nav-section, #navigation').remove
      
      # Process code blocks before conversion
      doc.css('pre code, .source_code').each do |code|
        lang = code['class']&.split&.find { |c| c.start_with?('language-') }&.sub('language-', '') || 'ruby'
        cleaned_code = clean_code_block(code.content)
        code.replace("```#{lang}\n#{cleaned_code}\n```")
      end
      
      # Convert to markdown using pandoc
      markdown = IO.popen(['pandoc', '-f', 'html', '-t', 'gfm', '--wrap=none'], 'w+') do |pipe|
        pipe.write(doc.at_css('body').inner_html)
        pipe.close_write
        pipe.read
      end
      
      # Post-process markdown
      markdown = markdown.gsub(/\{:.*?\}/, '')                    # Remove RDoc-specific markers
                        .gsub(/\[([^\]]+)\]\{[^}]+\}/, '[\1]')   # Clean up links
                        .gsub(/^\s*$\n\s*$\n/, "\n")             # Remove multiple blank lines
                        .gsub(/\n\n```/, "\n```")                # Fix code block spacing
      
      File.write(output_file, markdown)
    end
    
    # Process all HTML files
    Dir[File.join(doc_dir, '**', '*.html')].sort.each do |file|
      next if file.include?('table_of_contents.html')
      next if file.include?('index.html')
      next if file.include?('js/')
      process_html_file(file, markdown_dir)
    end
    
    puts "Markdown files generated in #{markdown_dir}"
  end
  
  desc "Generate PDF using Asciidoctor"
  task :pdf => :markdown do
    require 'fileutils'
    
    doc_dir = File.join(APP_ROOT, 'doc')
    markdown_dir = File.join(doc_dir, 'markdown')
    temp_dir = File.join(doc_dir, 'temp')
    output_file = File.join(doc_dir, 'flowbots_documentation.pdf')
    adoc_file = File.join(temp_dir, 'merged_documentation.adoc')
    
    FileUtils.mkdir_p(temp_dir)
    
    # Ensure asciidoctor-pdf is installed
    unless system('which asciidoctor-pdf > /dev/null 2>&1')
      puts "Installing asciidoctor-pdf..."
      system('gem install asciidoctor-pdf --no-document')
    end
    
    puts "Generating PDF documentation..."
    
    # Create the main asciidoc file
    File.open(adoc_file, 'w') do |output|
      # Document header
      output.puts "= Flowbots Documentation"
      output.puts ":doctype: book"
      output.puts ":source-highlighter: rouge"
      output.puts ":icons: font"
      output.puts ":toc: left"
      output.puts ":toclevels: 4"
      output.puts ":sectnums:"
      output.puts ":sectanchors:"
      output.puts ":chapter-label:"
      output.puts ":pdf-page-size: A4"
      output.puts ":pdf-fontsdir: #{doc_dir}/fonts"
      output.puts ":pdf-style: default"
      output.puts ":experimental:"
      output.puts ":source-language: ruby"
      output.puts "\n"
      
      # Process each markdown file
      Dir[File.join(markdown_dir, '*.md')].sort.each do |md_file|
        puts "Including #{File.basename(md_file)}..."
        
        content = File.read(md_file)
        
        # Convert markdown to asciidoc
        adoc_content = IO.popen(['pandoc', '-f', 'gfm', '-t', 'asciidoc', '--wrap=none'], 'w+') do |pipe|
          pipe.write(content)
          pipe.close_write
          pipe.read
        end
        
        # Clean up asciidoc content
        adoc_content.gsub!(/^=+ /) { |m| "=" + m } # Fix heading levels
        adoc_content.gsub!(/\[source,ruby\]\n----/, "[source,ruby]\n----") # Fix code blocks
        
        output.puts "\n== #{File.basename(md_file, '.md').gsub('_', ' ').capitalize}\n"
        output.puts adoc_content
        output.puts "\n'''\n" # Add separator between sections
      end
    end
    
    # Generate PDF
    cmd = [
      "asciidoctor-pdf",
      "--trace",
      "-a", "allow-uri-read",
      "-a", "experimental",
      "-a", "icons=font",
      "-a", "pdf-fontsdir=#{doc_dir}/fonts",
      adoc_file,
      "-o", output_file
    ]
    
    puts "Running asciidoctor-pdf..."
    if system(*cmd)
      puts "PDF generated successfully: #{output_file}"
      FileUtils.rm_rf(temp_dir)
    else
      puts "Error: PDF generation failed"
      puts "Command: #{cmd.join(' ')}"
      puts "Temporary files preserved for debugging in: #{temp_dir}"
      exit 1
    end
  end
end