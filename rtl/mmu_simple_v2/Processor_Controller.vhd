library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;

entity Processor_Controller is
    port (
        clk        : in  std_logic;
        rst_bar    : in  std_logic;
        enable     : in  std_logic;

        -- UART input
        rx         : in std_logic;
        loaded     : out std_logic;
        
        -- FSM CTRL 
        uart        : out std_logic;
        cpu         : out std_logic;

        -- debug
        reg_pos    : in  std_logic_vector(7 downto 0);
        reg_tog    : in  std_logic;
        reg_value  : out std_logic_vector(15 downto 0)
    );
end entity;

architecture structural of Processor_Controller is
    --------------------------------------------------------------------
    -- FSM CONTROL SIGNALS
    --------------------------------------------------------------------
    signal load_done  : std_logic;
    signal uart_en    : std_logic;
    signal cpu_en     : std_logic;

    --------------------------------------------------------------------
    -- USART OUTPUT SIGNALS
    --------------------------------------------------------------------
    signal  rx_data   : std_logic_vector(7 downto 0);
    signal rx_ready   : std_logic;
    
    --------------------------------------------------------------------
    -- PC ADDRESS SIGNALS
    --------------------------------------------------------------------
    signal pc_count   : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal pc_addr    : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    --------------------------------------------------------------------
    -- ACCUMULATOR → CPU BRAM INTERFACE
    --------------------------------------------------------------------
    signal instr_addr : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal instr_data : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);
    signal wr_enable  : std_logic;
    
    signal rst_busy : std_logic;
    signal fsm_enable : std_logic;
    
begin
    -- Gate FSM enable with rst_busy: only enable FSM when CPU reset is complete
    fsm_enable <= enable and (not rst_busy);

    --------------------------------------------------------------------
    -- A1. FSM CONTROLLER
    --------------------------------------------------------------------
    CNTRL_FSM : entity work.control_FSM(behavior)
    port map (
        clk       => clk,
        rst_bar   => rst_bar,
        enable    => fsm_enable,
        load_done => load_done,

        uart_en   => uart_en,
        cpu_en    => cpu_en
    );

    uart <= uart_en;
    cpu  <= cpu_en;
    loaded <= load_done;

    --------------------------------------------------------------------
    -- A2. USART UNIT
    --------------------------------------------------------------------
    USART : entity work.USART_unit(structural)
    port map ( 
        clk       => clk,
        rst_bar   => rst_bar,
        enable    => uart_en,
        
        rx  => rx,

        rx_data     => rx_data,
        rx_ready    => rx_ready
    );

    --------------------------------------------------------------------
    -- A3. ACCUMULATOR (UART → 32-bit instruction stream)
    --------------------------------------------------------------------
    INSTRUC_LDR : entity work.instruction_loader(behavior)
    port map (
        clk        => clk,
        rst_bar    => rst_bar,
        enable     => rx_ready,
        
        rx_data    => rx_data,
        bram_addr  => instr_addr,
        bram_data  => instr_data,
        bram_we    => wr_enable,
        
        load_done  => load_done
    );

    --------------------------------------------------------------------
    -- B1. CPU CORE (INCLUDES BRAM INSIDE)
    --------------------------------------------------------------------
    P_C : entity work.pc(behavior)				  
		port map (	 
		--control
		clk 		=> clk,	
		enable		=> cpu_en,
		reset_bar 	=> rst_bar,
		--output
		pc_count 	=> pc_count
		); 

    --------------------------------------------------------------------
    -- MUX(cpu_en & rst_busy) = {{xx: A3(instr_addr)}, {10: B1(pc_count)}} → C1(in_addr)
    --------------------------------------------------------------------

    pc_addr <= pc_count when cpu_en = '1' and rst_busy = '0' else instr_addr; 
    --------------------------------------------------------------------
    -- C1. CPU CORE (INCLUDES BRAM INSIDE)
    --------------------------------------------------------------------
    MMU_CPU : entity work.Multimedia_Processor_Unit(structural)
    port map (
        clk        => clk,
        reset_bar  => rst_bar,
        enable     => cpu_en,

        -- bootloader interface
        bram_data => instr_data,
        bram_addr => pc_addr,
        bram_we   => wr_enable,

        -- runtime outputs
        reg_tog   => reg_tog,
        reg_adr    => reg_pos(7 downto 3),
        reg_seg    => reg_pos(2 downto 0),
        reg_value  => reg_value,

        reset_busy => rst_busy
    );

end architecture;