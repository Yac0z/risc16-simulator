library ieee;
use ieee.std_logic_1164.all;
use work.isa_pkg.all;

entity tb_alu is
end entity;

architecture sim of tb_alu is
  signal op_sel  : std_logic_vector(3 downto 0);
  signal op1     : word_t;
  signal op2     : word_t;
  signal result  : word_t;
  signal flags   : std_logic_vector(3 downto 0);
begin
  dut : entity work.alu
    port map (
      op_sel_i => op_sel,
      status_i => (others => '0'),
      op1_i    => op1,
      op2_i    => op2,
      result_o => result,
      flags_o  => flags
    );

  stim : process
  begin
    op_sel <= OP_ADD;
    op1 <= x"0001";
    op2 <= x"0001";
    wait for 10 ns;
    assert result = x"0002" report "ADD failed" severity error;

    op_sel <= OP_AND;
    op1 <= x"00F0";
    op2 <= x"0FF0";
    wait for 10 ns;
    assert result = x"00F0" report "AND failed" severity error;

    wait;
  end process;
end architecture;
