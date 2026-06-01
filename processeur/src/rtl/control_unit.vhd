library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.isa_pkg.all;

entity control_unit is
  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    instr_i      : in  word_t;
    status_i     : in  std_logic_vector(3 downto 0);
    state_o      : out state_t;
    instr_ce_o   : out std_logic;
    acc_ce_o     : out std_logic;
    pc_ce_o      : out std_logic;
    rpc_ce_o     : out std_logic;
    rx_ce_o      : out std_logic;
    ram_we_o     : out std_logic;
    sel_ram_addr : out std_logic;
    sel_op1      : out std_logic;
    sel_rf_din   : out std_logic
  );
end entity;

architecture rtl of control_unit is
  signal state_r      : state_t := FETCH1;
  signal execute_en_s : std_logic;
begin
  execute_en_s <= cond_is_true(instr_i(COND_MSB downto COND_LSB), status_i);

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state_r <= FETCH1;
      else
        case state_r is
          when FETCH1 => state_r <= FETCH2;
          when FETCH2 => state_r <= DECODE;
          when DECODE => state_r <= EXEC;
          when EXEC   => state_r <= STORE;
          when STORE  => state_r <= FETCH1;
        end case;
      end if;
    end if;
  end process;

  process (all)
    variable op : std_logic_vector(3 downto 0);
  begin
    op := instr_i(OP_MSB downto OP_LSB);

    instr_ce_o   <= '0';
    acc_ce_o     <= '0';
    pc_ce_o      <= '0';
    rpc_ce_o     <= '0';
    rx_ce_o      <= '0';
    ram_we_o     <= '0';
    sel_ram_addr <= '0';
    sel_op1      <= '0';
    sel_rf_din   <= '0';

    case state_r is
      when FETCH1 =>
        sel_ram_addr <= '0';
      when FETCH2 =>
        instr_ce_o <= '1';
      when DECODE =>
        null;
      when EXEC =>
        pc_ce_o <= '1';
        if execute_en_s = '1' then
          if op = OP_STA then
            ram_we_o <= '1';
          elsif op = OP_CAL then
            rpc_ce_o <= '1';
          end if;
        end if;
      when STORE =>
        if execute_en_s = '1' then
          if op = OP_CAL then
            pc_ce_o <= '1';
          elsif op = OP_MTA or op = OP_MTR or op = OP_LDA or op = OP_ADD or op = OP_SUB or op = OP_AND or op = OP_OR or op = OP_XOR or op = OP_NOT or op = OP_LSL or op = OP_LSR then
            acc_ce_o <= '1';
              if op = OP_LDA then
                sel_rf_din <= '1';
              end if;
          elsif op = OP_STA or op = OP_JRP or op = OP_JRN or op = OP_JPR then
            rx_ce_o <= '1';
          end if;
        end if;
    end case;
  end process;

  state_o <= state_r;
end architecture;
