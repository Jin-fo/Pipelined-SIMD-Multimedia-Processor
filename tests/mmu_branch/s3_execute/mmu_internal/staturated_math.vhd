library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.signed_asm.all;

package saturate_math is
	procedure STM_main(
		signal opcode		: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
		in_rs3				: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
		in_rs2				: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
		in_rs1				: in std_logic_vector(REGISTER_LENGTH-1 downto 0);

		signal out_rd	: out std_logic_vector(REGISTER_LENGTH-1 downto 0) 
	);
end package saturate_math;
	
package body saturate_math is 
	procedure STM_main (
		signal opcode		: in std_logic_vector(OPCODE_LENGTH-1 downto 0);
		in_rs3				: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
		in_rs2				: in std_logic_vector(REGISTER_LENGTH-1 downto 0);
		in_rs1				: in std_logic_vector(REGISTER_LENGTH-1 downto 0);

		signal out_rd	: out std_logic_vector(REGISTER_LENGTH-1 downto 0)
	) is
		variable vector32		: std_logic_vector(31 downto 0);
		variable vector64		: std_logic_vector(63 downto 0);
		variable temp_out	: std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '0');	
	begin
		case opcode(2 downto 0) is

			when "000" =>
				for i in 3 downto 0 loop --low 16-bit integer mult-add
					mult_16(	
						in_rs3(16*(i*2+1)-1 downto 16*(i*2)),
						in_rs2(16*(i*2+1)-1 downto 16*(i*2)),
						vector32
					);
					add_32(
						in_rs1(16*(i*2+2)-1 downto 16*(i*2)), 
						vector32, 
						temp_out(16*(i*2+2)-1 downto 16*(i*2))
					);
				end loop;

			when "001" => 
				for i in 3 downto 0 loop --high 16-bit integer mult-add
					mult_16(
						in_rs3(16*(i*2+2)-1 downto 16*(i*2+1)),
						in_rs2(16*(i*2+2)-1 downto 16*(i*2+1)),
						vector32
					);
					add_32(
						in_rs1(16*(i*2+2)-1 downto 16*(i*2)), 
						vector32, 
						temp_out(16*(i*2+2)-1 downto 16*(i*2))
					);
				end loop;

			when "010" =>
				for i in 3 downto 0 loop --low 16-bit integer mult-sub
					mult_16(
						in_rs3(16*(i*2+1)-1 downto 16*(i*2)),
						in_rs2(16*(i*2+1)-1 downto 16*(i*2)),
						vector32
					);
					sub_32(
						in_rs1(16*(i*2+2)-1 downto 16*(i*2)),
						vector32,
						temp_out(16*(i*2+2)-1 downto 16*(i*2))
					);
				end loop;

			when "011" =>
				for i in 3 downto 0 loop --high 16-bit integer mult-sub
					mult_16(
						in_rs3(16*(i*2+2)-1 downto 16*(i*2+1)),
						in_rs2(16*(i*2+2)-1 downto 16*(i*2+1)),
						vector32
					);
					sub_32(
						in_rs1(16*(i*2+2)-1 downto 16*(i*2)),
						vector32,
						temp_out(16*(i*2+2)-1 downto 16*(i*2))
					);
				end loop;

			when "100" =>
				for i in 1 downto 0 loop --low 32-bit integer mult-add
					mult_32(
						in_rs3(32*(i*2+1)-1 downto 32*(i*2)),
						in_rs2(32*(i*2+1)-1 downto 32*(i*2)),
						vector64
					);	 
					add_64(												   
						in_rs1(32*(i*2+2)-1 downto 32*(i*2)),
						vector64,
						temp_out(32*(i*2+2)-1 downto 32*(i*2))
					);
				end loop;

			when "101" =>
				for i in 1 downto 0 loop --high 32-bit integer mult-add
					mult_32(
						in_rs3(32*(i*2+2)-1 downto 32*(i*2+1)),
						in_rs2(32*(i*2+2)-1 downto 32*(i*2+1)),
						vector64
					);
					add_64(
						in_rs1(32*(i*2+2)-1 downto 32*(i*2)),
						vector64,
						temp_out(32*(i*2+2)-1 downto 32*(i*2))
					);
				end loop;

			when "110" =>
				for i in 1 downto 0 loop --low 32-bit integer mult-sub
					mult_32(
						in_rs3(32*(i*2+1)-1 downto 32*(i*2)),
						in_rs2(32*(i*2+1)-1 downto 32*(i*2)),
						vector64
					);
					sub_64(
						in_rs1(32*(i*2+2)-1 downto 32*(i*2)),
						vector64,
						temp_out(32*(i*2+2)-1 downto 32*(i*2))
					);
				end loop;

			when "111" =>
				for i in 1 downto 0 loop --high 32-bit integer mult-sub
					mult_32(
						in_rs3(32*(i*2+2)-1 downto 32*(i*2+1)),
						in_rs2(32*(i*2+2)-1 downto 32*(i*2+1)),
						vector64
					);
					sub_64(
						in_rs1(32*(i*2+2)-1 downto 32*(i*2)),
						vector64,
						temp_out(32*(i*2+2)-1 downto 32*(i*2))
					);
				end loop;

			when others =>			
		end case;
			out_rd <= temp_out;
	end procedure;
end package body saturate_math;