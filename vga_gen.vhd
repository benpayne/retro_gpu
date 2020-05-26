----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- Description: Generates a test 1280x720 signal 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_gen is
    Port ( clk75 : in  STD_LOGIC;
           pclk  : out STD_LOGIC;
           red   : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
           green : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
           blue  : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
           blank : out STD_LOGIC := '0';
           hsync : out STD_LOGIC := '0';
           vsync : out STD_LOGIC := '0';
			  pattern  : in STD_LOGIC_VECTOR (3 downto 0);
			  write_enb : in STD_LOGIC := '0';
			  write_addr : in STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
			  write_pix : in STD_LOGIC_VECTOR(11 downto 0) := (others => '0')
			  );
end vga_gen;

architecture Behavioral of vga_gen is
   constant h_rez        : natural := 1280;
   constant h_sync_start : natural := 1280+72;
   constant h_sync_end   : natural := 1280+80;
   constant h_max        : natural := 1647;
   signal   h_count      : unsigned(10 downto 0) := (others => '0');

   constant v_rez        : natural :=720;
   constant v_sync_start : natural := 720+3;
   constant v_sync_end   : natural := 720+3+5;
   constant v_max        : natural := 720+29;
   signal   v_count      : unsigned(9 downto 0) := (others => '0');

   signal	row_start	 : unsigned(15 downto 0) := (others => '0');
   signal	vram_addr	 : unsigned(15 downto 0) := (others => '0');
   signal	vram_data	 : std_logic_vector(11 downto 0);

	signal	write_vram_strb : std_logic_vector(0 downto 0);
	
	COMPONENT blk_mem_gen_v7_3
	PORT(
		clka : IN std_logic;          
		wea   : IN std_logic_vector(0 downto 0);
		addra : IN std_logic_vector(15 downto 0);
		dina  : IN std_logic_vector(11 downto 0);
		clkb : IN std_logic;
		addrb : IN std_logic_vector(15 downto 0);
		doutb  : OUT std_logic_vector(11 downto 0)
		);
	END COMPONENT;

begin
	memblk : blk_mem_gen_v7_3
   PORT MAP (
		clka => clk75,
		wea => write_vram_strb,
		addra => write_addr,
		dina => write_pix,
		clkb => clk75,
		addrb => std_logic_vector(vram_addr),
		doutb => vram_data
   );

   pclk <= clk75;
	write_vram_strb(0) <= write_enb;
	
-- draw process   
process(clk75)
   begin
      if rising_edge(clk75) then
			
         if h_count < h_rez and v_count < v_rez then
				
				if pattern ="0000" then
					red   <= std_logic_vector(h_count(10 downto 3));
					green <= std_logic_vector(v_count(9 downto 2));
					blue  <= std_logic_vector(h_count(7 downto 0)+v_count(7 downto 0));            
					blank <= '0';

				else if pattern ="0001" then
					red   <= std_logic_vector(vram_data(11 downto 8) & (3 downto 0 => '0'));
					green   <= std_logic_vector(vram_data(7 downto 4) & (3 downto 0 => '0') );
					blue   <= std_logic_vector(vram_data(3 downto 0) & (3 downto 0 => '0') );
					blank <= '0';

				else if pattern ="1110" then
				
					if (h_count(6) xor v_count(6))='1' then					
						red   <= "11111111";
						green <= "11111111";
						blue  <= "11111111";
					else
					
						red   <= "00000000";
						green <= "00000000";
						blue  <= "00000000";
					end if;			
					blank <= '0';
				
				else if pattern ="1111" then
					if (h_count < 180) or (h_count >= 360+180 and h_count < 720 ) or (h_count >=720 and h_count < 720+180 ) or (h_count >=720+360 ) then					
						green   <= "11111111";
					else
						green   <= "00000000";
					end if;

					if (h_count >= 180 and h_count < 360 ) or (h_count >= 360+180 and h_count < 720 ) or (h_count >=180+720 and h_count < 720+360 ) or (h_count >=720+360  ) then					
						red   <= "11111111";
					else
						red   <= "00000000";
					end if;
				
					if (h_count >= 360 and h_count < 360+180 ) or (h_count >= 720 and h_count < 720+180 ) or (h_count >=180+720 and h_count < 720+360 ) or (h_count >=720+360 ) then					
						blue   <= "11111111";
					else
						blue   <= "00000000";
					end if;
					blank <= '0';

				else if pattern ="1011" then
					red   <= "11111111";
					green <= "00000000";
					blue  <= "00000000";
					blank <= '0';

				else if pattern ="0111" then
					red   <= "00000000";
					green <= "11111111";
					blue  <= "00000000";
					blank <= '0';

				else if pattern ="0011" then
					red   <= "00000000";
					green <= "00000000";
					blue <= "11111111";
					blank <= '0';

				end if;
				end if;
				end if;
				end if;	
				end if;
				end if;
				end if;
				if h_count(1 downto 0) = 3 then
					vram_addr <= vram_addr+1;
				end if;
         else
            red   <= (others => '0');
            green <= (others => '0');
            blue  <= (others => '0');
            blank <= '1';
         end if;

         if h_count >= h_sync_start and h_count < h_sync_end then
            hsync <= '1';
         else
            hsync <= '0';
         end if;
         
         if v_count >= v_sync_start and v_count < v_sync_end then
            vsync <= '1';
         else
            vsync <= '0';
         end if;
         
			
         if h_count = h_max then
            h_count <= (others => '0');
				if v_count(1 downto 0) = 3 then
					row_start <= row_start + 320;
				end if;
            if v_count = v_max then
               v_count <= (others => '0');
               row_start <= (others => '0');
            else
               v_count <= v_count+1;
            end if;
				vram_addr <= row_start;
         else
            h_count <= h_count+1;
         end if;

      end if;
   end process;

end Behavioral;