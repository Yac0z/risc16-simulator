# Coding Patterns

1. **Layer Boundaries**
Policy: Keep architecture split into instruction path, datapath, and control path. `control_unit` decides enables/selects; `alu` computes only; `cpu_top` wires only.

Bad example:
```vhdl
-- control logic embedded in ALU (forbidden)
if opcode = "1010" then
  pc_ce <= '1';
end if;
```
Good example:
```vhdl
-- ALU computes only
result_o <= std_logic_vector(signed(op1_i) + signed(op2_i));
-- control_unit drives pc_ce separately
```
Enforcement: Refuse PRs where ALU writes control signals or top-level performs ALU operations.

2. **Single Responsibility**
Policy: One process, one role. Keep combinational decode blocks focused and under about 40 lines before splitting.

Bad example:
```vhdl
process(all)
begin
  -- decode + ALU + register write + memory write mixed together
end process;
```
Good example:
```vhdl
process(state_r, instr_i, flags_i)
begin
  -- decode control outputs only
end process;
```
Enforcement: Request refactor when a process mixes decode, arithmetic, and storage side effects.

3. **Naming Conventions**
Policy: Use explicit signal naming and avoid ambiguous names (`data`, `info`, `result`, `temp`, `obj`, `thing`).

| Construct | Convention | Example |
|---|---|---|
| Entity | snake_case with role | `control_unit` |
| Architecture | `rtl` for synthesizable code | `architecture rtl of alu is` |
| Signals | suffix with type/intent | `state_r`, `next_state`, `alu_result_s` |
| Clock enable | `*_ce` | `pc_ce` |
| Select lines | `sel_*` | `sel_rf_din` |
| Constants | `UPPER_SNAKE_CASE` | `WORD_WIDTH` |
| Testbench entity | `tb_<unit>` | `tb_alu` |
| Packages | `<domain>_pkg` | `isa_pkg` |

Bad example:
```vhdl
signal temp : std_logic_vector(15 downto 0);
```
Good example:
```vhdl
signal alu_result_s : std_logic_vector(15 downto 0);
```
Enforcement: Rename unclear identifiers before merge.

4. **Numeric Types and Casting**
Policy: Use `numeric_std` with explicit `signed`/`unsigned` casts.

Bad example:
```vhdl
use ieee.std_logic_unsigned.all;
acc_o <= op1_i + op2_i;
```
Good example:
```vhdl
use ieee.numeric_std.all;
acc_o <= std_logic_vector(signed(op1_i) + signed(op2_i));
```
Enforcement: Block use of non-standard arithmetic packages.

5. **Sequential vs Combinational Discipline**
Policy: Sequential logic uses `rising_edge(clk)`; combinational logic has complete defaults to avoid latches.

Bad example:
```vhdl
process(all)
begin
  if sel = '1' then
    y <= a;
  end if;
end process;
```
Good example:
```vhdl
process(all)
begin
  y <= b;
  if sel = '1' then
    y <= a;
  end if;
end process;
```
Enforcement: Reject inferred latch patterns unless explicitly justified.

6. **Reset and Startup State**
Policy: On reset, initialize state machine deterministically and set PC to zero.

Bad example:
```vhdl
if rst = '1' then
  null;
end if;
```
Good example:
```vhdl
if rst = '1' then
  state_r <= FETCH1;
  regs(63) <= (others => '0');
end if;
```
Enforcement: Require explicit reset assignments for state and architectural registers.

7. **ISA Decode Centralization**
Policy: Decode field extraction (`cond`, `op`, `updt`, `imm`, `val`) must be centralized in package/functions or a single decode block.

Bad example:
```vhdl
if instr_i(11 downto 8) = "0011" then ...
-- repeated across files
```
Good example:
```vhdl
opcode <= instr_i(11 downto 8);
imm    <= instr_i(6);
```
Enforcement: Consolidate duplicated magic bit slicing into reusable helpers.

8. **Flag Update Rules**
Policy: Apply ISA-specific flag rules exactly, especially partial updates for logical ops and carry semantics for shifts.

Bad example:
```vhdl
z_o <= '0'; n_o <= '0'; c_o <= '0'; v_o <= '0';
```
Good example:
```vhdl
-- for logical ops, keep carry/overflow unchanged unless ISA says otherwise
z_o <= '1' when result = x"0000" else '0';
n_o <= result(15);
```
Enforcement: Require per-opcode flag behavior tests before accepting ALU changes.

9. **Testbench Structure**
Policy: Every unit testbench follows Arrange/Act/Assert style with one behavioral expectation per check.

Bad example:
```vhdl
-- many operations, no explicit expected assertions
```
Good example:
```vhdl
-- Arrange
op_sel <= OP_ADD; op1 <= x"0001"; op2 <= x"0001";
-- Act
wait for 10 ns;
-- Assert
assert result = x"0002" report "ADD failed" severity error;
```
Enforcement: Request test split when a single testbench sequence verifies unrelated behaviors without clear assertions.

10. **No Silent ISA Assumptions**
Policy: If opcode/condition mapping is uncertain, mark it and gate integration until verified from source spec.

Bad example:
```vhdl
constant OP_CAL : std_logic_vector(3 downto 0) := "1111"; -- guessed silently
```
Good example:
```vhdl
constant OP_CAL : std_logic_vector(3 downto 0) := "1111"; -- verify against Table 1
```
Enforcement: Treat unverified encodings as blockers for final integration tests.
