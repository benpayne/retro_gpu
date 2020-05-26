----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz<
-- 
-- Module Name:    dvid_serdes - Behavioral 
-- Description: Generating a DVI-D 720p signal using the OSERDES2 serialisers
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
Library UNISIM;
use UNISIM.vcomponents.all;

entity dvid_serdes is
    Port ( clk50 : in  STD_LOGIC;
           tmds_out_p : out  STD_LOGIC_VECTOR(3 downto 0);
           tmds_out_n : out  STD_LOGIC_VECTOR(3 downto 0);
           btns : in  STD_LOGIC_VECTOR(5 downto 0);
			  leds : out  STD_LOGIC_VECTOR(1 downto 0);
			  rx : in STD_LOGIC;
			  tx : out STD_LOGIC;
           seg : out  STD_LOGIC_VECTOR (6 downto 0);
           seg_an : out  STD_LOGIC_VECTOR (3 downto 0);
           seg_dot : out  STD_LOGIC;
			  sleds : out STD_LOGIC_VECTOR(7 downto 0));
			  
end dvid_serdes;

architecture Behavioral of dvid_serdes is

	signal pixel_clock_t     : std_logic;
	signal data_load_clock_t : std_logic;
	signal ioclock_t         : std_logic;
   signal serdes_strobe_t   : std_logic;
	
	signal red_mux   : std_logic_vector(7 downto 0);

	signal red_t   : std_logic_vector(7 downto 0);
	signal green_t : std_logic_vector(7 downto 0);
	signal blue_t  : std_logic_vector(7 downto 0);
	signal blank_t : std_logic;
	signal hsync_t : std_logic;
	signal vsync_t : std_logic;

   signal tmds_out_red_t   : std_logic;
   signal tmds_out_green_t : std_logic;
   signal tmds_out_blue_t  : std_logic;
   signal tmds_out_clock_t : std_logic;
	
	signal command : std_logic_vector(7 downto 0);
	signal rx_busy : std_logic;
	signal rx_error : std_logic;
	
	
   COMPONENT vga_gen
	PORT(
		clk75 : IN std_logic;          
		red   : OUT std_logic_vector(7 downto 0);
		green : OUT std_logic_vector(7 downto 0);
		blue  : OUT std_logic_vector(7 downto 0);
		blank : OUT std_logic;
		hsync : OUT std_logic;
		vsync : OUT std_logic;
		pattern  : in STD_LOGIC_VECTOR (3 downto 0);
      write_enb : in STD_LOGIC;  
		write_addr : in STD_LOGIC_VECTOR(15 downto 0);
		write_pix : in STD_LOGIC_VECTOR(11 downto 0)
		);
	END COMPONENT;

	COMPONENT clocking
	PORT(
		clk50m          : IN  std_logic;          
		pixel_clock     : OUT std_logic;
		data_load_clock : OUT std_logic;
		ioclock         : OUT std_logic;
		serdes_strobe   : OUT std_logic
		);
	END COMPONENT;

	COMPONENT dvid_out
	PORT(
		pixel_clock     : IN std_logic;
		data_load_clock : IN std_logic;
		ioclock         : IN std_logic;
		serdes_strobe   : IN std_logic;
		red_p : IN std_logic_vector(7 downto 0);
		green_p : IN std_logic_vector(7 downto 0);
		blue_p : IN std_logic_vector(7 downto 0);
		blank : IN std_logic;
		hsync : IN std_logic;
		vsync : IN std_logic;          
		red_s : OUT std_logic;
		green_s : OUT std_logic;
		blue_s : OUT std_logic;
		clock_s : OUT std_logic
		);
	END COMPONENT;

	COMPONENT uart
	PORT(
		clk		:	IN		STD_LOGIC;										--system clock
		reset_n	:	IN		STD_LOGIC;										--ascynchronous reset
		tx_ena	:	IN		STD_LOGIC;										--initiate transmission
		tx_data	:	IN		STD_LOGIC_VECTOR(7 DOWNTO 0);  			--data to transmit
		rx			:	IN		STD_LOGIC;										--receive pin
		rx_busy	:	OUT	STD_LOGIC;										--data reception in progress
		rx_error	:	OUT	STD_LOGIC;										--start, parity, or stop bit error detected
		rx_data	:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);				--data received
		tx_busy	:	OUT	STD_LOGIC;  									--transmission in progress
		tx			:	OUT	STD_LOGIC);										--transmit pin
	END COMPONENT;
	
	COMPONENT display_driver
	generic ( 
		clock_freq : integer;
		n_display : integer;
		refresh_rate : integer);
	port ( 
		clock : in  std_logic;
		reset : in  std_logic;
		input : in  std_logic_vector ((n_display * 4) - 1 downto 0);
		dots_en : in  std_logic_vector (n_display - 1 downto 0);
		display_en : in  std_logic_vector (n_display - 1 downto 0);
		cathodes : out  std_logic_vector (6 downto 0);
		dot : out  std_logic;
		anodes : out  std_logic_vector (n_display - 1 downto 0));
	end COMPONENT;
	
	COMPONENT pixel_writter
   port ( clk : in  STD_LOGIC;
			 cmd_enb : in  STD_LOGIC;
          cmd : in  STD_LOGIC_VECTOR (1 downto 0);
          data : in  STD_LOGIC_VECTOR (31 downto 0);
			 busy : out STD_LOGIC;
          write_addr : out  STD_LOGIC_VECTOR (15 downto 0);
          write_pixel : out  STD_LOGIC_VECTOR (11 downto 0);
          write_enb : out  STD_LOGIC);
	end COMPONENT;
	
	COMPONENT command_decoder
    Port ( clk : in  STD_LOGIC;
           rx_busy : in  STD_LOGIC;
           rx_data : in  STD_LOGIC_VECTOR (7 downto 0);
           cmd : out  STD_LOGIC_VECTOR (1 downto 0);
           cmd_data : out  STD_LOGIC_VECTOR (31 downto 0);
           cmd_enb : out  STD_LOGIC);
	end COMPONENT;
	
	signal s_seg : STD_LOGIC_VECTOR (6 downto 0);
   signal s_seg_an : STD_LOGIC_VECTOR (3 downto 0);
   signal s_seg_dot : STD_LOGIC;
	signal s_display : STD_LOGIC_VECTOR(15 downto 0);
	signal s_column : STD_LOGIC_VECTOR(7 downto 0);
	signal s_row : STD_LOGIC_VECTOR(11 downto 0);
	signal s_pixel : STD_LOGIC_VECTOR(11 downto 0);
	
	TYPE    rx_machine IS(idle, cmd, write_pixel_wait, write_pixel, write_buffer_hdr_wait, write_buffer_hdr, write_buffer_wait, write_buffer); --receive state machine data type
   SIGNAL  rx_state : rx_machine; --receive state machine         

	signal s_rx_addr : STD_LOGIC_VECTOR(15 downto 0);
	signal s_cmd : STD_LOGIC_VECTOR(1 downto 0);
	signal s_cmd_enb : STD_LOGIC;
	signal s_busy : STD_LOGIC;
	
	signal s_write_data : STD_LOGIC_VECTOR(31 downto 0);
	signal s_write_enb : STD_LOGIC;  
	signal s_write_pixels_stb : STD_LOGIC;
	signal s_write_addr_rst : STD_LOGIC;
	signal s_write_addr : STD_LOGIC_VECTOR(15 downto 0);
	signal s_write_pix : STD_LOGIC_VECTOR(11 downto 0);

	signal s_write_pixels : STD_LOGIC_VECTOR(23 downto 0);

