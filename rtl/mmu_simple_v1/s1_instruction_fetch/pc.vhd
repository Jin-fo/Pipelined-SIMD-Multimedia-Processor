library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use work.numeric_var.all;

entity pc is
	port(				  
	clk			: in std_logic;	 
	enable		: in std_logic;
	reset_bar 	: in std_logic;
	pc_count	: out std_logic_vector(COUNTER_LENGTH-1 downto 0) := (others => '0');
	pc_done        : out std_logic
	);
end pc;


architecture behavior of pc is
begin
    pc : process (reset_bar, clk)
		variable count : unsigned(COUNTER_LENGTH-1 downto 0) := (others => '0');
		variable start_zero : std_logic := '1';
		variable var_done : std_logic := '0';
    begin
        if reset_bar = '0' then
            count := (others => '0'); 
            var_done := '0';
			start_zero := '1';
        elsif rising_edge(clk) then	  	
            if enable = '1' then 
				if start_zero = '1' then 
					count := (others => '0'); 
					var_done := '0';
					start_zero := '0';
				elsif count < MAX_COUNT-1 then 
                	count := count + INCREMENT; 
                	var_done := '0';
                elsif count = MAX_COUNT-1 then
                    var_done := '1'; 
				end if;
            end if;
        end if;
        pc_done <= var_done; 
        pc_count <= std_logic_vector(count);
    end process;
end architecture;
