library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.decoder.all;

entity register_file is
    port(		   
        clk         : in std_logic;

        instruc     : in std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

        wb_rd       : in std_logic_vector(REGISTER_LENGTH-1 downto 0);
        wb_rd_ptr   : in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
        in_wback    : in std_logic;	

        out_file    : out std_logic_vector(REGISTER_SIZE-1 downto 0);
        opcode      : out std_logic_vector(OPCODE_LENGTH-1 downto 0);

        in_rs3      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
        in_rs2      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
        in_rs1      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);

        in_immed    : out std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

        rs3_ptr     : out std_logic_vector(ADDRESS_LENGTH-1 downto 0); 
        rs2_ptr     : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
        rs1_ptr     : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);  
        rd_ptr      : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);

        out_wback   : out std_logic := '0'	 
    );
end entity;

architecture behavior of register_file is  

    ---------------------------------------------------------------------
    -- Register File Storage
    ---------------------------------------------------------------------
    signal REG_FILE : std_logic_vector(REGISTER_SIZE-1 downto 0) := (others => '0');

begin

    ---------------------------------------------------------------------
    -- Write Back (Clocked)
    ---------------------------------------------------------------------
    reg_write : process(clk)
    begin
        if rising_edge(clk) then
            if in_wback = '1' then
                REG_FILE(
                    (to_integer(unsigned(wb_rd_ptr)) + 1) * REGISTER_LENGTH - 1 downto
                    to_integer(unsigned(wb_rd_ptr)) * REGISTER_LENGTH
                ) <= wb_rd;
            end if;
        end if;
    end process;

    ---------------------------------------------------------------------
    -- Decode + Read + Forwarding (Combinational)
    ---------------------------------------------------------------------
    register_file : process(instruc, REG_FILE, wb_rd, wb_rd_ptr, in_wback)

        -- Input to decoder MUST be variable
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

        -- Register read variables
        variable var_rs3 : std_logic_vector(REGISTER_LENGTH-1 downto 0);
        variable var_rs2 : std_logic_vector(REGISTER_LENGTH-1 downto 0);
        variable var_rs1 : std_logic_vector(REGISTER_LENGTH-1 downto 0);

    begin

        -----------------------------------------------------------------
        -- Default initialization (avoid latches)
        -----------------------------------------------------------------
        var_rs3 := (others => '0');
        var_rs2 := (others => '0');
        var_rs1 := (others => '0');

        -----------------------------------------------------------------
        -- Convert signal → variable for decoder
        -----------------------------------------------------------------
        var_instruc := instruc;

        -----------------------------------------------------------------
        -- Call decoder (VARIABLE inputs)
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
        -- Register Reads
        -----------------------------------------------------------------
        if var_read_sel(2) = '1' then
            var_rs3 := REG_FILE(
                (to_integer(unsigned(var_rs3_ptr)) + 1) * REGISTER_LENGTH - 1 downto
                to_integer(unsigned(var_rs3_ptr)) * REGISTER_LENGTH
            );
        end if;

        if var_read_sel(1) = '1' then
            var_rs2 := REG_FILE(
                (to_integer(unsigned(var_rs2_ptr)) + 1) * REGISTER_LENGTH - 1 downto
                to_integer(unsigned(var_rs2_ptr)) * REGISTER_LENGTH
            );
        end if;

        if var_read_sel(0) = '1' then
            var_rs1 := REG_FILE(
                (to_integer(unsigned(var_rs1_ptr)) + 1) * REGISTER_LENGTH - 1 downto
                to_integer(unsigned(var_rs1_ptr)) * REGISTER_LENGTH
            );
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

        out_file <= REG_FILE;

    end process;

end architecture;