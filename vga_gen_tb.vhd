--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:51:27 04/28/2020
-- Design Name:   
-- Module Name:   /home/parallels/fpga_work/dvid_serdes/vga_gen_tb.vhd
-- Project Name:  dvid_serdes
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: vga_gen
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
 
ENTITY vga_gen_tb IS
END vga_gen_tb;
 
ARCHITECTURE behavior OF vga_gen_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT vga_gen
    PORT(
         clk75 : IN  std_logic;
         pclk : OUT  std_logic;
         red : OUT  std_logic_vector(7 downto 0);
         green : OUT  std_logic_vector(7 downto 0);
         blue : OUT  std_logic_vector(7 downto 0);
         blank : OUT  std_logic;
         hsync : OUT  std_logic;
         vsync : OUT  std_logic;
         pattern : IN  std_logic_vector(3 downto 0);
         write_enb : IN  std_logic;
         write_row : IN  std_logic_vector(7 downto 0);
         write_col : IN  std_logic_vector(8 downto 0);
         write_pix : IN  std_logic_vector(11 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk75 : std_logic := '0';
   signal pattern : std_logic_vector(3 downto 0) := (others => '0');
   signal write_enb : std_logic := '0';
   signal write_row : std_logic_vector(7 downto 0) := (others => '0');
   signal write_col : std_logic_vector(8 downto 0) := (others => '0');
   signal write_pix : std_logic_vector(11 downto 0) := (others => '0');

 	--Outputs
   signal pclk : std_logic;
   signal red : std_logic_vector(7 downto 0);
   signal green : std_logic_vector(7 downto 0);
   signal blue : std_logic_vector(7 downto 0);
   signal blank : std_logic;
   signal hsync : std_logic;
   signal vsync : std_logic;

   -- Clock period definitions
   constant clk75_period : time := 10 ns;
   constant pclk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: vga_gen PORT MAP (
          clk75 => clk75,
          pclk => pclk,
          red => red,
          green => green,
          blue => blue,
          blank => blank,
          hsync => hsync,
          vsync => vsync,
          pattern => pattern,
          write_enb => write_enb,
          write_row => write_row,
          write_col => write_col,
          write_pix => write_pix
        );

   -- Clock process definitions
   clk75_process :process
   begin
		clk75 <= '0';
		wait for clk75_period/2;
		clk75 <= '1';
		wait for clk75_period/2;
   end process;
 
   pclk_process :process
   begin
		pclk <= '0';
		wait for pclk_period/2;
		pclk <= '1';
		wait for pclk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk75_period*10;

		write_row <= "00000001";
		write_col <= "000000010";
		write_pix <= "100010001000";
		write_enb <= '1';
		
      wait for clk75_period;

		write_enb <= '0';
		
      -- insert stimulus here 

      wait;
   end process;

END;
