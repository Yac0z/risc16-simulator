library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.isa_pkg.all;

entity ram is
  generic (
    ADDR_WIDTH_G : natural := 8;
    DATA_WIDTH_G : natural := WORD_WIDTH
  );
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    addr  : in  std_logic_vector(ADDR_WIDTH_G - 1 downto 0);
    din   : in  std_logic_vector(DATA_WIDTH_G - 1 downto 0);
    we    : in  std_logic;
    dout  : out std_logic_vector(DATA_WIDTH_G - 1 downto 0)
  );
end entity;

architecture rtl of ram is
  constant DEPTH_C : natural := 2 ** ADDR_WIDTH_G;

  type ram_t is array (0 to DEPTH_C - 1) of std_logic_vector(DATA_WIDTH_G - 1 downto 0);
  signal mem_r : ram_t := (others => (others => '0'));
begin
  process (clk)
    variable addr_idx_v : natural range 0 to DEPTH_C - 1;
  begin
    if rising_edge(clk) then
      addr_idx_v := to_integer(unsigned(addr));

      if rst = '1' then
        mem_r <= (others => (others => '0'));
      elsif we = '1' then
        mem_r(addr_idx_v) <= din;
      end if;
    end if;
  end process;

  dout <= mem_r(to_integer(unsigned(addr)));
end architecture;