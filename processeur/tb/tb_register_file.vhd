library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.isa_pkg.all;

entity tb_register_file is
end entity;

architecture sim of tb_register_file is
  signal clk     : std_logic := '0';
  signal rst     : std_logic := '1';
  signal din     : word_t := (others => '0');
  signal rx_num  : regid_t := (others => '0');
  signal acc_ce  : std_logic := '0';
  signal pc_ce   : std_logic := '0';
  signal rpc_ce  : std_logic := '0';
  signal rx_ce   : std_logic := '0';
  signal rx_out  : word_t;
  signal acc_out : word_t;
  signal pc_out  : word_t;
  signal rpc_out : word_t;
begin
  clk <= not clk after 5 ns;

  dut : entity work.register_file
    port map (
      clk     => clk,
      rst     => rst,
      din     => din,
      rx_num  => rx_num,
      acc_ce  => acc_ce,
      pc_ce   => pc_ce,
      rpc_ce  => rpc_ce,
      rx_ce   => rx_ce,
      rx_out  => rx_out,
      acc_out => acc_out,
      pc_out  => pc_out,
      rpc_out => rpc_out
    );

  stim : process
  begin
    wait for 12 ns;
    rst <= '0';

    din <= x"1234";
    acc_ce <= '1';
    wait for 10 ns;
    acc_ce <= '0';
    assert acc_out = x"1234" report "ACC write failed" severity error;

    rx_num <= std_logic_vector(to_unsigned(5, REG_ADDR_W));
    din <= x"ABCD";
    rx_ce <= '1';
    wait for 10 ns;
    rx_ce <= '0';
    assert rx_out = x"ABCD" report "RX write failed" severity error;

    wait;
  end process;
end architecture;
