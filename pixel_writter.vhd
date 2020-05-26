----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:00:38 04/30/2020 
-- Design Name: 
-- Module Name:    pixel_writter - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pixel_writter is
    Port ( clk : in  STD_LOGIC;
			  cmd_enb : in  STD_LOGIC;
           cmd : in  STD_LOGIC_VECTOR (1 downto 0);
           data : in  STD_LOGIC_VECTOR (31 downto 0);
			  busy : out STD_LOGIC;
           write_addr : out  STD_LOGIC_VECTOR (15 downto 0);
           write_pixel : out  STD_LOGIC_VECTOR (11 downto 0);
           write_enb : out  STD_LOGIC);
end pixel_writter;

architecture Behavioral of pixel_writter is

	TYPE    write_machine IS(idle, pixel_delay, pixel1_delay);
	SIGNAL  write_state : write_machine; --receive state machine  
	
begin
	
	-- this process gets commands from the serial interface and moves data to the vga_gen/display buffer
	process(clk)
		variable addr_reg : UNSIGNED(15 downto 0) := (others => '0');
		variable write_delay : INTEGER RANGE 0 to 10 := 0;
	begin
		if rising_edge(clk) then
			CASE write_state IS
			WHEN idle =>
				write_enb <= '0';
				busy <= '0';
				if cmd_enb = '1' then
					case cmd is
					when "00" => -- write pixel
						write_state <= pixel_delay;
						write_pixel <= data(11 downto 0);
						write_addr <= std_logic_vector(addr_reg);
						busy <= '1';
						write_delay := 0;
					when "01" => -- write pixel pair
						write_state <= pixel1_delay;
						write_pixel <= data(23 downto 12);
						write_addr <= std_logic_vector(addr_reg);
						busy <= '1';
						write_delay := 0;						
					when "10" => -- write address
						addr_reg := unsigned(data(15 downto 0));
					when others =>
						write_state <= idle;						
					end case;
				end if;
			WHEN pixel_delay =>
				if write_delay = 2 then
					write_enb <= '1';
					write_delay := write_delay + 1;				
				else if write_delay = 9 then
					addr_reg := addr_reg + 1;
					write_delay := write_delay + 1;
				else if write_delay = 10 then
					write_state <= idle;
					write_delay := 0;
				else
					write_enb <= '0';
					write_delay := write_delay + 1;
				end if;
				end if;
				end if;
			WHEN pixel1_delay =>
				if write_delay = 2 then
					write_enb <= '1';
					write_delay := write_delay + 1;				
				else if write_delay = 9 then
					addr_reg := addr_reg + 1;
					write_delay := write_delay + 1;
				else if write_delay = 10 then
					write_state <= pixel_delay;
					write_pixel <= data(11 downto 0);
					write_addr <= std_logic_vector(addr_reg);
					write_delay := 0;						
				else
					write_enb <= '0';
					write_delay := write_delay + 1;
				end if;
				end if;
				end if;
			end case;
		end if;
	end process;
end Behavioral;

