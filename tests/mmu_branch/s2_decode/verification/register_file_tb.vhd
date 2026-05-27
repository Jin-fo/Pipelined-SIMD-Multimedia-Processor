library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use work.numeric_var.all;

entity register_file_tb is
end entity;

architecture tb of register_file_tb is
	
	signal read_sel	  : std_logic_vector(2 downto 0);
	signal id_rs3_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal id_rs2_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal id_rs1_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal wb_rd      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal wb_rd_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal wb_wback   : std_logic := '0';
	signal out_file	  : std_logic_vector(REGISTER_SIZE-1 downto 0);
	signal id_rs3     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal id_rs2     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal id_rs1     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
	
	signal clk        : std_logic := '0';
	constant PERIOD   : time := 10 ns;
	
	function slv_to_str(v : std_logic_vector) return string is
		variable s : string(1 to v'length);
	begin
		for i in v'range loop
			case v(i) is
				when '0' => s(v'length - i) := '0';
				when '1' => s(v'length - i) := '1';
				when others => s(v'length - i) := 'X';
			end case;
		end loop;
		return s;
	end function;
	
begin
	
	DUT : entity work.register_file
	port map(
		read_sel   => read_sel,
		id_rs3_ptr => id_rs3_ptr,
		id_rs2_ptr => id_rs2_ptr,
		id_rs1_ptr => id_rs1_ptr,
		wb_rd	   => wb_rd,
		wb_rd_ptr  => wb_rd_ptr,
		wb_wback   => wb_wback,
		out_file   => out_file,
		id_rs3 => id_rs3,
		id_rs2 => id_rs2,
		id_rs1 => id_rs1
		);
	
	clk_proc : process
	begin
		clk <= '0';
		wait for PERIOD/2;
		clk <= '1';
		wait for PERIOD/2;
	end process;
	
	stim_proc : process
		variable i : integer;
		variable num_regs : integer;
		
	begin
		num_regs := REGISTER_SIZE / REGISTER_LENGTH;
		
		for i in 0 to num_regs - 1 loop
			wb_rd_ptr <= std_logic_vector(to_unsigned(i, ADDRESS_LENGTH));
			wb_rd <= std_logic_vector(to_unsigned(i * 256, REGISTER_LENGTH));
			wb_wback <= '1';
			
			id_rs3_ptr <= std_logic_vector(to_unsigned(i, ADDRESS_LENGTH));
			id_rs2_ptr <= std_logic_vector(to_unsigned(i, ADDRESS_LENGTH));
			id_rs1_ptr <= std_logic_vector(to_unsigned(i, ADDRESS_LENGTH));
			read_sel <= "111";
			
			wait until rising_edge(clk);
		end loop;
		
		wb_wback <= '0';
		wb_rd <= (others => '0');
		wb_rd_ptr <= (others => '0');
		read_sel <= "000";
		
		wait;
	end process;
	
	write_proc : process
		file f_out : text open write_mode is "register_file.txt";
		variable L       : line;
		variable regword : std_logic_vector(REGISTER_LENGTH-1 downto 0);
		variable i       : integer;
		variable num_regs : integer;
		
	begin
		wait until rising_edge(clk);
		
		loop
			num_regs := REGISTER_SIZE / REGISTER_LENGTH;
			
			file_close(f_out);
			file_open(f_out, "src\internal_result\register_file.txt", write_mode);
			
			for i in 0 to num_regs - 1 loop
				regword := out_file(((i+1)*REGISTER_LENGTH)-1 downto i*REGISTER_LENGTH);
				write(L, slv_to_str(regword));
				writeline(f_out, L);
			end loop;
			
			wait until rising_edge(clk);
		end loop;
		
	end process;
	
end architecture tb;