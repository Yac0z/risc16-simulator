library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.isa_pkg.all;

entity alu is
  port (
    op_sel_i : in  std_logic_vector(3 downto 0);
    status_i : in  std_logic_vector(3 downto 0);
    op1_i    : in  word_t;
    op2_i    : in  word_t;
    result_o : out word_t;
    flags_o  : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of alu is
begin
  process (all)
    variable a_s      : signed(15 downto 0);
    variable b_s      : signed(15 downto 0);
    variable res_s    : signed(15 downto 0);
    variable res_u    : unsigned(15 downto 0);
    variable carry_v  : std_logic;
    variable over_v   : std_logic;
    variable z_v      : std_logic;
    variable n_v      : std_logic;
    variable shift_amt : natural range 0 to 15;
    variable ejected_v : std_logic;
  begin
    a_s := signed(op1_i);
    b_s := signed(op2_i);
    res_s := (others => '0');
    carry_v := status_i(FLAG_C_I);
    over_v := status_i(FLAG_V_I);
    shift_amt := 0;
    ejected_v := '0';

    case op_sel_i is
      when OP_AND =>
        res_s := signed(op1_i and op2_i);
      when OP_OR =>
        res_s := signed(op1_i or op2_i);
      when OP_XOR =>
        res_s := signed(op1_i xor op2_i);
      when OP_NOT =>
        res_s := signed(not op1_i);
      when OP_ADD =>
        res_s := a_s + b_s;
        res_u := unsigned(op1_i) + unsigned(op2_i);
        if res_u < unsigned(op1_i) then
          carry_v := '1';
        end if;
        if (op1_i(15) = op2_i(15)) and (std_logic(res_s(15)) /= op1_i(15)) then
          over_v := '1';
        end if;
      when OP_SUB =>
        res_s := a_s - b_s;
        if unsigned(op1_i) < unsigned(op2_i) then
          carry_v := '1';
        end if;
        if (op1_i(15) /= op2_i(15)) and (std_logic(res_s(15)) /= op1_i(15)) then
          over_v := '1';
        end if;
      when OP_LSL =>
        shift_amt := to_integer(unsigned(op2_i(3 downto 0)));
        res_s := shift_left(a_s, shift_amt);
        if shift_amt > 0 then
          if op1_i(15 downto 16 - shift_amt) /= (15 downto 16 - shift_amt => '0') then
            ejected_v := '1';
          end if;
        end if;
        carry_v := ejected_v;
        if op1_i(15) /= std_logic(res_s(15)) then
          over_v := '1';
        end if;
      when OP_LSR =>
        shift_amt := to_integer(unsigned(op2_i(3 downto 0)));
        res_s := shift_right(a_s, shift_amt);
        if shift_amt > 0 then
          if op1_i(shift_amt - 1 downto 0) /= (shift_amt - 1 downto 0 => '0') then
            ejected_v := '1';
          end if;
        end if;
        carry_v := ejected_v;
        if op1_i(15) /= std_logic(res_s(15)) then
          over_v := '1';
        end if;
      when others =>
        res_s := a_s;
    end case;

    z_v := '1' when res_s = 0 else '0';
    n_v := std_logic(res_s(15));

    result_o <= std_logic_vector(res_s);
    flags_o  <= z_v & n_v & carry_v & over_v;
  end process;
end architecture;
