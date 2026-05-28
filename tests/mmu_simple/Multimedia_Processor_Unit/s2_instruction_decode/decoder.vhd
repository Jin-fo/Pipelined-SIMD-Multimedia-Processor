library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		
use work.numeric_var.all;


package decoder is
	procedure decoder_main(			  
		instruction : in std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);				 
	
		opcode 	: out std_logic_vector(OPCODE_LENGTH-1 downto 0); 
	
		rs3_ptr	: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		rs2_ptr	: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		rs1_ptr	: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);  
		
		immed	: out std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
		
		rd_ptr	: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		wback	: out std_logic;
		read_select	: out std_logic_vector(2 downto 0)
	);
end package decoder;  

package body decoder is	
	procedure decoder_main(		
		instruction : in std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
		opcode 	: out std_logic_vector(OPCODE_LENGTH-1 downto 0); 
	
		rs3_ptr	: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		rs2_ptr	: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		rs1_ptr	: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);  
		
		immed	: out std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
		
		rd_ptr	: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		wback	: out std_logic;	   
		read_select		: out std_logic_vector(2 downto 0)
	) is		   
		variable var_opcode : std_logic_vector(OPCODE_LENGTH-1 downto 0) := (others => '-');  
		variable var_rs3_ptr	: std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '-');
		variable var_rs2_ptr	: std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '-');
		variable var_rs1_ptr	: std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '-');	
		
		variable var_immed  : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0) := (others => '-');	
		variable var_rd_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '-');
		variable var_wback		: std_logic := '0';	
		variable var_read  		: std_logic_vector(2 downto 0) := (others => '0');
		
	begin
	    var_opcode(5 downto 4) := instruction(INSTRUCTION_LENGTH-1 downto INSTRUCTION_LENGTH-2);  

		case var_opcode(5 downto 4) is 
			when "00" | "01" => 
				var_opcode(2 downto 0) 	:= instruction(INSTRUCTION_LENGTH-2 downto INSTRUCTION_LENGTH-4);
				var_opcode(4 downto 3)	:= "00";
				var_immed 				:= instruction(INSTRUCTION_LENGTH-5 downto INSTRUCTION_LENGTH-20);
				var_rs3_ptr				:= instruction(INSTRUCTION_LENGTH-21 downto 0);		
				var_read				:= "100";	
				
				var_rd_ptr 				:= instruction(INSTRUCTION_LENGTH-21 downto 0);  
				var_wback 				:= '1';	
				
			when "10" =>
				var_opcode(2 downto 0) := instruction(INSTRUCTION_LENGTH-3 downto INSTRUCTION_LENGTH-5);
				var_opcode(3) := '0'; 
				
				var_rs3_ptr	 			:= instruction(INSTRUCTION_LENGTH-6 downto INSTRUCTION_LENGTH-10);
				var_rs2_ptr				:= instruction(INSTRUCTION_LENGTH-11 downto INSTRUCTION_LENGTH-15);
				var_rs1_ptr	  			:= instruction(INSTRUCTION_LENGTH-16 downto INSTRUCTION_LENGTH-20);
				var_read				:= "111";	
				
				var_rd_ptr				:= instruction(INSTRUCTION_LENGTH-21 downto 0);
				var_wback 				:= '1';
				
			when "11" => 
				var_opcode(3 downto 0) := instruction(INSTRUCTION_LENGTH-7 downto INSTRUCTION_LENGTH-10);  
				var_rs2_ptr := instruction(INSTRUCTION_LENGTH-11 downto INSTRUCTION_LENGTH-15);
				var_rs1_ptr := instruction(INSTRUCTION_LENGTH-16 downto INSTRUCTION_LENGTH-20);
				var_rd_ptr	:= instruction(INSTRUCTION_LENGTH-21 downto 0);	   
				var_wback 		:= '1';	
				case var_opcode(3 downto 0) is 	
					when "0000" =>
						var_wback 	:= '0';
						var_read := (others => '0');
					when "0001" => 	
						var_immed 		:= b"000000000000" & instruction(INSTRUCTION_LENGTH-12 downto INSTRUCTION_LENGTH-15); 
						var_read     := "001";		
					when "1010" =>
						var_immed	:= b"00000000000" & instruction(INSTRUCTION_LENGTH-11 downto INSTRUCTION_LENGTH-15);    
						var_read	:= "001";
					when others => 
						var_read := "011";
				end case;
			when others => 
			var_opcode := (others => '-');
			var_read := (others => '0');
		end case;		
			opcode	:= var_opcode;
			rs3_ptr := var_rs3_ptr;	
			rs2_ptr := var_rs2_ptr;
			rs1_ptr := var_rs1_ptr;	
			immed	:= var_immed;
			rd_ptr	:= var_rd_ptr;
			wback	:= var_wback;	
			read_select := var_read;
 
	end procedure;

end package body decoder;
