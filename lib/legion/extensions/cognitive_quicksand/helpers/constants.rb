# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveQuicksand
      module Helpers
        module Constants
          TRAP_TYPES = %i[overthinking rumination analysis_paralysis
                          perfectionism indecision].freeze

          STRUGGLE_MODES = %i[thrash freeze sink float escape].freeze

          MAX_TRAPS     = 200
          MAX_PITS      = 50
          SINK_RATE     = 0.08
          STRUGGLE_PENALTY = 0.12
          ESCAPE_THRESHOLD = 0.3
          CALM_RATE     = 0.03

          DEPTH_LABELS = [
            [(0.8..),      :submerged],
            [(0.6...0.8),  :chest_deep],
            [(0.4...0.6),  :waist_deep],
            [(0.2...0.4),  :ankle_deep],
            [(..0.2),      :surface]
          ].freeze

          VISCOSITY_LABELS = [
            [(0.8..),      :concrete],
            [(0.6...0.8),  :thick],
            [(0.4...0.6),  :moderate],
            [(0.2...0.4),  :thin],
            [(..0.2),      :dry]
          ].freeze

          def self.label_for(table, value)
            table.each { |range, label| return label if range.cover?(value) }
            table.last.last
          end
        end
      end
    end
  end
end
