# lex-cognitive-quicksand

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## Purpose

Cognitive quicksand model for thought traps. Quicksand traps represent cognitive patterns that pull agents deeper when they struggle: overthinking, rumination, analysis paralysis, perfectionism, indecision. Each trap has depth (how deep the agent is stuck) and viscosity (how thick/sticky the medium). Struggling while stuck in high-viscosity quicksand makes depth worse. Calming reduces depth. Escape is only possible when depth is below a threshold. Pits are named containers that group related traps and track combined danger level.

## Gem Info

- **Gem name**: `lex-cognitive-quicksand`
- **Module**: `Legion::Extensions::CognitiveQuicksand`
- **Version**: `0.1.0`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/cognitive_quicksand/
  version.rb
  client.rb
  helpers/
    constants.rb
    trap.rb
    pit.rb
    quicksand_engine.rb
  runners/
    cognitive_quicksand.rb
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `TRAP_TYPES` | `%i[overthinking rumination analysis_paralysis perfectionism indecision]` | Valid trap categories |
| `STRUGGLE_MODES` | `%i[thrash freeze sink float escape]` | Defined struggle mode vocabulary |
| `MAX_TRAPS` | `200` | Per-engine trap capacity |
| `MAX_PITS` | `50` | Per-engine pit capacity |
| `SINK_RATE` | `0.08` | Default depth increase per `sink!` call |
| `STRUGGLE_PENALTY` | `0.12` | Base penalty; multiplied by viscosity |
| `ESCAPE_THRESHOLD` | `0.3` | Depth must be <= `1.0 - ESCAPE_THRESHOLD` (0.7) to escape |
| `CALM_RATE` | `0.03` | Default depth reduction per `calm!` call |
| `DEPTH_LABELS` | range/label pairs | From `:surface` to `:submerged` |
| `VISCOSITY_LABELS` | range/label pairs | From `:dry` to `:concrete` |

## Helpers

### `Helpers::Trap`
Individual quicksand trap. Has `id`, `trap_type`, `domain`, `content`, `depth` (0.0–1.0), `viscosity` (0.0–1.0), and `struggle_count`.

- `sink!(rate:)` — increases depth
- `struggle!` — `struggle_count++`; `depth += STRUGGLE_PENALTY * viscosity` (struggling harder in thick quicksand makes it worse)
- `calm!(rate:)` — decreases depth
- `escape!` — returns `:too_deep` if depth > 0.7; otherwise resets depth to 0.0 and returns `:escaped`
- `submerged?` — depth >= 0.8
- `surface?` — depth < 0.2
- `stuck?` — depth >= 0.5 AND viscosity >= 0.5
- `depth_label` / `viscosity_label`
- Validates `trap_type` against `TRAP_TYPES` at initialization (raises `ArgumentError` on invalid)

### `Helpers::Pit`
Named container for traps. Has `id`, `saturation`, `danger_level`, and `trap_ids` array.

- `add_trap(trap_id)` → `:added` or `:already_present`; recalculates danger
- `remove_trap(trap_id)` → `:removed` or `:not_found`; recalculates danger
- `saturate!(rate:)` / `drain!(rate:)` — adjust saturation
- `deadly?` — danger_level >= 0.8
- `safe?` — danger_level < 0.2
- `recalculate_danger!` (private) — `danger = (trap_count/10.0 + saturation) / 2.0`

### `Helpers::QuicksandEngine`
Multi-trap, multi-pit manager.

- `create_trap(trap_type:, domain:, content:, depth:, viscosity:)` → trap or raises `ArgumentError`
- `create_pit(saturation:, danger_level:)` → pit or raises `ArgumentError`
- `sink_trap(trap_id:, rate:)` → trap
- `struggle(trap_id:)` → hash with trap, depth, struggle_count
- `calm(trap_id:, rate:)` → trap
- `attempt_escape(trap_id:)` → hash with trap and result (`:escaped` or `:too_deep`)
- `add_trap_to_pit(trap_id:, pit_id:)` → symbol
- `sink_all!` / `calm_all!` — apply to all traps
- `traps_by_type` → count hash per type
- `deepest(limit:)` / `shallowest(limit:)` / `submerged_traps` / `stuck_traps`
- `deadliest_pits(limit:)` → pits sorted by danger_level
- `avg_depth` / `quicksand_report`

## Runners

Module: `Runners::CognitiveQuicksand`

| Runner Method | Description |
|---|---|
| `create_trap(trap_type:, domain:, content:, depth:, viscosity:)` | Register a new trap |
| `create_pit(saturation:, danger_level:)` | Create a trap container |
| `struggle(trap_id:)` | Struggle (depth penalty scaled by viscosity) |
| `calm_down(trap_id:, rate:)` | Reduce depth (calming intervention) |
| `attempt_escape(trap_id:)` | Try to escape (only works at shallow depth) |
| `list_traps(trap_type:)` | All traps (optionally filtered by type) |
| `quicksand_status` | Full aggregate report |

All runners return `{success: true/false, ...}` hashes. `ArgumentError` from engine is rescued and returned as `{success: false, error: message}`.

## Integration Points

- `lex-tick` `action_selection`: check for stuck traps before acting; being stuck should gate certain actions
- `lex-emotion`: high depth + high viscosity → negative valence; escape → positive valence signal
- `lex-conflict`: rumination and analysis_paralysis traps can arise from unresolved conflicts in `lex-conflict`
- `lex-consent`: perfectionism traps may delay consent decisions; trap detection can prompt tier escalation

## Development Notes

- `Client` instantiates `@default_engine = Helpers::QuicksandEngine.new` via runner memoization
- `ESCAPE_THRESHOLD = 0.3` means escape requires depth <= 0.7 (not 0.3) — this constant is the safety margin from maximum depth
- `struggle!` multiplies penalty by viscosity: `0.12 * viscosity`; at viscosity=1.0 the penalty is full 0.12; at viscosity=0 it's 0 (struggle-free low-viscosity environment)
- `calm_down` runner uses keyword `rate: nil` and defaults to `CALM_RATE` when nil — explicit passthrough
- `ArgumentError` raised by engine (invalid trap_type, capacity exceeded) is rescued at runner level
