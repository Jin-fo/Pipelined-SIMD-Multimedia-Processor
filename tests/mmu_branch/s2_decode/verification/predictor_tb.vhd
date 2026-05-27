library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity predictor_tb is
end entity;

architecture behavior of predictor_tb is
    signal id_pc     : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal id_immed  : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
    signal ifd_target : std_logic_vector(COUNTER_LENGTH-1 downto 0);

    signal id_jump   : std_logic := '0';
    signal id_branch : std_logic := '0';

    signal ex_pc     : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal exw_state  : std_logic_vector(1 downto 0);
	signal exw_sctrl  : std_logic := '0';
	
    ----------------------------------------------------------------
    -- DUT outputs
    ----------------------------------------------------------------
    signal id_target  : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal id_tctrl   : std_logic;

    signal pred_pc    : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal id_pctrl : std_logic;
    signal id_state   : std_logic_vector(1 downto 0);
	signal id_brch	  : std_logic;

begin
    ----------------------------------------------------------------
    -- DUT instantiation
    ----------------------------------------------------------------
    dut : entity work.predictor
        port map (
            id_pc      => id_pc,
            id_immed   => id_immed,
            ifd_target  => ifd_target,

            id_jump    => id_jump,
            id_branch  => id_branch,

            ex_pc      => ex_pc,
            exw_state   => exw_state,			
			exw_sctrl  => exw_sctrl,
			
            id_target  => id_target,
            id_tctrl   => id_tctrl,

            pred_pc    => pred_pc,
            id_pctrl => id_pctrl,
            id_state   => id_state,  
			id_brch	   => id_brch
        );

    ----------------------------------------------------------------
    -- Stimulus
    ----------------------------------------------------------------
    stim : process
    begin
        ----------------------------------------------------------------
        -- INIT
        ----------------------------------------------------------------
        id_pc      <= (others => '0');
        id_immed   <= (others => '0');
        ifd_target  <= (others => '0');

        id_jump    <= '0';
        id_branch  <= '0';

        exw_sctrl  <= '0';
        ex_pc      <= (others => '0');
        exw_state   <= "11";

        wait for PERIOD/2;

        ----------------------------------------------------------------
        -- TEST 1: Jump (always taken, first encounter)
        ----------------------------------------------------------------
        id_pc      <= std_logic_vector(to_unsigned(16, COUNTER_LENGTH));
        id_immed   <= std_logic_vector(to_signed(4, IMMEDIATE_LENGTH));
        ifd_target  <= std_logic_vector(to_unsigned(20, COUNTER_LENGTH));
        id_jump    <= '1';
        id_branch <= '0';

        wait for PERIOD;

        ----------------------------------------------------------------
        -- TEST 2: Same jump again (should predict taken)
        ----------------------------------------------------------------
        id_jump   <= '1';
        id_branch <= '0';

        wait for PERIOD;

        ----------------------------------------------------------------
        -- TEST 3: Branch (allocate new state entry)
        ----------------------------------------------------------------
        id_pc      <= std_logic_vector(to_unsigned(32, COUNTER_LENGTH));
        id_immed   <= std_logic_vector(to_signed(-8, IMMEDIATE_LENGTH));
        ifd_target  <= std_logic_vector(to_unsigned(24, COUNTER_LENGTH));
        id_jump    <= '0';
        id_branch  <= '1';

        wait for PERIOD;

        ----------------------------------------------------------------
        -- TEST 4: Writeback (branch NOT taken ? state = 01 or 00)
        ----------------------------------------------------------------
        exw_sctrl <= '1';
        ex_pc     <= std_logic_vector(to_unsigned(32, COUNTER_LENGTH));
        exw_state  <= "01";

        wait for PERIOD;
        exw_sctrl <= '0';

        wait for PERIOD;

        ----------------------------------------------------------------
        -- TEST 5: Same branch again (observe updated state)
        ----------------------------------------------------------------
        id_jump   <= '0';
        id_branch <= '1';

        wait for PERIOD;

        ----------------------------------------------------------------
        -- TEST 6: Writeback (branch TAKEN ? state = 11)
        ----------------------------------------------------------------
        exw_sctrl <= '1';
        ex_pc     <= std_logic_vector(to_unsigned(32, COUNTER_LENGTH));
        exw_state  <= "11";

        wait for PERIOD;
        exw_sctrl <= '0';

        wait for PERIOD;

        ----------------------------------------------------------------
        -- END SIMULATION
        ----------------------------------------------------------------
        wait;
    end process;

end architecture;
