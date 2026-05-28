library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package numeric_var is 
--------PROGRAM_COUNTER_CONSTANT-------------------------------------------------
	constant COUNTER_LENGTH 			: integer := 6;
	constant INCREMENT					: integer := 1;	 
	
	constant MAX_COUNT					: integer := 64;
	
--------INSTRUCTION_FILE_CONSTANT-------------------------------------------------	
	constant INSTRUCTION_LENGTH			: integer := 25;
	constant BUFFER_SIZE				: integer := 2**(COUNTER_LENGTH) * (1 + COUNTER_LENGTH);
	constant INSTUCTION_AMOUNT			: integer := 64;
	constant FILE_SIZE					: integer := INSTRUCTION_LENGTH * INSTUCTION_AMOUNT; --buffer size of 64, ie 64 instruction 	
	
	constant IMMEDIATE_LENGTH			: integer := 16;
	constant INDEX_LENGTH				: integer := 3;
	constant OPCODE_LENGTH				: integer := 6;	
	
	constant NOP_INSTRUCTION			: std_logic_vector(INSTRUCTION_LENGTH-1 downto 0) := b"1100000000000000000000000";
--------BRANCH_PREDICTOR_CONSTANT-------------------------------------------------		
	constant STATE_LENGTH			   	: integer := 2;
	constant ENTRY_LENGTH			   	: integer := COUNTER_LENGTH * 2 + STATE_LENGTH;
	constant ENTRY_AMOUNT				: integer := INSTUCTION_AMOUNT/2; 
	
	
--------REGISTER_FILE_CONSTANT-------------------------------------------------	  
	constant REGISTER_LENGTH			: integer := 128;  
	constant REGISTER_SIZE				: integer := REGISTER_LENGTH * 32; --buffer size of 32, ie 32 address

	constant VALUE16					: integer := 16;
	constant ADDRESS_LENGTH				: integer := 5;		 

--------DEBUG_CONSTANT-------------------------------------------------	  
	constant PERIOD					    : time := 10ns;

end package;