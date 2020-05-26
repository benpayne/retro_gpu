--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:56:55 05/01/2020
-- Design Name:   
-- Module Name:   /home/parallels/fpga_work/dvid_serdes/pixel_writer_tb.vhd
-- Project Name:  dvid_serdes
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: pixel_writter
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY pixel_writer_tb IS
END pixel_writer_tb;
 
ARCHITECTURE behavior OF pixel_writer_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pixel_writter
    PORT(
         clk : IN  std_logic;
         cmd_enb : IN  std_logic;
         cmd : IN  std_logic_vector(1 downto 0);
         data : IN  std_logic_vector(31 downto 0);
			busy : out STD_LOGIC;
         write_addr : OUT  std_logic_vector(15 downto 0);
         write_pixel : OUT  std_logic_vector(11 downto 0);
         write_enb : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal cmd_enb : std_logic := '0';
   signal cmd : std_logic_vector(1 downto 0) := (others => '0');
   signal data : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal write_addr : std_logic_vector(15 downto 0);
   signal write_pixel : std_logic_vector(11 downto 0);
   signal write_enb : std_logic;
   signal busy : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pixel_writter PORT MAP (
          clk => clk,
          cmd_enb => cmd_enb,
          cmd => cmd,
          data => data,
			 busy => busy,
          write_addr => write_addr,
          write_pixel => write_pixel,
          write_enb => write_enb
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

		-- write one pixel
		cmd <= "00";
		cmd_enb <= '1';
		data(31 downto 12) <= (others => '0');
		data(11 downto 0) <= "101010011000";
		wait for clk_period;
		
		cmd_enb <= '0';
		
      -- insert stimulus here 

      wait for clk_period*20;

		assert (busy = '0') report "command not complete in time";
		
		-- write two pixels
		cmd <= "01";
		cmd_enb <= '1';
		data(31 downto 24) <= (others => '0');
		data(23 downto 12) <= "110111001011";
		data(11 downto 0) <= "101010011000";
		wait for clk_period;
		
		cmd_enb <= '0';

      wait for clk_period*30;

		assert (busy = '0') report "command not complete in time";

		-- write address
		cmd <= "10";
		cmd_enb <= '1';
		data(31 downto 12) <= (others => '0');
		data(11 downto 0) <= "000010000000";
		wait for clk_period;
		
		cmd_enb <= '0';

      wait for clk_period*20;

		assert (busy = '0') report "command not complete in time";

		-- write 2 more pixels at offset
		cmd <= "01";
		cmd_enb <= '1';
		data(31 downto 24) <= (others => '0');
		data(23 downto 12) <= "110111001011";
		data(11 downto 0) <= "101010011000";
		wait for clk_period*5;
		
		cmd_enb <= '0';

      wait for clk_period*30;

		assert (busy = '0') report "command not complete in time";

		-- write 2 more pixels at offset
		cmd <= "01";
		cmd_enb <= '1';
		data(31 downto 24) <= (others => '0');
		data(23 downto 12) <= "110111001011";
		data(11 downto 0) <= "101010011000";
		wait for clk_period*5;
		
		cmd_enb <= '0';

      wait for clk_period*30;

		assert (busy = '0') report "command not complete in time";

      wait;
   end process;

END;
