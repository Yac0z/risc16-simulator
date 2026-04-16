# Internal Signal Trace per Program Line

This file describes **internal CPU signals for every instruction line** in `assembly_programs_10.md`.

## Signal conventions used

- Instruction format: `cond op updt imm val`
- Fixed 5-state cycle per line: `FETCH1 -> FETCH2 -> DECODE -> EXEC -> STORE`
- In all lines:
  - `FETCH1`: `sel_ram_addr=0`, `ram_addr=PC` (instruction fetch address)
  - `FETCH2`: `instr_ce=1` (instruction latched)
  - `EXEC`: `pc_ce=1` (PC advances)
- If condition is false (`execute_en=0`): instruction side effects are blocked (except PC step in EXEC).

### Key control/data signals referenced

- `imm`: selects `op2` source (`0=Rx`, `1=immediate`)
- `ram_we`: memory write enable (active in EXEC for `STA` when condition true)
- `acc_ce/rx_ce/rpc_ce/pc_ce`: register write enables
- `sel_rf_din`: register-file write data source (`00=res_r`, `01=ram_dout`, `10=pc+1`)
- `ram_addr`: instruction fetch address in FETCH1, data address during memory op path

---

## Program 1 (addresses 00..03)

| Line | Instruction | Fetch RAM content | Internal signals (effective) | Data RAM address/content |
|---|---|---|---|---|
| 00 | `ANDT r1` | `RAM[00]=0001000010000001` | `imm=0 -> op2=R1`; STORE: `acc_ce=1`, `sel_rf_din=00` | none |
| 01 | `ORT 0x0F` | `RAM[01]=0001000111001111` | `imm=1 -> op2=0x000F`; STORE: `acc_ce=1`, `sel_rf_din=00` | none |
| 02 | `XORT r2` | `RAM[02]=0001001010000010` | `imm=0 -> op2=R2`; STORE: `acc_ce=1`, `sel_rf_din=00` | none |
| 03 | `NOTT r3` | `RAM[03]=0001001110000011` | `imm=0 -> op2=R3`; STORE: `acc_ce=1`, `sel_rf_din=00` | none |

## Program 2 (addresses 00..03)

| Line | Instruction | Fetch RAM content | Internal signals (effective) | Data RAM address/content |
|---|---|---|---|---|
| 00 | `ADDT r4` | `RAM[00]=0001010010000100` | `imm=0 -> op2=R4`; STORE: `acc_ce=1` | none |
| 01 | `SUBT 0x01` | `RAM[01]=0001010111000001` | `imm=1 -> op2=0x0001`; STORE: `acc_ce=1` | none |
| 02 | `LSLT 0x02` | `RAM[02]=0001011011000010` | `imm=1 -> shift=2`; STORE: `acc_ce=1` | none |
| 03 | `LSRT r5` | `RAM[03]=0001011110000101` | `imm=0 -> shift from R5`; STORE: `acc_ce=1` | none |

## Program 3 (addresses 00..03)

| Line | Instruction | Fetch RAM content | Internal signals (effective) | Data RAM address/content |
|---|---|---|---|---|
| 00 | `LDAT 0x08` | `RAM[00]=0001100001001000` | `imm=1`; STORE: `acc_ce=1`, `sel_rf_din=01` (load from RAM) | data read at address derived from ALU/op2 (typ. `0x0008`) |
| 01 | `STAT 0x10` | `RAM[01]=0001100101010000` | EXEC: `ram_we=1`; STORE: `rx_ce=1` (current control decode) | data write to address derived from ALU/op2 (typ. `0x0010`), content=`ACC` |
| 02 | `MTAT r6` | `RAM[02]=0001101010000110` | `imm=0 -> op2=R6`; STORE: `acc_ce=1` | none |
| 03 | `MTRT 0x05` | `RAM[03]=0001101111000101` | `imm=1 -> op2=0x0005`; STORE: `acc_ce=1` (per current control decode) | none |

## Program 4 (addresses 00..03)

| Line | Instruction | Fetch RAM content | Internal signals (effective) | Data RAM address/content |
|---|---|---|---|---|
| 00 | `JRPT r7` | `RAM[00]=0001110000000111` | STORE: `rx_ce=1` (per current control decode for `JRP`) | no RAM write; fetch RAM only |
| 01 | `JRNT 0x02` | `RAM[01]=0001110101000010` | STORE: `rx_ce=1` (per current control decode for `JRN`) | no RAM write; fetch RAM only |
| 02 | `JPRT r62` | `RAM[02]=0001111000111110` | STORE: `rx_ce=1` (per current control decode for `JPR`) | no RAM write; fetch RAM only |
| 03 | `CALT 0x04` | `RAM[03]=0001111101000100` | EXEC: `rpc_ce=1`; STORE: `pc_ce=1` | no RAM write; fetch RAM only |

## Program 5 (addresses 00..03)

