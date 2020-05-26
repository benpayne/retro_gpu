----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:42:05 08/09/2018 
-- Design Name: 
-- Module Name:    nibble_decode - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display_decoder is
    Port ( nibble : in  STD_LOGIC_VECTOR (3 downto 0);
           segments : out  STD_LOGIC_VECTOR (6 downto 0));
end display_decoder;

architecture Behavioral of display_decoder is

	type output_matrix is array (0 to 2 ** 4 - 1) of std_logic_vector(6 downto 0);

	constant segments_map : output_matrix := (("0111111"), ("0000110"),
		("1011011"), ("1001111"), ("1100110"), ("1101101"), ("1111101"),
		("0000111"), ("1111111"), ("1100111"), ("1110111"), ("1111100"),
		("0111001"), ("1011110"), ("1111001"), ("1110001"));
		
begin

	segments <= segments_map(to_integer(unsigned(nibble)));

end Behavioral;

