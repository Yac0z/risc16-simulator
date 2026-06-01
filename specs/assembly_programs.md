# 10 Assembly Programs for the Processeur RISC ISA

This document uses the current encoding in `isa_pkg.vhd`:

- `cond[15:12]`
- `op[11:8]`
- `updt[7]`
- `imm[6]`
- `val[5:0]`

For register-form instructions, `val` is the register number. For immediate-form instructions, `val` is a 6-bit two's-complement value.

Condition codes:

- `T = 0001`
- `F = 0000`
- `Z = 0010`
- `NZ = 0011`
- `P = 0100`
- `NP = 0101`
- `N = 0110`
- `NN = 0111`
- `C = 1000`
- `NC = 1001`
- `V = 1010`
- `NV = 1011`

Opcode codes:

- `AND = 0000`
- `OR  = 0001`
- `XOR = 0010`
- `NOT = 0011`
- `ADD = 0100`
- `SUB = 0101`
- `LSL = 0110`
- `LSR = 0111`
- `LDA = 1000`
- `STA = 1001`
- `MTA = 1010`
- `MTR = 1011`
- `JRP = 1100`
- `JRN = 1101`
- `JPR = 1110`
- `CAL = 1111`

## Program 1 - Logical operations, register and immediate forms

Purpose: cover AND, OR, XOR, NOT with different conditions and both operand encodings.

| Addr | Assembly | Binary |
| --- | --- | --- |
| 00 | ANDT r1 | `0001 0000 1 0 000001` |
| 01 | ORNZ 0x12 | `0011 0001 1 1 010010` |
| 02 | XORP r2 | `0100 0010 1 0 000010` |
| 03 | NOTT r3 | `0001 0011 0 0 000011` |

## Program 2 - Arithmetic and signed conditions

Purpose: cover ADD and SUB, including conditions tied to signed results.

| Addr | Assembly | Binary |
| --- | --- | --- |
| 00 | ADDT r4 | `0001 0100 1 0 000100` |
| 01 | SUBZ 0x01 | `0010 0101 1 1 000001` |
| 02 | ADDV 0x3F | `1010 0100 1 1 111111` |
| 03 | SUBNV r5 | `1011 0101 1 0 000101` |

## Program 3 - Shift operations and carry/overflow scenarios

Purpose: cover LSL and LSR with register and immediate shift counts.

| Addr | Assembly | Binary |
| --- | --- | --- |
| 00 | LSLT 0x01 | `0001 0110 1 1 000001` |
| 01 | LSRP 0x02 | `0100 0111 1 1 000010` |
| 02 | LSLC r6 | `1000 0110 1 0 000110` |
| 03 | LSRNC 0x03 | `1001 0111 0 1 000011` |

## Program 4 - Move/transfer instructions

Purpose: cover MTA and MTR with positive, negative, and unconditional conditions.

| Addr | Assembly | Binary |
| --- | --- | --- |
| 00 | MTAP r7 | `0100 1010 1 0 000111` |
| 01 | MTAN 0x2A | `0110 1010 1 1 101010` |
| 02 | MTRT r8 | `0001 1011 1 0 001000` |
| 03 | MTRNZ r9 | `0011 1011 0 0 001001` |

## Program 5 - Memory access scenarios

Purpose: cover LDA and STA with both register and immediate addressing styles.

| Addr | Assembly | Binary |
| --- | --- | --- |
| 00 | LDAT 0x04 | `0001 1000 0 1 000100` |
| 01 | STAT 0x10 | `0001 1001 0 1 010000` |
| 02 | LDAZ r9 | `0010 1000 1 0 001001` |
| 03 | STAN 0x08 | `0110 1001 0 1 001000` |

## Program 6 - Control flow and subroutine flow

Purpose: cover JRP, JRN, JPR, and CAL.

| Addr | Assembly | Binary |
| --- | --- | --- |
| 00 | JRPT r9 | `0100 1100 0 0 001001` |
| 01 | JRNT 0x02 | `0110 1101 0 1 000010` |
| 02 | JPRT r10 | `0001 1110 0 0 001010` |
| 03 | CALT 0x03 | `0001 1111 0 1 000011` |

## Program 7 - False-condition no-op test

Purpose: demonstrate that a false condition blocks execution regardless of opcode.

| Addr | Assembly | Binary |
| --- | --- | --- |
| 00 | ANDF r1 | `0000 0000 1 0 000001` |
| 01 | ORF 0x3F | `0000 0001 1 1 111111` |
| 02 | SUBF r2 | `0000 0101 1 0 000010` |
| 03 | STAF 0x20 | `0000 1001 0 1 100000` |

## Program 8 - Positive and negative condition coverage

Purpose: exercise P, NP, N, and NN.

| Addr | Assembly | Binary |
| --- | --- | --- |
| 00 | ADDP 0x01 | `0100 0100 1 1 000001` |
| 01 | ADDNP 0x01 | `0101 0100 1 1 000001` |
| 02 | ANDN r3 | `0110 0000 1 0 000011` |
| 03 | ANDNN r4 | `0111 0000 1 0 000100` |

## Program 9 - Carry and overflow condition coverage

Purpose: exercise C and NC with arithmetic and shifts.

| Addr | Assembly | Binary |
| --- | --- | --- |
| 00 | ADDC r5 | `1000 0100 1 0 000101` |
| 01 | ADDNC 0x04 | `1001 0100 1 1 000100` |
| 02 | LSLC 0x01 | `1000 0110 1 1 000001` |
| 03 | LSRNC 0x01 | `1001 0111 1 1 000001` |

## Program 10 - Full ISA sampler

Purpose: one compact sampler that touches every opcode again in a single sequence.

| Addr | Assembly | Binary |
| --- | --- | --- |
| 00 | ANDT r1 | `0001 0000 1 0 000001` |
| 01 | ORT r2 | `0001 0001 1 0 000010` |
| 02 | XORT 0x0F | `0001 0010 1 1 001111` |
| 03 | NOTT r3 | `0001 0011 1 0 000011` |
| 04 | ADDT r4 | `0001 0100 1 0 000100` |
| 05 | SUBT r5 | `0001 0101 1 0 000101` |
| 06 | LSLT 0x02 | `0001 0110 1 1 000010` |
| 07 | LSRT 0x01 | `0001 0111 1 1 000001` |
| 08 | LDAT 0x01 | `0001 1000 0 1 000001` |
| 09 | STAT 0x02 | `0001 1001 0 1 000010` |
| 0A | MTAT r6 | `0001 1010 1 0 000110` |
| 0B | MTRT r7 | `0001 1011 1 0 000111` |
| 0C | JRPT r8 | `0100 1100 0 0 001000` |
| 0D | JRNT r9 | `0110 1101 0 0 001001` |
| 0E | JPRT r10 | `0001 1110 0 0 001010` |
| 0F | CALT 0x04 | `0001 1111 0 1 000100` |

## Notes

- These examples are aligned with the current `isa_pkg.vhd` encodings.
- Immediate values are shown as 6-bit fields, so negative immediates should be encoded in two's complement.
- If you want, these programs can be turned into a ROM initialization file or a ModelSim test memory image next.