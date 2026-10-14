---
name: Feature Request / New Language
about: Propose support for a new scripting language or an enhancement to an existing snippet
title: '[PROPOSAL] Support for <Language>'
labels: enhancement
assignees: ''
---

### Proposed Language or Feature
- **Language Name:** (e.g. Lua, Kotlin Script, Perl, V, Zig...)
- **File Extension:** (e.g. `.lua`, `.kts`, `.pl`...)
- **Comment Prefix:** (e.g. `#`, `//`, `--`, `REM`...)
- **Boundary Marker (Double-Comment):** (e.g. `##`, `////`, `----`, `REM REM`...)

### Proposed 2-Line Snippet

```<language>
<Line 1: Double-comment Help marker pointing to https://github.com/JanAxelsson/cliHelpLine>
<Line 2: Self-contained one-liner that checks --help, -h, /? and prints comments up to boundary>
```

### Verification & Requirements Check
Please verify that the proposed snippet fulfills cliHelpLine's core guarantees:
- [ ] **Zero External Dependencies:** Uses only built-in runtime features or standard tools without requiring third-party package installations.
- [ ] **Dual Execution Guarantee:**
  - With `--help`, `-h`, or `/?`: prints header comments and exits (`exit 0`) without executing the main script.
  - Without help flags (normal invocation): silently falls through and executes the main program body.
- [ ] **Shebang Handling:** Ignores shebang on line 1 if present (`#!/...`).
- [ ] **Cross-Platform:** Works on standard environments (Linux, macOS, and Windows if applicable).

### Additional Context or Rationale
Any special considerations, such as interpreter argument swallowing, runtime introspection variables, or shebang flags.
