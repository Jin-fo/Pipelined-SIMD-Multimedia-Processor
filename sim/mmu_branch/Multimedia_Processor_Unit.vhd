library ieee;
use ieee.std_logic_1164.all;
use work.numeric_var.all;
use work.all;

entity Multimedia_Processor_Unit is	 
	port (		 	  
	--unit input
	clk 		: in std_logic;	  
	enable		: in std_logic;
	reset_bar 	: in std_logic;
	
	in_Ifile    : in std_logic_vector(FILE_SIZE-1 downto 0);   
	--unit output  
	out_Tbuffer : out std_logic_vector(BUFFER_SIZE-1 downto 0);	
	out_Sbuffer	: out std_logic_vector(BUFFER_SIZE-1 downto 0);	
	
	out_Rfile	: out std_logic_vector(REGISTER_SIZE-1 downto 0);  
	
    -- ======================
    -- IF stage (debug)
    -- ======================
	pc_current_i : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
	pc_next_i    : out std_logic_vector(COUNTER_LENGTH-1 downto 0);

    if_pc_i      : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    if_instruc_i : out std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

    id_target_i    : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    id_pctrl_i   : out std_logic;

    iff_target_i : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    ifd_target_i : out std_logic_vector(COUNTER_LENGTH-1 downto 0);

    -- ======================
    -- IF/ID stage (debug)
    -- ======================
    id_pc_i       : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    id_instruc_i : out std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

    -- ======================
    -- Decode stage (debug)
    -- ======================
    id_opcode_i  : out std_logic_vector(OPCODE_LENGTH-1 downto 0);

    id_rs3_ptr_i : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    id_rs2_ptr_i : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    id_rs1_ptr_i : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    id_rd_ptr_i  : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);

    id_immed_i   : out std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
    read_sel_i   : out std_logic_vector(2 downto 0);

    id_wback_i   : out std_logic;
    id_bctrl_i  : out std_logic;
    id_jump_i    : out std_logic;

    -- ======================
    -- Branch Predictor (debug)
    -- ======================
    id_tctrl_i  : out std_logic;

    id_state_i   : out std_logic_vector(STATE_LENGTH-1 downto 0);
    id_brch_i     : out std_logic;

    -- ======================
    -- Register File (debug)
    -- ======================
    id_rs3_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    id_rs2_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    id_rs1_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);

    -- ======================
    -- ID/EX pipeline (debug)
    -- ======================
    ex_pc_i    	 : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    ex_opcode_i  : out std_logic_vector(OPCODE_LENGTH-1 downto 0);

    ex_rs3_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    ex_rs2_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    ex_rs1_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    ex_immed_i   : out std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

    ex_rd_ptr_i  : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    ex_rs3_ptr_i : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    ex_rs2_ptr_i : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    ex_rs1_ptr_i : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
   
	ex_target_i  : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    ex_state_i   : out std_logic_vector(STATE_LENGTH-1 downto 0);
    ex_wback_i   : out std_logic;
    ex_pctrl_i   : out std_logic;
    ex_bctrl_i     : out std_logic;

    -- ======================
    -- Execute / Control (debug)
    -- ======================	
	fw_rs3_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    fw_rs2_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    fw_rs1_i     : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
	fw_state_i	 : out std_logic_vector(1 downto 0);
    ex_rd_i      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
	brch_pc_i 	 : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
    ex_sctrl_i   : out std_logic;
    flush_ctrl_i : out std_logic;

    -- ======================
    -- Write-back FSM (debug)
    -- ======================
    fsm_state_i  : out std_logic_vector(1 downto 0);
    fsm_sctrl_i  : out std_logic;

    -- ======================
    -- Write Back stage (debug)
    -- ======================
    wb_rd_i      : out std_logic_vector(REGISTER_LENGTH-1 downto 0);
    wb_rd_ptr_i  : out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    wb_wback_i   : out std_logic;	  
	
	wb_pc_i	  	 : out std_logic_vector(COUNTER_LENGTH-1 downto 0);
	wb_sctrl_i	 : out std_logic;
	wb_state_i	 : out std_logic_vector(1 downto 0)	 
	);