begin
	
--debug
	leds(0) <= rx_busy;
	leds(1) <= rx_error;
	sleds <= command;
	
Inst_clocking: clocking PORT MAP(
		clk50m          => clk50,
		pixel_clock     => pixel_clock_t,
		data_load_clock => data_load_clock_t,
		ioclock         => ioclock_t,
		serdes_strobe   => serdes_strobe_t
	);

   
i_vga_gen: vga_gen PORT MAP(
		clk75 => pixel_clock_t,
		red   => green_t,
		green => red_t,
		blue  => blue_t,
		blank => blank_t,
		hsync => hsync_t,
		vsync => vsync_t,
		pattern => btns(3 downto 0),		
		write_enb 		 => s_write_enb,
		write_addr 		 => s_write_addr,
		write_pix 		 => s_write_pix

	);

		

i_dvid_out: dvid_out PORT MAP(
		pixel_clock     => pixel_clock_t,
		data_load_clock => data_load_clock_t,
		ioclock         => ioclock_t,
		serdes_strobe   => serdes_strobe_t,

		red_p           => red_t,
		green_p         => green_t,
		blue_p          => blue_t,
		blank           => blank_t,
		hsync           => hsync_t,
		vsync           => vsync_t,
      
		red_s           => tmds_out_red_t,
		green_s         => tmds_out_green_t,
		blue_s          => tmds_out_blue_t,
		clock_s         => tmds_out_clock_t
		
	);
   
