library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		
use work.numeric_var.all;

entity target_correct is 
    port(   
        -- Inputs (branch)
        id_pc       : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
        id_immed    : in  std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
        ifd_target  : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
        id_bctrl    : in  std_logic;    
        
        -- Outputs (branch)
        id_target   : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
        id_tctrl    : out std_logic
    );                                      
end entity;

architecture behavior of target_correct is  
begin

    ----------------------------------------------------------------
    -- Target Calculation + Correction (Combinational)
    ----------------------------------------------------------------
    target_proc : process(id_pc, id_immed, id_bctrl, ifd_target)
        variable var_target : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    begin
        -- Branch active
        if (id_bctrl = '1') then

            -- Compute target = PC + immediate
            var_target := std_logic_vector(
                resize(signed(id_pc), COUNTER_LENGTH) +
                resize(signed(id_immed), COUNTER_LENGTH)
            );

            -- Check if correction needed
            if var_target /= ifd_target then
                id_tctrl <= '1';   -- mismatch ? correction needed
            end if;

            -- Output computed target
            id_target <= var_target;   
		else  
			-- ? Default assignments (prevents latches + X propagation)
	        id_target <= (others => '0');
	        id_tctrl  <= '0';

        end if;				

    end process;      

end architecture;