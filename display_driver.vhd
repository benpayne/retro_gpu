library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity display_driver is
	generic ( clock_freq : integer;
	n_display : integer;
	refresh_rate : integer);

	port ( clock : in  std_logic;
	reset : in  std_logic;
	input : in  std_logic_vector ((n_display * 4) - 1 downto 0);
	dots_en : in  std_logic_vector (n_display - 1 downto 0);
	display_en : in  std_logic_vector (n_display - 1 downto 0);
	cathodes : out  std_logic_vector (6 downto 0);
	dot : out  std_logic;
	anodes : out  std_logic_vector (n_display - 1 downto 0));
end display_driver;

architecture behavioral of display_driver is

	component display_decoder
	port( nibble : in std_logic_vector(3 downto 0);          
		segments : out std_logic_vector(6 downto 0));
	end component;

	constant clock_div : integer := clock_freq / refresh_rate / n_display;
	constant clock_div_bits : integer := integer(ceil(log2(real(clock_div))));
	constant n_display_bits : integer := integer(ceil(log2(real(n_display))));

	signal clock_counter : unsigned(clock_div_bits - 1 downto 0);

	signal nibble_clock : std_logic;

	signal nibble_counter : unsigned(n_display_bits - 1 downto 0);

	signal nibble_mux : std_logic_vector (3 downto 0);
	signal dot_mux : std_logic;
	signal anodes_mux : std_logic_vector (n_display - 1 downto 0);

	signal cathodes_internal : std_logic_vector (6 downto 0);
	signal cathodes_mux : std_logic_vector (6 downto 0);

begin

	nibble_mux <= input((to_integer(nibble_counter) + 1) * 4 - 1 downto to_integer(nibble_counter) * 4);
	dot_mux <= dots_en(to_integer(nibble_counter));
	anodes_mux <= std_logic_vector(to_unsigned(2 ** to_integer(unsigned(nibble_counter)), n_display));
	cathodes_mux <= cathodes_internal when display_en(to_integer(unsigned(nibble_counter))) = '1' else (others => '0');

	inst_display_decoder: display_decoder port map(
		nibble => nibble_mux,
		segments => cathodes_internal
	);

	process (clock)
	begin
		if rising_edge(clock) then
			if reset = '1' then
				cathodes <= (others => '0');
				dot <= '0';
				anodes <= (others => '0');
			else
				cathodes <= cathodes_mux;
				dot <= dot_mux;
				anodes <= anodes_mux;
			end if;
		end if;
	end process;

	process (clock)
	begin
		if rising_edge(clock) then
			if reset = '1' or clock_counter = clock_div then
				clock_counter <= to_unsigned(0, clock_div_bits);
			else
				clock_counter <= clock_counter + 1;
			end if;
		end if;
	end process;

	process (clock_counter)
	begin
		nibble_clock <= '0';

		if clock_counter = to_unsigned(clock_div, clock_div_bits) then
			nibble_clock <= '1';
		end if;
	end process;

	process (clock)
	begin
		if rising_edge(clock) then
			if reset = '1' then
				nibble_counter <= (others => '0');
			elsif nibble_clock = '1' then
				if nibble_counter = n_display - 1 then
					nibble_counter <= (others => '0');
				else
					nibble_counter <= nibble_counter + 1;
				end if;
			end if;
		end if;
	end process;

end behavioral;
