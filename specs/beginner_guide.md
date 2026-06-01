# Beginner Guide to the Processeur RISC Project

This project is a 16-bit RISC processor written in VHDL. The goal is to understand three things:

1. What an instruction looks like in the ISA.
2. How each VHDL file maps to one hardware block.
3. How those blocks are linked together into a working CPU.

## 1. Where to Start

If you are new to the project, read the files in this order:

1. [processeur/src/rtl/isa_pkg.vhd](../processeur/src/rtl/isa_pkg.vhd)
2. [processeur/src/rtl/register_file.vhd](../processeur/src/rtl/register_file.vhd)
3. [processeur/src/rtl/alu.vhd](../processeur/src/rtl/alu.vhd)
4. [processeur/src/rtl/control_unit.vhd](../processeur/src/rtl/control_unit.vhd)
5. [processeur/src/rtl/cpu_top.vhd](../processeur/src/rtl/cpu_top.vhd)
6. [processeur/src/rtl/basys3_top.vhd](../processeur/src/rtl/basys3_top.vhd)
7. [specs/assembly_programs.md](assembly_programs.md)

That order follows the hardware flow from the ISA definition to the board wrapper.

## 2. What Each File Does

### `isa_pkg.vhd`
This is the ISA reference file.
It defines:

- the instruction bit layout,
- the condition codes,
- the opcode values,
- helper functions like sign extension and condition checking,
- the 5 CPU states: `FETCH1`, `FETCH2`, `DECODE`, `EXEC`, `STORE`.

If you want to know what a bit means, start here.

### `register_file.vhd`
This file implements the 64 registers of the processor.
Important special registers:

- `R0` = `ACC`
- `R62` = `RPC`
- `R63` = `PC`

This block stores and outputs the architectural registers.

### `alu.vhd`
This file performs arithmetic and logic:

- `AND`, `OR`, `XOR`, `NOT`
- `ADD`, `SUB`
- `LSL`, `LSR`
- transfer-style operations that move data through the ALU path

It also computes flags `Z`, `N`, `C`, and `V`.

### `control_unit.vhd`
This is the FSM controller.
It decides, cycle by cycle:

- when to fetch an instruction,
- when to decode operands,
- when to execute the ALU,
- when to write back results,
- when memory should be read or written.

It does not do arithmetic itself. It only emits control signals.

### `cpu_top.vhd`
This is the core processor wiring.
It connects:

- instruction register,
- status register,
- register file,
- ALU,
- control unit,
- memory bus signals.

Think of it as the CPU "inside the chip".

### `ram.vhd`
This is the reusable memory block.
It matches the processor bus and can be used in simulation or on the FPGA.

### `basys3_top.vhd`
This is the board wrapper for the Basys3.
It connects real board signals to the CPU:

- 100 MHz clock,
- reset button,
- switches,
- LEDs.

It also instantiates the RAM and slows the board clock down so the CPU is observable on the board.

## 3. How the Files Connect

A simplified signal flow is:

1. The board clock enters `basys3_top.vhd`.
2. `basys3_top.vhd` instantiates `ram.vhd` and `cpu_top.vhd`.
3. `cpu_top.vhd` instantiates `control_unit.vhd`, `alu.vhd`, `register_file.vhd`, `instr_reg.vhd`, and `status_reg.vhd`.
4. `control_unit.vhd` decides what should happen in each CPU state.
5. `register_file.vhd` provides the operands.
6. `alu.vhd` computes the result and flags.
7. The result is written back into the register file or memory.

So the project is layered like this:

- ISA definition: `isa_pkg.vhd`
- CPU datapath and control: `cpu_top.vhd`
- Board integration: `basys3_top.vhd`
- Memory: `ram.vhd`

## 4. How to Read an Instruction

The 16-bit instruction is split like this:

