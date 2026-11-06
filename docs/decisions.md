# Decisions

Why this repository and this process look the way they do. Change a decision here before changing the process that implements it.

## 1. A separate repository from the plugins

Plugin repositories stay standalone and installable on their own. The process, standards, and templates are shared by every plugin, so they live once, here, and change once. A plugin repository may carry its own `STANDARDS.md` and `SCOPE.md`, but those are project-specific additions, never a fork of this skill.

## 2. Skills linked with junctions, not copied

The skill is delivered by directory junction (Windows) or symlink (macOS/Linux) from this repository into `%USERPROFILE%\.dsh\skills`, the same mechanism as `thirtybees-workflow`. DSH discovers skills there at user rank 400 from every workspace, `git pull` updates the live skill, and there is no copy to drift. Skills are discovered per session, so a new session is required after changing this repository.

## 3. One skill with references, not several skills

Everything a plugin build needs is one catalog entry, `dsh-plugin-development`. The `SKILL.md` routes to references, so the common case loads a small file and the deep rules load on demand. A second skill would split a decision that is really one process; split it only if the standards grow past what references can carry.

## 4. Five light gates, not thirtybees' seven

A plugin is usually small and the harness is fast to verify in the live UI, so the heavy ceremony of the thirty bees workflow (kickoff document, full design document, separate review and release gates) would cost more than it saves. The gates that do earn their place stay: no source before an approved plan, and no "done" without a live check. A fix that changes intended behaviour switches back to the feature tier.

## 5. Out-of-tree scope only

This skill covers bundles built in `dsh-works` and installed into a profile. Contributing a package, tool, or provider to the `deepseek-harness` repository itself is in-tree TypeScript work with its own gates, tests, and review standards; that checkout's `AGENTS.md` and cookbook own it. Keeping the scope split stops in-tree machinery (projections, snapshots, coverage gates) from being cargo-culted into plain-JS bundles.

## 6. Plain ESM JavaScript first

A bundle needs no build step: `dsh plugin add` links the directory and the harness loads `index.js`, `client.js`, and the locale files as written. Add a build step only when a plugin genuinely needs TypeScript or JSX, and then ship built output in `files` rather than making install run a compiler.

## 7. Standards are re-audited when the harness moves

The rules in `references/standards.md` are derived from the harness checkout, which is a developer preview with pre-stable APIs. Each plugin pins `engines.dsh`. When that pin moves, re-read the changed harness docs and update the standards deliberately; do not assume last quarter's rules are still enforced.

## 8. Derived, never authoritative

The harness checkout and the live harness are the only authority for behavior and rules. The skill and its standards are a digest of that checkout, with out-of-tree adaptations stated as such. When they disagree, the harness wins and the skill is corrected in that same change. A plugin repository's STANDARDS.md or SCOPE.md is project-specific notes and never overrides either. This is why every standard carries its harness source: the citation is the authority, the rule is the summary.

## 9. A stable `main` and a `dev` integration line

A profile links a working tree, so a linked checkout runs whichever branch is checked out — "what runs" and "what was verified" can only agree if one line is kept stable on purpose. `main` therefore carries only commits whose checks passed (and, once released, whose gate-3 evidence was recorded); `dev` absorbs in-flight work so `main` never becomes a moving target. `feature/<slug>` keeps one change reviewable and mergeable without blocking the line, and `hotfix/<slug>` lets a defect reach stable without waiting for unfinished `dev` work — then merges back so the fix is not lost. Working directly on `main` is what this replaces: even a green local increment belongs on `dev` until the release merges it.
