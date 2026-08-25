# Coding style

## Immutability (CRITICAL)

ALWAYS create new objects, NEVER mutate existing ones. Return a new copy with the change instead of modifying in place. This prevents hidden side effects and makes debugging easier.

## File organization

MANY SMALL FILES > FEW LARGE FILES:
- High cohesion, low coupling
- 200-400 lines typical, 800 max
- Extract utilities from large modules
- Organize by feature or domain, not by type

## Error handling

ALWAYS handle errors explicitly:
- Handle errors at every level
- Provide user-friendly error messages in UI-facing code
- Log detailed error context on the server side
- Never silently swallow errors

## Input validation

ALWAYS validate at system boundaries:
- Validate all user input before processing
- Use schema-based validation where available
- Fail fast with clear error messages
- Never trust external data (API responses, user input, file content)

## Naming conventions

- Variables and functions: `camelCase` with descriptive names
- Booleans: prefer `is`, `has`, `should`, or `can` prefixes
- Interfaces, types, and components: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Custom hooks: `camelCase` with a `use` prefix

## Code smells to avoid

### Deep nesting

Prefer early returns over nested conditionals once the logic starts stacking.

### Magic numbers

Use named constants for meaningful thresholds, delays, and limits.

### Long functions

Split large functions into focused pieces with clear responsibilities.
