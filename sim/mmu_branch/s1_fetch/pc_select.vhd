library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity pc_select is
    port(
        --inputs(default)
        pc_current     : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);  
		
		--inputs(predict)
        pred_pc    : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
        id_pctrl   : in  std_logic;	 
		
		--inputs(flush)
        brch_pc    : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
        flush_ctrl : in  std_logic;

        --outputs
        pc_next    : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
        if_pc      : out std_logic_vector(COUNTER_LENGTH-1 downto 0)
    );
end entity;

architecture behavior of pc_select is
begin

	process(pc_current, pred_pc, id_pctrl, brch_pc, flush_ctrl)
    	variable var_next : unsigned(COUNTER_LENGTH-1 downto 0);
	begin
	    -- priority: flush > predict > sequential
	    if flush_ctrl = '1' then
	        pc_next  <= std_logic_vector(unsigned(brch_pc) + INCREMENT);
	        if_pc    <= brch_pc;
	
	    elsif id_pctrl = '1' then
	        pc_next  <= std_logic_vector(unsigned(pred_pc) + INCREMENT);
	        if_pc    <= pred_pc;  
		else 
			-- default: sequential
	    	pc_next  <= std_logic_vector(unsigned(pc_current) + INCREMENT);
	    	if_pc    <= pc_current;
	    end if;
	
	end process;

end architecture;