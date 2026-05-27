library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.numeric_var.all;

entity instruction_file is
    Port (
        clk        : in std_logic;
        reset_bar  : in std_logic;

        in_addr    : in std_logic_vector(COUNTER_LENGTH-1 downto 0);
        in_instruc : in std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
        wr_enable  : in std_logic;

        out_instruc : out std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
        reset_busy  : out std_logic
    );
end entity;

architecture behavior of instruction_file is
    -- These signals are now always muxed from loader or CPU by the top-level controller
    signal write_en    : std_logic_vector(0 downto 0);
    signal reset_sig   : std_logic;
begin

    reset_sig <= not reset_bar;
    write_en(0) <= wr_enable;

    BLK_MEM : entity work.blk_mem_gen_0(blk_mem_gen_0_arch) -- instruction_file
        port map (
            clka      => clk,
            wea       => write_en,
            addra     => in_addr,
            dina      => in_instruc,
            douta     => out_instruc,
            rsta      => reset_sig,
            rsta_busy => reset_busy
        );

end architecture;
