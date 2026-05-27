library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity register_file is
    port(
        clk : in std_logic;

        -- IO signals
        reg_tog    : in std_logic;
        reg_adr    : in std_logic_vector(4 downto 0);  -- 5-bit address select, 
        reg_seg    : in std_logic_vector(2 downto 0);  -- 3-bit segment select
        reg_value : out std_logic_vector(15 downto 0);

        -- Decoded inputs
		id_rs3_ptr	: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		id_rs2_ptr	: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
		id_rs1_ptr	: in std_logic_vector(ADDRESS_LENGTH-1 downto 0);  
		
		read_sel : in std_logic_vector(2 downto 0);
		
        -- Writeback
        wb_rd     : in std_logic_vector(REGISTER_LENGTH-1 downto 0);
        wb_rd_ptr : in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
        wb_wback  : in std_logic;

        -- Outputs
        id_rs1 : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
        id_rs2 : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
        id_rs3 : out std_logic_vector(REGISTER_LENGTH-1 downto 0)
    );
end entity;

architecture behavior of register_file is

    type reg_array is array (0 to REGISTER_HEIGHT-1)
        of std_logic_vector(REGISTER_LENGTH-1 downto 0);

    signal REG_FILE         : reg_array := (others => (others => '0'));
    -- 2-flop synchronizer and edge detector for async reg_tog
    signal tog_sync_0       : std_logic := '0';
    signal tog_sync_1       : std_logic := '0';
    signal tog_sync_prev    : std_logic := '0';
    signal reg_adr_ltch     : std_logic_vector(4 downto 0) := (others => '0');
    signal reg_seg_ltch     : std_logic_vector(2 downto 0) := (others => '0');
   

begin
    ---------------------------------------------------------------------
    -- Debug read (16-bit slice) with 2-flop synchronizer for reg_tog
    ---------------------------------------------------------------------
    rising_edge_tog : process(clk)
    begin
        if rising_edge(clk) then
            tog_sync_0 <= reg_tog;
            tog_sync_1 <= tog_sync_0;
            if (tog_sync_1 = '1' and tog_sync_prev = '0') then
                reg_adr_ltch <= reg_adr;
                reg_seg_ltch <= reg_seg;
            end if;
            tog_sync_prev <= tog_sync_1;
        end if;
    end process;

    process(reg_adr_ltch, reg_seg_ltch, REG_FILE)
        variable v_adr_idx  : integer;
        variable v_seg_idx  : integer;
        variable v_seg_base : integer;
        variable v_reg      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    begin
        v_adr_idx := to_integer(unsigned(reg_adr_ltch));
        v_seg_idx := to_integer(unsigned(reg_seg_ltch));

        v_reg := REG_FILE(v_adr_idx);
        v_seg_base := v_seg_idx * 16; 
        reg_value <= v_reg(v_seg_base + 15 downto v_seg_base);
        
    end process;

    ------------------------------------------------------------------
    -- Decode + Read
    ------------------------------------------------------------------
    process(read_sel, id_rs3_ptr, id_rs2_ptr, id_rs1_ptr, wb_wback, wb_rd, wb_rd_ptr, REG_FILE)
        variable var_rs1      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
        variable var_rs2      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
        variable var_rs3      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    begin
        var_rs1 := (others => '0');
        var_rs2 := (others => '0');
        var_rs3 := (others => '0');
        
        if read_sel(0) = '1' then
            var_rs1 := REG_FILE(to_integer(unsigned(id_rs1_ptr)));
        end if;

        if read_sel(1) = '1' then
            var_rs2 := REG_FILE(to_integer(unsigned(id_rs2_ptr)));
        end if;

        if read_sel(2) = '1' then
            var_rs3 := REG_FILE(to_integer(unsigned(id_rs3_ptr)));
        end if;

        -- forwarding bypass
        if wb_wback = '1' then
            if wb_rd_ptr = id_rs1_ptr then var_rs1 := wb_rd; end if;
            if wb_rd_ptr = id_rs2_ptr then var_rs2 := wb_rd; end if;
            if wb_rd_ptr = id_rs3_ptr then var_rs3 := wb_rd; end if;
        end if;

        id_rs1    <= var_rs1;
        id_rs2    <= var_rs2;
        id_rs3    <= var_rs3;
    end process;
    
    ------------------------------------------------------------------
    -- Writeback: update REG_FILE
    ------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if wb_wback = '1' then
                REG_FILE(to_integer(unsigned(wb_rd_ptr))) <= wb_rd;
            end if;
        end if;
    end process;


end architecture;