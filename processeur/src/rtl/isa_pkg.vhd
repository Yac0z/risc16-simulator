library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package isa_pkg is
  constant WORD_WIDTH  : natural := 16;
  constant REG_COUNT   : natural := 64;
  constant REG_ADDR_W  : natural := 6;

  constant ACC_INDEX   : natural := 0;
  constant RPC_INDEX   : natural := 62;
  constant PC_INDEX    : natural := 63;

  subtype word_t  is std_logic_vector(WORD_WIDTH - 1 downto 0);
  subtype regid_t is std_logic_vector(REG_ADDR_W - 1 downto 0);

  -- Instruction field bit ranges.
  constant COND_MSB : natural := 15;
  constant COND_LSB : natural := 12;
  constant OP_MSB   : natural := 11;
  constant OP_LSB   : natural := 8;
  constant UPDT_BIT : natural := 7;
  constant IMM_BIT  : natural := 6;
  constant VAL_MSB  : natural := 5;
  constant VAL_LSB  : natural := 0;

  -- status(3)=Z inferred from assignment examples.
  constant FLAG_Z_I : natural := 3;
  constant FLAG_N_I : natural := 2;
  constant FLAG_C_I : natural := 1;
  constant FLAG_V_I : natural := 0;

  -- Condition codes from Table 2.
  constant COND_F   : std_logic_vector(3 downto 0) := "0000";
  constant COND_T   : std_logic_vector(3 downto 0) := "0001";
  constant COND_Z   : std_logic_vector(3 downto 0) := "0010";
  constant COND_NZ  : std_logic_vector(3 downto 0) := "0011";
  constant COND_P   : std_logic_vector(3 downto 0) := "0100";
  constant COND_NP  : std_logic_vector(3 downto 0) := "0101";
  constant COND_N   : std_logic_vector(3 downto 0) := "0110";
  constant COND_NN  : std_logic_vector(3 downto 0) := "0111";
  constant COND_C   : std_logic_vector(3 downto 0) := "1000";
  constant COND_NC  : std_logic_vector(3 downto 0) := "1001";
  constant COND_V   : std_logic_vector(3 downto 0) := "1010";
  constant COND_NV  : std_logic_vector(3 downto 0) := "1011";

  -- Opcode mapping from Table 1.
  constant OP_AND   : std_logic_vector(3 downto 0) := "0000";
  constant OP_OR    : std_logic_vector(3 downto 0) := "0001";
  constant OP_XOR   : std_logic_vector(3 downto 0) := "0010";
  constant OP_NOT   : std_logic_vector(3 downto 0) := "0011";
  constant OP_ADD   : std_logic_vector(3 downto 0) := "0100";
  constant OP_SUB   : std_logic_vector(3 downto 0) := "0101";
  constant OP_LSL   : std_logic_vector(3 downto 0) := "0110";
  constant OP_LSR   : std_logic_vector(3 downto 0) := "0111";
  constant OP_LDA   : std_logic_vector(3 downto 0) := "1000";
  constant OP_STA   : std_logic_vector(3 downto 0) := "1001";
  constant OP_MTA   : std_logic_vector(3 downto 0) := "1010";
  constant OP_MTR   : std_logic_vector(3 downto 0) := "1011";
  constant OP_JRP   : std_logic_vector(3 downto 0) := "1100";
  constant OP_JRN   : std_logic_vector(3 downto 0) := "1101";
  constant OP_JPR   : std_logic_vector(3 downto 0) := "1110";
  constant OP_CAL   : std_logic_vector(3 downto 0) := "1111";

  -- Backward-compatible aliases for the initial bootstrap.
  constant OP_LD    : std_logic_vector(3 downto 0) := OP_LDA;
  constant OP_ST    : std_logic_vector(3 downto 0) := OP_STA;
  constant OP_SHL   : std_logic_vector(3 downto 0) := OP_LSL;
  constant OP_SHR   : std_logic_vector(3 downto 0) := OP_LSR;
  constant OP_RET   : std_logic_vector(3 downto 0) := OP_JPR;
  constant OP_NOP   : std_logic_vector(3 downto 0) := "0000";
  constant OP_RSVD  : std_logic_vector(3 downto 0) := "0000";

  type state_t is (FETCH1, FETCH2, DECODE, EXEC, STORE);

  function sext6_to_word(val6 : std_logic_vector(5 downto 0)) return word_t;
  function cond_is_true(
    cond  : std_logic_vector(3 downto 0);
    flags : std_logic_vector(3 downto 0)
  ) return std_logic;
end package;

package body isa_pkg is
  function sext6_to_word(val6 : std_logic_vector(5 downto 0)) return word_t is
    variable ext : signed(WORD_WIDTH - 1 downto 0);
  begin
    ext := resize(signed(val6), WORD_WIDTH);
    return std_logic_vector(ext);
  end function;

  function cond_is_true(
    cond  : std_logic_vector(3 downto 0);
    flags : std_logic_vector(3 downto 0)
  ) return std_logic is
    variable z : std_logic := flags(FLAG_Z_I);
    variable n : std_logic := flags(FLAG_N_I);
    variable c : std_logic := flags(FLAG_C_I);
    variable v : std_logic := flags(FLAG_V_I);
  begin
    case cond is
      when COND_F => return '0';
      when COND_T => return '1';
      when COND_Z => return z;
      when COND_NZ =>
        if z = '0' then
          return '1';
        end if;
        return '0';
      when COND_P =>
        if z = '0' and n = '0' then
          return '1';
        end if;
        return '0';
      when COND_NP =>
        if z = '1' or n = '1' then
          return '1';
        end if;
        return '0';
      when COND_N => return n;
      when COND_NN =>
        if n = '0' then
          return '1';
        end if;
        return '0';
      when COND_C => return c;
      when COND_NC =>
        if c = '0' then
          return '1';
        end if;
        return '0';
      when COND_V => return v;
      when COND_NV =>
        if v = '0' then
          return '1';
        end if;
        return '0';
      when others =>
        return '0';
    end case;
  end function;
end package body;
