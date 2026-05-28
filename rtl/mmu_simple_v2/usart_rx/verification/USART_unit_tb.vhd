library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity USART_unit_tb is
end entity;

architecture sim of USART_unit_tb is

    --------------------------------------------------------------------
    -- DUT SIGNALS
    --------------------------------------------------------------------
    signal clk        : std_logic := '0';
    signal rst_bar    : std_logic := '0';
    signal enable     : std_logic := '0';

    signal rx         : std_logic := '1';

    signal rx_data    : std_logic_vector(7 downto 0);
    signal rx_ready   : std_logic;

    --------------------------------------------------------------------
    -- CLOCK / UART TIMING
    --------------------------------------------------------------------
    constant CLK_PERIOD  : time := 10 ns;     -- 100 MHz
    constant BAUD_PERIOD : time := 8680 ns;   -- ~115200 baud

    --------------------------------------------------------------------
    -- UART SEND PROCEDURE (MUST BE HERE)
    --------------------------------------------------------------------
     procedure uart_send_byte(
        signal rx_line : out std_logic;
        data : std_logic_vector(7 downto 0)
    ) is
    begin
        -- START BIT
        rx_line <= '0';
        wait for BAUD_PERIOD;

        -- DATA BITS (LSB FIRST)
        for i in 0 to 7 loop
            rx_line <= data(i);
            wait for BAUD_PERIOD;
        end loop;

        -- STOP BIT
        rx_line <= '1';
        wait for BAUD_PERIOD;
    end procedure;

begin

    --------------------------------------------------------------------
    -- CLOCK GENERATION
    --------------------------------------------------------------------
    clk <= not clk after CLK_PERIOD / 2;

    --------------------------------------------------------------------
    -- DUT INSTANTIATION
    --------------------------------------------------------------------
    DUT : entity work.USART_unit(structural)
    port map (
        clk      => clk,
        rst_bar=> rst_bar,  
        en_bar => enable,  
        rx       => rx,
        rx_data  => rx_data,
        rx_ready => rx_ready
    );

    --------------------------------------------------------------------
    -- STIMULUS
    --------------------------------------------------------------------
    process
    begin
        ----------------------------------------------------------------
        -- RESET
        ----------------------------------------------------------------
        rst_bar <= '0';
        enable  <= '0';
        wait for 100 ns;

        rst_bar <= '1';
        wait for 100 ns;

        ----------------------------------------------------------------
        -- ENABLE UART (active LOW)
        ----------------------------------------------------------------
        enable <= '0';

        ----------------------------------------------------------------
        -- SEND BYTES
        ----------------------------------------------------------------
        uart_send_byte(rx, x"AB");
        uart_send_byte(rx, x"CD");
        uart_send_byte(rx, x"DE");
        uart_send_byte(rx, x"F0");


        ----------------------------------------------------------------
        -- END
        ----------------------------------------------------------------
        wait;
    end process;


end architecture;