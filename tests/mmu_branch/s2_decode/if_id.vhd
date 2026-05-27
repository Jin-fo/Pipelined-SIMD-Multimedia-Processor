library IEEE;
use IEEE.std_logic_1164.all; 
use work.numeric_var.all;

entity if_id is
	port(	
	--setup
	clk			: in std_logic;	  
	enable		: in std_logic;
	reset_bar 	: in std_logic;	 
	
	--inputs(data)
	if_pc		: in std_logic_vector(COUNTER_LENGTH-1 downto 0);
	if_instruc 	: in std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);  
	iff_target	: in std_logic_vector(COUNTER_LENGTH-1 downto 0);
	
	--control
	flush_ctrl	: in std_logic;
	
	--outputs(data)
	id_pc		: out std_logic_vector(COUNTER_LENGTH-1 downto 0);
	id_instruc 	: out std_logic_vector(INSTRUCTION_LENGTH-1 downto 0); 
	ifd_target	: out std_logic_vector(COUNTER_LENGTH-1 downto 0)
	);
end if_id;


architecture behavior of if_id is
begin		
	
	if_id : process (clk)	
	begin 	   				  
		if (flush_ctrl = '1') then
			id_instruc  <= NOP_INSTRUCTION;	
			id_pc	<= (others => '0');
		end if;
		
		if (reset_bar = '0') then
			id_instruc  <= NOP_INSTRUCTION;
		elsif rising_edge(clk) then	
			if enable = '1' then
				id_instruc  <= if_instruc;
				id_pc       <= if_pc;
				ifd_target  <= iff_target;
			end if;   
		end if;
		
	end process;
end architecture;
