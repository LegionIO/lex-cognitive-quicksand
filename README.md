# lex-cognitive-quicksand

Cognitive quicksand model for LegionIO agents. Thought traps (overthinking, rumination, analysis paralysis, perfectionism, indecision) pull the agent deeper when it struggles. Calming reduces depth. Escape only works when depth is shallow enough.

## What It Does

- Five trap types: `overthinking`, `rumination`, `analysis_paralysis`, `perfectionism`, `indecision`
- Depth (0.0–1.0): how deep the agent is stuck
- Viscosity (0.0–1.0): how sticky the medium is
- `struggle`: makes depth worse (penalty × viscosity — high viscosity amplifies struggling)
- `calm_down`: reduces depth (the correct intervention)
- `attempt_escape`: only succeeds when depth <= 0.7; otherwise returns `:too_deep`
- Pits: containers that group traps and track combined danger level
- `submerged?` (depth >= 0.8), `stuck?` (depth >= 0.5 AND viscosity >= 0.5)

## Usage

```ruby
# Create a trap
result = runner.create_trap(trap_type: :overthinking, domain: :architecture,
                              content: 'endlessly weighing microservices vs monolith',
                              depth: 0.3, viscosity: 0.6)
trap_id = result[:trap][:id]

# Struggling makes it worse
runner.struggle(trap_id: trap_id)
# => { success: true, trap: { depth: 0.372, stuck: false }, struggle_count: 1 }

runner.struggle(trap_id: trap_id)
# => { success: true, trap: { depth: 0.444, stuck: false }, struggle_count: 2 }

# Calm down instead
runner.calm_down(trap_id: trap_id, rate: nil)
# => { success: true, trap: { depth: 0.414, ... } }

# Attempt escape when shallow enough
runner.attempt_escape(trap_id: trap_id)
# => { success: true, trap: ..., result: :escaped } OR { result: :too_deep }

# Status
runner.quicksand_status
# => { success: true, report: { total_traps: 1, submerged: 0, stuck: 0, avg_depth: 0.41, ... } }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
