library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use work.numeric_var.all;
use work.all;

entity Multimedia_Processor_Unit_tb is
end entity;

architecture tb of Multimedia_Processor_Unit_tb is

    -- ======================
    -- DUT interface
    -- ======================
    signal clk       : std_logic := '0';
    signal enable    : std_logic := '0';
    signal reset_bar : std_logic := '0';

    signal in_file   : std_logic_vector(FILE_SIZE-1 downto 0) := (others => '0');

    signal out_Tbuffer : std_logic_vector(BUFFER_SIZE-1 downto 0);
    signal out_Sbuffer : std_logic_vector(BUFFER_SIZE-1 downto 0);
    signal out_file    : std_logic_vector(REGISTER_SIZE-1 downto 0);

    constant PERIOD : time := 10 ns;

    -- ======================
    -- PC DEBUG (NEW)
    -- ======================
    signal pc_current : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal pc_next    : std_logic_vector(COUNTER_LENGTH-1 downto 0);

    -- ======================
    -- Internal signals (unchanged)
    -- ======================
    signal if_pc, iff_target, ifd_target :
        std_logic_vector(COUNTER_LENGTH-1 downto 0);

    signal if_instruc : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
    signal id_pctrl   : std_logic;

    signal id_pc      : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal id_instruc : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

    signal id_opcode  : std_logic_vector(OPCODE_LENGTH-1 downto 0);

    signal id_rs3_ptr, id_rs2_ptr, id_rs1_ptr, id_rd_ptr :
        std_logic_vector(ADDRESS_LENGTH-1 downto 0);

    signal id_immed  : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
    signal read_sel  : std_logic_vector(2 downto 0);

    signal id_wback, id_bctrl, id_jump : std_logic;

    signal id_target : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal id_tctrl  : std_logic;

    signal id_state  : std_logic_vector(STATE_LENGTH-1 downto 0);

    signal id_rs3, id_rs2, id_rs1 :
        std_logic_vector(REGISTER_LENGTH-1 downto 0);

    signal ex_pc     : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal ex_opcode : std_logic_vector(OPCODE_LENGTH-1 downto 0);

    signal ex_rs3, ex_rs2, ex_rs1 :
        std_logic_vector(REGISTER_LENGTH-1 downto 0);

    signal ex_immed  : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

    signal ex_rd_ptr, ex_rs3_ptr, ex_rs2_ptr, ex_rs1_ptr :
        std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal ex_target : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal ex_state  : std_logic_vector(STATE_LENGTH-1 downto 0);
    signal ex_wback, ex_pctrl, ex_bctrl : std_logic;

    signal fw_rs3, fw_rs2, fw_rs1 :
        std_logic_vector(REGISTER_LENGTH-1 downto 0);

    signal fw_state : std_logic_vector(1 downto 0);

    signal ex_rd    : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal brch_pc  : std_logic_vector(COUNTER_LENGTH-1 downto 0);

    signal ex_sctrl, flush_ctrl : std_logic;

    signal fsm_state : std_logic_vector(1 downto 0);
    signal fsm_sctrl : std_logic;

    signal wb_rd     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal wb_rd_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal wb_wback  : std_logic;

    signal wb_pc     : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal wb_state  : std_logic_vector(1 downto 0);
    signal wb_sctrl  : std_logic;

    -- ======================
    -- Helper
    -- ======================
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

    -- ======================
    -- DUT
    -- ======================
    UUT : entity work.Multimedia_Processor_Unit
        port map (
            clk => clk,
            enable => enable,
            reset_bar => reset_bar,
            in_Ifile => in_file,

            out_Tbuffer => out_Tbuffer,
            out_Sbuffer => out_Sbuffer,
            out_Rfile   => out_file,
			pc_current_i => pc_current,
            pc_next_i    => pc_next,
            if_pc_i => if_pc,
            if_instruc_i => if_instruc,
            id_pctrl_i => id_pctrl,
            iff_target_i => iff_target,
            ifd_target_i => ifd_target,

            id_pc_i => id_pc,
            id_instruc_i => id_instruc,

            id_opcode_i => id_opcode,
            id_rs3_ptr_i => id_rs3_ptr,
            id_rs2_ptr_i => id_rs2_ptr,
            id_rs1_ptr_i => id_rs1_ptr,
            id_rd_ptr_i  => id_rd_ptr,
            id_immed_i   => id_immed,
            read_sel_i   => read_sel,
            id_wback_i   => id_wback,
            id_bctrl_i   => id_bctrl,
            id_jump_i    => id_jump,

            id_target_i => id_target,
            id_tctrl_i  => id_tctrl,
            id_state_i  => id_state,

            id_rs3_i => id_rs3,
            id_rs2_i => id_rs2,
            id_rs1_i => id_rs1,

            ex_pc_i => ex_pc,
            ex_opcode_i => ex_opcode,
            ex_rs3_i => ex_rs3,
            ex_rs2_i => ex_rs2,
            ex_rs1_i => ex_rs1,
            ex_immed_i => ex_immed,
            ex_rd_ptr_i => ex_rd_ptr,
            ex_rs3_ptr_i => ex_rs3_ptr,
            ex_rs2_ptr_i => ex_rs2_ptr,
            ex_rs1_ptr_i => ex_rs1_ptr,	
			
			ex_target_i => ex_target,
            ex_state_i => ex_state,
            ex_wback_i => ex_wback,
            ex_pctrl_i => ex_pctrl,
            ex_bctrl_i => ex_bctrl,

            fw_rs3_i => fw_rs3,
            fw_rs2_i => fw_rs2,
            fw_rs1_i => fw_rs1,
            fw_state_i => fw_state,

            ex_rd_i => ex_rd,
            brch_pc_i => brch_pc,
            ex_sctrl_i => ex_sctrl,
            flush_ctrl_i => flush_ctrl,

            fsm_state_i => fsm_state,
            fsm_sctrl_i => fsm_sctrl,

            wb_rd_i => wb_rd,
            wb_rd_ptr_i => wb_rd_ptr,
            wb_wback_i => wb_wback,
            wb_pc_i => wb_pc,
            wb_sctrl_i => wb_sctrl,
            wb_state_i => wb_state
        );

    -- ======================
    -- Clock (2008)
    -- ======================
    clk <= not clk after PERIOD/2;

    -- ======================
    -- Reset
    -- ======================
    init : process
    begin
        enable    <= '0';
        reset_bar <= '0';
        wait for PERIOD/2;

        reset_bar <= '1';
        enable    <= '1';
        wait;
    end process;

    -- ======================
    -- Instruction Loader
    -- ======================
    Load_Instructions : process
        file f_in : text open read_mode is "instruction_file.txt";
        variable L : line;
        variable str : string(1 to INSTRUCTION_LENGTH);
        variable chunk : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
        variable mem : std_logic_vector(FILE_SIZE-1 downto 0);
        variable idx : integer := 0;
    begin
        mem := (others => '0');

        while not endfile(f_in) loop
            readline(f_in, L);
            read(L, str);

            for i in 1 to INSTRUCTION_LENGTH loop
                if str(i) = '1' then
                    chunk(INSTRUCTION_LENGTH - i) := '1';
                else
                    chunk(INSTRUCTION_LENGTH - i) := '0';
                end if;
            end loop;

            mem(idx + INSTRUCTION_LENGTH - 1 downto idx) := chunk;
            idx := idx + INSTRUCTION_LENGTH;
        end loop;

        in_file <= mem;
        wait;
    end process;

    -- ======================
    -- Register dump
    -- ======================
    Write_Back : process
        file f_out : text;
        variable L : line;
        variable regword : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    begin
        wait until rising_edge(clk);

        while true loop
            wait until rising_edge(clk);
            file_open(f_out, "src/internal_result/register_file.txt", write_mode);

            for i in 0 to (REGISTER_SIZE / REGISTER_LENGTH) - 1 loop
                regword := out_file(((i+1)*REGISTER_LENGTH)-1 downto i*REGISTER_LENGTH);
                write(L, slv_to_str(regword));
                writeline(f_out, L);
            end loop;

            file_close(f_out);
        end loop;
    end process;

    -- ======================
    -- Target buffer dump
    -- ======================
    write_Tbuffer_proc : process
        variable L : line;
        variable bit_index : integer;
        variable valid_bit : std_logic;
        variable target_value : std_logic_vector(COUNTER_LENGTH-1 downto 0);
        file f : text;
    begin
        wait until rising_edge(clk);

        while true loop
            wait until rising_edge(clk);
            file_open(f, "src/internal_result/buffer_file.txt", write_mode);

            bit_index := 0;
            for i in 0 to (2**COUNTER_LENGTH)-1 loop
                valid_bit := out_Tbuffer(bit_index);
                target_value := out_Tbuffer(bit_index + COUNTER_LENGTH downto bit_index + 1);

                write(L, std_logic'image(valid_bit)(2));
                write(L, slv_to_str(target_value));
                writeline(f, L);

                bit_index := bit_index + (1 + COUNTER_LENGTH);
            end loop;

            file_close(f);
        end loop;
    end process;

    -- ======================
    -- State buffer dump
    -- ======================
    write_Sbuffer_proc : process
        variable L : line;
        variable bit_index : integer;
        variable valid_bit : std_logic;
        variable state_bits : std_logic_vector(1 downto 0);
        file f : text;
    begin
        wait until rising_edge(clk);

        while true loop
            wait until rising_edge(clk);
            file_open(f, "src/internal_result/tsb_buffer.txt", write_mode);

            bit_index := 0;
            for i in 0 to (2**COUNTER_LENGTH)-1 loop
                valid_bit := out_Sbuffer(bit_index);
                state_bits := out_Sbuffer(bit_index + 2 downto bit_index + 1);

                write(L, std_logic'image(valid_bit)(2));
                write(L, slv_to_str(state_bits));
                writeline(f, L);

                bit_index := bit_index + 3;
            end loop;

            file_close(f);
        end loop;
    end process;

end architecture;