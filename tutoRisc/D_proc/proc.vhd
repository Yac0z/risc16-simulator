-------------------------------------------------------------------------------
-- Top-level processor component used by the D_proc tutorial testbench.
--
-- Ports:
--   - clk [in]  : clock signal driving sequential logic
--   - rst [in]  : reset signal used to clear staged datapath registers
--
--   - ram_addr [out] : memory address bus
--   - ram_din  [out] : memory write-data bus
--   - ram_dout [in]  : memory read-data bus
--   - ram_we   [out] : memory write-enable bus
-------------------------------------------------------------------------------

-- Import IEEE library namespace so standard logic packages can be referenced.
library ieee;
-- Import std_logic/std_logic_vector types used for ports and signals.
use ieee.std_logic_1164.all;
-- Import unsigned-style vector arithmetic used in this tutorial file.
use ieee.std_logic_unsigned.all;

-- Declare the processor entity that the testbench instantiates.
entity proc is
  -- Declare all top-level external ports exposed by the processor.
  port ( clk : in  std_logic;
         -- Clock input for all synchronous updates in this top-level integration.
         rst : in  std_logic;
         -- Active-high reset input for staged registers.
         
         ram_addr : out std_logic_vector(15 downto 0);
         -- Output address sent toward RAM (instruction fetch or data address).
         ram_din  : out std_logic_vector(15 downto 0);
         -- Output write-data sent toward RAM during store.
         ram_dout : in  std_logic_vector(15 downto 0);
         -- Input read-data returning from RAM.
         ram_we   : out std_logic );
         -- Output write-enable controlling RAM writes.
end entity;

