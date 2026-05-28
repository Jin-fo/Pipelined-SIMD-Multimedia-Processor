library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use work.numeric_var.all;
use work.decoder.all;

entity write_back_tb is
end entity;

architecture tb of write_back_tb is

    signal clk        : std_logic := '0';
    signal instruc    : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0) := (others => '-');

    signal wb_rd      : std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '-');
    signal wb_rd_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '-');
    signal in_wback   : std_logic := '0';

    signal out_file   : std_logic_vector(REGISTER_SIZE-1 downto 0);
    signal opcode     : std_logic_vector(OPCODE_LENGTH-1 downto 0);
    signal in_rs3     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal in_rs2     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal in_rs1     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal in_immed   : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

    signal rs3_ptr, rs2_ptr, rs1_ptr, rd_ptr :
        std_logic_vector(ADDRESS_LENGTH-1 downto 0);

    signal out_wback  : std_logic;

    --------------------------------------------------------------------
    -- string ? slv helpers
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
    end;

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
    end;

begin

    --------------------------------------------------------------------
    -- Clock generator
    --------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0'; wait for PERIOD/2;
        clk <= '1'; wait for PERIOD/2;
    end process;


    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
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


    --------------------------------------------------------------------
    -- Stimulus
    --------------------------------------------------------------------
    stim_proc : process
        file f_in  : text open read_mode  is "instruction_file.txt";
        file f_out : text open write_mode is "src/register_file.txt";

        variable L        : line;
        variable str      : string(1 to INSTRUCTION_LENGTH);
        variable word128  : std_logic_vector(127 downto 0);
        variable reg4096  : std_logic_vector(REGISTER_SIZE-1 downto 0);

        variable temp_out : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    begin

        ----------------------------------------------------------------
        -- Loop through input lines
        ----------------------------------------------------------------
        while not endfile(f_in) loop

            ------------------------------
            -- Read instruction
            ------------------------------
            readline(f_in, L);
            read(L, str);

            ------------------------------
            -- Apply instruction (posedge)
            ------------------------------
            wait until rising_edge(clk);
            instruc <= str_to_slv(str);
			
			
            ------------------------------
            -- Compute expected register write
            ------------------------------
            wb_rd     <= in_rs3;
            wb_rd_ptr <= rd_ptr;
            in_wback  <= out_wback;	 
			
			wait for 1 ns;
            -------------------------------------------
            -- WRITE FULL REGISTER FILE TO OUTPUT FILE
            -------------------------------------------
            reg4096 := out_file;  -- full 4096-bit file

            for i in 0 to 31 loop
                word128 :=
                    reg4096(REGISTER_SIZE-1 - i*128 downto
                            REGISTER_SIZE-128 - i*128);

                -- clear line
                L := null;

                -- write string from SLV
                write(L, slv_to_str(word128));
                writeline(f_out, L);
            end loop;

        end loop;

        report "All instructions processed; register_file.txt updated.";
        wait;
    end process;

end architecture;
