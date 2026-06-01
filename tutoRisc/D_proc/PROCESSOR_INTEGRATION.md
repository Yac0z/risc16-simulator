# Processor Integration Notes (`tutoRisc/D_proc`)

## What was done

The processor top-level in `proc.vhd` was converted from an empty architecture into a wired structural implementation compatible with `proc_test.vhd`.

Integration was performed **only in a `.vhd` file**:

- `tutoRisc/D_proc/proc.vhd`

No `.sws`, `.sym`, or other project metadata files were modified.

## Structural changes made

### 1. Added internal processor wiring in `proc.vhd`

New internal signals were introduced to connect instruction decode, control, datapath, ALU, and memory interface:

- Instruction fields: `instr_cond_s`, `instr_op_s`, `instr_updt_s`, `instr_imm_s`, `instr_val_s`
- Status/flags: `status_s`, `flags_s`
- Register outputs: `acc_s`, `pc_s`, `rx_s`
- Datapath registers: `op1_r`, `op2_r`, `res_r`
- ALU output: `alu_res_s`
- Control enables: `instr_ce_s`, `status_ce_s`, `acc_ce_s`, `pc_ce_s`, `rpc_ce_s`, `rx_ce_s`
- Select signals: `sel_ram_s`, `sel_op1_s`, `sel_rf_din_s`
- Mux/utility signals: `rf_din_s`, `pc_plus_1_s`

### 2. Instantiated tutorial dummy blocks

The following components are now instantiated and connected:

- `instr_reg_dummy`
- `status_reg_dummy`
- `reg_file_dummy`
- `alu_dummy`
- `control_dummy`

### 3. Implemented datapath sequencing

A clocked process was added to latch pipeline-style values:

- `op1_r` selected from accumulator or PC (`sel_op1_s`)
- `op2_r` selected from register or immediate (`instr_imm_s`)
- `res_r` loaded from ALU result

Reset behavior initializes these registers to zero.

### 4. Implemented key mux logic

- `pc_plus_1_s <= pc_s + X"0001"`
- Register file input (`rf_din_s`) selected as:
  - `"00"` → `res_r`
  - `"01"` → `ram_dout`
  - others (used as `"10"`) → `pc_plus_1_s`

### 5. Connected memory interface outputs

- `ram_addr <= pc_s` when `sel_ram_s='0'`, else `op2_r`
- `ram_din  <= acc_s`
- `ram_we` driven by `control_dummy`

## Why this fixes testbench integration

`proc_test.vhd` expects the `proc` entity to expose meaningful RAM/control behavior over time.  
Before this change, `proc.vhd` architecture was empty; now it has the required control/datapath interconnect and output behavior expected by the testbench stimulus and checks.

## Validation status

Simulation execution could not be run in this environment because `ghdl` is not installed (`GHDL_NOT_FOUND`).
