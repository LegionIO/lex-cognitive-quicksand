# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveQuicksand
      module Helpers
        class QuicksandEngine
          def initialize
            @traps = {}
            @pits  = {}
          end

          def create_trap(trap_type:, domain:, content:, depth: nil, viscosity: nil)
            raise ArgumentError, 'trap limit reached' if @traps.size >= Constants::MAX_TRAPS

            t = Trap.new(trap_type: trap_type, domain: domain, content: content,
                         depth: depth, viscosity: viscosity)
            @traps[t.id] = t
            t
          end

          def create_pit(saturation: nil, danger_level: nil)
            raise ArgumentError, 'pit limit reached' if @pits.size >= Constants::MAX_PITS

            p = Pit.new(saturation: saturation, danger_level: danger_level)
            @pits[p.id] = p
            p
          end

          def sink_trap(trap_id:, rate: Constants::SINK_RATE)
            trap = fetch_trap(trap_id)
            trap.sink!(rate: rate)
            trap
          end

          def struggle(trap_id:)
            trap = fetch_trap(trap_id)
            trap.struggle!
            { trap: trap, depth: trap.depth, struggle_count: trap.struggle_count }
          end

          def calm(trap_id:, rate: Constants::CALM_RATE)
            trap = fetch_trap(trap_id)
            trap.calm!(rate: rate)
            trap
          end

          def attempt_escape(trap_id:)
            trap   = fetch_trap(trap_id)
            result = trap.escape!
            { trap: trap, result: result }
          end

          def add_trap_to_pit(trap_id:, pit_id:)
            fetch_trap(trap_id)
            pit = fetch_pit(pit_id)
            pit.add_trap(trap_id)
          end

          def sink_all!
            @traps.each_value(&:sink!)
          end

          def calm_all!
            @traps.each_value(&:calm!)
          end

          def traps_by_type
            counts = Constants::TRAP_TYPES.to_h { |t| [t, 0] }
            @traps.each_value { |t| counts[t.trap_type] += 1 }
            counts
          end

          def deepest(limit: 5)
            @traps.values.sort_by { |t| -t.depth }.first(limit)
          end

          def shallowest(limit: 5)
            @traps.values.sort_by(&:depth).first(limit)
          end

          def submerged_traps
            @traps.values.select(&:submerged?)
          end

          def stuck_traps
            @traps.values.select(&:stuck?)
          end

          def deadliest_pits(limit: 5)
            @pits.values.sort_by { |p| -p.danger_level }.first(limit)
          end

          def avg_depth
            return 0.0 if @traps.empty?

            (@traps.values.sum(&:depth) / @traps.size).round(10)
          end

          def quicksand_report
            {
              total_traps: @traps.size,
              total_pits:  @pits.size,
              by_type:     traps_by_type,
              submerged:   submerged_traps.size,
              stuck:       stuck_traps.size,
              avg_depth:   avg_depth,
              deadly_pits: @pits.values.count(&:deadly?)
            }
          end

          def all_traps
            @traps.values
          end

          def all_pits
            @pits.values
          end

          private

          def fetch_trap(id)
            @traps.fetch(id) { raise ArgumentError, "trap not found: #{id}" }
          end

          def fetch_pit(id)
            @pits.fetch(id) { raise ArgumentError, "pit not found: #{id}" }
          end
        end
      end
    end
  end
end
