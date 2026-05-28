library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.load_immediate.all;
use work.saturate_math.all;
use work.rest_instruction.all; 

entity mmu is 
	port ( 
	--inputs
	opcode		: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
	
	fw_rs3		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	fw_rs2		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	fw_rs1		: in std_logic_vector(REGISTER_LENGTH-1 downto 0); 
	in_immed	: in std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);	
	
	--outputs
	out_rd		: out std_logic_vector(REGISTER_LENGTH-1 downto 0)
	);
end entity;

architecture behavior of mmu is	  
begin 
	main : process(opcode, fw_rs3, fw_rs2, fw_rs1, in_immed)
		variable temp_out_rd : std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '-');
	begin		 

		case opcode(OPCODE_LENGTH-1 downto OPCODE_LENGTH-2) is 
			when "00" | "01" =>
				LDI_memory(		 	--ref. procedure_package/load_immediate.vhd
					opcode, 
					fw_rs3, 
					in_immed,     
					
					temp_out_rd 
				);
			
			when "10" =>
				STM_main(			--ref. procedure_package/saturate_math.vhd
					opcode, 
					fw_rs3, 
					fw_rs2, 
					fw_rs1,  	
					
					temp_out_rd 
				);
			
			when "11" => 
				RSI_main(			--ref. procedure_package/rest_instruction.vhd	
					opcode, 
					fw_rs2, 
					fw_rs1,
					in_immed,	
					
					temp_out_rd 
				);
			
			when others => 
				temp_out_rd  := (others => '-');
		end case;  
		out_rd <= temp_out_rd;
	end process;
end architecture;
				
	
	