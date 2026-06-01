# 10 ISA Programs (Assembly + Binary)

Instruction format used:

- `cond[15:12] op[11:8] updt[7] imm[6] val[5:0]`
- Binary shown as: `cccc oooo u i vvvvvv` and flat 16-bit word.

---

## Program 1 — Logic core

| Assembly | Binary fields | 16-bit |
|---|---|---|
| `ANDT r1` | `0001 0000 1 0 000001` | `0001000010000001` |
| `ORT 0x0F` | `0001 0001 1 1 001111` | `0001000111001111` |
| `XORT r2` | `0001 0010 1 0 000010` | `0001001010000010` |
| `NOTT r3` | `0001 0011 1 0 000011` | `0001001110000011` |

## Program 2 — Arithmetic + shifts

| Assembly | Binary fields | 16-bit |
|---|---|---|
| `ADDT r4` | `0001 0100 1 0 000100` | `0001010010000100` |
| `SUBT 0x01` | `0001 0101 1 1 000001` | `0001010111000001` |
| `LSLT 0x02` | `0001 0110 1 1 000010` | `0001011011000010` |
| `LSRT r5` | `0001 0111 1 0 000101` | `0001011110000101` |

## Program 3 — Memory + transfer

| Assembly | Binary fields | 16-bit |
|---|---|---|
| `LDAT 0x08` | `0001 1000 0 1 001000` | `0001100001001000` |
| `STAT 0x10` | `0001 1001 0 1 010000` | `0001100101010000` |
| `MTAT r6` | `0001 1010 1 0 000110` | `0001101010000110` |
| `MTRT 0x05` | `0001 1011 1 1 000101` | `0001101111000101` |

## Program 4 — Control flow

| Assembly | Binary fields | 16-bit |
|---|---|---|
| `JRPT r7` | `0001 1100 0 0 000111` | `0001110000000111` |
| `JRNT 0x02` | `0001 1101 0 1 000010` | `0001110101000010` |
| `JPRT r62` | `0001 1110 0 0 111110` | `0001111000111110` |
| `CALT 0x04` | `0001 1111 0 1 000100` | `0001111101000100` |

## Program 5 — Conditions Z/NZ/P/NP

| Assembly | Binary fields | 16-bit |
|---|---|---|
| `ADDZ r1` | `0010 0100 1 0 000001` | `0010010010000001` |
| `SUBNZ 0x03` | `0011 0101 1 1 000011` | `0011010111000011` |
| `ANDP r2` | `0100 0000 1 0 000010` | `0100000010000010` |
| `ORNP 0x3F` | `0101 0001 1 1 111111` | `0101000111111111` |

## Program 6 — Conditions N/NN/C/NC

| Assembly | Binary fields | 16-bit |
|---|---|---|
| `XORN r3` | `0110 0010 1 0 000011` | `0110001010000011` |
| `NOTNN r4` | `0111 0011 1 0 000100` | `0111001110000100` |
| `ADDC 0x01` | `1000 0100 1 1 000001` | `1000010011000001` |
| `SUBNC r5` | `1001 0101 1 0 000101` | `1001010110000101` |

## Program 7 — Conditions V/NV/F

| Assembly | Binary fields | 16-bit |
|---|---|---|
| `LSLV 0x01` | `1010 0110 1 1 000001` | `1010011011000001` |
| `LSRNV 0x01` | `1011 0111 1 1 000001` | `1011011111000001` |
| `LDAF 0x04` | `0000 1000 0 1 000100` | `0000100001000100` |
| `STAF r6` | `0000 1001 0 0 000110` | `0000100100000110` |

## Program 8 — Call/return style

| Assembly | Binary fields | 16-bit |
|---|---|---|
| `CALT 0x06` | `0001 1111 0 1 000110` | `0001111101000110` |
| `MTAT r10` | `0001 1010 1 0 001010` | `0001101010001010` |
| `JRPT r10` | `0001 1100 0 0 001010` | `0001110000001010` |
| `JPRT r62` | `0001 1110 0 0 111110` | `0001111000111110` |

## Program 9 — Register/memory roundtrip

| Assembly | Binary fields | 16-bit |
|---|---|---|
| `MTAT 0x1E` | `0001 1010 1 1 011110` | `0001101011011110` |
| `MTRT r12` | `0001 1011 1 0 001100` | `0001101110001100` |
| `STAT r12` | `0001 1001 0 0 001100` | `0001100100001100` |
| `LDAT r12` | `0001 1000 0 0 001100` | `0001100000001100` |

## Program 10 — Mixed short sequence

| Assembly | Binary fields | 16-bit |
|---|---|---|
| `ANDT 0x15` | `0001 0000 1 1 010101` | `0001000011010101` |
| `XORT 0x2A` | `0001 0010 1 1 101010` | `0001001011101010` |
| `ADDT 0x3F` | `0001 0100 1 1 111111` | `0001010011111111` |
| `JRNZ 0x01` | `0010 1101 0 1 000001` | `0010110101000001` |

---

## Dedicated RPC Example (R62)

`RPC` is register `R62` (`val = 111110`).

### Example sequence

| Assembly | Meaning | Binary fields | 16-bit |
|---|---|---|---|
| `CALT 0x08` | call target, save return address into RPC | `0001 1111 0 1 001000` | `0001111101001000` |
| `...` | subroutine body | `...` | `...` |
| `JPRT r62` | return using RPC | `0001 1110 0 0 111110` | `0001111000111110` |

This is the standard call/return pair with RPC.

