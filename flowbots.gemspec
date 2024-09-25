require_relative "lib/version"

Gem::Specification.new do |spec|
  spec.name = "flowbots"
  spec.version = Flowbots::VERSION
  spec.authors = ["Robert Pannick"]
  spec.email = ["rwpannick@gmail.com"]

  spec.summary = "It's basically a workflow orchestration system.  \"Workflow orchestration system\" - sounds impressive, right? In reality, it's like trying to herd cats, except the cats are AI agents with a penchant for existential dread and the occasional haiku. We use Jongleur and NanoBot libraries."
  spec.homepage = "https://github.com/b08x/flowbots"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/b08x/flowbots/issues",
    "changelog_uri" => "https://github.com/b08x/flowbots/releases",
    "source_code_uri" => "https://github.com/b08x/flowbots",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[LICENSE.txt README.md {exe,lib}/**/*]).reject { |f| File.directory?(f) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  # spec.add_dependency "dotenv", "~> 3.1"
  # spec.add_dependency "jongleur", "~> 1.1"
  # spec.add_dependency "json", "~> 2.7"
  # spec.add_dependency "nano-bots", "~> 3.4"
  # spec.add_dependency "redis", "~> 5.2"
  # spec.add_dependency "rubocop", "~> 1.64"
  # spec.add_dependency "thor", "~> 1.2"
  # spec.add_dependency "tty-prompt"
  # spec.add_dependency "yaml", "~> 0.3.0"
end
