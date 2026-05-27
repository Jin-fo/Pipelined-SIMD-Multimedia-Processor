library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.numeric_var.all;   -- contains INSTRUCTION_LENGTH, NOP, etc.
use std.textio.all;
use ieee.std_logic_textio.all;

entity if_id_tb is
end if_id_tb;

architecture tb of if_id_tb is

    -- DUT signals
    signal clk        : std_logic := '-';
    signal enable     : std_logic := '-';
    signal reset_bar  : std_logic := '-';
    signal if_instruc : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0):= (others => '-');
    signal id_instruc : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

    --------------------------------------------------------------------
    -- LOCAL helper function : converts string -> std_logic_vector
    --------------------------------------------------------------------
    function str_to_slv(s : string) return std_logic_vector is
        variable v : std_logic_vector(s'length-1 downto 0);
    begin
        for i in s'range loop
            case s(i) is
                when '0' => v(s'length - i) := '0';
                when '1' => v(s'length - i) := '1';
                when others => v(s'length - i) := 'X';
            end case;
        end loop;
        return v;
    end function;

begin

    -------------------------------------------------------------------
    -- DUT INSTANTIATION
    -------------------------------------------------------------------
    DUT: entity work.if_id
        port map (
            clk        => clk,
            enable     => enable,
            reset_bar  => reset_bar,
            if_instruc => if_instruc,
            id_instruc => id_instruc
        );

    -------------------------------------------------------------------
    -- CLOCK GENERATION
    -------------------------------------------------------------------
    clk_process : process
	begin
	    clk <= '0';
	    wait for PERIOD/2;
	    clk <= '1';
	    wait for PERIOD/2;
	end process;
	
    -------------------------------------------------------------------
    -- TEST SEQUENCE: LOOP THROUGH FILE
    -------------------------------------------------------------------
    stim_proc : process
        file f       : text open read_mode is "instruction_file.txt";
        variable L   : line;
        variable str : string(1 to INSTRUCTION_LENGTH);
    begin

        -------------------------------------------------------------------
        -- 1. Apply reset
        -------------------------------------------------------------------
        reset_bar <= '0';
        enable    <= '0';
        wait for PERIOD/2;
        reset_bar <= '1';
		enable	  <= '1';
        wait until rising_edge(clk);

        -------------------------------------------------------------------
        -- 2. Read all instructions from file
        -------------------------------------------------------------------
        while not endfile(f) loop
            readline(f, L);
            read(L, str);    -- read INSTRUCTION_LENGTH chars

            -- convert string -> std_logic_vector
            if_instruc <= str_to_slv(str);

            wait until rising_edge(clk);
        end loop;

        -------------------------------------------------------------------
        -- 3. Finish simulation
        -------------------------------------------------------------------
        report "All instructions processed. Simulation complete." severity note;
        wait;
    end process;


end architecture;
