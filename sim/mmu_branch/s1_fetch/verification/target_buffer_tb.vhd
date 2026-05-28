library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.numeric_var.all;

entity target_buffer_tb is
end entity;

architecture tb of target_buffer_tb is
    signal pc_counter : std_logic_vector(COUNTER_LENGTH-1 downto 0) := (others => '0');
    signal id_tctrl   : std_logic := '0';
    signal id_pc      : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal id_target  : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal out_buffer : std_logic_vector(BUFFER_SIZE-1 downto 0);
    
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
    
    dut : entity work.target_buffer
        port map (
            if_pc        => pc_counter,
            id_tctrl     => id_tctrl,
            id_pc        => id_pc,
            id_target    => id_target,
            iff_target   => open,
            out_buffer   => out_buffer
        );
    
    write_buffer_proc : process(pc_counter)
        variable line_buf : line;
        variable bit_index : integer := 0;
        variable valid_bit : std_logic;
        variable target_value : std_logic_vector(COUNTER_LENGTH-1 downto 0);
        file output_file : text;
    begin
        
        file_open(output_file, "src/internal_result/out_buffer.txt", write_mode);
        
        bit_index := 0;
        for i in 0 to (2**(COUNTER_LENGTH)-1) loop
            valid_bit := out_buffer(bit_index);
            target_value := out_buffer(bit_index + COUNTER_LENGTH downto bit_index + 1);
            
            write(line_buf, std_logic'image(valid_bit)(2 to 3));
            write(line_buf, slv_to_str(target_value));
            
            writeline(output_file, line_buf);
            bit_index := bit_index + (1 + COUNTER_LENGTH);
        end loop;
        
        file_close(output_file);
        
    end process write_buffer_proc;
    
    pc_counter_proc : process
    begin
        pc_counter <= (others => '0');
        wait for PERIOD;
        
        while to_integer(unsigned(pc_counter)) < 2**(COUNTER_LENGTH)-1 loop
            pc_counter <= std_logic_vector(unsigned(pc_counter) + 1);
            wait for PERIOD;
        end loop;
        
        wait;
    end process pc_counter_proc;
    
    stim : process
    begin
        id_pc     <= (others => '0');
        id_target <= (others => '0');
        id_tctrl  <= '0';
        wait for PERIOD;
        
        id_tctrl  <= '1';
        id_pc     <= std_logic_vector(to_unsigned(1, COUNTER_LENGTH));
        id_target <= std_logic_vector(to_unsigned(63, COUNTER_LENGTH));
        wait for PERIOD;
        id_tctrl  <= '0';
        wait for PERIOD;
        
        id_tctrl  <= '1';
        id_pc     <= std_logic_vector(to_unsigned(2, COUNTER_LENGTH));
        id_target <= std_logic_vector(to_unsigned(10, COUNTER_LENGTH));
        wait for PERIOD;
        id_tctrl  <= '0';
        wait for PERIOD;
        
        id_tctrl  <= '1';
        id_pc     <= std_logic_vector(to_unsigned(5, COUNTER_LENGTH));
        id_target <= std_logic_vector(to_unsigned(32, COUNTER_LENGTH));
        wait for PERIOD;
        id_tctrl  <= '0';
        wait for PERIOD * 20;
        
        assert false report "Simulation finished" severity note;
        wait;
    end process stim;

end architecture tb;