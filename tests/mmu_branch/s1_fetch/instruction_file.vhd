library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;
use work.numeric_var.all;

entity instruction_file is 
	port(			
	--inputs(data)
	if_pc		: in std_logic_vector(COUNTER_LENGTH-1 downto 0);	
	reset_bar	: in std_logic;	  
	in_file		: in std_logic_vector(FILE_SIZE-1 downto 0); 
	  	  
	--outputs(data)
	if_instruc	: out std_logic_vector(INSTRUCTION_LENGTH-1 downto 0)
	);
end entity;

architecture behavior of instruction_file is	
    signal INSTRUC_FILE : std_logic_vector(FILE_SIZE-1 downto 0) := (others => '0');
begin
	reg_file : process(if_pc, reset_bar, in_file)
		variable pc_index : integer;
		variable msb      : integer;
		variable lsb      : integer;
	begin
		if reset_bar = '0' then
			INSTRUC_FILE <= in_file;		--little endian, lsb on the left and msb on the right
		else 	  			  
			pc_index := to_integer(unsigned(if_pc));
			msb := (pc_index * INSTRUCTION_LENGTH + INSTRUCTION_LENGTH) -1;
			lsb := msb - INSTRUCTION_LENGTH + 1;
			if_instruc <= INSTRUC_FILE(msb downto lsb); 
		end if;						 
	end process;
end architecture;
