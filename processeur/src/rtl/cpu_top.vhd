library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.isa_pkg.all;

entity cpu_top is
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    ram_data_i    : in  word_t;
    ram_data_o    : out word_t;
    ram_addr_o    : out word_t;
    ram_we_o      : out std_logic;
    dbg_acc_o     : out word_t;
    dbg_pc_o      : out word_t;
    dbg_state_o   : out state_t
  );
end entity;

architecture rtl of cpu_top is
  signal instr_s      : word_t;
  signal status_s     : std_logic_vector(3 downto 0);
  signal flags_s      : std_logic_vector(3 downto 0);
  signal op1_s        : word_t;
  signal op2_s        : word_t;
  signal op1_r        : word_t;
  signal op2_r        : word_t;
  signal alu_res_s    : word_t;
  signal res_r        : word_t;
  signal pc_plus1_s   : word_t;
  signal rf_din_s     : word_t;
  signal rx_num_s     : regid_t;
  signal rx_out_s     : word_t;
  signal acc_s        : word_t;
  signal pc_s         : word_t;
  signal rpc_s        : word_t;

  signal instr_ce_s   : std_logic;
  signal acc_ce_s     : std_logic;
  signal pc_ce_s      : std_logic;
  signal rpc_ce_s     : std_logic;
  signal rx_ce_s      : std_logic;
  signal sel_ram_s    : std_logic;
  signal sel_op1_s    : std_logic;
  signal sel_rf_din_s : std_logic;
  signal state_s      : state_t;
begin
  u_ir : entity work.instr_reg
    port map (
      clk => clk,
      rst => rst,
      ce  => instr_ce_s,
      i   => ram_data_i,
      o   => instr_s
    );

  u_sr : entity work.status_reg
    port map (
      clk => clk,
      rst => rst,
      ce  => instr_s(UPDT_BIT),
      i   => flags_s,
      o   => status_s
    );

  rx_num_s <= instr_s(VAL_MSB downto VAL_LSB);
  pc_plus1_s <= std_logic_vector(unsigned(pc_s) + 1);

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        op1_r <= (others => '0');
        op2_r <= (others => '0');
        res_r <= (others => '0');
      else
        op1_r <= acc_s when sel_op1_s = '0' else rx_out_s;
        op2_r <= rx_out_s when instr_s(IMM_BIT) = '0' else sext6_to_word(instr_s(VAL_MSB downto VAL_LSB));
        res_r <= alu_res_s;
      end if;
    end if;
  end process;

  u_rf : entity work.register_file
    port map (
      clk     => clk,
      rst     => rst,
      din     => rf_din_s,
      rx_num  => rx_num_s,
      acc_ce  => acc_ce_s,
      pc_ce   => pc_ce_s,
      rpc_ce  => rpc_ce_s,
      rx_ce   => rx_ce_s,
      rx_out  => rx_out_s,
      acc_out => acc_s,
      pc_out  => pc_s,
      rpc_out => rpc_s
    );

  op1_s <= op1_r;
  op2_s <= op2_r;
  rf_din_s <= pc_plus1_s when state_s = EXEC else ram_data_i when sel_rf_din_s = '1' else res_r;

  u_alu : entity work.alu
    port map (
      op_sel_i => instr_s(OP_MSB downto OP_LSB),
      status_i => status_s,
      op1_i    => op1_s,
      op2_i    => op2_s,
      result_o => alu_res_s,
      flags_o  => flags_s
    );

  u_ctrl : entity work.control_unit
    port map (
      clk          => clk,
      rst          => rst,
      instr_i      => instr_s,
      status_i     => status_s,
      state_o      => state_s,
      instr_ce_o   => instr_ce_s,
      acc_ce_o     => acc_ce_s,
      pc_ce_o      => pc_ce_s,
      rpc_ce_o     => rpc_ce_s,
      rx_ce_o      => rx_ce_s,
      ram_we_o     => ram_we_o,
      sel_ram_addr => sel_ram_s,
      sel_op1      => sel_op1_s,
      sel_rf_din   => sel_rf_din_s
    );

  ram_addr_o  <= pc_s when sel_ram_s = '0' else res_r;
  ram_data_o  <= acc_s;
  dbg_acc_o   <= acc_s;
  dbg_pc_o    <= pc_s;
  dbg_state_o <= state_s;
end architecture;