-- Start structural architecture where dummy blocks are wired together.
architecture arch of proc is
  -- Declare instruction-register component interface used by this architecture.
  component instr_reg_dummy is
    -- List instruction register ports exactly as expected by the testbench library.
    port ( clk : in  std_logic;
           -- Clock input for instruction register storage.
           ce  : in  std_logic;
           -- Clock-enable deciding when a new instruction is latched.
           rst : in  std_logic;
           -- Reset input for instruction register.

           instr : in  std_logic_vector(15 downto 0);
           -- Instruction word input, typically from RAM read data.
           cond  : out std_logic_vector(3 downto 0);
           -- Decoded condition field output.
           op    : out std_logic_vector(3 downto 0);
           -- Decoded opcode field output.
           updt  : out std_logic;
           -- Decoded update-flags bit output.
           imm   : out std_logic;
           -- Decoded immediate/register mode bit output.
           val   : out std_logic_vector(5 downto 0) );
           -- Decoded low field output (register index or immediate payload).
  end component;

  -- Declare status-register component interface.
  component status_reg_dummy is
    -- Status register ports for flags storage.
    port ( clk : in  std_logic;
           -- Clock input for status register.
           ce  : in  std_logic;
           -- Clock-enable for status updates.
           rst : in  std_logic;
           -- Reset input for status register.

           i : in  std_logic_vector(3 downto 0);
           -- Flags candidate input from ALU.
           o : out std_logic_vector(3 downto 0) );
           -- Latched flags output toward control.
  end component;

  -- Declare register-file component interface.
  component reg_file_dummy is
    -- Register-file ports exposing ACC/PC plus general register path.
    port ( clk : in  std_logic;
           -- Clock input for register writes.
           rst : in  std_logic;
           -- Reset input for register file.

           acc_out : out std_logic_vector(15 downto 0);
           -- Accumulator read output (R0).
           acc_ce  : in  std_logic;
           -- Accumulator write-enable.

           pc_out : out std_logic_vector(15 downto 0);
           -- Program-counter read output (R63).
           pc_ce  : in  std_logic;
           -- Program-counter write-enable.
           rpc_ce : in  std_logic;
           -- Return-PC write-enable (R62).

           rx_num : in  std_logic_vector(5 downto 0);
           -- Selected general register index.
           rx_out : out std_logic_vector(15 downto 0);
           -- Selected general register read output.
           rx_ce  : in  std_logic;
           -- Selected general register write-enable.

           din : in  std_logic_vector(15 downto 0) );
           -- Common write-data input for enabled destination register.
  end component;

  -- Declare ALU component interface.
  component alu_dummy is
    -- ALU ports for operation selection and operand/result exchange.
    port ( op : in  std_logic_vector(3 downto 0);
           -- ALU opcode selector.
           i1 : in  std_logic_vector(15 downto 0);
           -- ALU operand 1 input.
           i2 : in  std_logic_vector(15 downto 0);
           -- ALU operand 2 input.
           o  : out std_logic_vector(15 downto 0);
           -- ALU result output.
           st : out std_logic_vector(3 downto 0) );
           -- ALU status flags output.
  end component;

  -- Declare control-unit component interface.
  component control_dummy is
    -- Control-unit ports generating enables and mux selects.
    port ( clk : in  std_logic;
           -- Control-unit clock input.
           rst : in  std_logic;
           -- Control-unit reset input.

           status     : in  std_logic_vector(3 downto 0);
           -- Current status flags input for conditional execution.
           instr_cond : in  std_logic_vector(3 downto 0);
           -- Instruction condition field input.
           instr_op   : in  std_logic_vector(3 downto 0);
           -- Instruction opcode field input.
           instr_updt : in  std_logic;
           -- Instruction update-flags bit input.

           instr_ce  : out std_logic;
           -- Output enable for instruction register.
           status_ce : out std_logic;
           -- Output enable for status register.
           acc_ce    : out std_logic;
           -- Output enable for accumulator write.
           pc_ce     : out std_logic;
           -- Output enable for program-counter write.
           rpc_ce    : out std_logic;
           -- Output enable for return-PC write.
           rx_ce     : out std_logic;
           -- Output enable for selected general register write.

           ram_we : out std_logic;
           -- Output memory write-enable control.

           sel_ram_addr : out std_logic;
           -- Output select deciding RAM address source.
           sel_op1      : out std_logic;
           -- Output select deciding ALU operand1 source.
           sel_rf_din   : out std_logic_vector(1 downto 0) );
           -- Output select deciding register-file input source.
  end component;

  -- Internal signal carrying decoded instruction condition bits.
  signal instr_cond_s : std_logic_vector(3 downto 0);
  -- Internal signal carrying decoded instruction opcode bits.
  signal instr_op_s   : std_logic_vector(3 downto 0);
  -- Internal signal carrying decoded instruction update bit.
  signal instr_updt_s : std_logic;
  -- Internal signal carrying decoded immediate/register mode bit.
  signal instr_imm_s  : std_logic;
  -- Internal signal carrying decoded val field (reg/immediate).
  signal instr_val_s  : std_logic_vector(5 downto 0);

  -- Internal signal carrying currently latched status flags.
  signal status_s     : std_logic_vector(3 downto 0);
  -- Internal signal carrying ALU-generated flags before latching.
  signal flags_s      : std_logic_vector(3 downto 0);

  -- Internal signal exposing accumulator value from register file.
  signal acc_s        : std_logic_vector(15 downto 0);
  -- Internal signal exposing PC value from register file.
  signal pc_s         : std_logic_vector(15 downto 0);
  -- Internal signal exposing selected general register value.
  signal rx_s         : std_logic_vector(15 downto 0);

  -- Internal staged register for ALU operand 1.
  signal op1_r        : std_logic_vector(15 downto 0);
  -- Internal staged register for ALU operand 2.
  signal op2_r        : std_logic_vector(15 downto 0);
  -- Internal staged register for ALU result.
  signal res_r        : std_logic_vector(15 downto 0);
  -- Internal combinational ALU result signal.
  signal alu_res_s    : std_logic_vector(15 downto 0);

  -- Internal control-enable for instruction register.
  signal instr_ce_s   : std_logic;
  -- Internal control-enable for status register.
  signal status_ce_s  : std_logic;
  -- Internal control-enable for accumulator update.
  signal acc_ce_s     : std_logic;
  -- Internal control-enable for PC update.
  signal pc_ce_s      : std_logic;
  -- Internal control-enable for RPC update.
  signal rpc_ce_s     : std_logic;
  -- Internal control-enable for selected register update.
  signal rx_ce_s      : std_logic;

  -- Internal mux-select choosing RAM address source.
  signal sel_ram_s    : std_logic;
  -- Internal mux-select choosing ALU operand1 source.
  signal sel_op1_s    : std_logic;
  -- Internal mux-select choosing register-file input source.
  signal sel_rf_din_s : std_logic_vector(1 downto 0);

  -- Internal signal carrying selected writeback data into register file.
  signal rf_din_s     : std_logic_vector(15 downto 0);
  -- Internal signal carrying PC incremented by one.
  signal pc_plus_1_s  : std_logic_vector(15 downto 0);