end Multimedia_Processor_Unit;

architecture structural of Multimedia_Processor_Unit is	 
   	-- ======================
    -- Global / IF stage
    -- ====================== 	  
	signal pc_current : std_logic_vector(COUNTER_LENGTH-1 downto 0);
	signal pc_next    : std_logic_vector(COUNTER_LENGTH-1 downto 0);

    signal if_pc        : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal if_instruc  : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

    signal id_pctrl    : std_logic;

    signal iff_target  : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal ifd_target  : std_logic_vector(COUNTER_LENGTH-1 downto 0);

    -- ======================
    -- IF/ID stage
    -- ======================
    signal id_pc        : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal id_instruc  : std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);

    -- ======================
    -- Decode stage
    -- ======================
    signal id_opcode   : std_logic_vector(OPCODE_LENGTH-1 downto 0);

    signal id_rs3_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal id_rs2_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal id_rs1_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal id_rd_ptr   : std_logic_vector(ADDRESS_LENGTH-1 downto 0);

    signal id_immed    : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

    signal read_sel    : std_logic_vector(2 downto 0);

    signal id_wback    : std_logic;
    signal id_bctrl   : std_logic;
    signal id_jump     : std_logic;

    -- ======================
    -- Branch Predictor
    -- ======================
    signal id_target  : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal id_tctrl   : std_logic;

    signal id_state    : std_logic_vector(STATE_LENGTH-1 downto 0);
    signal id_brch      : std_logic;

    -- ======================
    -- Register File
    -- ======================
    signal id_rs3      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal id_rs2      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal id_rs1      : std_logic_vector(REGISTER_LENGTH-1 downto 0);

    -- ======================
    -- ID/EX pipeline
    -- ======================
    signal ex_pc       : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal ex_opcode  : std_logic_vector(OPCODE_LENGTH-1 downto 0);

    signal ex_rs3     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal ex_rs2     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal ex_rs1     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal ex_immed   : std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);

    signal ex_rd_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal ex_rs3_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal ex_rs2_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal ex_rs1_ptr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	
	signal ex_target   : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal ex_state   : std_logic_vector(STATE_LENGTH-1 downto 0);
    signal ex_wback   : std_logic;
    signal ex_pctrl   : std_logic;
    signal ex_bctrl     : std_logic;

    -- ======================
    -- Execute / MMU / ALU
    -- ======================
	signal fw_rs3     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal fw_rs2     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal fw_rs1     : std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal fw_state	  : std_logic_vector(1 downto 0);
	
    signal ex_rd      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal brch_pc	  : std_logic_vector(COUNTER_LENGTH-1 downto 0);
    signal ex_sctrl   : std_logic;
    signal flush_ctrl : std_logic;

    -- ======================
    -- FSM write-back signals
    -- ======================	   
    signal fsm_state  : std_logic_vector(1 downto 0);
    signal fsm_sctrl  : std_logic;

    -- ======================
    -- Write Back stage
    -- ======================
    signal wb_rd      : std_logic_vector(REGISTER_LENGTH-1 downto 0);
    signal wb_rd_ptr  : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
    signal wb_wback   : std_logic; 	
	signal wb_pc	  : std_logic_vector(COUNTER_LENGTH-1 downto 0);
	signal wb_state	  :	std_logic_vector(1 downto 0);
	signal wb_sctrl	  :	std_logic;

