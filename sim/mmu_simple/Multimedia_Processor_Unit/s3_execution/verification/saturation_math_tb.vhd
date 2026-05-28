library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.all;

entity mmu_STM_tb is 
end mmu_STM_tb;

architecture test_bench of mmu_STM_tb is 
	--inputs
	signal opcode		: std_logic_vector(OPCODE_LENGTH-1 downto 0);
	
	signal in_rs3		: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal in_rs2		: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal in_rs1		: std_logic_vector(REGISTER_LENGTH-1 downto 0); 
	signal in_immed		: std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);	
	
	--fowarding
	signal rs3_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal rs2_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	signal rs1_ptr		: std_logic_vector(ADDRESS_LENGTH-1 downto 0); 
	
	signal wb_rd		: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	signal wb_rd_ptr	: std_logic_vector(ADDRESS_LENGTH-1 downto 0);  --for forwarding address comparision
	signal in_wback		: std_logic;
	
	--outputs
	signal out_rd		: std_logic_vector(REGISTER_LENGTH-1 downto 0);
	
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
        opcode      => opcode,

        in_rs3    	=> in_rs3,
        in_rs2    	=> in_rs2,
        in_rs1    	=> in_rs1,
        in_immed    => in_immed,
		
		rs3_ptr		=> rs3_ptr,
		rs2_ptr		=> rs2_ptr,
		rs1_ptr		=> rs1_ptr,
		
		wb_rd 	  	=> wb_rd,
		wb_rd_ptr 	=> wb_rd_ptr,
		in_wback 	=> in_wback,
        out_rd   	=> out_rd
		);
		   
	-- Stimulus process
	stim_proc : process
	begin
----------------------------------------------------------------
-- saturate_math TEST w/overflow and underflow checks
---------------------------------------------------------------- 
		in_immed <= x"DEAD";
		in_rs3 <= x"000100020003000470057006F0077008";
		in_rs2 <= x"000800070006000570047003F0027001";
		in_rs1 <= x"00000000000000007FFF00007FFF0000";  

    --------------------------------------------------------------------
    -- TEST: Opcode 10-000
    --------------------------------------------------------------------
		opcode <= "100000"; 
		wait for period;		             
		assert out_rd = x"0000000E000000147FFFFFFF7FFFFFFF" 
		    report "Test failed: 100000, out_rd = x" & slv_to_hex(out_rd)
		    severity error; 

    --------------------------------------------------------------------
    -- TEST: Opcode 10-001 
    --------------------------------------------------------------------
	    	opcode <= "100001"; 
	    	wait for period;
	    	assert out_rd = x"00000008000000127FFFFFFF7FFFFFFF"
	        	report "Test failed: 100001, out_rd = x" & slv_to_hex(out_rd)
	        	severity error;

	--------------------------------------------------------------------
	-- TEST: Opcode 10-010
	-------------------------------------------------------------------- 			 
		in_rs1 <= x"00000000000000008001000080010000";
		opcode <= "100010"; 
		wait for period;
		assert out_rd = x"FFFFFFF2FFFFFFEC8000000080000000"
		    report "Test failed: 100010, out_rd = x" & slv_to_hex(out_rd)
		    severity error;
			
	--------------------------------------------------------------------			
	-- TEST: Opcode 10-011		
	--------------------------------------------------------------------
        opcode <= "100011"; 
        wait for period;
        assert out_rd = x"FFFFFFF8FFFFFFEE8000000080000000"
            report "Test failed: 100011, out_rd = x" & slv_to_hex(out_rd)
            severity error;
			
	--------------------------------------------------------------------			
	-- TEST: Opcode 10-100
	--------------------------------------------------------------------
		in_rs1 <= x"00000000000000007FFF00007FFF0000";  
		opcode <= "100100"; 
		wait for period;
		assert out_rd = x"00000012002700147FFFFFFFFFFFFFFF"
			report "Test failed: 100100, out_rd = x" & slv_to_hex(out_rd)
			severity error;
			
	--------------------------------------------------------------------			
	-- TEST: Opcode 10-101
	--------------------------------------------------------------------        
        opcode <= "100101"; 
        wait for period;
        assert out_rd = x"000000080017000E7FFFFFFFFFFFFFFF"
            report "Test failed: 100101, out_rd = x" & slv_to_hex(out_rd)
            severity error;
			
	--------------------------------------------------------------------			
	-- TEST: Opcode 10-110	
	-------------------------------------------------------------------- 
		in_rs1 <= x"00000000000000008001000080010000";
		opcode <= "100110"; 
		wait for period;
		assert out_rd = x"FFFFFFEDFFD8FFEC8000000000000000"
		    report "Test failed: 100110, out_rd = x" & slv_to_hex(out_rd)
		    severity error;	 
			
	--------------------------------------------------------------------			
	-- TEST: Opcode 10-111	
	--------------------------------------------------------------------
		opcode <= "100111"; 
		wait for period;
		assert out_rd = x"FFFFFFF7FFE8FFF28000000000000000"
		    report "Test failed: 100111, out_rd = x" & slv_to_hex(out_rd)
		    severity error;																   
		
		report "TEST COMPLETED: saturate_math w/o saturating" severity warning;  
	end process;				
end test_bench;

