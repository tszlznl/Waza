---
name: check
description: Use after completing a task or before merging. Not for exploring ideas or debugging.
version: 1.5.0
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Grep
  - Glob
  - Agent
  - AskUserQuestion
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: "input=\"$CLAUDE_TOOL_INPUT\"; if echo \"$input\" | grep -qE 'git push --force|git push -f |rm -rf /|DROP TABLE|--no-verify'; then echo 'BLOCK: Destructive command during /check review. Confirm with user first.' >&2; exit 1; fi"
---

# Check: Review Before You Ship

Read the diff, find the problems, fix what can be fixed safely, ask about the rest. Do not claim done until verification has run in this session.

## Get the Diff

```bash
git fetch origin
git diff origin/main
```

If the base branch is not `main`, ask before running. Already on the base branch? Stop and ask which commits to review.

## Did We Build What Was Asked?

Before reading the code, check for scope drift:
- Pull up recent commit messages and any task files
- Does the diff match the stated goal? Flag anything outside that scope: unrelated files, voluntary additions, missing requirements
- Label it: **on target** / **drift** / **incomplete** and note it, but do not block on it

## What to Look For

### Hard stops (fix before merging)

These are not negotiable:

- **Destructive auto-execution**: any task flagged as "safe" or "auto-run" that modifies user-visible state (history files, config files, stored preferences, installed software, cache entries the user can inspect) must require explicit confirmation. "Safe" means no side effects, not "probably harmless." If a task deletes or rewrites something the user can see, it is not safe by default.
- **Release artifacts missing**: a GitHub release with an empty body, missing assets, or unuploaded build files is not a completed release. Verify every artifact listed in the release template exists as a local file and has been uploaded before declaring done.
- **Translated file naming collision**: when placing a file in a language-specific directory (e.g., `_posts_en/`, `en/`), the file name must not repeat the language suffix. Check the naming convention of existing files in the same directory first.

- **GitHub issue or PR number mismatch**: before commenting on, closing, or acting on a GitHub issue or PR, verify the number matches the one discussed in this session. Do not rely on memory. Run `gh issue view N` or `gh pr view N` to confirm the title matches before writing.

- **GitHub comment style**: PR review comments and issue replies must be brief (1-2 sentences), natural-sounding, and friendly. Not verbose. Not formatted like a report. Not AI-sounding. If a comment needs more than 2 sentences, it should be structured as a list, not a paragraph.

- **Injection and validation**: SQL, command, path injection; inputs that bypass validation at system entry points
- **Shared state**: unsynchronized writes, check-then-act races, missing locks
- **External trust**: output from LLMs, APIs, or user input fed into commands or queries without sanitization; credentials hardcoded or logged
- **Missing cases**: enum or match exhaustiveness; use grep on sibling values outside the diff to confirm
- **Dependency changes**: unexpected additions or version bumps in `package.json`, `Cargo.toml`, `go.mod`, or `requirements.txt`. Flag any new dependency not obviously required by the diff.

### Soft signals (flag, do not block)

Worth noting but not merge-blocking:

- Side effects that are not obvious from the function signature
- Magic literals that should be named constants
- Dead code, stale comments, style gaps relative to the surrounding code
- Untested new paths
- Loop queries, missing indexes, unbounded growth

## How to Handle Findings

Fix directly when the correct answer is unambiguous: clear bugs, null checks on crash paths, style inconsistencies matching the surrounding code, trivial test additions.

Batch everything else into a single AskUserQuestion when the fix involves behavior changes, architectural choices, or anything where "right" depends on intent:

```
[N items need a decision]

1. [hard stop / signal] What: ... Suggested fix: ... Keep / Skip?
2. ...
```

## Judgment Quality

Beyond correctness, ask three questions a senior reviewer would ask:

- **Right problem?** Does the diff solve what was actually needed, or a slightly different version of it? A technically correct solution to the wrong problem is a bug with extra steps.
- **Mature approach?** Is the implementation idiomatic for this codebase and language, or does it introduce a pattern that will confuse the next person? Clever code that nobody else can maintain is a liability.
- **Honest edge cases?** Does the code handle failure modes and boundary conditions explicitly, or does it silently succeed in the happy path and silently corrupt in the others? Check what happens on nil, empty, zero, concurrent access, and upstream failure.

These do not block a merge on their own, but a "no" on any of them is worth flagging explicitly.

## Regression Coverage

For every new code path: trace it, check if a test covers it. If this change fixes a bug, a test that fails on the old code must exist before this is done.

## Verification

After all fixes are applied, run `scripts/verify.sh` from this skill's directory, or the project's known verification command:

```bash
bash "$(dirname "$0")/../scripts/verify.sh"
```

If nothing is detected, ask the user for the verification command before proceeding.

Paste the full output. Report exact numbers. Done means: the command ran in this session and passed.

If no verification command exists or the command fails: halt. Do not claim done. Ask the user how to verify before proceeding.

If the urge to skip this arises: "should work now" means run it. "I'm confident" is not evidence. "It's a trivial change" is how trivial changes break things.

## Gotchas

Real failures from prior sessions, in order of frequency:

- **Commented on the wrong issue.** Left a comment on #249 when the conversation was about #255. Run `gh issue view N` or `gh pr view N` to confirm title before commenting or closing.
- **PR comments sounded like a report.** User had to iterate multiple times on comment tone. GitHub comments should be 1-2 sentences, natural, like a colleague, not a structured review output.
- **Announced release done before uploading artifacts.** Pushed the GitHub release with no .dmg/.zip/.sha256 attached. Verify every artifact listed in the release template exists as a local file and has been uploaded.
- **Language suffix doubled.** Placed `article.en.md` inside `_posts_en/`, generating a duplicate URL. Check the naming convention of existing files in the target directory first.
- **Skipped verification on "trivial" changes.** "It's a one-line fix" is how trivial changes break things. If the urge to skip arises, run `scripts/verify.sh` anyway.
- **Deployed without env vars.** Pushed to Vercel while API keys only existed in local `.env.local`. Site returned 401 on every request. Run `vercel env ls` or equivalent and diff against local keys before deploying.
- **Git push failed from auth mismatch.** Two failed pushes before discovering remote was HTTPS but local expected SSH. Run `git remote -v` and verify auth method before the first push in a new project.

## Sign-off

```
files changed:    N (+X -Y)
scope:            on target / drift: [what]
hard stops:       N found, N fixed, N deferred
signals:          N noted
new tests:        N
verification:     [command] → pass / fail
```
