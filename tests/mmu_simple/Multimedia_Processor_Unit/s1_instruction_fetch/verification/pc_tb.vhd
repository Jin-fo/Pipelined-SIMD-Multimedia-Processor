library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity pc_tb is
end pc_tb;

architecture tb of pc_tb is

    signal clk        : std_logic := '-';
    signal reset_bar  : std_logic := '-';
    signal enable     : std_logic := '-';
    signal pc_count   : std_logic_vector(COUNTER_LENGTH-1 downto 0);
begin

    UUT : entity work.pc
        port map (
            clk       => clk,
            enable    => enable,
            reset_bar => reset_bar,
            pc_count  => pc_count
        );

    -- clock
    clk_process : process
	begin
	    clk <= '0';
	    wait for PERIOD/2;
	    clk <= '1';
	    wait for PERIOD/2;
	end process;
							 
    pc : process
        variable expected : unsigned(COUNTER_LENGTH-1 downto 0);
    begin
	-- after reset
	reset_bar <= '0';
	enable    <= '0';
	wait for PERIOD/2;          
	reset_bar <= '1';
	enable    <= '1';  
	wait for PERIOD/2;
	
	expected := (others => '0');  -- start from 0
	
	-- first rising edge will output 0, then increment expected
	for i in 0 to 31 loop
	    wait until rising_edge(clk);
	
	    assert unsigned(pc_count) = expected
	        report "Mismatch at cycle " & integer'image(i) &
	               ": expected=" & integer'image(to_integer(expected)) &
	               ", got=" & integer'image(to_integer(unsigned(pc_count)))
	               severity error;
	
	    expected := (expected + INCREMENT) mod 2**COUNTER_LENGTH;
	end loop;

        report "PC counter test completed successfully!" severity note;
        wait; 
    end process;

end architecture;
