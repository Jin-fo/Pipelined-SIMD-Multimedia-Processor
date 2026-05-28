library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use work.numeric_var.all;

entity decoder_tb is
end decoder_tb;

architecture test_bench of decoder_tb is

    signal id_instruc   : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
    signal id_opcode    : std_logic_vector(OPCODE_LENGTH-1 downto 0);
    signal id_rs3_ptr   : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal id_rs2_ptr   : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal id_rs1_ptr   : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal id_rd_ptr    : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal id_immed     : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
    signal read_sel     : std_logic_vector(2 downto 0);
    signal id_wback     : std_logic;
    signal id_branch    : std_logic;
    signal id_jump      : std_logic;

begin

    UUT : entity work.decoder
        port map (
            id_instruc  => id_instruc,
            id_opcode   => id_opcode,
            id_rs3_ptr  => id_rs3_ptr,
            id_rs2_ptr  => id_rs2_ptr,
            id_rs1_ptr  => id_rs1_ptr,
            id_rd_ptr   => id_rd_ptr,
            id_immed    => id_immed,
            read_sel    => read_sel,
            id_wback    => id_wback,
            id_branch   => id_branch,
            id_jump     => id_jump
        );

    test_proc : process
        file f_in   : text open read_mode is "instruction_file.txt";
        variable L  : line;
        variable str : string(1 to INSTRUCTION_LENGTH);
        variable chunk : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
        
    begin
        while not endfile(f_in) loop
            readline(f_in, L);
            
            if L'length = 0 then
                next;
            end if;
            
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
            
            id_instruc <= chunk;
            wait for 10 ns;
            
        end loop;
        
        file_close(f_in);
        wait;
    end process;

end architecture test_bench;