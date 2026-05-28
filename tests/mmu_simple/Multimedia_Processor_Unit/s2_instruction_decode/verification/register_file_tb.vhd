library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use work.numeric_var.all;
use work.decoder.all;

entity register_file_tb is
end entity;

architecture tb of register_file_tb is

    signal clk        : std_logic := '-';
    signal instruc    : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0) := (others => '-');

    signal wb_rd      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal wb_rd_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal in_wback   : std_logic := '0';
	
	signal out_file	  : std_logic_vector(REGISTER_SIZE-1 downto 0);
    signal opcode     : std_logic_vector(OPCODE_LENGTH-1 downto 0);
    signal in_rs3     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal in_rs2     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal in_rs1     : std_logic_vector(REGISTER_LENGTH-1 downto 0);

    signal in_immed   : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

    signal rs3_ptr, rs2_ptr, rs1_ptr, rd_ptr :
        std_logic_vector(ADDRESS_LENGTH-1 downto 0);

    signal out_wback  : std_logic;

	--------------------------------------------------------------------
    -- LOCAL helper function : converts string -> std_logic_vector
    --------------------------------------------------------------------
    function str_to_slv(s : string) return std_logic_vector is
        variable v : std_logic_vector(s'length-1 downto 0);
    begin
        for i in s'range loop
            case s(i) is
                when '0' => v(s'length - i) := '0';
                when '1' => v(s'length - i) := '1';
                when others => v(s'length - i) := 'X';
            end case;
        end loop;
        return v;
    end function;	  
begin

    	clk_process : process
	begin
	    clk <= '0';
	    wait for PERIOD/2;
	    clk <= '1';
	    wait for PERIOD/2;
	end process;	 

    DUT : entity work.register_file
        port map(
            clk       => clk,
            instruc   => instruc,

            wb_rd     => wb_rd,
            wb_rd_ptr => wb_rd_ptr,
            in_wback  => in_wback,
			
			out_file  => out_file,
            opcode    => opcode,

            in_rs3    => in_rs3,
            in_rs2    => in_rs2,
            in_rs1    => in_rs1,

            in_immed  => in_immed,

            rs3_ptr   => rs3_ptr,
            rs2_ptr   => rs2_ptr,
            rs1_ptr   => rs1_ptr,
            rd_ptr    => rd_ptr,
            out_wback => out_wback
        );	
		
	stim_proc : process	
	    file f_in  : text open read_mode  is "instruction_file.txt";
	    variable L       : line;
	    variable str     : string(1 to INSTRUCTION_LENGTH);
	begin			 
	    while not endfile(f_in) loop
			-- read instruction	
			readline(f_in, L);
			read(L, str);
			
			-- apply instruction on rising edge
			instruc <= str_to_slv(str);
			wait until rising_edge(clk);
		end loop;
		wait for PERIOD * 2;
	    report "All instructions processed; register_file.txt updated.";
	    wait;
	end process;
end architecture;
