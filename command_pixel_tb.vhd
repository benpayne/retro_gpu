--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:36:09 05/07/2020
-- Design Name:   
-- Module Name:   /home/parallels/fpga_work/dvid_serdes/command_pixel_tb.vhd
-- Project Name:  dvid_serdes
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: command_decoder
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
 
ENTITY command_pixel_tb IS
END command_pixel_tb;
 
ARCHITECTURE behavior OF command_pixel_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT command_decoder
    PORT(
         clk : IN  std_logic;
         rx_busy : IN  std_logic;
         rx_data : IN  std_logic_vector(7 downto 0);
         cmd : OUT  std_logic_vector(1 downto 0);
         cmd_data : OUT  std_logic_vector(31 downto 0);
         cmd_enb : OUT  std_logic
        );
    END COMPONENT;
    
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
   signal rx_busy : std_logic := '0';
   signal rx_data : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal cmd : std_logic_vector(1 downto 0);
   signal cmd_data : std_logic_vector(31 downto 0);
   signal cmd_enb : std_logic;
	signal busy : std_logic;
	
	--Write Out
   signal write_addr : std_logic_vector(15 downto 0);
   signal write_pixel : std_logic_vector(11 downto 0);
   signal write_enb : std_logic;
	
   signal command : std_logic_vector(7 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk_period : time := 20 ns;
   constant baud_period : time := 1000 ms / 115200;

	procedure send_command(constant baud_period : in time;
								  signal command : in STD_LOGIC_VECTOR(7 downto 0);									
								  signal rx_data : out STD_LOGIC_VECTOR(7 downto 0);
								  signal rx_busy : out STD_LOGIC
								  ) is
	begin
		wait for baud_period;
		rx_busy <= '1';
		wait for baud_period*9;
		rx_data <= command;
		wait for baud_period*2;
		rx_busy <= '0';		
	end send_command;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut_command: command_decoder PORT MAP (
          clk => clk,
          rx_busy => rx_busy,
          rx_data => rx_data,
          cmd => cmd,
          cmd_data => cmd_data,
          cmd_enb => cmd_enb
        );

	-- Instantiate the Unit Under Test (UUT)
   uut_pixel: pixel_writter PORT MAP (
          clk => clk,
          cmd_enb => cmd_enb,
          cmd => cmd,
          data => cmd_data,
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

      -- insert stimulus here 

		command <= X"01";
		send_command(baud_period, command, rx_data, rx_busy);

		command <= X"00";
		send_command(baud_period, command, rx_data, rx_busy);

		command <= X"02";
		send_command(baud_period, command, rx_data, rx_busy);

		command <= X"0F";
		send_command(baud_period, command, rx_data, rx_busy);

		command <= X"ED";
		send_command(baud_period, command, rx_data, rx_busy);
		
      -- insert stimulus here 

		-- cmd send pixels
		command <= X"02";
		send_command(baud_period, command, rx_data, rx_busy);

		-- send 8 pixels
		command <= X"00";
		send_command(baud_period, command, rx_data, rx_busy);
		command <= X"08";
		send_command(baud_period, command, rx_data, rx_busy);

		-- pair 1
		command <= X"FE";
		send_command(baud_period, command, rx_data, rx_busy);
		command <= X"DC";
		send_command(baud_period, command, rx_data, rx_busy);
		command <= X"BA";
		send_command(baud_period, command, rx_data, rx_busy);

		-- pair 2
		command <= X"98";
		send_command(baud_period, command, rx_data, rx_busy);
		command <= X"76";
		send_command(baud_period, command, rx_data, rx_busy);
		command <= X"54";
		send_command(baud_period, command, rx_data, rx_busy);

		-- pair 3
		command <= X"32";
		send_command(baud_period, command, rx_data, rx_busy);
		command <= X"10";
		send_command(baud_period, command, rx_data, rx_busy);
		command <= X"FE";
		send_command(baud_period, command, rx_data, rx_busy);

		-- pair 4
		command <= X"DC";
		send_command(baud_period, command, rx_data, rx_busy);
		command <= X"BA";
		send_command(baud_period, command, rx_data, rx_busy);
		command <= X"98";
		send_command(baud_period, command, rx_data, rx_busy);

		-- cmd send pixels
		command <= X"02";
		send_command(baud_period, command, rx_data, rx_busy);

		-- send 8 pixels
		command <= X"00";
		send_command(baud_period, command, rx_data, rx_busy);
		command <= X"04";
		send_command(baud_period, command, rx_data, rx_busy);

		-- pair 1
		command <= X"32";
		send_command(baud_period, command, rx_data, rx_busy);
		command <= X"10";
		send_command(baud_period, command, rx_data, rx_busy);
		command <= X"FE";
		send_command(baud_period, command, rx_data, rx_busy);

		-- pair 2
		command <= X"DC";
		send_command(baud_period, command, rx_data, rx_busy);
		command <= X"BA";
		send_command(baud_period, command, rx_data, rx_busy);
		command <= X"98";
		send_command(baud_period, command, rx_data, rx_busy);

      wait;
   end process;

END;