begin				 
	-- =========================
	-- PC REGISTER
	-- =========================
	PC : entity work.pc(behavior)
	    port map (			 
			--setup
	        clk        => clk,
	        enable     => enable,
	        reset_bar  => reset_bar, 
			
			--inputs
	        pc_next    => pc_next,	
			
			--outputs
	        pc_current => pc_current
	    );
	
	-- =========================
	-- PC SELECT (COMBINATIONAL)
	-- =========================
	PC_SEL : entity work.pc_select(behavior)
	    port map (	   
			--inputs(default)
	        pc_current     => pc_current, 
			
			--inputs(predict)
	        pred_pc    => id_target,
	        id_pctrl   => id_pctrl,	 
			
			--inputs(flush)
	        brch_pc    => brch_pc,
	        flush_ctrl => flush_ctrl,
			
			--outputs
	        pc_next    => pc_next,
	        if_pc      => if_pc
	    );
		
	T_BUFF : entity work.target_buffer(behavior)
		port map ( 	
		--input
		clk			=> clk,
		if_pc		=> if_pc,
		
		--wback(branch)
		id_tctrl	=> id_tctrl,
		id_pc  	  	=> id_pc,
		id_target 	=> id_target, 
		
		--outputs(branch)   
		iff_target 	=> iff_target, 
		
		--outputs(debug)
		out_buffer	=> out_Tbuffer);

	I_File : entity work.instruction_file(behavior)		
		port map (	  
		--inputs(data)
		if_pc 		=> if_pc,
		reset_bar	=> reset_bar,
		in_file		=> in_Ifile,	
		
		--outputs(data)
		if_instruc 	=> if_instruc);
		
	IF_ID : entity work.if_id(behavior)
		port map (	
		--setup
		clk			=> clk,	  
		enable		=> enable,
		reset_bar 	=> reset_bar,
		
		--inputs(data)				 
		if_pc		=> if_pc,
		if_instruc 	=> if_instruc,
		iff_target 	=> iff_target,	
		
		--control
		flush_ctrl  => flush_ctrl,
		
		--outputs(data)	
		id_pc		=> id_pc,
		id_instruc  => id_instruc,
		ifd_target	=> ifd_target);
		
	D_CODE : entity work.decoder(behavior) 
		port map (		
		--input
		id_instruc  => id_instruc,
		
		--outputs(data)
		id_opcode	=> id_opcode,
		id_rs3_ptr	=> id_rs3_ptr,
		id_rs2_ptr	=> id_rs2_ptr,
		id_rs1_ptr	=> id_rs1_ptr,
		id_rd_ptr	=> id_rd_ptr,
		id_immed	=> id_immed,
		read_sel   	=> read_sel,
		
		--controls(data)
		id_wback	=> id_wback,
		
		--controls(branch)
		id_bctrl	=> id_bctrl,
		id_jump		=> id_jump);
	
	B_Target : entity work.target_correct(behavior)
		port map ( 
		--inputs(branch)
		id_pc	 	=> id_pc,
		id_immed	=> id_immed,
		ifd_target	=> ifd_target,
		id_bctrl	=> id_bctrl,
		
		--outputs(branch)
		id_target	=> id_target,
		id_tctrl	=> id_tctrl);
		
	S_BUFF : entity work.state_buffer(behavior)
		port map (
		--inputs(branch)	
		clk 		=> clk,
		id_pc		=> id_pc,
		id_bctrl	=> id_bctrl, 
		
		--wback(branch)
		wb_pc 		=> wb_pc,
		wb_state    => wb_state,
		wb_sctrl	=> wb_sctrl,
		
		--outputs(branch)
		id_state	=> id_state,
		out_buffer	=> out_Sbuffer);
		
	B_PRED: entity work.branch_predictor(behavior)
		port map (	   
		--inputs(branch) 
		id_state	=> id_state,
		id_jump		=> id_jump,
		
		--outputs(branch)
		id_pctrl    => id_pctrl);

	R_File : entity work.register_file(behavior)
		port map (
		--inputs(data)	
		clk 		=> clk,
		read_sel 	=> read_sel,
		
		id_rs3_ptr 	=> id_rs3_ptr, 
		id_rs2_ptr	=> id_rs2_ptr, 
		id_rs1_ptr	=> id_rs1_ptr,
		
		--wback(data)  
		wb_rd		=> wb_rd,	  
		wb_rd_ptr	=> wb_rd_ptr,
		wb_wback	=> wb_wback,	  
		
		--outputs(data)			
		id_rs3	 	=> id_rs3,
		id_rs2		=> id_rs2,
		id_rs1		=> id_rs1, 
		
		--outputs(debug)
		out_file 	=> out_Rfile);
		
	ID_EX : entity work.id_ex(behavior)
		port map (	
		--setup
		clk 		=> clk,	 
		enable		=> enable,
		reset_bar 	=> reset_bar,
		
		--inputs(data)
		id_pc		=> id_pc,
		id_opcode	=> id_opcode,
		
		id_rs3		=> id_rs3,
		id_rs2		=> id_rs2,
		id_rs1 		=> id_rs1,
		id_immed 	=> id_immed,
		
		id_rd_ptr	=> id_rd_ptr,
		id_rs3_ptr	=> id_rs3_ptr,			
		id_rs2_ptr	=> id_rs2_ptr,		  
		id_rs1_ptr	=> id_rs1_ptr, 
		
		--inputs(branch)
		id_target	=> id_target,
		id_state	=> id_state,
		id_wback	=> id_wback,
		id_pctrl	=> id_pctrl,
		id_bctrl	=> id_bctrl,
		
		--outputs(data)
		ex_pc		=> ex_pc,
		ex_opcode	=> ex_opcode,
		
		ex_rs3		=> ex_rs3,
		ex_rs2		=> ex_rs2,
		ex_rs1		=> ex_rs1,
		ex_immed   	=> ex_immed,
		
		ex_rd_ptr	=> ex_rd_ptr,
		ex_rs3_ptr  => ex_rs3_ptr,
		ex_rs2_ptr	=> ex_rs2_ptr,
		ex_rs1_ptr	=> ex_rs1_ptr,
		
		--outputs(branch)		
		ex_target	=> ex_target,
		ex_state	=> ex_state,
		ex_wback	=> ex_wback,
		ex_pctrl	=> ex_pctrl,
		ex_bctrl	=> ex_bctrl); 
		
	FOR_WARD : entity work.forward(behavior)
		port map (	   
		--inputs(data)
		ex_rs3 		=> ex_rs3,
		ex_rs2		=> ex_rs2,
		ex_rs1		=> ex_rs1, 
		
		ex_rs3_ptr	=> ex_rs3_ptr,
		ex_rs2_ptr	=> ex_rs2_ptr,
		ex_rs1_ptr	=> ex_rs1_ptr,	
		ex_pc 		=> ex_pc,  
		
		--inputs(branch)
		ex_state	=> ex_state,
		
		--forward(data)
		wb_rd		=> wb_rd,
		wb_rd_ptr	=> wb_rd_ptr,
		wb_wback	=> wb_wback,
		
		--forward(branch)
		wb_state	=> wb_state,
		wb_pc	   	=> wb_pc,
		wb_sctrl	=> wb_sctrl,
		
		--outputs(data)
		fw_rs3 		=> fw_rs3,
		fw_rs2		=> fw_rs2,
		fw_rs1		=> fw_rs1, 	
		
		--output(branch)
		fw_state	=> fw_state);
		
	MMU_ALU : entity work.mmu(behavior)
		port map ( 
		--inputs(data)
		ex_opcode	=> ex_opcode,		
		fw_rs3 		=> fw_rs3,
		fw_rs2		=> fw_rs2,
		fw_rs1		=> fw_rs1,
		ex_immed	=> ex_immed,
		
		--inputs(branch)	  
		ex_bctrl	=> ex_bctrl,
		
		--outputs(data)
		ex_rd		=> ex_rd,
		
		--outputs(branch)	
		ex_sctrl	=> ex_sctrl);	 
		
	CTRL_FLUSH : entity work.flush_control(behavior)
    	port map (
        --inputs(branch)   
		ex_bctrl   => ex_bctrl, 
        ex_pctrl   => ex_pctrl,     -- predicted branch control
        ex_sctrl   => ex_sctrl,     -- actual resolved branch control
        ex_pc      => ex_pc,        -- current PC in EX stage
        ex_target   => ex_target,     -- immediate for branch

        -- outputs(branch)
        brch_pc    => brch_pc,      -- branch target PC
        flush_ctrl => flush_ctrl   -- pipeline flush signal
    );
		
	S_FSM : entity work.state_lookup(behavior)
		port map (
		--inputs   
		ex_bctrl	=> ex_bctrl,
		fw_state  	=> fw_state,
		ex_sctrl	=> ex_sctrl,  
		
		--outputs
		fsm_state   => fsm_state,
		fsm_sctrl	=> fsm_sctrl);
		
	EX_WB : entity work.ex_wb(behavior) 
		port map ( 	 
		--setup 
		clk 		=> clk,
		enable		=> enable,
		reset_bar 	=> reset_bar,  	
		
		--inputs(data) 
		ex_rd		=> ex_rd,
		ex_rd_ptr	=> ex_rd_ptr, 
		ex_wback	=> ex_wback,  
		
		--inputs(branch) 
		ex_pc		=> ex_pc,
		ex_sctrl  	=> fsm_sctrl,
		ex_state	=> fsm_state,
		
		--outputs(data)	
		wb_rd		=> wb_rd,
		wb_rd_ptr	=> wb_rd_ptr,
		wb_wback	=> wb_wback,
		
		--outputs(branch)
		wb_pc		=> wb_pc,
		wb_sctrl	=> wb_sctrl,
		wb_state	=> wb_state
		
		);		
    -- ======================
    -- Debug signal exposure
    -- ======================  
	pc_current_i <= pc_current;
	pc_next_i	<= pc_next;
	if_pc_i       	<= if_pc;
	if_instruc_i	<= if_instruc;
	
	id_target_i     <= id_target;
	id_pctrl_i    <= id_pctrl;
	
	iff_target_i  <= iff_target;
	ifd_target_i  <= ifd_target;
	
	id_pc_i       <= id_pc;
	id_instruc_i <= id_instruc;
	
	id_opcode_i  <= id_opcode;
	
	id_rs3_ptr_i <= id_rs3_ptr;
	id_rs2_ptr_i <= id_rs2_ptr;
	id_rs1_ptr_i <= id_rs1_ptr;
	id_rd_ptr_i  <= id_rd_ptr;
	
	id_immed_i   <= id_immed;
	read_sel_i   <= read_sel;
	
	id_wback_i   <= id_wback;
	id_bctrl_i  <= id_bctrl;
	id_jump_i   <= id_jump;
	
	id_target_i <= id_target;
	id_tctrl_i  <= id_tctrl;
	
	id_state_i   <= id_state;
	id_brch_i     <= id_brch;
	
	id_rs3_i     <= id_rs3;
	id_rs2_i     <= id_rs2;
	id_rs1_i     <= id_rs1;
	
	ex_pc_i      <= ex_pc;
	ex_opcode_i <= ex_opcode;
	
	ex_rs3_i    <= ex_rs3;
	ex_rs2_i    <= ex_rs2;
	ex_rs1_i    <= ex_rs1;
	ex_immed_i  <= ex_immed;
	
	ex_rd_ptr_i <= ex_rd_ptr;
	ex_rs3_ptr_i <= ex_rs3_ptr;
	ex_rs2_ptr_i <= ex_rs2_ptr;
	ex_rs1_ptr_i <= ex_rs1_ptr;
	
	ex_target_i	<= ex_target;
	ex_state_i  <= ex_state;
	ex_wback_i  <= ex_wback;
	ex_pctrl_i  <= ex_pctrl;
	ex_bctrl_i   <= ex_bctrl;
	
	fw_rs3_i    <= fw_rs3;
	fw_rs2_i    <= fw_rs2;
	fw_rs1_i    <= fw_rs1;
	fw_state_i 	<= fw_state;
	
	ex_rd_i     <= ex_rd;
	brch_pc_i	<= brch_pc;
	ex_sctrl_i  <= ex_sctrl;
	flush_ctrl_i<= flush_ctrl;
	
	fsm_state_i <= fsm_state;
	fsm_sctrl_i <= fsm_sctrl;
	
	wb_rd_i     <= wb_rd;
	wb_rd_ptr_i <= wb_rd_ptr;
	wb_wback_i  <= wb_wback; 
	
	wb_pc_i		<= wb_pc;
	wb_sctrl_i	<= wb_sctrl;
	wb_state_i  <= wb_state;
end architecture;
