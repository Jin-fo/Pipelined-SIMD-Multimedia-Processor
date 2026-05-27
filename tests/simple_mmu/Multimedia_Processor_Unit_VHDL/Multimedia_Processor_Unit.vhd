library ieee;
use ieee.std_logic_1164.all;
use work.numeric_var.all;
use work.all;

entity Multimedia_Processor_Unit is	 
	port (		 	  
	--unit input
	clk 		: in std_logic;	  
	enable		: in std_logic;
	reset_bar 	: in std_logic;
	in_file 	: in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);   
	
	--unit output
	out_file	: out std_logic_vector(REGISTER_SIZE-1 downto 0);  
	
	--test beanch signals
    pc_count_tb    : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    if_instruc_tb  : out std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
    id_instruc_tb  : out std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

    id_opcode_tb   : out std_logic_vector(OPCODE_LENGTH-1 downto 0);
    ex_opcode_tb   : out std_logic_vector(OPCODE_LENGTH-1 downto 0);

    id_rs3_tb      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    id_rs2_tb      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    id_rs1_tb      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);

    ex_rs3_tb      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    ex_rs2_tb      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    ex_rs1_tb      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    ex_rd_tb       : out std_logic_vector(REGISTER_LENGTH-1 downto 0);

    id_immed_tb    : out std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
    ex_immed_tb    : out std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

    id_rs3_ptr_tb  : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    id_rs2_ptr_tb  : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    id_rs1_ptr_tb  : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    id_rd_ptr_tb   : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);

    id_wback_tb    : out std_logic;

    ex_rs3_ptr_tb  : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    ex_rs2_ptr_tb  : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    ex_rs1_ptr_tb  : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    ex_rd_ptr_tb   : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);

    ex_wback_tb    : out std_logic;

    wb_rd_tb       : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    wb_rd_ptr_tb   : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    wb_wback_tb    : out std_logic
	);
end Multimedia_Processor_Unit;

architecture structural of Multimedia_Processor_Unit is	 
	signal pc_count 	: std_logic_vector(COUNTER_LENGTH-1 downto 0);
	signal if_instruc 	: std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
	signal id_instruc 	: std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);	
	
	signal id_opcode 	  	: std_logic_vector(OPCODE_LENGTH-1 downto 0);	 
	signal ex_opcode 	  	: std_logic_vector(OPCODE_LENGTH-1 downto 0);	
	
	signal id_rs3			: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal id_rs2			: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal id_rs1			: std_logic_vector(REGISTER_LENGTH-1 downto 0);	
	
	signal ex_rs3			: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal ex_rs2			: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal ex_rs1			: std_logic_vector(REGISTER_LENGTH-1 downto 0);	
	signal ex_rd			: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	
	signal id_immed		: std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
	signal ex_immed		: std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
	
	signal id_rs3_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal id_rs2_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal id_rs1_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal id_rd_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0); 
	
	signal id_wback		: std_logic;
	
	signal ex_rs3_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal ex_rs2_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal ex_rs1_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal ex_rd_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	
	signal ex_wback		: std_logic;
	
	signal wb_rd		: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal wb_rd_ptr	: std_logic_vector(ADDRESS_LENGTH-1 downto 0);		 
	signal wb_wback		: std_logic;
