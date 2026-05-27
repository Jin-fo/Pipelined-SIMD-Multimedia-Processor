  library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		
use work.numeric_var.all;

entity predictor is 
    port(  
    --inputs(branch)
    id_target   : in std_logic_vector(COUNTER_LENGTH-1 downto 0);   
    id_state    : in std_logic_vector(1 downto 0); 
	id_jump		: in std_logic; 	
	
	--outputs(branch)
	pred_pc     : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    id_pctrl    : out std_logic
    );								  					   
end entity;	

architecture behavior of predictor is  
begin	
	
	predictor : process(id_target) 	//include all inpute in list	 
		variable var_pctrl : std_logic;
	begin
		
		if id_jump = '1' then
			var_pctrl := '1';
		else 
			if id_state = "10" or id_state = "11" then 
				var_pctrl := '1';
			else 
				var_pctrl := '0';
			end if;	
		end if;
		
		if var_pctrl = '1' then
			pred_pc <= id_target;
		else 
			pred_pc <= (others => '-');
		end if;
			
		id_pctrl <= var_pctrl;
		
	end process;
end architecture;

	
	