- `cond[15:12]`: execution condition
- `op[11:8]`: opcode
- `updt[7]`: update flags or not
- `imm[6]`: operand mode
- `val[5:0]`: register number or immediate value

Example:

`ANDT r1`

Means:

- `cond = T = 0001`
- `op = AND = 0000`
- `updt = 1` or `0` depending on the exact syntax used in the program file
- `imm = 0` because `r1` is a register
- `val = 000001`

So the binary word is built by concatenating those fields in that order.

## 5. How One Instruction Moves Through the CPU

Take a simple instruction like `ADDT r4`.

1. `FETCH1`: the PC is used as the memory address.
2. `FETCH2`: the instruction is loaded into the instruction register.
3. `DECODE`: the CPU extracts `cond`, `op`, `updt`, `imm`, and `val`.
4. `EXEC`: the ALU prepares the result and the PC advances.
5. `STORE`: the result is written back if the condition is true.

That 5-state cycle is fixed for every instruction.

## 5B. The FSM State Machine and Component Activation

The CPU behavior is controlled by a **Finite State Machine (FSM)** in the `control_unit.vhd` file.
This FSM has exactly 5 states, and in each state, different hardware components are "activated" by setting control signals.

### Understanding Control Signals

Control signals are clock-enable lines (`*_ce_o`) and multiplexer selectors (`sel_*`) that activate specific hardware components:

- `instr_ce_o`: clock enable for the **instruction register** → freezes or updates the instruction
- `acc_ce_o`: clock enable for `R0` (accumulator) → saves ALU results to R0
- `pc_ce_o`: clock enable for `R63` (program counter) → advances PC or jumps
- `rpc_ce_o`: clock enable for `R62` (return PC) → saves return address for function calls
- `rx_ce_o`: clock enable for general registers → writes to R1...R61
- `ram_we_o`: **RAM write enable** → allows memory stores
- `sel_ram_addr`: mux selector for RAM address → chooses between PC (fetching) and register (memory op)
- `sel_op1`: mux selector for ALU operand 1
- `sel_rf_din`: mux selector for register file input → chooses data source: ALU result, RAM data, or PC+1

The control unit also evaluates `execute_en_s`, a flag that says "is the condition true?"
If the condition is false, most component activations are inhibited, so the instruction is skipped.

### State-by-State Breakdown

#### **FETCH1**

**Goal**: Set up the memory address bus to fetch the next instruction.

**Components activated:**
- None. This state only prepares the address.

**Control signals set:**
- `sel_ram_addr <= '0'` → RAM address comes from the **PC**, not from a register

**What happens:**
- The PC (stored in R63) drives the RAM address lines.
- The RAM responds by placing the instruction data on its output bus.
- No clock enable is set, so nothing is stored yet; we are just looking at the instruction.

**Hardware flow:**
```
PC from R63 → RAM address mux → RAM address port
            ↓ (combinational)
         RAM data output ← ready for FETCH2 to capture
```

#### **FETCH2**

**Goal**: Capture the instruction into the instruction register.

**Components activated:**
- **Instruction Register** (via `instr_ce_o`)

**Control signals set:**
- `instr_ce_o <= '1'` → clock enable the instruction register

**What happens:**
- On the rising clock edge, the instruction data (from the RAM) is latched into `instr_r` inside `instr_reg.vhd`.
- This freezes the instruction for the rest of the cycle, even if the RAM output changes.
- The instruction now has stable 16-bit fields: `cond`, `op`, `updt`, `imm`, `val`.

**Hardware flow:**
```
RAM output bus ← (instruction from memory)
              ↓
      Instruction Register ← captures on clock edge (FETCH2 → FETCH3)
              ↓
      Instruction fields (cond, op, imm, val) now stable
```

#### **DECODE**

**Goal**: Extract operands from the register file.

**Components activated:**
- None explicitly; this is a passive state.

**Control signals set:**
- All set to `'0'`, so nothing is written.

