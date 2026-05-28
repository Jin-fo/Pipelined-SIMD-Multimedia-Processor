library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity data_rx is
    port (
        clk       : in  std_logic;
        reset_bar  : in  std_logic;
        baud_tick : in  std_logic;

        rx        : in  std_logic;

        rx_data   : out std_logic_vector(7 downto 0);
        rx_ready  : out std_logic
    );
end entity;

architecture behavior of data_rx is

    type state_type is (IDLE, START, DATA, STOP);
    signal state : state_type := IDLE;

    signal shift   : std_logic_vector(7 downto 0);
    signal bit_cnt : integer range 0 to 7 := 0;
    signal os_cnt  : integer range 0 to (SAMPLE_COUNT-1) := 0;

    signal ready : std_logic := '0';

begin

process(clk)
begin
    if rising_edge(clk) then

        if reset_bar = '0' then
            state   <= IDLE;
            os_cnt  <= 0;
            bit_cnt <= 0;
            ready   <= '0';

        elsif baud_tick = '1' then

            case state is

                ----------------------------------------------------------------
                -- IDLE: wait for start bit
                ----------------------------------------------------------------
                when IDLE =>
                    ready <= '0';

                    if rx = '0' then
                        os_cnt <= 0;
                        state  <= START;
                    end if;

                ----------------------------------------------------------------
                -- START: align to middle of start bit (8 ticks)
                ----------------------------------------------------------------
                when START =>
                    ready <= '0';
                    if os_cnt = (SAMPLE_COUNT/2)-1 then
                        os_cnt <= 0;
                        bit_cnt <= 0;
                        state <= DATA;
                    else
                        os_cnt <= os_cnt + 1;
                    end if;

                ----------------------------------------------------------------
                -- DATA: sample every 16 ticks at center
                ----------------------------------------------------------------
                when DATA =>
                    ready <= '0';
                    if os_cnt = SAMPLE_COUNT-1 then
                        os_cnt <= 0;
                        
                        case bit_cnt is
                            when 0 => shift(0) <= rx;
                            when 1 => shift(1) <= rx;
                            when 2 => shift(2) <= rx;
                            when 3 => shift(3) <= rx;
                            when 4 => shift(4) <= rx;
                            when 5 => shift(5) <= rx;
                            when 6 => shift(6) <= rx;
                            when 7 => shift(7) <= rx;
                            when others => null;
                        end case;

                        if bit_cnt = 7 then
                            state <= STOP;
                        else
                            bit_cnt <= bit_cnt + 1;
                        end if;
                    else
                        os_cnt <= os_cnt + 1;
                    end if;

                ----------------------------------------------------------------
                -- STOP: one bit time
                ----------------------------------------------------------------
                when STOP =>
                    if os_cnt = SAMPLE_COUNT-1 then
                        rx_data <= shift;
                        ready   <= '1';
                        state   <= IDLE;
                        os_cnt  <= 0;
                    else
                        ready <= '0';
                        os_cnt <= os_cnt + 1;
                    end if;

            end case;
        else
            ready <= '0';
        end if;
    end if;
end process;

rx_ready <= ready;

end architecture;