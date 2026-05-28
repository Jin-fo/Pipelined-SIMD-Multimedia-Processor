library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity forward is 
	port (
	--inputs(data)
	ex_rs3		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	ex_rs2		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	ex_rs1		: in std_logic_vector(REGISTER_LENGTH-1 downto 0); 
	ex_rs3_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	ex_rs2_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	ex_rs1_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	ex_pc			: in std_logic_vector(COUNTER_LENGTH-1 downto 0);
	
	--inputs(branch)
	ex_state	: in std_logic_vector(1 downto 0);
	
	--forward(data)
	wb_rd		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	wb_rd_ptr	: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);  --for forwarding address comparision	  \
	wb_wback	: in std_logic;									  
	
	--forward(branch)
	wb_state	: in std_logic_vector(1 downto 0);
	wb_pc		: in std_logic_vector(COUNTER_LENGTH-1 downto 0);
	wb_sctrl	: in std_logic;
	
	--outputs(data)
	fw_rs3		: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
	fw_rs2		: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
	fw_rs1		: out std_logic_vector(REGISTER_LENGTH-1 downto 0);	
	
	--output(branch)
	fw_state	: out std_logic_vector(1 downto 0)
	);
end entity;

architecture behavior of forward is 
begin
	
	main : process(
		ex_rs3, ex_rs2, ex_rs1,
		ex_rs3_ptr, ex_rs2_ptr, ex_rs1_ptr,
		wb_rd, wb_rd_ptr, wb_wback,	
		
		ex_state,
		ex_pc,
		wb_state, wb_pc, wb_sctrl 
		)
		
	begin	
		fw_rs3 <= ex_rs3;
		fw_rs2 <= ex_rs2;
		fw_rs1 <= ex_rs1;	 
		
		fw_state <= ex_state;
		
		-- Apply forwarding if needed
	    if wb_wback = '1' then
	        if wb_rd_ptr = ex_rs3_ptr then fw_rs3 <= wb_rd; end if;
	        if wb_rd_ptr = ex_rs2_ptr then fw_rs2 <= wb_rd; end if;
	        if wb_rd_ptr = ex_rs1_ptr then fw_rs1 <= wb_rd; end if;	 
	    end if;	 
		
		if wb_sctrl = '1' then
			if wb_pc = ex_pc then fw_state <= wb_state; end if;
		end if;
	end process;
end architecture;
