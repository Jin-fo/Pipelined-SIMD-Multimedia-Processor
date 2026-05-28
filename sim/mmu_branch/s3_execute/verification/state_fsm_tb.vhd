library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_fsm_tb is
end entity;

architecture behavior of state_fsm_tb is

    --------------------------------------------------------------------
    -- Clock
    --------------------------------------------------------------------
    signal clk : std_logic := '0';
    constant PERIOD : time := 10 ns;

    --------------------------------------------------------------------
    -- Inputs
    --------------------------------------------------------------------
    signal ex_brch : std_logic := '0';
    signal ex_state : std_logic_vector(1 downto 0) := "00";
    signal pc_sctrl  : std_logic := '0';

    --------------------------------------------------------------------
    -- Outputs
    --------------------------------------------------------------------
    signal exw_state : std_logic_vector(1 downto 0);
    signal exw_sctrl   : std_logic;

begin

    --------------------------------------------------------------------
    -- Clock generator
    --------------------------------------------------------------------
    clk <= not clk after PERIOD/2;

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    dut : entity work.state_fsm
        port map (
            --clk      => clk,
            ex_brch   => ex_brch,
            ex_state => ex_state,
            pc_sctrl => pc_sctrl,
            exw_state => exw_state,
            exw_sctrl => exw_sctrl
        );

    --------------------------------------------------------------------
    -- Stimulus
    --------------------------------------------------------------------
    stim : process
    begin
        ------------------------------------------------------------
        -- INIT
        ------------------------------------------------------------
        ex_brch <= '0';
        pc_sctrl  <= '0';
        ex_state <= "00";

        wait for PERIOD/2;

        ------------------------------------------------------------
        -- TEST 1: State "00" ? taken (pc_sctrl = 1)
        -- Expect: exw_state = "01", exw_sctrl = 1
        ------------------------------------------------------------
        ex_state <= "00";
        ex_brch   <= '1';
        pc_sctrl  <= '1';

        wait for PERIOD;

        ------------------------------------------------------------
        -- TEST 2: State "01" ? taken
        -- Expect: exw_state = "11", exw_sctrl = 1
        ------------------------------------------------------------
        ex_state <= "01";
        pc_sctrl  <= '1';

        wait for PERIOD;

        ------------------------------------------------------------
        -- TEST 3: State "01" ? not taken
        -- Expect: exw_state = "00", exw_sctrl = 1
        ------------------------------------------------------------
        ex_state <= "01";
        pc_sctrl  <= '0';

        wait for PERIOD;

        ------------------------------------------------------------
        -- TEST 4: State "11" ? mispredict (pc_sctrl = 0)
        -- Expect: exw_state = "01", exw_sctrl = 1
        ------------------------------------------------------------
        ex_state <= "11";
        pc_sctrl  <= '0';

        wait for PERIOD;

        ------------------------------------------------------------
        -- TEST 5: State "11" ? correct (pc_sctrl = 1)
        -- Expect: no change, exw_sctrl = 0
        ------------------------------------------------------------
        ex_state <= "11";
        pc_sctrl  <= '1';

        wait for PERIOD;

        ------------------------------------------------------------
        -- TEST 6: State "10" ? taken
        -- Expect: exw_state = "11", exw_sctrl = 1
        ------------------------------------------------------------
        ex_state <= "10";
        pc_sctrl  <= '1';

        wait for PERIOD;

        ------------------------------------------------------------
        -- TEST 7: State "10" ? not taken
        -- Expect: exw_state = "00", exw_sctrl = 1
        ------------------------------------------------------------
        ex_state <= "10";
        pc_sctrl  <= '0';

        wait for PERIOD;

        ------------------------------------------------------------
        -- TEST 8: No branch/jump ? no update
        ------------------------------------------------------------
        ex_brch <= '0';
        ex_state <= "01";
        pc_sctrl  <= '1';

        wait for PERIOD;

        ------------------------------------------------------------
        -- END SIMULATION
        ------------------------------------------------------------
        wait;
    end process;

end architecture;
