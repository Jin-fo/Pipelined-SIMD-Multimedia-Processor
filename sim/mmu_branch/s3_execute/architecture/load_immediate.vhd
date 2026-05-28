library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

package load_immediate is 
	
	procedure LDI_memory(
		signal opcode		: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
		in_rs3				: in std_logic_vector(REGISTER_LENGTH-1 downto 0); 
		in_immed			: in std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

		signal out_rd 		: out std_logic_vector(REGISTER_LENGTH-1 downto 0) 
	);
end package load_immediate;					 

package body load_immediate is 
	
	procedure LDI_memory ( 
		signal opcode		: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
		in_rs3				: in std_logic_vector(REGISTER_LENGTH-1 downto 0); 
		in_immed			: in std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

		signal out_rd 	: out std_logic_vector(REGISTER_LENGTH-1 downto 0)
	) is 	  
		variable low_bit  	: integer;
		variable high_bit 	: integer;
		variable temp_out 	: std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '0');		  
	begin			   
		temp_out := in_rs3;
		low_bit := to_integer(unsigned(opcode(2 downto 0))) * VALUE16;
		high_bit := low_bit + VALUE16;
		temp_out(high_bit-1 downto low_bit) := in_immed;
		
		out_rd <= temp_out;					 
	end procedure;
end package body load_immediate;