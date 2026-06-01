# Processeur RISC 16 bits - Bootstrap VHDL

## Structure

- `src/rtl/isa_pkg.vhd`: types, constants ISA, helper functions.
- `src/rtl/instr_reg.vhd`: registre instruction 16 bits.
- `src/rtl/status_reg.vhd`: registre statut 4 bits (Z N C V).
- `src/rtl/register_file.vhd`: banc de 64 registres 16 bits (R0/R62/R63 speciaux).
- `src/rtl/ram.vhd`: RAM generique compatible avec le bus memoire du processeur.
- `src/rtl/alu.vhd`: operations arithmetiques/logiques + flags.
- `src/rtl/control_unit.vhd`: FSM fetch1/fetch2/decode/exec/store + signaux de commande.
- `src/rtl/cpu_top.vhd`: interconnexion globale.
- `tb/`: testbenches de depart.
- `modelsim/run.do`: script ModelSim.

## Lancer simulation

Depuis ModelSim, executer:

```
do modelsim/run.do
```

## Vivado / Basys3

- Top-level board entity: `src/rtl/basys3_top.vhd`.
- Constraints Vivado: `vivado/basys3.xdc`.
- `cpu_top.vhd` remains the board-agnostic processor core.
- The Basys3 wrapper instantiates `ram.vhd` as the on-chip memory block so the design can run on the FPGA without external memory.

Flux recommande dans Vivado:

1. Creer un projet pour Basys3.
2. Ajouter les fichiers VHDL de `src/rtl/`.
3. Definir `basys3_top` comme top module.
4. Ajouter `vivado/basys3.xdc`.
5. Lancer synthese, implementation puis programmation de la carte.

## Beginner guide

Voir [specs/beginner_guide.md](../specs/beginner_guide.md) pour une explication pas a pas du projet, du lien entre les fichiers, et du lien avec l'ISA.

## Assembly examples

Voir [specs/assembly_programs.md](../specs/assembly_programs.md) pour 10 programmes exemples en assembleur ISA avec leur encodage binaire 16 bits.

## Important

Les constantes opcodes/conditions dans `isa_pkg.vhd` sont marquees comme verification requise si la valeur n'etait pas lisible dans l'extraction OCR du PDF. Verifier Tableau 1 et Tableau 2 avant validation finale.
