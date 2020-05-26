--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:07:47 05/05/2020
-- Design Name:   
-- Module Name:   /home/parallels/fpga_work/dvid_serdes/dvid_tb.vhd
-- Project Name:  dvid_serdes
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dvid_serdes
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
 
ENTITY dvid_tb IS
END dvid_tb;
 
ARCHITECTURE behavior OF dvid_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dvid_serdes
    PORT(
         clk50 : IN  std_logic;
         tmds_out_p : OUT  std_logic_vector(3 downto 0);
         tmds_out_n : OUT  std_logic_vector(3 downto 0);
         btns : IN  std_logic_vector(5 downto 0);
         leds : OUT  std_logic_vector(1 downto 0);
         rx : IN  std_logic;
         tx : OUT  std_logic;
         seg : OUT  std_logic_vector(6 downto 0);
         seg_an : OUT  std_logic_vector(3 downto 0);
         seg_dot : OUT  std_logic;
         sleds : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk50 : std_logic := '0';
   signal btns : std_logic_vector(5 downto 0) := (others => '0');
   signal rx : std_logic := '0';

 	--Outputs
   signal tmds_out_p : std_logic_vector(3 downto 0);
   signal tmds_out_n : std_logic_vector(3 downto 0);
   signal leds : std_logic_vector(1 downto 0);
   signal tx : std_logic;
   signal seg : std_logic_vector(6 downto 0);
   signal seg_an : std_logic_vector(3 downto 0);
   signal seg_dot : std_logic;
   signal sleds : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk50_period : time := 20 ns;
 
   constant baud_period : time := 104 us;

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dvid_serdes PORT MAP (
          clk50 => clk50,
          tmds_out_p => tmds_out_p,
          tmds_out_n => tmds_out_n,
          btns => btns,
          leds => leds,
          rx => rx,
          tx => tx,
          seg => seg,
          seg_an => seg_an,
          seg_dot => seg_dot,
          sleds => sleds
        );

   -- Clock process definitions
   clk50_process :process
   begin
		clk50 <= '0';
		wait for clk50_period/2;
		clk50 <= '1';
		wait for clk50_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk50_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
