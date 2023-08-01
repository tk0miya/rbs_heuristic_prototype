# frozen_string_literal: true

require_relative "lib/rbs_heuristic_prototype/version"

Gem::Specification.new do |spec|
  spec.name = "rbs_heuristic_prototype"
  spec.version = RbsHeuristicPrototype::VERSION
  spec.authors = ["Takeshi KOMIYA"]
  spec.email = ["i.tkomiya@gmail.com"]

  spec.summary = "Update prototype signature files by heuristic rules"
  spec.description = "Update prototype signature files by heuristic rules"
  spec.homepage = "https://github.com/tk0miya/rbs_heuristic_prototype"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rbs"
end