i_uart: uart PORT MAP (
		clk 		=> clk50,
		reset_n	=> '1',
		tx_ena	=> '1',
		tx_data	=> "10101010",
		tx 		=> tx,
		rx 		=> rx,
		rx_data	=> command,
		rx_busy	=> rx_busy,
		rx_error => rx_error
	);

i_display: display_driver 
	GENERIC MAP (
		clock_freq => 50_000_000,
		n_display => 4,
		refresh_rate => 60
	)
	PORT MAP (
		clock => clk50,
		reset => '0',
		input => s_display,
		dots_en => "0000",
		display_en => "1111",
		cathodes => s_seg,
		dot => s_seg_dot,
		anodes => s_seg_an
	);

OBUFDS_red   : OBUFDS port map ( O  => tmds_out_p(2), OB => tmds_out_n(2), I  => tmds_out_green_t);
OBUFDS_green : OBUFDS port map ( O  => tmds_out_p(1), OB => tmds_out_n(1), I  => tmds_out_red_t);
OBUFDS_blue  : OBUFDS port map ( O  => tmds_out_p(0), OB => tmds_out_n(0), I  => tmds_out_blue_t);
OBUFDS_clock : OBUFDS port map ( O  => tmds_out_p(3), OB => tmds_out_n(3), I  => tmds_out_clock_t);

	seg(0) <= not s_seg(0);
	seg(1) <= not s_seg(1);
	seg(2) <= not s_seg(2);
	seg(3) <= not s_seg(3);
	seg(4) <= not s_seg(4);
	seg(5) <= not s_seg(5);
	seg(6) <= not s_seg(6);

	seg_dot <= not s_seg_dot;

	seg_an(3) <= not s_seg_an(0);
	seg_an(2) <= not s_seg_an(1);
	seg_an(1) <= not s_seg_an(2);
	seg_an(0) <= not s_seg_an(3);

	--s_display <= s_write_data(31 downto 24) & s_write_data(19 downto 12);
	s_display <= s_write_addr;
	
i_pixel_writer: pixel_writter
   port map (
		clk => clk50,
		cmd_enb => s_cmd_enb,
		cmd => s_cmd,
		data => s_write_data,
		busy => s_busy,
      write_addr => s_write_addr,
      write_pixel => s_write_pix,
      write_enb => s_write_enb
	);
	
i_command_decoder: command_decoder
	port map ( 
		clk => clk50,
		rx_busy => rx_busy,
		rx_data => command,
		cmd => s_cmd,
		cmd_data => s_write_data, 
		cmd_enb =>s_cmd_enb
	);

end Behavioral;