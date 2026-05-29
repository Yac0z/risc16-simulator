# Copilot Instructions - Processeur RISC 16 bits

## Session Gate (Mandatory)

Before any technical discussion, code proposal, or edit, run this exact protocol.

STEP 1 — Sync with remote
  Run: git fetch origin
  Purpose: update local knowledge of remote state without merging.

STEP 2 — Surface uncommitted work
  Run: git status
  Run: git diff HEAD
  If uncommitted changes exist:
    → Show a summary of changed files
    → Ask the developer: "Stash, commit, or discard before we continue?"
    → Do not proceed until the developer makes an explicit choice.

STEP 3 — Check divergence from origin
  Run: git log HEAD..origin/[default-branch] --oneline
  Run: git log origin/[default-branch]..HEAD --oneline
  If the local branch is behind origin:
    → Warn: "Your branch is N commits behind origin/[default-branch]."
    → Ask: "Pull and rebase before we continue? (recommended)"
    → Do not proceed until the developer decides.
  If the local branch has unpushed commits:
    → Surface them: "You have N local commits not yet pushed."
    → Note them for the PR step at the end of the session.

STEP 4 — Create a scoped branch for this session's work
  Branch naming convention: [type]/[short-slug]
  Types: feat | fix | refactor | chore | docs | test
  Example: feat/carrier-mobile-view | fix/webhook-retry-logic
  Run: git checkout -b [type]/[slug] origin/[default-branch]
  If a branch for this task already exists:
    → Offer to check it out instead of creating a new one.
    → Run: git checkout [existing-branch] && git pull origin [existing-branch]

STEP 5 — Confirm and proceed
  Print: "✓ Git context clean. Branch: [branch-name]. Ready to work."
  Only after this confirmation may the AI begin discussing or writing code.

## Project-Specific Engineering Rules

- Never violate ISA field layout: cond[15:12], op[11:8], updt[7], imm[6], val[5:0].
- Keep strict 5-state FSM cycle: fetch1, fetch2, decode, exec, store.
- Preserve register semantics:
  - R0 = ACC
  - R62 = RPC
  - R63 = PC
- Ensure PC reset is exactly x"0000".
- Keep control and datapath separated.
- Use IEEE.numeric_std for arithmetic.
- Do not silently guess opcode/condition encodings. Mark uncertain values and request verification.
- Any ALU change must include corresponding flag behavior verification.
- Any control FSM change must include updated testbench coverage.

## Review Expectations

PRs should include:
- What ISA behavior changed.
- What tests prove correctness.
- Any remaining verification dependency on Table 1/Table 2 source values.
