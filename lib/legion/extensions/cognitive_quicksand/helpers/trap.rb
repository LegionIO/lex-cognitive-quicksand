# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveQuicksand
      module Helpers
        class Trap
          attr_reader :id, :trap_type, :domain, :content,
                      :struggle_count, :created_at
          attr_accessor :depth, :viscosity

          def initialize(trap_type:, domain:, content:,
                         depth: nil, viscosity: nil)
            validate_trap_type!(trap_type)
            @id             = SecureRandom.uuid
            @trap_type      = trap_type.to_sym
            @domain         = domain.to_sym
            @content        = content.to_s
            @depth          = (depth || 0.3).to_f.clamp(0.0, 1.0).round(10)
            @viscosity      = (viscosity || 0.5).to_f.clamp(0.0, 1.0).round(10)
            @struggle_count = 0
            @created_at     = Time.now.utc
          end

          def sink!(rate: Constants::SINK_RATE)
            @depth = (@depth + rate.abs).clamp(0.0, 1.0).round(10)
          end

          def struggle!
            @struggle_count += 1
            penalty = Constants::STRUGGLE_PENALTY * @viscosity
            @depth = (@depth + penalty).clamp(0.0, 1.0).round(10)
          end

          def calm!(rate: Constants::CALM_RATE)
            @depth = (@depth - rate.abs).clamp(0.0, 1.0).round(10)
          end

          def escape!
            return :too_deep if @depth > (1.0 - Constants::ESCAPE_THRESHOLD)

            @depth = 0.0
            :escaped
          end

          def submerged?
            @depth >= 0.8
          end

          def surface?
            @depth < 0.2
          end

          def stuck?
            @depth >= 0.5 && @viscosity >= 0.5
          end

          def depth_label
            Constants.label_for(Constants::DEPTH_LABELS, @depth)
          end

          def viscosity_label
            Constants.label_for(Constants::VISCOSITY_LABELS, @viscosity)
          end

          def to_h
            {
              id:              @id,
              trap_type:       @trap_type,
              domain:          @domain,
              content:         @content,
              depth:           @depth,
              viscosity:       @viscosity,
              depth_label:     depth_label,
              viscosity_label: viscosity_label,
              struggle_count:  @struggle_count,
              submerged:       submerged?,
              surface:         surface?,
              stuck:           stuck?,
              created_at:      @created_at
            }
          end

          private

          def validate_trap_type!(val)
            return if Constants::TRAP_TYPES.include?(val.to_sym)

            raise ArgumentError,
                  "unknown trap type: #{val.inspect}; " \
                  "must be one of #{Constants::TRAP_TYPES.inspect}"
          end
        end
      end
    end
  end
end
