library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity Multimedia_Processor_Unit_tb is
end Multimedia_Processor_Unit_tb;

architecture test_bench of Multimedia_Processor_Unit_tb is

    ------------------------------------------------------------------
    -- Constants (hardcoded from numeric_var package)
    ------------------------------------------------------------------
    constant PERIOD              : time    := 10 ns;

    constant COUNTER_LENGTH      : integer := 6;
    constant INSTRUCTION_LENGTH  : integer := 25;
    constant INSTRUCTION_HEIGHT  : integer := 64;
    constant IMMEDIATE_LENGTH    : integer := 16;
    constant OPCODE_LENGTH       : integer := 6;
    constant REGISTER_LENGTH     : integer := 128;
    constant REGISTER_HEIGHT     : integer := 32;
    constant ADDRESS_LENGTH      : integer := 5;

    constant NOP_INSTRUCTION     : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0)
                                 := b"1100000000000000000000000";

    ------------------------------------------------------------------
    -- Signals
    ------------------------------------------------------------------
    signal clk       : std_logic := '0';
    signal enable    : std_logic := '0';
    signal reset_bar : std_logic := '0';

    signal reg_pos   : std_logic_vector(7 downto 0) := (others => '0');
    signal reg_tog   : std_logic := '0';
    signal reg_lr    : std_logic_vector(1 downto 0) := "00";
    signal reg_value : std_logic_vector(15 downto 0);
    
    signal reg_seven : std_logic_vector(6 downto 0);
    signal led_ctrl  : std_logic_vector(3 downto 0);
--    -- ============================================================
--    -- IF Stage (Instruction Fetch)
--    -- ============================================================
    signal pc_count_tb   : std_logic_vector(COUNTER_LENGTH-1 downto 0);
--    signal if_instruc_tb : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
    
--    -- ============================================================
--    -- ID Stage (Instruction Decode)
--    -- ============================================================
--    signal id_instruc_tb : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
--    signal id_opcode_tb  : std_logic_vector(OPCODE_LENGTH-1 downto 0);
--    signal id_rs1_tb, id_rs2_tb, id_rs3_tb : std_logic_vector(REGISTER_LENGTH-1 downto 0);
--    signal id_rs1_ptr_tb, id_rs2_ptr_tb, id_rs3_ptr_tb, id_rd_ptr_tb : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
--    signal id_immed_tb   : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
--    signal id_wback_tb   : std_logic;
    
--    -- ============================================================
--    -- EX Stage (Execute)
--    -- ============================================================
--    signal ex_opcode_tb  : std_logic_vector(OPCODE_LENGTH-1 downto 0);
--    signal ex_rs1_tb, ex_rs2_tb, ex_rs3_tb : std_logic_vector(REGISTER_LENGTH-1 downto 0);
--    signal ex_rd_tb      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
--    signal ex_rs1_ptr_tb, ex_rs2_ptr_tb, ex_rs3_ptr_tb, ex_rd_ptr_tb : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
--    signal ex_immed_tb   : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
--    signal ex_wback_tb   : std_logic;
    
--    -- ============================================================
--    -- WB Stage (Write Back)
--    -- ============================================================
--    signal wb_rd_tb      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
--    signal wb_rd_ptr_tb  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
--    signal wb_wback_tb   : std_logic;

begin

    ------------------------------------------------------------------
    -- DUT
    ------------------------------------------------------------------
    UUT : entity work.Multimedia_Processor_Unit
    port map(
        clk       => clk,
        enable    => enable,
        reset_bar => reset_bar,
    
        reg_pos   => reg_pos,
        reg_tog   => reg_tog,
        reg_value => reg_value,
        reg_seven => reg_seven,
        led_ctrl => led_ctrl
    
--       pc_count_tb   => pc_count_tb
--        if_instruc_tb => if_instruc_tb,
--        id_instruc_tb => id_instruc_tb,
    
--        id_opcode_tb  => id_opcode_tb,
--        ex_opcode_tb  => ex_opcode_tb,
    
--        id_rs3_tb     => id_rs3_tb,
--        id_rs2_tb     => id_rs2_tb,
--        id_rs1_tb     => id_rs1_tb,
    
--        ex_rs3_tb     => ex_rs3_tb,
--        ex_rs2_tb     => ex_rs2_tb,
--        ex_rs1_tb     => ex_rs1_tb,
--        ex_rd_tb      => ex_rd_tb,
    
--        id_immed_tb   => id_immed_tb,
--        ex_immed_tb   => ex_immed_tb,
    
--        id_rs3_ptr_tb => id_rs3_ptr_tb,
--        id_rs2_ptr_tb => id_rs2_ptr_tb,
--        id_rs1_ptr_tb => id_rs1_ptr_tb,
--        id_rd_ptr_tb  => id_rd_ptr_tb,
    
--        id_wback_tb   => id_wback_tb,
    
--        ex_rs3_ptr_tb => ex_rs3_ptr_tb,
--        ex_rs2_ptr_tb => ex_rs2_ptr_tb,
--        ex_rs1_ptr_tb => ex_rs1_ptr_tb,
--        ex_rd_ptr_tb  => ex_rd_ptr_tb,
    
--        ex_wback_tb   => ex_wback_tb,
    
--        wb_rd_tb      => wb_rd_tb,
--        wb_rd_ptr_tb  => wb_rd_ptr_tb,
--        wb_wback_tb   => wb_wback_tb
    );

    ------------------------------------------------------------------
    -- Clock Generation
    ------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for PERIOD/2;
            clk <= '1'; wait for PERIOD/2;
        end loop;
    end process;

    ------------------------------------------------------------------
    -- Reset + Enable Sequence
    ------------------------------------------------------------------
    init_process : process
    begin
        enable    <= '0';
        reset_bar <= '0';

        wait for PERIOD * 2;

        reset_bar <= '1';
        enable    <= '1';

        wait;
    end process;

    ------------------------------------------------------------------
    -- Register Dump to File
    ------------------------------------------------------------------
    dump_mem : process
        file     mem_out : text;
        variable L       : line;
        variable reg_idx : integer;
        variable seg_idx : integer;
    begin
        -- wait until system is running
        wait until reset_bar = '1';
        wait for PERIOD * (INSTRUCTION_HEIGHT + 10);

        file_open(mem_out, "register_file.txt", write_mode);

        for reg_idx in 0 to REGISTER_HEIGHT-1 loop

            L := null;

            for seg_idx in 7 downto 0 loop

                -- compose address (5-bit reg + 3-bit segment)
                reg_pos <= std_logic_vector(to_unsigned(reg_idx, 5)) &
                           std_logic_vector(to_unsigned(seg_idx, 3));

                -- trigger read
                reg_tog <= '1';
                wait for PERIOD * 32;
                reg_tog <= '0';
                wait for PERIOD * 32;

                -- write value
                write(L, reg_value);
                write(L, string'(" "));

            end loop;

            writeline(mem_out, L);

        end loop;

        file_close(mem_out);

        wait;
    end process;

end architecture;