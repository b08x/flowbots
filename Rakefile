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
  rdoc.rdoc_files.include "lib/ui.rb"
  rdoc.rdoc_files.include "lib/tasks.rb"
  rdoc.rdoc_files.include "lib/workflows.rb"

  rdoc.rdoc_files.include "lib/components/BatchProcessor.rb"
  rdoc.rdoc_files.include "lib/components/ExceptionAgent.rb"
  rdoc.rdoc_files.include "lib/components/ExceptionHandler.rb"
  rdoc.rdoc_files.include "lib/components/FileDiscovery.rb"
  rdoc.rdoc_files.include "lib/components/FileLoader.rb"
  rdoc.rdoc_files.include "lib/components/InputRetrieval.rb"
  rdoc.rdoc_files.include "lib/components/OhmModels.rb"
  rdoc.rdoc_files.include "lib/components/RedisKeys.rb"
  rdoc.rdoc_files.include "lib/components/word_salad.rb"
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
  rdoc.rdoc_files.include "lib/tasks/display_results_task.rb"
  rdoc.rdoc_files.include "lib/tasks/file_loader_task.rb"
  rdoc.rdoc_files.include "lib/tasks/filter_segments_task.rb"
  rdoc.rdoc_files.include "lib/tasks/llm_analysis_task.rb"
  rdoc.rdoc_files.include "lib/tasks/load_file_object_task.rb"
  rdoc.rdoc_files.include "lib/tasks/load_text_files_task.rb"
  rdoc.rdoc_files.include "lib/tasks/nlp_analysis_task.rb"
  rdoc.rdoc_files.include "lib/tasks/preprocess_file_object_task.rb"
  rdoc.rdoc_files.include "lib/tasks/text_segment_task.rb"
  rdoc.rdoc_files.include "lib/tasks/text_tagger_task.rb"
  rdoc.rdoc_files.include "lib/tasks/text_tokenize_task.rb"
  rdoc.rdoc_files.include "lib/tasks/tokenize_segments_task.rb"
  rdoc.rdoc_files.include "lib/tasks/topic_modeling_task.rb"
  rdoc.rdoc_files.include "lib/tasks/train_topic_model_task.rb"

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
  rdoc.rdoc_files.include "lib/flowbots.rb"
  rdoc.rdoc_files.include "lib/helper.rb"
  rdoc.rdoc_files.include "lib/logging.rb"
  rdoc.rdoc_files.include "lib/tasks.rb"
  rdoc.rdoc_files.include "lib/ui.rb"
  rdoc.rdoc_files.include "lib/workflows.rb"

  rdoc.rdoc_files.include "lib/integrations/flowise.rb"

  rdoc.rdoc_files.include "lib/processors/GrammarProcessor.rb"
  rdoc.rdoc_files.include "lib/processors/NLPProcessor.rb"
  rdoc.rdoc_files.include "lib/processors/TextProcessor.rb"
  rdoc.rdoc_files.include "lib/processors/TextSegmentProcessor.rb"
  rdoc.rdoc_files.include "lib/processors/TextTaggerProcessor.rb"
  rdoc.rdoc_files.include "lib/processors/TextTokenizeProcessor.rb"
  rdoc.rdoc_files.include "lib/processors/TopicModelProcessor.rb"

  rdoc.rdoc_files.include "lib/tasks/accumulate_filtered_segments_task.rb"
  rdoc.rdoc_files.include "lib/tasks/display_results_task.rb"
  rdoc.rdoc_files.include "lib/tasks/file_loader_task.rb"
  rdoc.rdoc_files.include "lib/tasks/filter_segments_task.rb"
  rdoc.rdoc_files.include "lib/tasks/llm_analysis_task.rb"
  rdoc.rdoc_files.include "lib/tasks/load_text_files_task.rb"
  rdoc.rdoc_files.include "lib/tasks/nlp_analysis_task.rb"
  rdoc.rdoc_files.include "lib/tasks/preprocess_text_file_task.rb"
  rdoc.rdoc_files.include "lib/tasks/text_segment_task.rb"
  rdoc.rdoc_files.include "lib/tasks/text_tagger_task.rb"
  rdoc.rdoc_files.include "lib/tasks/text_tokenize_task.rb"
  rdoc.rdoc_files.include "lib/tasks/tokenize_segments_task.rb"
  rdoc.rdoc_files.include "lib/tasks/topic_modeling_task.rb"
  rdoc.rdoc_files.include "lib/tasks/train_topic_model_task.rb"

  rdoc.rdoc_files.include "lib/components/ExceptionAgent.rb"
  rdoc.rdoc_files.include "lib/components/ExceptionHandler.rb"
  rdoc.rdoc_files.include "lib/components/FileLoader.rb"
  rdoc.rdoc_files.include "lib/components/OhmModels.rb"
  rdoc.rdoc_files.include "lib/components/WorkflowAgent.rb"
  rdoc.rdoc_files.include "lib/components/WorkflowOrchestrator.rb"
  rdoc.rdoc_files.include "lib/components/word_salad.rb"

  rdoc.rdoc_files.include "lib/grammars/markdown_yaml.rb"

  rdoc.rdoc_files.include "lib/utils/command.rb"
  rdoc.rdoc_files.include "lib/utils/transcribe.rb"
  rdoc.rdoc_files.include "lib/utils/tts.rb"
  rdoc.rdoc_files.include "lib/utils/writefile.rb"

  rdoc.rdoc_files.include "lib/workflows/text_processing_workflow.rb"
  rdoc.rdoc_files.include "lib/workflows/topic_model_trainer_workflow.rb"
  rdoc.rdoc_files.include "lib/workflows/topic_model_trainer_workflowtest.rb"
end

Gokdok::Dokker.new do |gd|
  gd.remote_path = "" # Put into the root directory
  gd.repo_url = "git@github.com:b08x/flowbots.git"
  gd.doc_home = "#{APP_ROOT}/doc"
end
