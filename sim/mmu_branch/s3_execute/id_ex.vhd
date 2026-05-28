library IEEE;
use IEEE.std_logic_1164.all; 
use work.numeric_var.all;

entity id_ex is
	port(	
	--setup
	clk 			: in std_logic;	  
	enable			: in std_logic;
	reset_bar 		: in std_logic;
	
	--inputs(data)
	id_pc			: in std_logic_vector(COUNTER_LENGTH-1 downto 0);
	id_opcode		: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
	
	id_rs3			: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	id_rs2			: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	id_rs1			: in std_logic_vector(REGISTER_LENGTH-1 downto 0); 
	id_immed		: in std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);	
	
	id_rd_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	id_rs3_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	id_rs2_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	id_rs1_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0); 
	
	--inputs(branch)  
	id_target			: in std_logic_vector(COUNTER_LENGTH-1 downto 0);
	id_state		: in std_logic_vector(1 downto 0); 
	id_wback		: in std_logic;	  
	id_pctrl 		: in std_logic;
	id_bctrl			: in std_logic;
	
	--outputs(data) 
	ex_pc			: out std_logic_vector(COUNTER_LENGTH-1 downto 0);
	ex_opcode		: out std_logic_vector(OPCODE_LENGTH-1 downto 0);
	
	ex_rs3			: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
	ex_rs2			: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
	ex_rs1			: out std_logic_vector(REGISTER_LENGTH-1 downto 0); 
	ex_immed		: out std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);	
	
	ex_rd_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	ex_rs3_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	ex_rs2_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	ex_rs1_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0); 
	
	--outputs(branch)  
	ex_target		: out std_logic_vector(COUNTER_LENGTH-1 downto 0);
	ex_state		: out std_logic_vector(1 downto 0);
	ex_wback		: out std_logic;
	ex_pctrl		: out std_logic;
	ex_bctrl			: out std_logic
	);
end id_ex;

architecture behavior of id_ex is
begin
	
	id_ex : process (reset_bar, clk, enable)
	begin
		if reset_bar = '0' then   
			ex_opcode 	<= "110000";
			ex_wback    <= '0';
			ex_pctrl	<= '0';
			ex_bctrl	<= '0';	 
			
		elsif rising_edge(clk) then
			if enable = '1' then   
				ex_pc	<= id_pc;
				ex_opcode 	<= id_opcode; 
				ex_rs3 	<= id_rs3;
				ex_rs2 	<= id_rs2; 
				ex_rs1 	<= id_rs1;
				ex_immed 	<= id_immed; 
				
				ex_rd_ptr  	<= id_rd_ptr;
				ex_rs3_ptr 	<= id_rs3_ptr;
				ex_rs2_ptr 	<= id_rs2_ptr;
				ex_rs1_ptr	 <= id_rs1_ptr;	
				ex_target	<= id_target;
				ex_state   	<= id_state;
				
				ex_wback   	<= id_wback;
				ex_pctrl	<= id_pctrl; 
				ex_bctrl	<= id_bctrl;
			end if;
		end if;	
		
	end process;
end behavior;
