library IEEE;
use IEEE.std_logic_1164.all; 
use work.numeric_var.all;

entity id_ex is
	port(	  
		clk 			: in std_logic;	  
		enable			: in std_logic;
		reset_bar 		: in std_logic;
		
		id_opcode		: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
		
		id_rs3			: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
		id_rs2			: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
		id_rs1			: in std_logic_vector(REGISTER_LENGTH-1 downto 0); 
		id_immed		: in std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);	
		
		id_rs3_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		id_rs2_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		id_rs1_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0); 
		id_rd_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		
		id_wback		: in std_logic;
		
		ex_opcode		: out std_logic_vector(OPCODE_LENGTH-1 downto 0);
		
		ex_rs3			: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
		ex_rs2			: out std_logic_vector(REGISTER_LENGTH-1 downto 0);
		ex_rs1			: out std_logic_vector(REGISTER_LENGTH-1 downto 0); 
		ex_immed		: out std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);	
		
		ex_rs3_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		ex_rs2_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		ex_rs1_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0); 
		ex_rd_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		
		ex_wback		: out std_logic
	);
end id_ex;

architecture behavior of id_ex is
begin
	
	id_ex : process (reset_bar, clk, enable)
	begin
		if reset_bar = '0' then 
			ex_opcode 	<=  (others => '-');
			ex_rs3      <= (others => '-');
			ex_rs2      <= (others => '-');
			ex_rs1      <= (others => '-');
			ex_immed    <= (others => '-');
			
			ex_rs3_ptr  <= (others => '-');
			ex_rs2_ptr  <= (others => '-');
			ex_rs1_ptr  <= (others => '-');
			ex_rd_ptr   <= (others => '-');
			
			ex_wback    <= '0';
		elsif rising_edge(clk) then
			if enable = '1' then 
				ex_opcode <= id_opcode; 
				ex_rs3 <= id_rs3;
				ex_rs2 <= id_rs2; 
				ex_rs1 <= id_rs1;
				ex_immed <= id_immed; 
				
				ex_rs3_ptr <= id_rs3_ptr;
				ex_rs2_ptr <= id_rs2_ptr;
				ex_rs1_ptr <= id_rs1_ptr;	
				ex_rd_ptr  <= id_rd_ptr;
				ex_wback   <= id_wback;
				
			end if;
		end if;	
		
	end process;
end behavior;
