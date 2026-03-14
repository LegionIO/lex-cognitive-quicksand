# frozen_string_literal: true

require 'securerandom'

require_relative 'cognitive_quicksand/version'
require_relative 'cognitive_quicksand/helpers/constants'
require_relative 'cognitive_quicksand/helpers/trap'
require_relative 'cognitive_quicksand/helpers/pit'
require_relative 'cognitive_quicksand/helpers/quicksand_engine'
require_relative 'cognitive_quicksand/runners/cognitive_quicksand'
require_relative 'cognitive_quicksand/client'

module Legion
  module Extensions
    module CognitiveQuicksand
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
