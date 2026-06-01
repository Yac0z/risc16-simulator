-------------------------------------------------------------------------------
-- Arithmetic logic unit
--
-- Ports:
--   - op [in]  : 4-bit instruction opcode
--   - i1 [in]  : operand 1
--   - i2 [in]  : operand 2
--   - o  [out] : result
--   - st [out] : 4-bit status flags
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu is
  port ( op : in  std_logic_vector(3 downto 0);
         i1 : in  std_logic_vector(15 downto 0);
         i2 : in  std_logic_vector(15 downto 0);
         o  : out std_logic_vector(15 downto 0);
         st : out std_logic_vector(3 downto 0) );
end entity;

architecture arch of alu is
begin
end architecture;