| Line | Instruction | Fetch RAM content | Internal signals (effective) | Data RAM address/content |
|---|---|---|---|---|
| 00 | `ADDZ r1` | `RAM[00]=0010010010000001` | If `Z=1`: STORE `acc_ce=1`; else blocked | none |
| 01 | `SUBNZ 0x03` | `RAM[01]=0011010111000011` | If `Z=0`: STORE `acc_ce=1`; else blocked | none |
| 02 | `ANDP r2` | `RAM[02]=0100000010000010` | If `Z=0,N=0`: STORE `acc_ce=1`; else blocked | none |
| 03 | `ORNP 0x3F` | `RAM[03]=0101000111111111` | If `Z=1 or N=1`: STORE `acc_ce=1`; else blocked | none |

## Program 6 (addresses 00..03)

| Line | Instruction | Fetch RAM content | Internal signals (effective) | Data RAM address/content |
|---|---|---|---|---|
| 00 | `XORN r3` | `RAM[00]=0110001010000011` | If `N=1`: STORE `acc_ce=1`; else blocked | none |
| 01 | `NOTNN r4` | `RAM[01]=0111001110000100` | If `N=0`: STORE `acc_ce=1`; else blocked | none |
| 02 | `ADDC 0x01` | `RAM[02]=1000010011000001` | If `C=1`: STORE `acc_ce=1`; else blocked | none |
| 03 | `SUBNC r5` | `RAM[03]=1001010110000101` | If `C=0`: STORE `acc_ce=1`; else blocked | none |

## Program 7 (addresses 00..03)

| Line | Instruction | Fetch RAM content | Internal signals (effective) | Data RAM address/content |
|---|---|---|---|---|
| 00 | `LSLV 0x01` | `RAM[00]=1010011011000001` | If `V=1`: STORE `acc_ce=1`; else blocked | none |
| 01 | `LSRNV 0x01` | `RAM[01]=1011011111000001` | If `V=0`: STORE `acc_ce=1`; else blocked | none |
| 02 | `LDAF 0x04` | `RAM[02]=0000100001000100` | `COND=F` -> blocked side effects | no data read committed |
| 03 | `STAF r6` | `RAM[03]=0000100100000110` | `COND=F` -> `ram_we=0`, store blocked | no data write |

## Program 8 (addresses 00..03)

| Line | Instruction | Fetch RAM content | Internal signals (effective) | Data RAM address/content |
|---|---|---|---|---|
| 00 | `CALT 0x06` | `RAM[00]=0001111101000110` | EXEC: `rpc_ce=1` stores return; STORE: `pc_ce=1` | no RAM write |
| 01 | `MTAT r10` | `RAM[01]=0001101010001010` | `imm=0`; STORE: `acc_ce=1` | none |
| 02 | `JRPT r10` | `RAM[02]=0001110000001010` | STORE: `rx_ce=1` (current control decode) | no RAM write |
| 03 | `JPRT r62` | `RAM[03]=0001111000111110` | Uses `val=111110` (RPC register index) | no RAM write |

## Program 9 (addresses 00..03)

| Line | Instruction | Fetch RAM content | Internal signals (effective) | Data RAM address/content |
|---|---|---|---|---|
| 00 | `MTAT 0x1E` | `RAM[00]=0001101011011110` | `imm=1 -> op2=0x001E`; STORE: `acc_ce=1` | none |
| 01 | `MTRT r12` | `RAM[01]=0001101110001100` | `imm=0 -> op2=R12`; STORE: `acc_ce=1` (current decode) | none |
| 02 | `STAT r12` | `RAM[02]=0001100100001100` | EXEC: `ram_we=1`; STORE: `rx_ce=1` | data write at address derived from ALU/op2 (typ. R12), content=`ACC` |
| 03 | `LDAT r12` | `RAM[03]=0001100000001100` | STORE: `acc_ce=1`, `sel_rf_din=01` | data read at address derived from ALU/op2 (typ. R12) |

## Program 10 (addresses 00..03)

| Line | Instruction | Fetch RAM content | Internal signals (effective) | Data RAM address/content |
|---|---|---|---|---|
| 00 | `ANDT 0x15` | `RAM[00]=0001000011010101` | `imm=1 -> op2=0x0015`; STORE: `acc_ce=1` | none |
| 01 | `XORT 0x2A` | `RAM[01]=0001001011101010` | `imm=1 -> op2=0x002A`; STORE: `acc_ce=1` | none |
| 02 | `ADDT 0x3F` | `RAM[02]=0001010011111111` | `imm=1 -> op2=0x003F`; STORE: `acc_ce=1` | none |
| 03 | `JRNZ 0x01` | `RAM[03]=0010110101000001` | If `Z=0`: STORE side active for `JRN` (`rx_ce=1` in current decode) | no RAM write |

---

## RPC-focused line-level example

| Line | Instruction | Fetch RAM content | Internal signals | RAM usage |
|---|---|---|---|---|
| 00 | `CALT 0x08` | `RAM[00]=0001111101001000` | EXEC: `rpc_ce=1` (writes return PC to `R62`); STORE: `pc_ce=1` | instruction fetch only |
| 01 | `JPRT r62` | `RAM[01]=0001111000111110` | `val=111110` selects `R62` (RPC) as operand/register index | instruction fetch only |

