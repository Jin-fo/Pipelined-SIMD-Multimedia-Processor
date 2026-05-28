  library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		
use work.numeric_var.all;

entity branch_predictor is 
    port(  
    --inputs(branch)
    id_state    : in std_logic_vector(1 downto 0); 
	id_jump		: in std_logic; 	
	
	--outputs(branch)
    id_pctrl    : out std_logic
    );								  					   
end entity;	

architecture behavior of branch_predictor is 
	--signal pctrl_reg : std_logic;
begin	
	
	Control : process(id_state, id_jump) 
		variable pctrl_var : std_logic;
	begin
		if id_state = "10" or id_state = "11" then
			pctrl_var := '1';
		else 
			pctrl_var := '0';
		end if;	
		
		id_pctrl <= pctrl_var or id_jump;
	end process;

end architecture;

	
	