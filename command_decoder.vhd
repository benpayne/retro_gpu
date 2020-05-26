----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:13:47 05/06/2020 
-- Design Name: 
-- Module Name:    command_decoder - Behavioral 
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

entity command_decoder is
    Port ( clk : in  STD_LOGIC;
           rx_busy : in  STD_LOGIC;
           rx_data : in  STD_LOGIC_VECTOR (7 downto 0);
           cmd : out  STD_LOGIC_VECTOR (1 downto 0);
           cmd_data : out  STD_LOGIC_VECTOR (31 downto 0);
           cmd_enb : out  STD_LOGIC);
end command_decoder;

architecture Behavioral of command_decoder is

	TYPE    rx_machine IS(idle, command_byte, write_pixel_wait, write_pixel, write_buffer_hdr_wait, write_buffer_hdr, write_buffer_wait, write_buffer); --receive state machine data type
   SIGNAL  rx_state : rx_machine; --receive state machine         

	signal	s_cmd_enb : STD_LOGIC := '0';
	signal	s_cmd_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin

	cmd_enb <= s_cmd_enb;
	
	-- this process reads bytes from the serial port and trigger commands on the Pixel write in response. 
	process(clk, rx_busy)
		variable byte_count : INTEGER RANGE 0 to 320*180 := 0;
		variable write_len : UNSIGNED(15 downto 0) := (others => '0');
		variable cmd_delay : STD_LOGIC := '0';
	begin
		if rising_edge(clk) then
			-- cmd_enb should always be cleared on next clock if set.
			if s_cmd_enb = '1' then
				if cmd_delay = '0' then
					cmd_delay := '1';
				else
					s_cmd_enb <= '0';
				end if;
			else
				cmd_delay := '0';
			end if;
			CASE rx_state IS
				WHEN idle =>
					if (rx_busy = '1') then
						rx_state <= command_byte;
					end if;
				WHEN command_byte =>
					if (rx_busy = '0') then
						if (rx_data = "00000001") then
							rx_state <= write_pixel_wait;
							byte_count := 0;
						else if (rx_data = "00000010") then
							rx_state <= write_buffer_hdr_wait;
							byte_count := 0;
						else
							rx_state <= idle;
						end if;
						end if;
					end if;
				WHEN write_pixel_wait =>
					if (rx_busy = '1') then
						rx_state <= write_pixel;
					end if;
				WHEN write_pixel =>
					if (rx_busy = '0') then
						if (byte_count = 1) then
							rx_state <= write_pixel_wait;
							byte_count := byte_count + 1;
							cmd <= "10";
							cmd_data(31 downto 16) <= (others => '0');
							cmd_data(15 downto 0) <= s_cmd_data(7 downto 0) & rx_data;
							s_cmd_enb <= '1';
						else if (byte_count = 3) then
							rx_state <= idle;
							byte_count := 0;
							cmd <= "00";
							cmd_data(31 downto 16) <= (others => '0');
							cmd_data(15 downto 0) <= s_cmd_data(7 downto 0) & rx_data;
							s_cmd_enb <= '1';
						else
							rx_state <= write_pixel_wait;
							s_cmd_data <= s_cmd_data(23 downto 0) & rx_data;
							byte_count := byte_count + 1;
						end if;
						end if;
					end if;
				WHEN write_buffer_hdr_wait =>
					if (rx_busy = '1') then
						rx_state <= write_buffer_hdr;
					end if;
				WHEN write_buffer_hdr =>
					if rx_busy = '0' then
						if byte_count = 1 then
							rx_state <= write_buffer_wait;
							write_len := unsigned(s_cmd_data(7 downto 0) & rx_data);
							byte_count := 0;
							-- set address to zero to write from start
							cmd <= "10";
							cmd_data <= (others => '0');
							s_cmd_enb <= '1';
						else
							rx_state <= write_buffer_hdr_wait;
							s_cmd_data <= s_cmd_data(23 downto 0) & rx_data;
							byte_count := 1;
						end if;
					end if;
				WHEN write_buffer_wait =>
					if rx_busy = '1' then
						rx_state <= write_buffer;
					end if;
				WHEN write_buffer =>
					if (rx_busy = '0') then
						-- if read 3 bytes we have 2 pixels to write
						if (byte_count = 2) then
							cmd <= "01";
							cmd_data <= s_cmd_data(23 downto 0) & rx_data;
							s_cmd_enb <= '1';
							byte_count := 0;
							if write_len = 2 then
								rx_state <= idle;
							else
								rx_state <= write_buffer_wait;
								write_len := write_len - 2;
							end if;
						else
							rx_state <= write_buffer_wait;
							s_cmd_data <= s_cmd_data(23 downto 0) & rx_data;
							byte_count := byte_count + 1;
						end if;
					end if;
			end case;
		end if;
	end process;
	
end Behavioral;