**What happens:**
- The control unit is idle in this state.
- However, the **register file** is always reading combinationally in the background.
- Based on the `val` field of the instruction, the register file outputs the selected register values to the ALU input ports.
- The ALU also sets up its operands based on the `imm` bit:
  - If `imm = 0`, use register value.
  - If `imm = 1`, use the sign-extended `val` as a 6-bit immediate.
- The ALU does **not** compute yet because `execute_en_s` has not triggered the data capture.

**Hardware flow:**
```
Instruction (instr_r) → register_file address ports
                    ↓ (combinational read)
Register outputs (operand1, operand2) → ALU input mux
                                    ↓
                            ALU (ready, not computing)
```

#### **EXEC**

**Goal**: Execute the ALU operation and if it is a branch, compute the new PC.

**Components activated:**
- **Register File** (PC only, via `pc_ce_o`) 
- **Operand Register** (latches ALU operands via registered logic)
- **Result Register** (latches ALU result via registered logic)

**Control signals set (always active):**
- `pc_ce_o <= '1'` → the PC is **always** updated here

**Conditional control signals (if `execute_en_s = '1'`, meaning the condition is true):**
- `ram_we_o <= '1'` (if `op == OP_STA`) → enable memory write for store operations
- `rpc_ce_o <= '1'` (if `op == OP_CAL`) → save return address to R62 for function calls

**What happens:**
1. The ALU computes the result and flags.
2. The operand registers (`op1_r` and `op2_r` in `cpu_top.vhd`) capture the ALU inputs to ensure stable operands.
3. The result register (`res_r` in `cpu_top.vhd`) captures the ALU output.
4. The PC is **always** incremented by 1 and stored back to R63 (this is unconditional).
5. If the instruction is a `STA` (store to memory) and the condition is true, the RAM write line goes active.
6. If the instruction is a `CAL` (call/function) and the condition is true, the return PC is saved.

**Critical point:** The PC advances in EXEC regardless of instruction type or condition.  
Branch instructions that want to jump to a different address will override the PC in the STORE state.

**Hardware flow:**
```
ALU computes result & flags
        ↓
result_r ← ALU result
        ↓
PC + 1 ← (default next PC)
        ↓
PC_ce = '1' → R63 (PC) = PC + 1 (on clock edge EXEC → STORE)
        ↓
If condition true AND op == STA:
        ↓
    ram_we_o = '1' → allow memory write
```

#### **STORE**

**Goal**: Write back the result to the register file or memory.

**Components activated:**
Multiple possible pathways depending on instruction type and condition:

**1. Accumulator write** (`acc_ce_o` if condition is true):
- Activated if: `op ∈ {MTA, MTR, LDA, ADD, SUB, AND, OR, XOR, NOT, LSL, LSR}`
- Writes the ALU result to `R0` (the accumulator)
- Special case: if `op == LDA`, the register file input is routed to the **RAM data bus** instead of the ALU result

**2. General register write** (`rx_ce_o` if condition is true):
- Activated if: `op ∈ {STA, JRP, JRN, JPR}`
- Writes to registers R1...R61 (determined by the `val` field)

**3. Special PC override** (`pc_ce_o` if condition is true):
- Activated if: `op == CAL` and condition is true
- Overrides the PC increment from EXEC with a branch target from a register

**Control signals set (unless condition is false):**
- `sel_rf_din`: mux selector determines where register input comes from:
  - `'0'`: ALU result (`res_r`)
  - `'1'`: RAM data bus (for `LDA` loads from memory)

**What happens:**
1. Based on the opcode and condition, the control unit selects which register to write and where data comes from.
2. If `sel_rf_din = '1'` (for `LDA`), the register file input is connected to the RAM data bus, so the loaded value is written to R0.
3. If the condition is true, the selected register is clocked and updated.
4. If the condition is false, no registers are clocked, so the instruction has no effect.

**Hardware flow for common cases:**

