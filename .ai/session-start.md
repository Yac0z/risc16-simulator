# Session Start Protocol

Load order for every AI-assisted session:
1. `.ai/context.md`
2. `.ai/patterns.md`
3. `.ai/decisions.md`
4. `.github/copilot-instructions.md`
5. `.ai/tasks.md`

## Mandatory Git Opening Protocol

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

## Session Git Closing Protocol

At the end of every session, before signing off:

STEP 1 — Stage and commit all changes
  Run: git add -p
  (Patch-add — review every hunk before staging. No blind git add .)
  Commit message format:
    [type]([scope]): [imperative sentence under 72 chars]

    [Optional body: what changed and why, not what the diff shows]

    [Optional footer: Closes #NNN | Breaking change: ...]

  Example:
    feat(carrier): add real-time status update webhook handler

    Adds SQS consumer that processes carrier status events and pushes
    updates to connected shipper clients via WebSocket. Retries up to
    3 times with exponential backoff before sending to DLQ.

    Closes #142

STEP 2 — Push the branch
  Run: git push -u origin [branch-name]

STEP 3 — Open a Pull Request
  PR title: mirrors the commit subject line
  PR description must include:
    ## What changed
    [2–5 sentences — the why and what, not a diff summary]

    ## How to test
    [step-by-step — what the reviewer should run or click]

    ## Checklist
    - [ ] Tests pass locally
    - [ ] No new linting errors
    - [ ] No console.log / debug statements left in
    - [ ] No secrets or credentials in any changed file
    - [ ] Relevant docs updated if behaviour changed

STEP 4 — Update .ai/tasks.md
  Move completed items to "Completed This Sprint".
  Record the session in the Session Notes table.
  Commit this update on the same branch before the PR.
