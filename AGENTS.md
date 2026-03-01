# AGENTS.md

## Repository Layout

* `fcos/` directory containts files relating to the Fedora CoreOS immutable
   linux distro
* `homebrew/` directory contains a snapshot of `brew bundle` output from an old
   machine when i was experimenting with committing to nix-darwin for host
   configuration. That decision is finalised now so I intend to delete this soon
* `nix/` has organically grown over time to contain directories named after each
   host which i've onboarded to nix. Currently contains lots of duplicated nix
   configuration. There are opportunities to restructure this better
* `AGENTS.md` this file
* `README.md` human readable version of this file with some additional notes
   for a human using this repo

That is all that is contained in this repo currently.

## Git Repo

* Commits use a "conventional commits" style
* This repo has a long history but none of the history is relevant to an
  agent at this point. The repo underwent a large shift in structure at tag
  v0.5.0 and anything before then should be ignored.

## Keeping AGENTS.md Up To Date

* Propose edits to this file to keep it updated. For example when i repeatedly
  correct an agent or share significant info about how to work in this repo
