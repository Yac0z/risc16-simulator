library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.isa_pkg.all;

entity register_file is
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    din      : in  word_t;
    rx_num   : in  regid_t;
    acc_ce   : in  std_logic;
    pc_ce    : in  std_logic;
    rpc_ce   : in  std_logic;
    rx_ce    : in  std_logic;
    rx_out   : out word_t;
    acc_out  : out word_t;
    pc_out   : out word_t;
    rpc_out  : out word_t
  );
end entity;

architecture rtl of register_file is
  type reg_array_t is array (0 to REG_COUNT - 1) of word_t;
  signal regs : reg_array_t := (others => (others => '0'));
begin
  process (clk)
    variable idx : natural range 0 to REG_COUNT - 1;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        regs <= (others => (others => '0'));
        regs(PC_INDEX) <= (others => '0');
      else
        idx := to_integer(unsigned(rx_num));

        if acc_ce = '1' then
          regs(ACC_INDEX) <= din;
        end if;

        if rpc_ce = '1' then
          regs(RPC_INDEX) <= din;
        end if;

        if pc_ce = '1' then
          regs(PC_INDEX) <= din;
        end if;

        if rx_ce = '1' and idx /= ACC_INDEX and idx /= RPC_INDEX and idx /= PC_INDEX then
          regs(idx) <= din;
        end if;
      end if;
    end if;
  end process;

  rx_out  <= regs(to_integer(unsigned(rx_num)));
  acc_out <= regs(ACC_INDEX);
  rpc_out <= regs(RPC_INDEX);
  pc_out  <= regs(PC_INDEX);
end architecture;
