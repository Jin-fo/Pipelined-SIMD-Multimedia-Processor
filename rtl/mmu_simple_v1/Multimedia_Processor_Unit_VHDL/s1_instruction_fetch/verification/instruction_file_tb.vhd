library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use ieee.numeric_std.all;
use work.numeric_var.all;
use work.all;

entity instruction_file_tb is
end entity;

architecture tb of instruction_file_tb is

    --------------------------------------------------------------------
    -- Helper Function: std_logic_vector -> hex string
    --------------------------------------------------------------------
    function slv_to_hex(slv : std_logic_vector) return string is
        variable num_nibbles : integer := (slv'length + 3) / 4;
        variable padded_slv  : std_logic_vector(num_nibbles*4 - 1 downto 0);
        variable result      : string(1 to num_nibbles);
        variable nibble_val  : integer;
    begin
        padded_slv := (others => '0');
        padded_slv(slv'length-1 downto 0) := slv;

        for i in 0 to num_nibbles - 1 loop
            nibble_val := to_integer(unsigned(
                padded_slv((i+1)*4 - 1 downto i*4)
            ));
            if nibble_val < 10 then
                result(num_nibbles - i) := character'VAL(nibble_val + character'POS('0'));
            else
                result(num_nibbles - i) := character'VAL(nibble_val - 10 + character'POS('A'));
            end if;
        end loop;
        return result;
    end function;
    --------------------------------------------------------------------

    signal pc_count : std_logic_vector(COUNTER_LENGTH-1 downto 0) := (others => '0');
    signal reload_bar   : std_logic := '0';
    signal in_file  : std_logic_vector(FILE_SIZE-1 downto 0) := (others => '0');
    signal instruc  : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

    constant NUM_INSTR : integer := FILE_SIZE / INSTRUCTION_LENGTH;

begin

    UUT : entity work.instruction_file
        port map (
            pc_count => pc_count,
            in_file  => in_file,
            reload_bar   => reload_bar,
            instruc  => instruc
        );			
			
	Load_Instructions : process
	    file f            : text open read_mode is "instruction_file.txt";
	    variable L        : line;
	    variable str      : string(1 to INSTRUCTION_LENGTH);
	    variable chunk    : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
	    variable little_endian      : std_logic_vector(FILE_SIZE-1 downto 0);
	
	    -- LITTLE-ENDIAN: start at LOW address
	    variable index    : integer := 0;
	begin
	    little_endian := (others => '0');
	
	    while not endfile(f) loop
	        readline(f, L);    
	        read(L, str);       
		 
	        for i in 1 to INSTRUCTION_LENGTH loop
	            if str(i) = '0' then
	                chunk(INSTRUCTION_LENGTH - i) := '0';
	            elsif str(i) = '1' then
	                chunk(INSTRUCTION_LENGTH - i) := '1';
	            else
	                chunk(INSTRUCTION_LENGTH - i) := 'X';
	            end if;
	        end loop;
	
	        little_endian(index + INSTRUCTION_LENGTH - 1 downto index) := chunk;
	
	        index := index + INSTRUCTION_LENGTH;
	    end loop;
	
	    in_file <= little_endian;
	
	    wait;
	end process;


    stimulus : process
		variable expected : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0); 
		variable pc	: integer;
    begin
		reload_bar <= '0'; 
		wait for PERIOD/2;	
		reload_bar <= '1';
		pc_count <= (others => '0');

	for pc in 0 to NUM_INSTR-1 loop
	    pc_count <= std_logic_vector(to_unsigned(pc, COUNTER_LENGTH));
		wait for PERIOD;
	    expected :=
	        in_file((pc+1)*INSTRUCTION_LENGTH - 1 downto pc*INSTRUCTION_LENGTH);
	
	    assert instruc = expected
	        report "FAIL PC=" & integer'image(pc) &
	               " got=" & slv_to_hex(instruc) &
	               " expected=" & slv_to_hex(expected)
	        severity error;
	
	    report "PASS PC=" & integer'image(pc) &
	           " instr=" & slv_to_hex(instruc);
	end loop;

        report "TEST COMPLETE";
        wait;
    end process;

end architecture;
