library IEEE;
use IEEE.std_logic_1164.all;
use work.numeric_var.all;

entity ex_wb is
	port(  
		clk 		: in std_logic;	   
		enable		: in std_logic;
		reset_bar 	: in std_logic;		  
		
		ex_rd		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
		ex_rd_ptr	: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		ex_wback	: in std_logic;		 
		
		wb_rd		: out std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '-');
		wb_rd_ptr	: out std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '-');
		wback		: out std_logic := '0'
	);
end ex_wb;

architecture behavior of ex_wb is
begin	 
	
	ex_wb : process(reset_bar, clk, enable)	   
	begin 
		
		if reset_bar = '0' then 
			wback <= '0'; 
			wb_rd 	  <= (others => '-');
			wb_rd_ptr <= (others => '-');
		elsif rising_edge(clk) then 
			if enable = '1' then
				wback 	<= ex_wback;
				wb_rd		<= ex_rd;
				wb_rd_ptr	<= ex_rd_ptr;
			end if;
		end if;  
	end process;
end architecture;
