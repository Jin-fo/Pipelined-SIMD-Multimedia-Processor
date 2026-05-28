library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.numeric_var.all;

entity id_ex_tb is
end id_ex_tb;

architecture tb of id_ex_tb is

    --------------------------------------------------------------------
    -- DUT Signals
    --------------------------------------------------------------------
    signal clk        : std_logic := '0';
    signal enable     : std_logic := '0';
    signal reset_bar  : std_logic := '0';

    signal id_pc      : std_logic_vector(COUNTER_LENGTH-1 downto 0) := (others => '0');
    signal id_opcode  : std_logic_vector(OPCODE_LENGTH-1 downto 0) := (others => '0');

    signal id_rs3     : std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '0');
    signal id_rs2     : std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '0');
    signal id_rs1     : std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '0');
    signal id_immed   : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0) := (others => '0');

    signal id_rs3_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '0');
    signal id_rs2_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '0');
    signal id_rs1_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '0');
    signal id_rd_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0) := (others => '0');

    signal id_state   : std_logic_vector(1 downto 0) := "00";
    signal id_wback   : std_logic := '0';
    signal id_pctrl   : std_logic := '0';
    signal id_brch     : std_logic := '0';

    signal ex_pc      : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal ex_opcode  : std_logic_vector(OPCODE_LENGTH-1 downto 0);

    signal ex_rs3     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal ex_rs2     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal ex_rs1     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal ex_immed   : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

    signal ex_rs3_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal ex_rs2_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal ex_rs1_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal ex_rd_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);

    signal ex_state   : std_logic_vector(1 downto 0);
    signal ex_wback   : std_logic;
    signal ex_pctrl   : std_logic;
    signal ex_brch     : std_logic;

begin

    --------------------------------------------------------------------
    -- Instantiate DUT
    --------------------------------------------------------------------
    DUT: entity work.id_ex
        port map (
            clk        => clk,
            enable     => enable,
            reset_bar  => reset_bar,

            id_pc      => id_pc,
            id_opcode  => id_opcode,

            id_rs3     => id_rs3,
            id_rs2     => id_rs2,
            id_rs1     => id_rs1,
            id_immed   => id_immed,

            id_rd_ptr  => id_rd_ptr,
            id_rs3_ptr => id_rs3_ptr,
            id_rs2_ptr => id_rs2_ptr,
            id_rs1_ptr => id_rs1_ptr,
            id_state   => id_state,

            id_wback   => id_wback,
            id_pctrl   => id_pctrl,
            id_brch     => id_brch,

            ex_pc      => ex_pc,
            ex_opcode  => ex_opcode,

            ex_rs3     => ex_rs3,
            ex_rs2     => ex_rs2,
            ex_rs1     => ex_rs1,
            ex_immed   => ex_immed,

            ex_rd_ptr  => ex_rd_ptr,
            ex_rs3_ptr => ex_rs3_ptr,
            ex_rs2_ptr => ex_rs2_ptr,
            ex_rs1_ptr => ex_rs1_ptr,
            ex_state   => ex_state,

            ex_wback   => ex_wback,
            ex_pctrl   => ex_pctrl,
            ex_brch     => ex_brch
        );

    --------------------------------------------------------------------
    -- CLOCK GENERATION
    --------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for PERIOD/2;
        clk <= '1';
        wait for PERIOD/2;
    end process;

    --------------------------------------------------------------------
    -- PRESET STIMULUS (UNCHANGED)
    --------------------------------------------------------------------
    stim_proc : process
    begin
        -- RESET
        reset_bar <= '0';
        enable    <= '0';
        wait for PERIOD/2;
        reset_bar <= '1';
        enable    <= '1';
        wait until rising_edge(clk);

        -- TEST VECTOR 1
        id_opcode  <= "000000";
        id_rs3     <= (others => '1');
        id_rs2     <= (others => '0');
        id_rs1     <= (others => '1');
        id_immed   <= (others => '0');
        id_rs3_ptr <= (others => '0');
        id_rs2_ptr <= (others => '1');
        id_rs1_ptr <= (others => '0');
        id_rd_ptr  <= (others => '1');
        id_wback   <= '0';
        wait until rising_edge(clk);

        -- TEST VECTOR 2
        id_opcode  <= "100000";
        id_rs3     <= x"A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1A1";
        id_rs2     <= x"B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2B2";
        id_rs1     <= x"C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3C3";
        id_immed   <= (others => '1');
        id_rs3_ptr <= (others => '1');
        id_rs2_ptr <= (others => '0');
        id_rs1_ptr <= (others => '1');
        id_rd_ptr  <= (others => '0');
        id_wback   <= '1';
        wait until rising_edge(clk);

        -- TEST VECTOR 3
        id_opcode  <= "100000";
        id_rs3     <= (others => '0');
        id_rs2     <= (others => '1');
        id_rs1     <= (others => '0');
        id_immed   <= (others => '1');
        id_rs3_ptr <= (others => '0');
        id_rs2_ptr <= (others => '1');
        id_rs1_ptr <= (others => '0');
        id_rd_ptr  <= (others => '1');
        id_wback   <= '0';
        wait until rising_edge(clk);

        -- TEST VECTOR 4
        id_opcode  <= "110000";
        id_rs3     <= x"55555555555555555555555555555555";
        id_rs2     <= x"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        id_rs1     <= x"33333333333333333333333333333333";
        id_immed   <= x"FFFF";
        id_rs3_ptr <= (others => '1');
        id_rs2_ptr <= (others => '1');
        id_rs1_ptr <= (others => '0');
        id_rd_ptr  <= (others => '0');
        id_wback   <= '1';
        wait until rising_edge(clk);

        -- TEST VECTOR 5
        id_opcode  <= "110000";
        id_rs3     <= x"A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0";
        id_rs2     <= x"0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F";
        id_rs1     <= x"F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0";
        id_immed   <= x"0A0A";
        id_rs3_ptr <= (others => '0');
        id_rs2_ptr <= (others => '0');
        id_rs1_ptr <= (others => '1');
        id_rd_ptr  <= (others => '1');
        id_wback   <= '1';
        wait until rising_edge(clk);

        report "All 5 ID?EX preset test vectors completed." severity note;
        wait;
    end process;

end architecture;