begin				 
	P_C : entity work.pc(behavior)				  
		port map (	 
		--control
		clk 		=> clk,	
		enable		=> enable,
		reset_bar 	=> reset_bar,
		--output
		pc_count 	=> pc_count); 

	I_File : entity work.instruction_file(behavior)		
		port map (	  
		--input
		clk         => clk,
		pc_count 	=> pc_count,
		in_file		=> in_file,	
		reload_bar	=> reset_bar,
		--output
		instruc 	=> if_instruc);
		
	IF_ID : entity work.if_id(behavior)
		port map (	
		--control
		clk			=> clk,	  
		enable		=> enable,
		reset_bar 	=> reset_bar,
		--input
		if_instruc 	=> if_instruc, 
		--output
		id_instruc  => id_instruc);
		
	R_File : entity work.register_file(behavior)
		port map (
		--input
		clk         => clk,	  
		instruc 	=> id_instruc, 
		
		--write back 
		wb_rd		=> wb_rd,	  
		wb_rd_ptr	=> wb_rd_ptr,
		in_wback	=> wb_wback,	  
		
		--output			
		out_file 	=> out_file,
		opcode 		=> id_opcode,
		
		in_rs3	 	=> id_rs3,
		in_rs2		=> id_rs2,
		in_rs1		=> id_rs1,	 
		
		in_immed	=> id_immed,
		
		rs3_ptr 	=> id_rs3_ptr, 
		rs2_ptr		=> id_rs2_ptr, 
		rs1_ptr	   	=> id_rs1_ptr,
		rd_ptr		=> id_rd_ptr,
		out_wback	=> id_wback);
		
	ID_EX : entity work.id_ex(behavior)
		port map (	
		--control
		clk 		=> clk,	 
		enable		=> enable,
		reset_bar 	=> reset_bar,
		
		--input
		id_opcode	=> id_opcode,
		
		id_rs3		=> id_rs3,
		id_rs2		=> id_rs2,
		id_rs1 		=> id_rs1,
		id_immed 	=> id_immed,
		
		id_rs3_ptr	=> id_rs3_ptr,			
		id_rs2_ptr	=> id_rs2_ptr,		  
		id_rs1_ptr	=> id_rs1_ptr, 
		id_rd_ptr	=> id_rd_ptr, 
		
		id_wback	=> id_wback,
		
		--output
		ex_opcode	=> ex_opcode,
		
		ex_rs3		=> ex_rs3,
		ex_rs2		=> ex_rs2,
		ex_rs1		=> ex_rs1,
		ex_immed   	=> ex_immed,
		
		ex_rs3_ptr  => ex_rs3_ptr,
		ex_rs2_ptr	=> ex_rs2_ptr,
		ex_rs1_ptr	=> ex_rs1_ptr,
		ex_rd_ptr	=> ex_rd_ptr,
		
		ex_wback	=> ex_wback); 
		
	MMU_ALU : entity work.mmu(behavior)
		port map ( 
		--inputs
		opcode		=> ex_opcode,		
		
		in_rs3 		=> ex_rs3,
		in_rs2		=> ex_rs2,
		in_rs1		=> ex_rs1,
		in_immed	=> ex_immed,
		
		rs3_ptr		=> ex_rs3_ptr,
		rs2_ptr		=> ex_rs2_ptr,
		rs1_ptr		=> ex_rs1_ptr,
		--write back
		wb_rd		=> wb_rd,
		wb_rd_ptr	=> wb_rd_ptr,
		in_wback	=> wb_wback,
		
		--output
		out_rd		=> ex_rd);	
		
	EX_ID : entity work.ex_wb(behavior) 
		port map ( 	 
		--control
		clk 		=> clk,
		enable		=> enable,
		reset_bar 	=> reset_bar,  
		--input 
		ex_rd		=> ex_rd,
		ex_rd_ptr	=> ex_rd_ptr, 
		ex_wback	=> ex_wback,
		
		--output 		
		wb_rd		=> wb_rd,
		wb_rd_ptr	=> wb_rd_ptr,
		wback		=> wb_wback);		
		
	--exposed signal for test-beanch	  
	pc_count_tb    <= pc_count;
	if_instruc_tb  <= if_instruc;
	id_instruc_tb  <= id_instruc;
	
	id_opcode_tb   <= id_opcode;
	ex_opcode_tb   <= ex_opcode;
	
	id_rs3_tb      <= id_rs3;
	id_rs2_tb      <= id_rs2;
	id_rs1_tb      <= id_rs1;
	
	ex_rs3_tb      <= ex_rs3;
	ex_rs2_tb      <= ex_rs2;
	ex_rs1_tb      <= ex_rs1;
	ex_rd_tb       <= ex_rd;
	
	id_immed_tb    <= id_immed;
	ex_immed_tb    <= ex_immed;
	
	id_rs3_ptr_tb  <= id_rs3_ptr;
	id_rs2_ptr_tb  <= id_rs2_ptr;
	id_rs1_ptr_tb  <= id_rs1_ptr;
	id_rd_ptr_tb   <= id_rd_ptr;
	
	id_wback_tb    <= id_wback;
	
	ex_rs3_ptr_tb  <= ex_rs3_ptr;
	ex_rs2_ptr_tb  <= ex_rs2_ptr;
	ex_rs1_ptr_tb  <= ex_rs1_ptr;
	ex_rd_ptr_tb   <= ex_rd_ptr;
	
	ex_wback_tb    <= ex_wback;
	
	wb_rd_tb       <= wb_rd;
	wb_rd_ptr_tb   <= wb_rd_ptr;
	wb_wback_tb    <= wb_wback;

end architecture;
