# Onboarding - Processeur RISC 16 bits

## 1. Project Goal

Build and validate a 16-bit RISC processor in VHDL, then synthesize/implement on Spartan 3E FPGA.

## 2. Read First

1. `specs/ProcesseurRISC.pdf`
2. `.ai/context.md`
3. `.ai/patterns.md`
4. `.ai/decisions.md`
5. `.ai/session-start.md`

## 3. Tooling

- ModelSim (simulation)
- FPGA toolchain for Spartan 3E (synthesis, place, route)

## 4. Repository Areas

- `processeur/src/rtl/`: synthesizable VHDL
- `processeur/tb/`: testbenches
- `processeur/modelsim/`: simulation scripts
- `.ai/`: AI collaboration docs and standards

## 5. First-Day Tasks

1. Verify opcode/condition tables from source PDF (Tableau 1 and Tableau 2).
2. Update `isa_pkg.vhd` constants accordingly.
3. Run ALU/register file testbenches.
4. Implement control FSM decode/store behavior per ISA.
5. Build top-level CPU test program and trace control flow.

## 6. Definition of Done (Core Milestone)

- All RTL modules compile.
- Unit testbenches pass in ModelSim.
- ISA decode and flags behavior validated against assignment.
- Top-level simulation executes representative instruction flow.
- Synthesis report produced for Spartan 3E with fmax and utilization metrics.

## 7. Critical Risk

The original PDF OCR output was incomplete, so always keep the user-provided table images as the source of truth when editing ISA mappings.
