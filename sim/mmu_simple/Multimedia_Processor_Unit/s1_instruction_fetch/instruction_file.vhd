library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;
use work.numeric_var.all;

entity instruction_file is 
	port(				  
	  clk        : in std_logic;
	  pc_count   : in std_logic_vector(COUNTER_LENGTH-1 downto 0);	
	  in_file    : in std_logic_vector(INSTRUCTION_SIZE-1 downto 0); 
	  reload_bar : in std_logic;
	  instruc    : out std_logic_vector(INSTRUCTION_LENGTH-1 downto 0)
	);
end entity;

architecture behavior of instruction_file is	

    signal INSTRUC_FILE : std_logic_vector(INSTRUCTION_SIZE-1 downto 0) := (others => '0');

begin

    ---------------------------------------------------------------------
    -- Memory Load (Clocked)
    ---------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reload_bar = '0' then
                INSTRUC_FILE <= in_file;
            end if;
        end if;
    end process;

    ---------------------------------------------------------------------
    -- Instruction Fetch (Combinational)
    ---------------------------------------------------------------------
    process(pc_count, INSTRUC_FILE)
        variable pc_index : integer;
        variable msb      : integer;
        variable lsb      : integer;
    begin
        pc_index := to_integer(unsigned(pc_count));

        msb := (pc_index * INSTRUCTION_LENGTH + INSTRUCTION_LENGTH) - 1;
        lsb := msb - INSTRUCTION_LENGTH + 1;

        instruc <= INSTRUC_FILE(msb downto lsb);
    end process;

end architecture;