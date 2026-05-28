library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

use work.numeric_var.all;
use work.all;

entity Multimedia_Processor_Unit_tb is
end Multimedia_Processor_Unit_tb;

architecture test_bench of Multimedia_Processor_Unit_tb is
	--unit input
    signal clk         : std_logic := '0';
    signal enable      : std_logic := '0';
    signal reset_bar   : std_logic := '0';

    signal in_file     : std_logic_vector(FILE_SIZE-1 downto 0) := (others => '0');	
	
	--unit output
    signal out_file    : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');
	
	--test beanch signals
    signal pc_count    : std_logic_vector(COUNTER_LENGTH-1 downto 0) := (others => '0');
    signal if_instruc  : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0) := (others => '0');
    signal id_instruc  : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0) := (others => '0');

    signal id_opcode   : std_logic_vector(OPCODE_LENGTH-1 downto 0) := (others => '0');
    signal ex_opcode   : std_logic_vector(OPCODE_LENGTH-1 downto 0) := (others => '0');

    signal id_rs3, id_rs2, id_rs1 : std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '0');
    signal ex_rs3, ex_rs2, ex_rs1 : std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '0');
    signal ex_rd                  : std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '0');

    signal id_immed  : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0) := (others => '0');
    signal ex_immed  : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0) := (others => '0');

    signal id_rs3_ptr, id_rs2_ptr, id_rs1_ptr, id_rd_ptr :
           std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '0');

    signal id_wback : std_logic := '0';

    signal ex_rs3_ptr, ex_rs2_ptr, ex_rs1_ptr, ex_rd_ptr :
           std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '0');

    signal ex_wback  : std_logic := '0';
    signal wb_rd     : std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '0');
    signal wb_rd_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '0');
    signal wb_wback  : std_logic := '0';

    constant PERIOD : time := 10 ns;

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

    UUT : entity work.Multimedia_Processor_Unit
        port map(
            clk       => clk,
            enable    => enable,
            reset_bar => reset_bar,
            in_file   => in_file, 
			
            out_file => out_file,
			
            pc_count_tb   => pc_count,
            if_instruc_tb => if_instruc,
            id_instruc_tb => id_instruc,
            id_opcode_tb  => id_opcode,
            ex_opcode_tb  => ex_opcode,
            id_rs3_tb     => id_rs3,
            id_rs2_tb     => id_rs2,
            id_rs1_tb     => id_rs1,
            ex_rs3_tb     => ex_rs3,
            ex_rs2_tb     => ex_rs2,
            ex_rs1_tb     => ex_rs1,
            ex_rd_tb      => ex_rd,
            id_immed_tb   => id_immed,
            ex_immed_tb   => ex_immed,
            id_rs3_ptr_tb => id_rs3_ptr,
            id_rs2_ptr_tb => id_rs2_ptr,
            id_rs1_ptr_tb => id_rs1_ptr,
            id_rd_ptr_tb  => id_rd_ptr,
            id_wback_tb   => id_wback,
            ex_rs3_ptr_tb => ex_rs3_ptr,
            ex_rs2_ptr_tb => ex_rs2_ptr,
            ex_rs1_ptr_tb => ex_rs1_ptr,
            ex_rd_ptr_tb  => ex_rd_ptr,
            ex_wback_tb   => ex_wback,
            wb_rd_tb      => wb_rd,
            wb_rd_ptr_tb  => wb_rd_ptr,
            wb_wback_tb   => wb_wback
        );	
		
	-- read from in_file + write to register_file.txt in little endian
	Write_Back : process
        file f_out : text;
        variable L        : line;
        variable word128  : std_logic_vector(127 downto 0);
        variable reg4096  : std_logic_vector(REGISTER_SIZE-1 downto 0);
        variable cycle_cnt: natural := 0;
    begin
        file_open(f_out, "src/register_file.txt", write_mode);
        file_close(f_out);

        wait until wb_wback = '1';
        while true loop
            wait for 1 ns;
            reg4096 := out_file;

            if wb_wback = '1' then 
				
                file_open(f_out, "src/register_file.txt", write_mode);

                for i in 0 to 31 loop
                    word128 := reg4096(
                        ((i+1)*REGISTER_LENGTH)-1
                        downto
                        i*REGISTER_LENGTH
                    );
                    write(L, slv_to_str(word128));
                    writeline(f_out, L);
                end loop;

                file_close(f_out);	  
				wait until rising_edge(clk);
            end if;
        end loop;
	end process;	  
	
	-- clk 
	clk_process : process
    begin
        clk <= '0';  wait for PERIOD/2;
        clk <= '1';  wait for PERIOD/2;
    end process;
	
	-- enable and reset
	inital : process
    begin
        enable    <= '0';
        reset_bar <= '0';
        wait for PERIOD/2;
        reset_bar <= '1';
        enable    <= '1';
        wait;
    end process;
	
	-- read from instruction_file.txt + write into in_file in little endian
    Load_Instructions : process
        file f_in  : text open read_mode is "instruction_file.txt";
        variable L        : line;
        variable str      : string(1 to INSTRUCTION_LENGTH);
        variable chunk    : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
        variable little_endian : std_logic_vector(FILE_SIZE-1 downto 0);
        variable index    : integer := 0;
    begin
        little_endian := (others => '0');

        while not endfile(f_in) loop
            readline(f_in, L);
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

end architecture;


