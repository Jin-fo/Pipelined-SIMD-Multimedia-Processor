library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decoder.all;
use work.numeric_var.all;

entity register_file is
    port(
        clk : in std_logic;

        -- Debug IO
        reg_pos   : in std_logic_vector(7 downto 0);
        reg_tog   : in std_logic;
        reg_value : out std_logic_vector(15 downto 0);
        
        -- Instruction
        instruc : in std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

        -- Writeback
        wb_rd     : in std_logic_vector(REGISTER_LENGTH-1 downto 0);
        wb_rd_ptr : in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
        in_wback  : in std_logic;

        -- Outputs
        opcode    : out std_logic_vector(OPCODE_LENGTH-1 downto 0);

        in_rs3    : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
        in_rs2    : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
        in_rs1    : out std_logic_vector(REGISTER_LENGTH-1 downto 0);

        in_immed  : out std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

        rs3_ptr   : out std_logic_vector(ADDRESS_LENGTH-1 downto 0); 
        rs2_ptr   : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
        rs1_ptr   : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);  
        rd_ptr    : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);

        out_wback : out std_logic
    );
end entity;

architecture behavior of register_file is  

    ---------------------------------------------------------------------
    -- Register File Storage (record-based)
    ---------------------------------------------------------------------
    type reg_entry is record
        data : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    end record;

    type reg_array is array (0 to 2**ADDRESS_LENGTH - 1) of reg_entry;

    signal REG_FILE : reg_array := (others => (data => (others => '0')));

    signal reg_pos_internal : std_logic_vector(7 downto 0) := (others => '0');

begin

    ---------------------------------------------------------------------
    -- Debug latch
    ---------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reg_tog = '1' then
                reg_pos_internal <= reg_pos;
            end if;
        end if;
    end process;

    ---------------------------------------------------------------------
    -- Debug read (16-bit slice)
    ---------------------------------------------------------------------
    process(reg_pos_internal, REG_FILE)
        variable v_reg_idx  : integer;
        variable v_seg_idx  : integer;
        variable v_seg_base : integer;
        variable v_reg      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    begin
        v_reg_idx := to_integer(unsigned(reg_pos_internal(7 downto 3)));
        v_seg_idx := to_integer(unsigned(reg_pos_internal(2 downto 0)));

        v_reg := REG_FILE(v_reg_idx).data;
        v_seg_base := v_seg_idx * 16;

        if (v_seg_base + 15) < REGISTER_LENGTH then
            reg_value <= v_reg(v_seg_base + 15 downto v_seg_base);
        else
            reg_value <= (others => '0');
        end if;
    end process;

    ---------------------------------------------------------------------
    -- Register Write (clocked)
    ---------------------------------------------------------------------
    reg_write : process(clk)
        variable idx : integer;
    begin
        if rising_edge(clk) then
            if in_wback = '1' then
                idx := to_integer(unsigned(wb_rd_ptr));
                REG_FILE(idx).data <= wb_rd;
            end if;
        end if;
    end process;

    ---------------------------------------------------------------------
    -- Decode + Read + Forwarding (Combinational)
    ---------------------------------------------------------------------
    register_file : process(instruc, REG_FILE, wb_rd, wb_rd_ptr, in_wback)

        variable var_instruc : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

        -- Decoder outputs
        variable var_opcode   : std_logic_vector(OPCODE_LENGTH-1 downto 0);
        variable var_rs3_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
        variable var_rs2_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
        variable var_rs1_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
        variable var_rd_ptr   : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
        variable var_immed    : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
        variable var_wback    : std_logic;
        variable var_read_sel : std_logic_vector(2 downto 0);

        -- Read values
        variable var_rs3 : std_logic_vector(REGISTER_LENGTH-1 downto 0);
        variable var_rs2 : std_logic_vector(REGISTER_LENGTH-1 downto 0);
        variable var_rs1 : std_logic_vector(REGISTER_LENGTH-1 downto 0);

        variable idx3, idx2, idx1 : integer;

    begin
        -----------------------------------------------------------------
        -- Defaults
        -----------------------------------------------------------------
        var_rs3 := (others => '0');
        var_rs2 := (others => '0');
        var_rs1 := (others => '0');

        var_instruc := instruc;

        -----------------------------------------------------------------
        -- Decode instruction
        -----------------------------------------------------------------
        decoder_main(
            var_instruc,
            var_opcode,
            var_rs3_ptr,
            var_rs2_ptr,
            var_rs1_ptr,
            var_immed,
            var_rd_ptr,
            var_wback,
            var_read_sel
        );

        -----------------------------------------------------------------
        -- Convert pointers
        -----------------------------------------------------------------
        idx3 := to_integer(unsigned(var_rs3_ptr));
        idx2 := to_integer(unsigned(var_rs2_ptr));
        idx1 := to_integer(unsigned(var_rs1_ptr));

        -----------------------------------------------------------------
        -- Register Reads
        -----------------------------------------------------------------
        if var_read_sel(2) = '1' then
            var_rs3 := REG_FILE(idx3).data;
        end if;

        if var_read_sel(1) = '1' then
            var_rs2 := REG_FILE(idx2).data;
        end if;

        if var_read_sel(0) = '1' then
            var_rs1 := REG_FILE(idx1).data;
        end if;

        -----------------------------------------------------------------
        -- Forwarding
        -----------------------------------------------------------------
        if in_wback = '1' then
            if wb_rd_ptr = var_rs3_ptr then
                var_rs3 := wb_rd;
            end if;

            if wb_rd_ptr = var_rs2_ptr then
                var_rs2 := wb_rd;
            end if;

            if wb_rd_ptr = var_rs1_ptr then
                var_rs1 := wb_rd;
            end if;
        end if;

        -----------------------------------------------------------------
        -- Outputs
        -----------------------------------------------------------------
        in_rs3 <= var_rs3;
        in_rs2 <= var_rs2;
        in_rs1 <= var_rs1;

        opcode   <= var_opcode;
        in_immed <= var_immed;
        out_wback <= var_wback;

        rs3_ptr <= var_rs3_ptr;
        rs2_ptr <= var_rs2_ptr;
        rs1_ptr <= var_rs1_ptr;
        rd_ptr  <= var_rd_ptr;

    end process;

end architecture;