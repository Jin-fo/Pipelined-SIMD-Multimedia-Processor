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
	
	in_rs3		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	in_rs2		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	in_rs1		: in std_logic_vector(REGISTER_LENGTH-1 downto 0); 
	in_immed	: in std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);	
	
	--fowarding
	rs3_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	rs2_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	rs1_ptr		: in std_logic_vector(ADDRESS_LENGTH-1 downto 0); 
	
	wb_rd		: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
	wb_rd_ptr	: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);  --for forwarding address comparision
	in_wback	: in std_logic;
	
	--outputs
	out_rd		: out std_logic_vector(REGISTER_LENGTH-1 downto 0)
	);
end entity;

architecture behavior of mmu is	  
begin 
	main : process(opcode, in_rs3, in_rs2, in_rs1, in_immed, rs3_ptr, rs2_ptr, rs1_ptr, wb_rd, wb_rd_ptr, in_wback)
		variable var_opcode : std_logic_vector(OPCODE_LENGTH-1 downto 0);
		variable temp_out_rd : std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '-');
		variable fw_rs3 : std_logic_vector(REGISTER_LENGTH-1 downto 0);
		variable fw_rs2 : std_logic_vector(REGISTER_LENGTH-1 downto 0);
		variable fw_rs1 : std_logic_vector(REGISTER_LENGTH-1 downto 0);
	begin		 
	
	    var_opcode := opcode; 
		-- no forward pre-set
	    fw_rs3 := in_rs3;
	    fw_rs2 := in_rs2;
	    fw_rs1 := in_rs1;
	
	    -- Apply forwarding if needed
	    if in_wback = '1' then
	        if wb_rd_ptr = rs3_ptr then fw_rs3 := wb_rd; end if;
	        if wb_rd_ptr = rs2_ptr then fw_rs2 := wb_rd; end if;
	        if wb_rd_ptr = rs1_ptr then fw_rs1 := wb_rd; end if;
	    end if;

		case opcode(OPCODE_LENGTH-1 downto OPCODE_LENGTH-2) is 
			when "00" | "01" =>
				LDI_memory(		 	--ref. procedure_package/load_immediate.vhd
					var_opcode, 
					fw_rs3, 
					in_immed,     
					
					temp_out_rd 
				);
			
			when "10" =>
				STM_main(			--ref. procedure_package/saturate_math.vhd
					var_opcode, 
					fw_rs3, 
					fw_rs2, 
					fw_rs1,  	
					
					temp_out_rd 
				);
			
			when "11" => 
				RSI_main(			--ref. procedure_package/rest_instruction.vhd	
					var_opcode, 
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
				
	
	