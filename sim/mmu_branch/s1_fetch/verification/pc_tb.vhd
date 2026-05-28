library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity pc_tb is
end pc_tb;

architecture tb of pc_tb is

    signal clk        : std_logic := '0';
    signal reset_bar  : std_logic := '0';
    signal enable     : std_logic := '0';

    signal pred_pc    : std_logic_vector(COUNTER_LENGTH-1 downto 0) := (others => '0');
    signal id_pctrl : std_logic := '0';

    signal ex_pc      : std_logic_vector(COUNTER_LENGTH-1 downto 0) := (others => '0');
    signal flush_ctrl : std_logic := '0';

    signal if_pc   : std_logic_vector(COUNTER_LENGTH-1 downto 0);

begin

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    UUT : entity work.pc
        port map (
            clk        => clk,
            enable     => enable,
            reset_bar  => reset_bar,
            pred_pc    => pred_pc,
            id_pctrl  => id_pctrl,
            ex_pc      => ex_pc,
            flush_ctrl => flush_ctrl,
            if_pc   => if_pc
        );

    --------------------------------------------------------------------
    -- CLOCK
    --------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for PERIOD/2;
        clk <= '1';
        wait for PERIOD/2;
    end process;

    --------------------------------------------------------------------
    -- STIMULUS
    --------------------------------------------------------------------
    pc_proc : process
        variable expected : unsigned(COUNTER_LENGTH-1 downto 0);
    begin
        ----------------------------------------------------------------
        -- RESET / BASE COUNT TEST (UNCHANGED LOGIC)
        ----------------------------------------------------------------
        reset_bar <= '0';
        enable    <= '0';
        id_pctrl <= '0';
        flush_ctrl <= '0';

        wait for PERIOD/2;
        reset_bar <= '1';
        enable    <= '1';
        wait for PERIOD/2;

        expected := (others => '0');

        for i in 0 to 31 loop
            wait until rising_edge(clk);

            assert unsigned(if_pc) = expected
                report "Mismatch at cycle " & integer'image(i) &
                       ": expected=" & integer'image(to_integer(expected)) &
                       ", got=" & integer'image(to_integer(unsigned(if_pc)))
                severity error;

            expected := expected + INCREMENT;
        end loop;

        ----------------------------------------------------------------
        -- BRANCH PREDICTION TEST
        ----------------------------------------------------------------
        pred_pc   <= std_logic_vector(to_unsigned(16, COUNTER_LENGTH));
        id_pctrl <= '1';

        wait until rising_edge(clk);

        assert unsigned(if_pc) = 16
            report "Prediction failed: pc not loaded with pred_pc"
            severity error;
		
        id_pctrl <= '0';   
		
		wait for PERIOD * 2;
		
		 wait until rising_edge(clk);
        ----------------------------------------------------------------
        -- FLUSH TEST (HAS PRIORITY OVER PREDICTION)
        ----------------------------------------------------------------
        ex_pc      <= std_logic_vector(to_unsigned(20, COUNTER_LENGTH));
        flush_ctrl <= '1';

        wait until rising_edge(clk);

        assert unsigned(if_pc) = (20 + INCREMENT)
            report "Flush failed: pc not set to ex_pc + INCREMENT"
            severity error;

        flush_ctrl <= '0';

        report "PC test completed successfully!" severity note;
        wait;
    end process;

end architecture;
