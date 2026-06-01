# Code Review Guide

## Priorities
1. ISA compliance correctness (encoding, decode, execution semantics).
2. Flag correctness (Z/N/C/V) for each opcode family.
3. FSM correctness across fetch1/fetch2/decode/exec/store.
4. Synthesizability and deterministic reset behavior.
5. Testbench quality and behavior coverage.

## Review Checklist

- [ ] Instruction fields are extracted with correct bit slices.
- [ ] Register file keeps R0/R62/R63 semantics and write enables.
- [ ] PC reset value is exactly `0x0000`.
- [ ] Control outputs default safely in combinational blocks.
- [ ] No latch inference in decode/output logic.
- [ ] ALU arithmetic uses `numeric_std` conversions explicitly.
- [ ] Logical operations only update N/Z when `updt` requests status update.
- [ ] Shift carry behavior follows assignment text.
- [ ] Overflow detection for add/sub/shift-left follows assignment text.
- [ ] CAL path updates RPC and writes target into PC in store phase.
- [ ] Testbenches include clear assertions, not visual-only waveform checks.

## Common Failure Modes

- Mixing control and datapath behavior in one module.
- Guessing opcode constants without explicit ISA table verification.
- Updating all flags for all instructions by default.
- Forgetting default assignments in combinational decode.
- Writing directly to arbitrary registers when ACC/PC/RPC path is expected.

## Required Evidence in PR

- Summary of impacted ISA behavior.
- Testbench assertions added/updated.
- Waveform screenshot or transcript for non-trivial control changes.
- Note on whether opcode/condition table mappings were changed.
