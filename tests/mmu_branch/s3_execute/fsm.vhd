library ieee;
use ieee.std_logic_1164.all;
use work.numeric_var.all;

entity state_lookup is
    port (
        -- inputs
        ex_bctrl  : in  std_logic;
        fw_state   : in  std_logic_vector(1 downto 0); -- current state
        ex_sctrl   : in  std_logic;

        -- outputs
        fsm_state  : out std_logic_vector(1 downto 0); -- next state
        fsm_sctrl  : out std_logic                    -- control output
    );
end entity;

architecture behavior of state_lookup is
begin

    process(ex_bctrl, fw_state, ex_sctrl)
    begin
        -- defaults (important to avoid latches)
        fsm_state <= fw_state;
        fsm_sctrl <= '0';

        if ex_bctrl = '1' then
            case fw_state is

                when "00" =>
                    if ex_sctrl = '1' then
                        fsm_state <= "01";
                        fsm_sctrl <= '1';
                    end if;

                when "01" =>
                    fsm_sctrl <= '1';
                    if ex_sctrl = '1' then
                        fsm_state <= "11";
                    else
                        fsm_state <= "00";
                    end if;

                when "11" =>
                    if ex_sctrl = '0' then
                        fsm_state <= "01";
                        fsm_sctrl <= '1';
                    end if;

                when "10" =>
                    fsm_sctrl <= '1';
                    if ex_sctrl = '1' then
                        fsm_state <= "11";
                    else
                        fsm_state <= "00";
                    end if;

                when others =>
                    fsm_state <= "00";
                    fsm_sctrl <= '0';

            end case;
        end if;
    end process;

end architecture;