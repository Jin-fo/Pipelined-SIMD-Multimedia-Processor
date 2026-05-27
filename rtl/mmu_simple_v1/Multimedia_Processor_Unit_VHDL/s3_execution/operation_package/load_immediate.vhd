library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

package load_immediate is 
	
	procedure LDI_memory(
		opcode		: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
		in_rs3				: in std_logic_vector(REGISTER_LENGTH-1 downto 0); 
		in_immed			: in std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

		out_rd 		: out std_logic_vector(REGISTER_LENGTH-1 downto 0)
	);
end package load_immediate;					 

package body load_immediate is 
	
    procedure LDI_memory ( 
        opcode      : in std_logic_vector(OPCODE_LENGTH-1 downto 0);
        in_rs3      : in std_logic_vector(REGISTER_LENGTH-1 downto 0); 
        in_immed    : in std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
        out_rd      : out std_logic_vector(REGISTER_LENGTH-1 downto 0)
    ) is      
        variable temp_out : std_logic_vector(REGISTER_LENGTH-1 downto 0);          
    begin               
        temp_out := in_rs3;
    
        case opcode(2 downto 0) is
            when "000" =>
                temp_out(15 downto 0) := in_immed;
    
            when "001" =>
                temp_out(31 downto 16) := in_immed;
    
            when "010" =>
                temp_out(47 downto 32) := in_immed;
    
            when "011" =>
                temp_out(63 downto 48) := in_immed;
    
            when "100" =>
                temp_out(79 downto 64) := in_immed;
    
            when "101" =>
                temp_out(95 downto 80) := in_immed;
    
            when "110" =>
                temp_out(111 downto 96) := in_immed;
    
            when "111" =>
                temp_out(127 downto 112) := in_immed;
    
            when others =>
                null;
        end case;
    
        out_rd := temp_out;                     
    end procedure;
end package body load_immediate;
	