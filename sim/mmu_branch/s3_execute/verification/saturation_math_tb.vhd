library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.all;

entity mmu_STM_tb is 
end mmu_STM_tb;

architecture test_bench of mmu_STM_tb is 
	--inputs
	signal ex_opcode		: std_logic_vector(OPCODE_LENGTH-1 downto 0);
	
	signal fw_rs3		: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal fw_rs2		: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal fw_rs1		: std_logic_vector(REGISTER_LENGTH-1 downto 0); 
	signal ex_immed		: std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);	
	
	--branching
	signal ex_pctrl		: std_logic;
	signal ex_pc		: std_logic_vector(COUNTER_LENGTH-1 downto 0);
	signal ex_brch		: std_logic;
	signal pc_sctrl		: std_logic;
	signal flush_ctrl 	: std_logic;
	
	--outputs
	signal ex_rd		: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	
	constant period: time := 20ns;	 
	--------------------------------------------------------------------
    -- Helper: Convert std_logic_vector ? hex string (portable)
    --------------------------------------------------------------------
    function slv_to_hex(slv : std_logic_vector) return string is
 		variable num_nibbles : integer := (slv'length + 3) / 4;
        	variable padded_slv  : std_logic_vector(num_nibbles * 4 - 1 downto 0);
        	variable result      : string(1 to num_nibbles);
        	variable nibble_val  : integer;
	begin
			-- Pad MSBs with zeros if not multiple of 4 bits
			padded_slv := (others => '0');
			padded_slv(slv'length - 1 downto 0) := slv;
		
			for i in 0 to num_nibbles - 1 loop
		   	nibble_val := to_integer(unsigned(padded_slv((i+1)*4 - 1 downto i*4)));
				case nibble_val is
				when 0  => result(num_nibbles - i) := '0';
				when 1  => result(num_nibbles - i) := '1';
				when 2  => result(num_nibbles - i) := '2';
				when 3  => result(num_nibbles - i) := '3';
				when 4  => result(num_nibbles - i) := '4';
				when 5  => result(num_nibbles - i) := '5';
				when 6  => result(num_nibbles - i) := '6';
				when 7  => result(num_nibbles - i) := '7';
				when 8  => result(num_nibbles - i) := '8';
				when 9  => result(num_nibbles - i) := '9';
				when 10 => result(num_nibbles - i) := 'A';
				when 11 => result(num_nibbles - i) := 'B';
				when 12 => result(num_nibbles - i) := 'C';
				when 13 => result(num_nibbles - i) := 'D';
				when 14 => result(num_nibbles - i) := 'E';
				when 15 => result(num_nibbles - i) := 'F';
				when others => result(num_nibbles - i) := 'X';
			end case;
		end loop;
		return result;
	end function;
    --------------------------------------------------------------------		
begin 
	
	UUT : entity work.mmu 
		port map(
        ex_opcode      => ex_opcode,

        fw_rs3    	=> fw_rs3,
        fw_rs2    	=> fw_rs2,
        fw_rs1    	=> fw_rs1,
        ex_immed    => ex_immed,
		
		ex_pctrl	=> ex_pctrl,
		ex_pc		=> ex_pc,
		
		pc_sctrl	=> pc_sctrl,
		flush_ctrl	=> flush_ctrl, 
		ex_brch		=> ex_brch,
        ex_rd   	=> ex_rd
		);
	
	-- stimulus process
	stim_proc : process
	begin
----------------------------------------------------------------
-- saturate_math TEST w/overflow and underflow checks
---------------------------------------------------------------- 
		ex_immed <= x"DEAD";
		fw_rs3 <= x"000100020003000470057006F0077008";
		fw_rs2 <= x"000800070006000570047003F0027001";
		fw_rs1 <= x"00000000000000007FFF00007FFF0000";  

    --------------------------------------------------------------------
    -- TEST: ex_opcode 10-000
    --------------------------------------------------------------------
		ex_opcode <= "100000"; 
		wait for period;		             
		assert ex_rd = x"0000000E000000147FFFFFFF7FFFFFFF" 
		    report "Test failed: 100000, ex_rd = x" & slv_to_hex(ex_rd)
		    severity error; 

    --------------------------------------------------------------------
    -- TEST: ex_opcode 10-001 
    --------------------------------------------------------------------
	    	ex_opcode <= "100001"; 
	    	wait for period;
	    	assert ex_rd = x"00000008000000127FFFFFFF7FFFFFFF"
	        	report "Test failed: 100001, ex_rd = x" & slv_to_hex(ex_rd)
	        	severity error;

	--------------------------------------------------------------------
	-- TEST: ex_opcode 10-010
	-------------------------------------------------------------------- 			 
		fw_rs1 <= x"00000000000000008001000080010000";
		ex_opcode <= "100010"; 
		wait for period;
		assert ex_rd = x"FFFFFFF2FFFFFFEC8000000080000000"
		    report "Test failed: 100010, ex_rd = x" & slv_to_hex(ex_rd)
		    severity error;
			
	--------------------------------------------------------------------			
	-- TEST: ex_opcode 10-011		
	--------------------------------------------------------------------
        ex_opcode <= "100011"; 
        wait for period;
        assert ex_rd = x"FFFFFFF8FFFFFFEE8000000080000000"
            report "Test failed: 100011, ex_rd = x" & slv_to_hex(ex_rd)
            severity error;
			
	--------------------------------------------------------------------			
	-- TEST: ex_opcode 10-100
	--------------------------------------------------------------------
		fw_rs1 <= x"00000000000000007FFF00007FFF0000";  
		ex_opcode <= "100100"; 
		wait for period;
		assert ex_rd = x"00000012002700147FFFFFFFFFFFFFFF"
			report "Test failed: 100100, ex_rd = x" & slv_to_hex(ex_rd)
			severity error;
			
	--------------------------------------------------------------------			
	-- TEST: ex_opcode 10-101
	--------------------------------------------------------------------        
        ex_opcode <= "100101"; 
        wait for period;
        assert ex_rd = x"000000080017000E7FFFFFFFFFFFFFFF"
            report "Test failed: 100101, ex_rd = x" & slv_to_hex(ex_rd)
            severity error;
			
	--------------------------------------------------------------------			
	-- TEST: ex_opcode 10-110	
	-------------------------------------------------------------------- 
		fw_rs1 <= x"00000000000000008001000080010000";
		ex_opcode <= "100110"; 
		wait for period;
		assert ex_rd = x"FFFFFFEDFFD8FFEC8000000000000000"
		    report "Test failed: 100110, ex_rd = x" & slv_to_hex(ex_rd)
		    severity error;	 
			
	--------------------------------------------------------------------			
	-- TEST: ex_opcode 10-111	
	--------------------------------------------------------------------
		ex_opcode <= "100111"; 
		wait for period;
		assert ex_rd = x"FFFFFFF7FFE8FFF28000000000000000"
		    report "Test failed: 100111, ex_rd = x" & slv_to_hex(ex_rd)
		    severity error;																   
		
		report "TEST COMPLETED: saturate_math w/o saturating" severity warning;  
	end process;				
end test_bench;

