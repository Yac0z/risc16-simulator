library ieee;
use ieee.std_logic_1164.all;

entity status_reg is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    ce    : in  std_logic;
    i     : in  std_logic_vector(3 downto 0);
    o     : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of status_reg is
  signal r : std_logic_vector(3 downto 0) := (others => '0');
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        r <= (others => '0');
      elsif ce = '1' then
        r <= i;
      end if;
    end if;
  end process;

  o <= r;
end architecture;
