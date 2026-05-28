library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity pc is
    port(  
		--setup
        clk        : in  std_logic;
        enable     : in  std_logic;
        reset_bar  : in  std_logic;	
		
		--inputs
        pc_next    : in  std_logic_vector(COUNTER_LENGTH-1 downto 0); 
		
		--outputs
        pc_current     : out std_logic_vector(COUNTER_LENGTH-1 downto 0)
    );
end entity;

architecture behavior of pc is
    signal pc_reg : unsigned(COUNTER_LENGTH-1 downto 0);
begin

	process(clk, reset_bar)
	begin
	    if reset_bar = '0' then
	        pc_reg <= (others => '0');
	
	    elsif rising_edge(clk) then
	        if enable = '1' then
	            pc_reg <= unsigned(pc_next);
	        end if;
	    end if;
	end process;
	
	pc_current <= std_logic_vector(pc_reg);

end architecture;