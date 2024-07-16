OWNER = 'b08x'.freeze
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
      base_image_tag = 'latest'
    when /\AFROM\s+([^:]+)/
      base_image_name = Regexp.last_match(1)
    end
  end
  [
    name,
    [base_image_name, base_image_tag].join(':')
  ]
end.to_h

DOCKER_FLAGS = ENV['DOCKER_FLAGS']

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

desc 'Build all images'
task 'build-all' do
  ALL_IMAGES.each do |image|
    Rake::Task["build/#{image}"].invoke
  end
end

desc 'Tag all images'
task 'tag-all' do
  ALL_IMAGES.each do |image|
    Rake::Task["tag/#{image}"].invoke
  end
end

desc 'Push all images'
task 'push-all' do
  ALL_IMAGES.each do |image|
    Rake::Task["push/#{image}"].invoke
  end
end
