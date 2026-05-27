library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use work.numeric_var.all;

entity register_file is
    port(	
		-- inputs (read)   
		clk			: in std_logic;
        read_sel    : in std_logic_vector(2 downto 0);

        id_rs3_ptr  : in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
        id_rs2_ptr  : in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
        id_rs1_ptr  : in std_logic_vector(ADDRESS_LENGTH-1 downto 0);

        -- writeback
        wb_rd       : in std_logic_vector(REGISTER_LENGTH-1 downto 0);
        wb_rd_ptr   : in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
        wb_wback    : in std_logic;	

        -- outputs
        id_rs3      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
        id_rs2      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
        id_rs1      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);	

        -- debug
        out_file    : out std_logic_vector(REGISTER_SIZE-1 downto 0)
    );
end entity;

architecture behavior of register_file is  

    ----------------------------------------------------------------
    -- Structured register file
    ----------------------------------------------------------------
    type reg_entry is record
        data : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    end record;

    type reg_array is array(0 to 2**ADDRESS_LENGTH - 1) of reg_entry;

    signal REG_FILE : reg_array := (others => (data => (others => '0')));

begin		

    ----------------------------------------------------------------
    -- Process 1: Read + Forwarding (combinational)
    ----------------------------------------------------------------
    register_read : process(read_sel, id_rs3_ptr, id_rs2_ptr, id_rs1_ptr, wb_wback, wb_rd, wb_rd_ptr, REG_FILE)
        variable var_rs3 : std_logic_vector(REGISTER_LENGTH-1 downto 0);
        variable var_rs2 : std_logic_vector(REGISTER_LENGTH-1 downto 0);
        variable var_rs1 : std_logic_vector(REGISTER_LENGTH-1 downto 0);

        variable idx3, idx2, idx1 : integer;
    begin
        -- defaults
        var_rs3 := (others => '0');
        var_rs2 := (others => '0');
        var_rs1 := (others => '0');

        idx3 := to_integer(unsigned(id_rs3_ptr));
        idx2 := to_integer(unsigned(id_rs2_ptr));
        idx1 := to_integer(unsigned(id_rs1_ptr));

        -- read
        if read_sel(2) = '1' then
            var_rs3 := REG_FILE(idx3).data;
        end if;

        if read_sel(1) = '1' then
            var_rs2 := REG_FILE(idx2).data;
        end if;

        if read_sel(0) = '1' then
            var_rs1 := REG_FILE(idx1).data;
        end if;

        -- forwarding
        if wb_wback = '1' then
            if wb_rd_ptr = id_rs3_ptr then
                var_rs3 := wb_rd;
            end if;

            if wb_rd_ptr = id_rs2_ptr then
                var_rs2 := wb_rd;
            end if;

            if wb_rd_ptr = id_rs1_ptr then
                var_rs1 := wb_rd;
            end if;
        end if;

        -- outputs
        id_rs3 <= var_rs3;
        id_rs2 <= var_rs2;
        id_rs1 <= var_rs1;

    end process;

    ----------------------------------------------------------------
    -- Process 2: Clocked Write
    ----------------------------------------------------------------
    register_write : process(clk)
        variable idx : integer;
    begin
        if falling_edge(clk) then
            if wb_wback = '1' then
                idx := to_integer(unsigned(wb_rd_ptr));
                REG_FILE(idx).data <= wb_rd;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Process 3: Debug Output
    ----------------------------------------------------------------
    register_debug : process(REG_FILE)
    begin
        for i in 0 to 2**ADDRESS_LENGTH - 1 loop
            out_file((i+1)*REGISTER_LENGTH-1 downto i*REGISTER_LENGTH) 
                <= REG_FILE(i).data;
        end loop;
    end process;

end architecture;