library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.numeric_var.all;
use work.all;

entity mmu_RSI_tb is 
end mmu_RSI_tb;

architecture test_bench of mmu_RSI_tb is 
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
		   
    -- Clock process

	
	-- Stimulus process
	stim_proc : process
	begin
----------------------------------------------------------------
-- rest_instruction TEST 
---------------------------------------------------------------- 
	--------------------------------------------------------------------
    -- TEST: Opcode 110001
    --------------------------------------------------------------------
	opcode <= "110001";	  	 
	in_immed <= x"0004"; 
	in_rs2 <=(others => '-');
	in_rs1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_rd = x"0700070007000700070007000F000700"
	report "TEST FAIL: 110001, out_rd =" & slv_to_hex(out_rd)
	severity error;	
	--------------------------------------------------------------------
    -- TEST: Opcode 110010, stauturated
    --------------------------------------------------------------------
	opcode <= "110010";	 
	in_rs2 <= x"80010004800100037FFF00027FFF0001";
	in_rs1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_rd = x"F009700BF0077008F0037005FFFFFFFF"
	report "TEST FAIL: 110010, out_rd =" & slv_to_hex(out_rd)
	severity error;	
		
	--------------------------------------------------------------------
    -- TEST: Opcode 110011
    --------------------------------------------------------------------
	opcode <= "110011";	   
	in_rs2 <= (others => '-');
	in_rs1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_rd = x"00040006000500050004000500050004"
	report "TEST FAIL: 110011, out_rd =" & slv_to_hex(out_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 110100
    --------------------------------------------------------------------
	opcode <= "110100";	
	in_rs2 <= x"80010004800100037FFF7FF27FFFFFF1";
	in_rs1 <= x"700870077006800570047003F0027001";
	wait for period;
	assert out_rd = x"F009700BF00780087FFF7FFF70016FF2"
	report "TEST FAIL: 110100, out_rd =" & slv_to_hex(out_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 110101
    --------------------------------------------------------------------
	opcode <= "110101";
	in_rs2 <= x"0000000000000000FFFFFFFFFFFFFFFF";
	in_rs1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_rd = x"7008700770067005FFFFFFFFFFFFFFFF"
	report "TEST FAIL: 110101, out_rd =" & slv_to_hex(out_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 110110
    --------------------------------------------------------------------
	opcode <= "110110";		   
	in_rs2 <= (others => '-');	 
	in_rs1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_rd = x"70087007700870077008700770087007"
	report "TEST FAIL: 110110, out_rd =" & slv_to_hex(out_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 110111
    --------------------------------------------------------------------
	opcode <= "110111";	
	in_rs2 <= x"80010004800100037FFF00027FFF0001";
	in_rs1 <= x"700870077006700570047003F0027001";
	wait for period;	
	assert out_rd = x"70087007700670057FFF00027FFF0001"
	report "TEST FAIL: 110111, out_rd =" & slv_to_hex(out_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 111000
    --------------------------------------------------------------------
	opcode <= "111000";
	in_rs2 <= x"80010004800100037FFF00027FFF0001";
	in_rs1 <= x"700870077006700570047003F0027001";
	wait for period;		
	assert out_rd = x"800100048001000370047003F0027001"
	report "TEST FAIL: 111000, out_rd =" & slv_to_hex(out_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 111001
    --------------------------------------------------------------------
	opcode <= "111001";	   
	in_rs2 <= x"80010004800100037FFF7FF27FFFFFF1";
	in_rs1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_rd = x"0001C01C0001500F37FB5FD66FFA6FF1"
	report "TEST FAIL: 111001, out_rd =" & slv_to_hex(out_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 111010
    --------------------------------------------------------------------
	opcode <= "111010";	   
	in_immed <= x"0014"; 
	in_rs2 <= (others => '-');
	in_rs1 <= x"80010004800100037FFF00027FFF0001";
	wait for period;
	assert out_rd = x"000000500000003C0000002800000014"
	report "TEST FAIL: 111010, out_rd =" & slv_to_hex(out_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 111011
    --------------------------------------------------------------------
	opcode <= "111011";	
	in_rs2 <= x"0000000000000000FFFFFFFFFFFFFFFF";
	in_rs1 <= x"80010004800100037FFF00027FFF0001";
	wait for period;
	assert out_rd = x"00000000000000007FFF00027FFF0001"
	report "TEST FAIL: 111011, out_rd =" & slv_to_hex(out_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 111100
    --------------------------------------------------------------------   
	opcode <= "111100";		   
	in_rs2 <= (others => '-');
	in_rs1 <= x"070870071006700570047003F0027001";
	wait for period;
	assert out_rd = x"00000005000000030000000100000000"
	report "TEST FAIL: 111100, out_rd =" & slv_to_hex(out_rd)
	severity error;												   
	
	--------------------------------------------------------------------
    -- TEST: Opcode 111101
    --------------------------------------------------------------------   
	opcode <= "111101";	   
	in_rs2 <= x"FFFFFF10FFFFFFF00000000100000000";
	in_rs1 <= x"80010004800100037FFF00027FFF0001";
	wait for period;
	assert out_rd = x"00048001000380013FFF80017FFF0001"
	report "TEST FAIL: 111101, out_rd =" & slv_to_hex(out_rd)
	severity error;			 

	--------------------------------------------------------------------
    -- TEST: Opcode 111110
    --------------------------------------------------------------------   
	opcode <= "111110";	 
	in_rs2 <= x"80010004800100037FFF00027FFF0001";
	in_rs1 <= x"700870077006700570047003F0027001";
	wait for period;
	assert out_rd = x"0FF88FFD0FFA8FFE0FFA8FFF00000000"
	report "TEST FAIL: 111110, out_rd =" & slv_to_hex(out_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 111111
    --------------------------------------------------------------------   
	opcode <= "111111";	
	in_rs2 <= x"80010004800100057FFF00067FFF8F01";
	in_rs1 <= x"70080007780600037004FFF3F0027001";
	wait for period;
	assert out_rd = x"8000FFFD800000020FFB00137FFF8000"
	report "TEST FAIL: 111111, out_rd =" & slv_to_hex(out_rd)
	severity error;	
	
	--------------------------------------------------------------------
    -- TEST: Opcode 110000
    --------------------------------------------------------------------
	opcode <= "110000";	   
	in_rs2 <= (others => '-');
	in_rs1 <= (others => '-');
	wait for period;	  
	
    report "TEST COMPLETED: rest of the instruction" severity warning;
	end process;
end test_bench; 