begin
  -- Instantiate instruction register and wire decode outputs.
  u_ir : instr_reg_dummy
    port map (
      clk   => clk,
      -- Feed global clock into instruction register.
      ce    => instr_ce_s,
      -- Feed control-generated capture enable into instruction register.
      rst   => rst,
      -- Feed global reset into instruction register.
      instr => ram_dout,
      -- Feed memory output into instruction register input.
      cond  => instr_cond_s,
      -- Route decoded cond bits to internal signal.
      op    => instr_op_s,
      -- Route decoded opcode bits to internal signal.
      updt  => instr_updt_s,
      -- Route decoded update bit to internal signal.
      imm   => instr_imm_s,
      -- Route decoded immediate bit to internal signal.
      val   => instr_val_s
      -- Route decoded value field to internal signal.
    );

  -- Instantiate status register and wire ALU flags path.
  u_sr : status_reg_dummy
    port map (
      clk => clk,
      -- Feed global clock into status register.
      ce  => status_ce_s,
      -- Feed control-generated status write enable.
      rst => rst,
      -- Feed global reset into status register.
      i   => flags_s,
      -- Provide ALU-generated flags as candidate status.
      o   => status_s
      -- Expose latched status flags internally.
    );

  -- Instantiate register file and wire data/control paths.
  u_rf : reg_file_dummy
    port map (
      clk     => clk,
      -- Feed global clock into register file.
      rst     => rst,
      -- Feed global reset into register file.
      acc_out => acc_s,
      -- Read accumulator value into internal datapath.
      acc_ce  => acc_ce_s,
      -- Use control signal for accumulator writes.
      pc_out  => pc_s,
      -- Read PC value into internal datapath.
      pc_ce   => pc_ce_s,
      -- Use control signal for PC writes.
      rpc_ce  => rpc_ce_s,
      -- Use control signal for RPC writes.
      rx_num  => instr_val_s,
      -- Select general register index from instruction val field.
      rx_out  => rx_s,
      -- Read selected general register value.
      rx_ce   => rx_ce_s,
      -- Use control signal for selected register writes.
      din     => rf_din_s
      -- Feed selected writeback data into register file input.
    );

  -- Instantiate ALU and wire staged operands and outputs.
  u_alu : alu_dummy
    port map (
      op => instr_op_s,
      -- Select ALU function from decoded opcode.
      i1 => op1_r,
      -- Feed staged operand 1 to ALU input.
      i2 => op2_r,
      -- Feed staged operand 2 to ALU input.
      o  => alu_res_s,
      -- Capture ALU result into combinational result signal.
      st => flags_s
      -- Capture ALU flags into combinational flags signal.
    );

  -- Instantiate control unit and wire instruction/status inputs and controls.
  u_ctrl : control_dummy
    port map (
      clk          => clk,
      -- Feed global clock into control unit.
      rst          => rst,
      -- Feed global reset into control unit.
      status       => status_s,
      -- Provide current status flags to control decision logic.
      instr_cond   => instr_cond_s,
      -- Provide instruction condition field to control logic.
      instr_op     => instr_op_s,
      -- Provide instruction opcode field to control logic.
      instr_updt   => instr_updt_s,
      -- Provide update-bit field to control logic.
      instr_ce     => instr_ce_s,
      -- Receive generated instruction-register enable.
      status_ce    => status_ce_s,
      -- Receive generated status-register enable.
      acc_ce       => acc_ce_s,
      -- Receive generated accumulator write-enable.
      pc_ce        => pc_ce_s,
      -- Receive generated PC write-enable.
      rpc_ce       => rpc_ce_s,
      -- Receive generated RPC write-enable.
      rx_ce        => rx_ce_s,
      -- Receive generated selected-register write-enable.
      ram_we       => ram_we,
      -- Drive top-level memory write-enable from control.
      sel_ram_addr => sel_ram_s,
      -- Receive generated RAM address-select signal.
      sel_op1      => sel_op1_s,
      -- Receive generated ALU operand1-select signal.
      sel_rf_din   => sel_rf_din_s
      -- Receive generated register-file input-select signal.
    );

  -- Synchronous staging process for operands and ALU result.
  process (clk)
  begin
    -- Evaluate staged-register updates only on rising clock edge.
    if clk'event and clk = '1' then
      -- On reset, clear all staged datapath registers.
      if rst = '1' then
        op1_r <= (others => '0');
        -- Clear staged operand1 register.
        op2_r <= (others => '0');
        -- Clear staged operand2 register.
        res_r <= (others => '0');
        -- Clear staged ALU-result register.
      else
        -- Select staged operand1 source using control mux.
        if sel_op1_s = '0' then
          op1_r <= acc_s;
          -- Use accumulator as operand1 when select=0.
        else
          op1_r <= pc_s;
          -- Use program counter as operand1 when select=1.
        end if;

        -- Select staged operand2 source based on immediate bit.
        if instr_imm_s = '0' then
          op2_r <= rx_s;
          -- Use register-file selected register value when imm=0.
        else
          op2_r <= "0000000000" & instr_val_s;
          -- Zero-extend 6-bit immediate field into 16-bit operand2.
        end if;

        res_r <= alu_res_s;
        -- Latch combinational ALU result for stable writeback selection.
      end if;
    end if;
  end process;

  pc_plus_1_s <= pc_s + X"0001";
  -- Compute PC+1 for the control path that needs next-PC value.

  rf_din_s <= res_r      when sel_rf_din_s = "00" else
              -- Select ALU result path into register file when mux=00.
              ram_dout   when sel_rf_din_s = "01" else
              -- Select RAM read-data path into register file when mux=01.
              pc_plus_1_s;
              -- Select PC+1 path into register file for remaining mux cases.

  ram_addr <= pc_s  when sel_ram_s = '0' else op2_r;
  -- Drive RAM address from PC during fetch, else from staged operand2 path.
  ram_din  <= acc_s;
  -- Drive RAM write-data bus with accumulator value.
end architecture;
