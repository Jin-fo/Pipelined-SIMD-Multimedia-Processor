library IEEE;
use IEEE.std_logic_1164.all; 
use work.numeric_var.all;

entity if_id is
	port(				  
		clk			: in std_logic;	  
		enable		: in std_logic;
		reset_bar 	: in std_logic;
		if_instruc 		: in std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
		id_instruc 		: out std_logic_vector(INSTRUCTION_LENGTH-1 downto 0):= (others => '-') 
	);
end if_id;


architecture behavior of if_id is
begin		
	
	if_id : process (reset_bar, clk, enable)	
		--variable var_instruc : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
	begin 
		if reset_bar = '0' then
			id_instruc <= (others => '-');
		elsif rising_edge(clk) then	
			if enable = '1' then
				id_instruc <= if_instruc;
			end if;   
		end if;	 		
	end process;
end behavior;
