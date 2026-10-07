# Project execution guide

`jawline.nvim` is an experimental Neovim statusline plugin.

## Authority and workflow

Repository source, tests/development files, and public documentation are durable
product truth. Use the [README](README.md) for orientation and the
[reference](docs/reference.md) for current behavior and the module map.
Historical chats provide supplemental rationale, not proof of implementation
or an accepted backlog. Surface disagreements between source, docs, and a task
brief instead of silently choosing or changing product behavior.

Normal Chat owns requirements, product decisions, architecture, prioritization,
and task scope. Work/Codex owns bounded execution and validation within the
agreed brief. The normal flow is:

```text
discovery/evidence → Chat decision → bounded execution → completion report
```

Make ordinary implementation decisions within the settled design. Return
material unresolved product or architecture choices to Normal Chat, while
continuing independent work within scope. Do not infer a roadmap, milestone,
release promise, or compatibility policy without an explicit product decision.

## Execution boundaries

- Inspect branch and working-tree state before edits. Read only the
  documentation and source relevant to the task.
- Preserve unrelated local changes. Do not stash, reset, discard, stage, or
  incorporate them into the task. Use an isolated location when necessary.
- Keep changes within the agreed scope. Do not turn documentation work into
  source fixes, redesign, or tooling changes.
- Keep implementation, validation, staging, commits, and publication distinct.
  Stage, commit, push, open a PR, tag, release, or change repository settings
  only when the user explicitly authorizes that action.
- Review proposed public content for secrets, personal paths, private project
  references, logs, and other accidental disclosure. Do not reproduce secrets.
- Run checks appropriate to the change and report their actual limits. The
  [development configuration](tests/minimal.lua) is interactive, not an
  assertion-based suite; do not claim automated coverage from its presence.
- Record accepted decisions, behavior changes, validation, and task status in
  the existing authoritative document or issue when applicable. Link to that
  detail instead of creating duplicate state or continuation diaries.

## Completion report

Report the task result, important changes, verification, durable updates,
material decisions or unresolved planning questions, and next action. State
explicitly whether changes are committed and published.
