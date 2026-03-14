# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveQuicksand
      module Helpers
        class Pit
          attr_reader :id, :trap_ids, :created_at
          attr_accessor :saturation, :danger_level

          def initialize(saturation: nil, danger_level: nil)
            @id           = SecureRandom.uuid
            @saturation   = (saturation || 0.5).to_f.clamp(0.0, 1.0).round(10)
            @danger_level = (danger_level || 0.3).to_f.clamp(0.0, 1.0).round(10)
            @trap_ids     = []
            @created_at   = Time.now.utc
          end

          def add_trap(trap_id)
            return :already_present if @trap_ids.include?(trap_id)

            @trap_ids << trap_id
            recalculate_danger!
            :added
          end

          def remove_trap(trap_id)
            return :not_found unless @trap_ids.include?(trap_id)

            @trap_ids.delete(trap_id)
            recalculate_danger!
            :removed
          end

          def saturate!(rate: 0.1)
            @saturation = (@saturation + rate.abs).clamp(0.0, 1.0).round(10)
          end

          def drain!(rate: 0.1)
            @saturation = (@saturation - rate.abs).clamp(0.0, 1.0).round(10)
            recalculate_danger!
          end

          def deadly?
            @danger_level >= 0.8
          end

          def safe?
            @danger_level < 0.2
          end

          def trap_count
            @trap_ids.size
          end

          def to_h
            {
              id:           @id,
              saturation:   @saturation,
              danger_level: @danger_level,
              trap_count:   trap_count,
              deadly:       deadly?,
              safe:         safe?,
              created_at:   @created_at
            }
          end

          private

          def recalculate_danger!
            trap_factor = (@trap_ids.size / 10.0).clamp(0.0, 1.0)
            @danger_level = ((trap_factor + @saturation) / 2.0).clamp(0.0, 1.0).round(10)
          end
        end
      end
    end
  end
end
