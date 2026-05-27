library IEEE;
use IEEE.std_logic_1164.all;
use work.numeric_var.all;

entity ex_wb is
	port(  
	--setup
	clk 		: in std_logic;	   
	enable		: in std_logic;
	reset_bar 	: in std_logic;	
	
	--inputs(data) 
	ex_rd		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	ex_rd_ptr	: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	ex_wback	: in std_logic;	
	
	--inputs(branch) 
	ex_pc		: in std_logic_vector(COUNTER_LENGTH-1 downto 0);
	ex_sctrl	: in std_logic;	
	ex_state	: in std_logic_vector(1 downto 0);	 
	
	--outputs(data)
	wb_rd		: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
	wb_rd_ptr	: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	wb_wback	: out std_logic := '0';	
	
	--outputs(branch)
	wb_pc		: out std_logic_vector(COUNTER_LENGTH-1 downto 0);
	wb_sctrl	: out std_logic;
	wb_state	: out std_logic_vector(1 downto 0)
	);
end ex_wb;

architecture behavior of ex_wb is
begin	 
	
	ex_wb : process(reset_bar, clk, enable)	   
	begin 
		
		if reset_bar = '0' then 
			wb_wback <= '0'; 	 
			wb_sctrl <= '0';	 
		elsif rising_edge(clk) then 
			if enable = '1' then
				wb_wback 	<= ex_wback;
				wb_rd		<= ex_rd;
				wb_rd_ptr	<= ex_rd_ptr;
				
				wb_pc		<= ex_pc;
				wb_sctrl	<= ex_sctrl;
				wb_state	<= ex_state;
			end if;
		end if;  
	end process;
end architecture;
