## Description
Briefly describe the change, language added, or bug fixed.

---

## Type of Change
- [ ] New language support (adds language #25+)
- [ ] Bug fix / resilience improvement to an existing snippet
- [ ] Test suite enhancement
- [ ] Documentation update

---

## Contributor Checklist
Before submitting, please ensure your changes adhere to the project standards:
- [ ] **Dual Execution Tested:** Tested both with `--help` (prints header and exits 0) and without arguments (executes main body).
- [ ] **Flag Coverage:** Verified `--help`, `-h`, and `/?` flags.
- [ ] **Byte-for-Byte Synchronization:** The 2-line snippet in `examples/cliHelpLine.<ext>` matches `README.md` byte-for-byte.
- [ ] **Alphabetical Ordering:** Language heading in `README.md` and jump bar are positioned strictly alphabetically (A–Z).
- [ ] **Tests Pass:** Verified locally via `./run_tests.sh --local` (or full suite `./run_tests.sh`).