**ADD (Arithmetic):**
```
ALU result (res_r) → register file input
                 ↓
            acc_ce_o = '1' → R0 updated on clock edge
```

**LDA (Load from memory):**
```
RAM data bus → register file input (via sel_rf_din = '1')
            ↓
       acc_ce_o = '1' → R0 updated on clock edge
```

**JRP (Jump Register, Relative Positive):**
```
ALU computed new PC → register file input
                   ↓
              rx_ce_o = '1' → R<val> (Rx) updated on clock edge
```

**STA (Store to memory):**
```
ALU result (address) → register file input
                     ↓
                rx_ce_o = '1' → R<val> (Rx) updated
    (Memory write already happened in EXEC, data was put on bus)
```

### Complete Instruction Example: `ADDT r1`

Let's trace `ADDT r1` (Add to R1 if True) through all 5 states:

**FETCH1:**
- Control: `sel_ram_addr = '0'`
- PC (in R63) drives RAM address
- RAM data appears on output bus

**FETCH2:**
- Control: `instr_ce_o = '1'`
- Instruction is captured: `0001_0100_?_0_000001` (True + ADD + ? + register + R1)
- Fields locked: `cond=T`, `op=ADD`, `val=000001` (R1)

**DECODE:**
- Control: all zero
- Register file reads R1 and R0 (via `val` field)
- ALU is ready to compute

**EXEC:**
- Control: `pc_ce_o = '1'`
- ALU computes operand1 + operand2
- Result register captures: ALU output
- PC increments: R63 ← R63 + 1 (PC + 1)
- Flags computed by ALU (Z, N, C, V)

**STORE:**
- Condition check: `cond_is_true(T, status)` → returns `'1'` (always execute)
- Control: `acc_ce_o = '1'`
- Register writeback: R1 ← result_r (the addition result)
- Next cycle: FETCH1 →  FETCH2 →  DECODE →  EXEC →  STORE → (back to FETCH1)

### Why Component Activation Matters

By activating different components in different states:
- **FETCH states** create a stable instruction in the register
- **DECODE** prepares the operands combintionally
- **EXEC** does the math and moves PC forward
- **STORE** writes the result back

This separation ensures that:
- Each stage has time to settle before the next stage latches data
- Control signals do not change during a clock cycle (avoiding metastability)
- Different instruction types can reuse the same states by selecting different write paths

## 7. How the ISA Affects the Hardware

The ISA controls the hardware in three main ways:

- `cond` decides whether the instruction is allowed to execute.
- `op` chooses the ALU operation or control-flow action.
- `imm` decides whether `val` is a register number or an immediate constant.

The `updt` bit matters because it tells the status register whether the ALU flags should be stored.

## 8. How to Use the Example Programs

The file [specs/assembly_programs.md](assembly_programs.md) gives 10 example programs.
Each one is designed to cover a different part of the ISA:

- logical operations,
- arithmetic,
- shifts,
- move/transfer instructions,
- memory access,
- branching and call instructions,
- false-condition tests,
- signed condition tests,
- carry/overflow tests,
- a full ISA sampler.

If you are learning the project, read those examples after `isa_pkg.vhd`.

## 9. Practical Reading Tips

- Start from the package, not from the board wrapper.
- Follow the signals: instruction -> decode -> ALU -> register file -> memory.
- When you see a signal named `*_ce`, it is a clock enable.
- When you see `sel_*`, it is a mux select line.
- When you see `R0`, `R62`, or `R63`, those are not normal registers.

## 10. Minimal Mental Model

If you only remember one thing, remember this:

- `isa_pkg.vhd` says what the ISA means.
- `control_unit.vhd` decides what should happen.
- `alu.vhd` computes.
- `register_file.vhd` stores the architectural state.
- `cpu_top.vhd` connects everything.
- `basys3_top.vhd` adapts the CPU to the Basys3 board.

That is the whole project structure in one chain.
