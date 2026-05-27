library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

use work.numeric_var.all;

entity ex_wb_tb is
end entity;

architecture tb of ex_wb_tb is

    -- Clock period
    constant PERIOD : time := 10 ns;

    -- DUT signals
    signal clk        : std_logic := '-';
    signal enable     : std_logic := '-';
    signal reset_bar  : std_logic := '-';

    signal ex_rd      : std_logic_vector(REGISTER_LENGTH-1 downto 0) := (others => '-');
    signal ex_rd_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0)  := (others => '-');
    signal ex_wback   : std_logic := '0';

    signal wb_rd      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal wb_rd_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal wback      : std_logic;

    --------------------------------------------------------------------
    -- Converts SLV to string (your function)
    --------------------------------------------------------------------
    function slv_to_str(v : std_logic_vector) return string is
        variable s : string(1 to v'length);
    begin
        for i in v'range loop
            case v(i) is
                when '0' => s(v'length - i) := '0';
                when '1' => s(v'length - i) := '1';
                when others => s(v'length - i) := 'X';
            end case;
        end loop;
        return s;
    end function;

begin

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    DUT : entity work.ex_wb
        port map(
            clk       => clk,
            enable    => enable,
            reset_bar => reset_bar,
            ex_rd     => ex_rd,
            ex_rd_ptr => ex_rd_ptr,
            ex_wback  => ex_wback,
            wb_rd     => wb_rd,
            wb_rd_ptr => wb_rd_ptr,
            wback     => wback
        );

    --------------------------------------------------------------------
    -- Clock generation
    --------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for PERIOD/2;
        clk <= '1';
        wait for PERIOD/2;
    end process;

    --------------------------------------------------------------------
    -- Stimulus + file writing
    --------------------------------------------------------------------
    stim_proc : process
        file f_out : text open write_mode is "src\register_file.txt";
        variable L : line;
    begin
        ---------------------------------------------------------
        -- Apply reset
        ---------------------------------------------------------
		reset_bar <= '0';
		enable    <= '0';
		wait for PERIOD/2;
		reset_bar <= '1';
		enable    <= '1';
		wait until rising_edge(clk);
		
		-- Test Vector 1
		ex_rd     <= (others => '1');
		ex_rd_ptr <= std_logic_vector(to_unsigned(5, ADDRESS_LENGTH));
		ex_wback  <= '1';
		
		wait until rising_edge(clk);
		wait for 1 ns;   -- critical to allow DUT to update outputs
		
		write(L, string'("rd="));
		write(L, slv_to_str(wb_rd));
		write(L, string'("  ptr="));
		write(L, slv_to_str(wb_rd_ptr));
		write(L, string'("  wb="));
		write(L, wback);
		writeline(f_out, L);
		
        ---------------------------------------------------------
        -- Done
        ---------------------------------------------------------
        report "Testbench completed. File ex_wb_output.txt created.";
        wait;
    end process;

end architecture;
