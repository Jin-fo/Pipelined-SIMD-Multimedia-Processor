library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity flush_control is
    port(
        -- Inputs
        ex_bctrl   : in  std_logic;  -- branch instruction valid
        ex_pctrl   : in  std_logic;  -- predicted branch (from predictor)
        ex_sctrl   : in  std_logic;  -- actual branch decision (resolved)
        ex_pc      : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);
        ex_target  : in  std_logic_vector(COUNTER_LENGTH-1 downto 0);

        -- Outputs
        brch_pc    : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
        flush_ctrl : out std_logic
    );
end entity;

architecture behavior of flush_control is
begin

    ----------------------------------------------------------------
    -- Combinational branch resolution + flush logic
    ----------------------------------------------------------------
    process(ex_bctrl, ex_pctrl, ex_sctrl, ex_pc, ex_target)
    begin
        -- Default assignments (prevent latches)
        brch_pc    <= (others => '0');
        flush_ctrl <= '0';

        if ex_bctrl = '1' then

            -- Detect misprediction
            flush_ctrl <= ex_sctrl xor ex_pctrl;

            -- Compute correct PC only on misprediction
            if (ex_pctrl = '1' and ex_sctrl = '0') then
                -- Predicted taken, actually not taken
                brch_pc <= std_logic_vector(unsigned(ex_pc) + INCREMENT);

            elsif (ex_pctrl = '0' and ex_sctrl = '1') then
                -- Predicted not taken, actually taken
                brch_pc <= ex_target;

            end if;

        end if;
    end process;

end architecture;