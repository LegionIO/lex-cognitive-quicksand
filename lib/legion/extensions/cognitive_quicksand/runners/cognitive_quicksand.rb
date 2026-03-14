# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveQuicksand
      module Runners
        module CognitiveQuicksand
          extend self

          def create_trap(trap_type:, domain:, content:,
                          depth: nil, viscosity: nil, engine: nil, **)
            eng = resolve_engine(engine)
            t   = eng.create_trap(trap_type: trap_type, domain: domain, content: content,
                                  depth: depth, viscosity: viscosity)
            { success: true, trap: t.to_h }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def create_pit(saturation: nil, danger_level: nil, engine: nil, **)
            eng = resolve_engine(engine)
            p   = eng.create_pit(saturation: saturation, danger_level: danger_level)
            { success: true, pit: p.to_h }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def struggle(trap_id:, engine: nil, **)
            eng    = resolve_engine(engine)
            result = eng.struggle(trap_id: trap_id)
            { success: true, trap: result[:trap].to_h,
              depth: result[:depth], struggle_count: result[:struggle_count] }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def calm_down(trap_id:, rate: nil, engine: nil, **)
            eng  = resolve_engine(engine)
            trap = eng.calm(trap_id: trap_id, rate: rate || Helpers::Constants::CALM_RATE)
            { success: true, trap: trap.to_h }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def attempt_escape(trap_id:, engine: nil, **)
            eng    = resolve_engine(engine)
            result = eng.attempt_escape(trap_id: trap_id)
            { success: true, trap: result[:trap].to_h, result: result[:result] }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def list_traps(engine: nil, trap_type: nil, **)
            eng     = resolve_engine(engine)
            results = eng.all_traps
            results = results.select { |t| t.trap_type == trap_type.to_sym } if trap_type
            { success: true, traps: results.map(&:to_h), count: results.size }
          end

          def quicksand_status(engine: nil, **)
            eng = resolve_engine(engine)
            { success: true, report: eng.quicksand_report }
          end

          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          private

          def resolve_engine(engine)
            engine || default_engine
          end

          def default_engine
            @default_engine ||= Helpers::QuicksandEngine.new
          end
        end
      end
    end
  end
end
