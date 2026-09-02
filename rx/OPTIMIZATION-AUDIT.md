# RX/ZSH Optimization Audit

Generated: 2026-05-17

## Inventory

- **RX scripts**: 57 files (~155KB)
- **ZSH modules**: 15 files (+ .zwc compiled)
- **Shared libs**: `lib/common.sh`, `lib/repo-sync-common.sh`
- **Total functions**: ~85 across all modules
- **Total aliases**: ~160 in aliases.zsh

---

## 1. Redundancies

### 1.1 Script ↔ Function Duplicates (HIGH priority)

| Function (ZSH) | Script (RX) | Action |
|----------------|-------------|--------|
| `dots-sync()` in functions.zsh:42 | `dots-sync.sh` | Keep script (called by kanata); remove function |
| `dedupemuz()` in functions.zsh:28 | `dedupe-mp3.sh` | Keep script; function is a wrapper → simplify to alias |
| `lstype()` in functions.zsh:69 | `list-file-types.sh` | Keep function (simple); delete script |
| `move-large()` in file_management.zsh:25 | `move-large-files.sh` | Keep function; script adds nothing |

### 1.2 Move/File Functions: 6 variants → 1 generic

In `file_management.zsh`:
- `fd-move-exclude()` :7
- `fd-move()` :12
- `move-large()` :25
- `move-iso()` :32
- `move-pix()` :42
- `rm-pix()` :51

Plus `move-files` script in RX. All follow the same `find ... -exec mv {} $dest` pattern.

**Consolidation**: One `move-by-type <ext> <src> <dst>` function. Keep `move-files` as the RX script entry point; delete the 5 specialized ZSH functions and alias them to `move-by-type`.

### 1.3 Wezterm/Ghostty Dead References

User uses Kitty exclusively. These are dead weight:
- `open-wezterm()` in config.zsh:26
- `open-ghostty()` in config.zsh:27
- `alias vg` in aliases.zsh:157 (ghostty config)
- `alias vw` in aliases.zsh:158 (wezterm config)
- `open -a wezterm` in torrent.zsh:10,54 (should be kitty)

### 1.4 OpenClaw References (Dead)

User dropped OpenClaw. Remove:
- `_openclaw_or_note()` in functions.zsh:48-66
- `oct()`, `occ()`, `ocd()` in functions.zsh:57-66
- References in agent_vault.zsh:51, agent-vault-lib.sh:59, agent-vault-init.sh:65

### 1.5 Agent-Vault → Crypt Rename

9 scripts in RX still named `agent-vault-*`. Should be renamed to `crypt-*`:
- agent-vault-checkpoint.sh → crypt-checkpoint.sh
- agent-vault-handoff.sh → crypt-handoff.sh
- agent-vault-init.sh → crypt-init.sh
- agent-vault-lib.sh → crypt-lib.sh
- agent-vault-memory-backup.sh → crypt-memory-backup.sh
- agent-vault-monitor.sh → crypt-monitor.sh
- agent-vault-status.sh → crypt-status.sh
- agent-vault-sync.sh → crypt-sync.sh
- agent-vault-wifi-sync.sh → crypt-wifi-sync.sh

Module `agent_vault.zsh` → `crypt.zsh`. Aliases already have `crypt*` versions alongside `av*` — drop `av*`, keep `crypt*`.

---

## 2. Gaps

### 2.1 current-theme.zsh Not Sourced — FIXED
Added to zshenv:69 during this session.

### 2.2 No Dependency Checks in Most Scripts
Only `theme` and scripts that source `lib/common.sh` get `check_deps`. Scripts like `daily-notes.sh`, `bak.sh`, `organize-downloads.sh` do NOT source common.sh and have no dep checks.

### 2.3 No Central Error Handling
`lib/common.sh` provides `die()` and `log()` but only ~12 of 57 scripts source it. The rest use raw `echo` + `exit 1`.

### 2.4 Missing .zwc Recompilation
`update-zwc()` in config.zsh recompiles modules, but there's no hook to auto-recompile after module edits. Stale .zwc files silently shadow changes.

---

## 3. Consolidation Plan (Priority Order)

### P1: Rename agent-vault → crypt (LOW risk)
- Rename 9 RX scripts
- Rename ZSH module
- Update all internal references
- Update aliases.zsh (drop av* aliases)
- Update hermes memory entry
- Risk: Other machines may still expect `agent-vault` name

### P2: Remove dead code (NO risk)
- Delete wezterm/ghostty functions + aliases
- Delete openclaw functions
- Fix torrent.zsh to use kitty instead of wezterm

### P3: Deduplicate script↔function overlaps (LOW risk)
- Remove 4 redundant functions, replace with aliases to scripts
- Risk: Any scripts calling functions directly (unlikely)

### P4: Consolidate move-* functions (MEDIUM risk)
- Create generic `move-by-type`
- Alias old names for backward compat
- Risk: Behavioral differences in edge cases

### P5: Standardize common.sh sourcing (LOW risk)
- Add `source "$(dirname "$0")/lib/common.sh"` to remaining scripts
- Risk: Path resolution if scripts are symlinked

---

## 4. Git Overlap Assessment

**No actual overlap.** The git.zsh functions (`git-add-commit-push`, `git-pull`, `git-push`, etc.) are well-organized. Aliases in aliases.zsh correctly point to these functions. No separate RX script for git. **No action needed.**

---

## 5. Summary

| Category | Count | Action |
|----------|-------|--------|
| Duplicate script↔function | 4 | Remove function, keep script |
| Dead references (wezterm/ghostty/openclaw) | 9 | Delete |
| Agent-vault → crypt rename | 9 scripts + 1 module + ~20 aliases | Rename |
| Move function consolidation | 6 → 1 | Merge |
| Scripts missing common.sh | ~40 | Add source line |
| .zwc auto-recompile | 0 | Add precmd hook |
