# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_quicksand/version'

Gem::Specification.new do |spec|
  spec.name    = 'lex-cognitive-quicksand'
  spec.version = Legion::Extensions::CognitiveQuicksand::VERSION
  spec.authors = ['Esity']
  spec.email   = ['matthewdiverson@gmail.com']

  spec.summary     = 'Cognitive quicksand trap dynamics for LegionIO agentic architecture'
  spec.description = 'Models sinking patterns where overthinking causes deeper entanglement ' \
                     'with struggle penalties and escape mechanics for brain-modeled AI agents'
  spec.homepage    = 'https://github.com/LegionIO/lex-cognitive-quicksand'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = spec.homepage
  spec.metadata['documentation_uri'] = "#{spec.homepage}/blob/master/README.md"
  spec.metadata['changelog_uri']     = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']   = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?('spec/', '.git', '.rubocop', 'Gemfile')
    end
  end

  spec.require_paths = ['lib']
end
