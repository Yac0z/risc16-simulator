# Project Context

> Source of truth for every AI session. Update when the stack, goal, or
> constraints change. Terse and accurate beats thorough and stale.

---

## What This Project Is

**Name:** Processeur RISC 16 bits
**Type:** Other (digital hardware design project)
**Summary:** Conception RTL VHDL d'un processeur RISC 16 bits conditionnel avec simulation ModelSim puis implementation FPGA Spartan 3E.
**Primary user:** Etudiants/enseignants du module Conception de circuits numeriques.

---

## Tech Stack

**Language(s):** VHDL
**Runtime / platform:** ModelSim simulation + FPGA Spartan 3E target
**Main frameworks / libraries:** IEEE.std_logic_1164, IEEE.numeric_std
**Database(s):** None identified
**Infrastructure / deployment:** Local EDA flow (simulation, synthese, implementation FPGA)
**Key external services / APIs:** None identified
**Package manager:** None identified
**Test framework(s):** VHDL testbenches in ModelSim
**Default branch:** main <!-- inferred — verify this -->

---

## Repository Layout

- `specs/`: project specification and ISA source PDF.
- `.ai/`: AI collaboration context and standards.
- `.github/prompts/`: workspace bootstrap prompt.
- `processeur/src/rtl/`: RTL VHDL modules (registers, ALU, control unit, top).
- `processeur/tb/`: testbenches.
- `processeur/modelsim/`: simulation scripts.

**Entry point(s):** `processeur/src/rtl/cpu_top.vhd` <!-- inferred — verify this -->
**Business logic:** `processeur/src/rtl/control_unit.vhd`, `processeur/src/rtl/alu.vhd`
**Tests:** `processeur/tb/`
**Config / secrets:** None identified.

---

## Current Goal

**Milestone / sprint goal:** Bootstrap complet du projet processeur avec composants RTL, contraintes ISA, et workflow de verification.
**Active problem this session:** Initialiser le socle VHDL et la documentation de travail en respectant strictement la spec ISA disponible.

---

## Hard Constraints

- ISA 16 bits avec format instruction: cond[15:12], op[11:8], updt[7], imm[6], val[5:0].
- 64 registres de 16 bits.
- R0 = ACC, R62 = RPC, R63 = PC.
- Execution de toutes instructions conditionnee par `cond`.
- FSM obligatoire sur 5 etats: fetch1, fetch2, decode, exec, store.
- Flags a gerer: Z, N, C, V.
- Regles flags: logique met a jour N/Z uniquement; decalages gerent C et overflow de signe.
- Reset du PC a `0x0000`.
- Description RTL synthesizeable en VHDL.
- Simulation sur ModelSim obligatoire.
- Cible d'implementation: FPGA Spartan 3E.

---

## Patterns Already Established

- Separation nette entre datapath (registres/ALU/mux) et controle (FSM).
- Utiliser `numeric_std` (pas `std_logic_arith`).
- Utiliser `rising_edge(clk)` pour toute logique sequentielle.
- Registres avec `ce` explicite pour maitriser les ecritures.
- Lectures asynchrones exposees pour ACC et PC dans le banc de registres.
- Decodage condition/opcode centralise.

---

## What Not to Touch

- Encodages exacts opcodes/conditions non extraits integralement du PDF OCR: valider avant freeze de l'ISA package.
- Ne pas modifier les regles de cycle CPU (5 etats) sans decision d'architecture documentee.

---

## Glossary

| Term | Meaning in this project |
|------|------------------------|
| ACC | Accumulateur du processeur, mappe sur R0 |
| PC | Program counter, mappe sur R63 |
| RPC | Return program counter, mappe sur R62 |
| cond | Predicate de condition d'execution d'une instruction |
| op | Opcode de l'instruction |
| updt | Drapeau de mise a jour des flags |
| imm | Selection operande immediate vs registre |
| val | Champ operande (registre ou immediate) |
| ALU/UAL | Unite arithmetique et logique |
| FSM | Automate de controle du cycle instruction |

---

## Links

- specs/ProcesseurRISC.pdf
