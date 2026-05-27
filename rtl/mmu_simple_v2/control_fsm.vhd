library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity control_fsm is
    port (
        clk        : in  std_logic;
        rst_bar    : in  std_logic;
        enable     : in  std_logic;

        load_done  : in  std_logic;

        -- control outputs
        uart_en    : out std_logic;
        cpu_en     : out std_logic
    );
end entity;

architecture behavior of control_fsm is

    type state_type is (RESET, LOAD, EXECUTE);
    signal state, next_state : state_type;

begin
--------------------------------------------------------------------
-- state register
--------------------------------------------------------------------
process(clk)
begin
    if rising_edge(clk) then
        if rst_bar = '0' then
            state <= RESET;
        else
            state <= next_state;
        end if;
    end if;
end process;

--------------------------------------------------------------------
-- next state
--------------------------------------------------------------------
process(state, enable, load_done)
begin
    next_state <= state;

    case state is

        when RESET =>
            next_state <= LOAD;

        when LOAD =>
            if enable = '1' and load_done = '1' then
                next_state <= EXECUTE;
            end if;
            
        when EXECUTE =>
            next_state <= EXECUTE;

    end case;
end process;

--------------------------------------------------------------------
-- outputs
--------------------------------------------------------------------
process(state)
begin
    uart_en <= '0';
    cpu_en  <= '0';

    case state is
        when LOAD =>
            uart_en <= '1';

        when EXECUTE =>
            cpu_en <= '1';

        when others =>
            null;
    end case;
end process;

end architecture;