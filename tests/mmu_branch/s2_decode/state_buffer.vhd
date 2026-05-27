library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		
use work.numeric_var.all;

entity state_buffer is 
    port(
	--inputs(branch)
	clk			: in  std_logic;
    id_pc       : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
    id_bctrl    : in  std_logic; 
    
    --wback(branch)
    wb_pc       : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
    wb_state    : in  std_logic_vector(1 downto 0);
    wb_sctrl    : in  std_logic; 
    
    --outputs(branch)	  
    id_state    : out std_logic_vector(1 downto 0);
	out_buffer	: out std_logic_vector(BUFFER_SIZE-1 downto 0)
    );								  					   
end entity;

architecture behavior of state_buffer is  
    type entry is record
        valid : std_logic;
        state : std_logic_vector(1 downto 0);
    end record;

    type state_array is array(0 to 2**(COUNTER_LENGTH)-1) of entry;

    signal TSB : state_array := (others => (valid => '0', state => "00"));
begin	
	
	----------------------------------------------------------------
	-- Process 2 : State Lookup + Prediction
	----------------------------------------------------------------
	state_read : process(id_pc, id_bctrl, wb_sctrl, wb_state, wb_pc)
	    variable i   	: integer range 0 to 2**(COUNTER_LENGTH)-1;
	    variable var_state  : std_logic_vector(1 downto 0);
	begin
	
	    if (id_bctrl = '1') then
		   	-- Forward State
			if wb_sctrl = '1' and wb_pc = id_pc then 
				var_state := wb_state;
			else 	
		        -- Read State
		        i := to_integer(unsigned(id_pc));
		        if TSB(i).valid = '1' then
		            var_state := TSB(i).state;
				else 
					var_state := "10";
		        end if;			
			
		    end if;
		else 	
			var_state := "01";
	    end if;	
		
		-- Drive outputs 
		id_state <= var_state;
	end process;		
	
	--make it clk
	state_write : process(clk)
	    variable j : integer range 0 to 2**(COUNTER_LENGTH)-1;
	begin	 
		if falling_edge(clk) then
	    	j := to_integer(unsigned(wb_pc));
		    if wb_sctrl = '1' then
		        TSB(j).valid <= '1';
		        TSB(j).state <= wb_state;
		    end if;					   
		end if;	
	end process;

	debug : process(TSB, wb_sctrl) is
	    variable bit_index : integer := 0;
	begin	   
		out_buffer <= (others => '0');
		
	    if wb_sctrl = '1' then
	        bit_index := 0;
	        for i in 0 to (2**(COUNTER_LENGTH)-1) loop
	            -- valid bit
	            out_buffer(bit_index) <= TSB(i).valid;
	
	            -- 2-bit state
	            out_buffer(bit_index + 2 downto bit_index + 1) <= TSB(i).state;
	
	            bit_index := bit_index + 3;
	        end loop;
	    end if;
	end process;
	
end architecture;