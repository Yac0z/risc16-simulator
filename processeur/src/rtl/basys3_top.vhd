library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.isa_pkg.all;

entity basys3_top is
  port (
    clk100mhz_i : in  std_logic;
    btn_reset_i  : in  std_logic;
    sw_i         : in  std_logic_vector(15 downto 0);
    led_o        : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of basys3_top is
  constant RAM_DEPTH_C : natural := 256;
  constant CLK_DIV_C   : natural := 24_999_999;

  signal cpu_clk_r    : std_logic := '0';
  signal clk_div_r    : unsigned(24 downto 0) := (others => '0');
  signal rst_s        : std_logic;
  signal run_en_s     : std_logic;

  signal ram_addr_s   : word_t;
  signal ram_data_o_s : word_t;
  signal ram_data_i_s : word_t;
  signal ram_we_s     : std_logic;

  signal dbg_acc_s    : word_t;
  signal dbg_pc_s     : word_t;
  signal dbg_state_s  : state_t;

  function state_to_slv(state_i : state_t) return std_logic_vector is
  begin
    case state_i is
      when FETCH1 => return "0001";
      when FETCH2 => return "0010";
      when DECODE => return "0011";
      when EXEC   => return "0100";
      when STORE  => return "0101";
    end case;
  end function;
begin
  rst_s    <= btn_reset_i;
  run_en_s <= not sw_i(15);

  process (clk100mhz_i)
  begin
    if rising_edge(clk100mhz_i) then
      if rst_s = '1' then
        clk_div_r <= (others => '0');
        cpu_clk_r <= '0';
      elsif run_en_s = '1' then
        if to_integer(clk_div_r) = CLK_DIV_C then
          clk_div_r <= (others => '0');
          cpu_clk_r <= not cpu_clk_r;
        else
          clk_div_r <= clk_div_r + 1;
        end if;
      end if;
    end if;
  end process;

  u_ram : entity work.ram
    generic map (
      ADDR_WIDTH_G => 8,
      DATA_WIDTH_G => WORD_WIDTH
    )
    port map (
      clk  => cpu_clk_r,
      rst  => rst_s,
      addr => ram_addr_s(7 downto 0),
      din  => ram_data_o_s,
      we   => ram_we_s,
      dout => ram_data_i_s
    );

  u_cpu : entity work.cpu_top
    port map (
      clk         => cpu_clk_r,
      rst         => rst_s,
      ram_data_i  => ram_data_i_s,
      ram_data_o  => ram_data_o_s,
      ram_addr_o  => ram_addr_s,
      ram_we_o    => ram_we_s,
      dbg_acc_o   => dbg_acc_s,
      dbg_pc_o    => dbg_pc_s,
      dbg_state_o => dbg_state_s
    );

  led_o <= dbg_acc_s(3 downto 0) & dbg_pc_s(7 downto 0) & state_to_slv(dbg_state_s);
end architecture;