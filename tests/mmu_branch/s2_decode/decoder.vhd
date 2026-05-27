library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;		
use work.numeric_var.all;

entity decoder is 
	port(
	--input
	id_instruc	: in std_logic_vector(INSTRUCTION_LENGTH-1 downto 0);  
	
	--outputs(data)
	id_opcode		: out std_logic_vector(OPCODE_LENGTH-1 downto 0);
	id_rs3_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	id_rs2_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	id_rs1_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0); 	
	id_rd_ptr		: out std_logic_vector(ADDRESS_LENGTH-1 downto 0);
	id_immed		: out std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);  
	read_sel		: out std_logic_vector(2 downto 0); 	
	
	--controls(data)
	id_wback		: out std_logic;  
	
	--controls(branch)
	id_bctrl    	: out std_logic;
	id_jump	 	: out std_logic
	);
end entity;

architecture behavior of decoder is 
begin 
	
	main : process(id_instruc)
		variable var_id_opcode	: std_logic_vector(OPCODE_LENGTH-1 downto 0);
	begin				 
		var_id_opcode(5 downto 3) := id_instruc(INSTRUCTION_LENGTH-1 downto INSTRUCTION_LENGTH-3);
		case var_id_opcode(5 downto 4)	is		 
			when "00" | "01" => 
				id_opcode(2 downto 0) 	<= id_instruc(INSTRUCTION_LENGTH-2 downto INSTRUCTION_LENGTH-4);
				id_opcode(4 downto 3)	<= "00";   
				id_opcode(5 downto 4) 	<= var_id_opcode(5 downto 4);
				
				id_rs3_ptr		<= id_instruc(INSTRUCTION_LENGTH-21 downto 0);		
				id_rd_ptr 		<= id_instruc(INSTRUCTION_LENGTH-21 downto 0);	
				id_immed	<= id_instruc(INSTRUCTION_LENGTH-5 downto INSTRUCTION_LENGTH-20);
				
				read_sel	<= "100";
				
				id_wback 	<= '1';	
				id_bctrl	<= '0';
				id_jump		<= '0';
				
								   	
			when "10" =>
				id_opcode(2 downto 0) 	<= id_instruc(INSTRUCTION_LENGTH-3 downto INSTRUCTION_LENGTH-5);
				id_opcode(3) 			<= '0'; 
				id_opcode(5 downto 4) 	<= var_id_opcode(5 downto 4);
				
				id_rs3_ptr		<= id_instruc(INSTRUCTION_LENGTH-6 downto INSTRUCTION_LENGTH-10);
				id_rs2_ptr		<= id_instruc(INSTRUCTION_LENGTH-11 downto INSTRUCTION_LENGTH-15);
				id_rs1_ptr		<= id_instruc(INSTRUCTION_LENGTH-16 downto INSTRUCTION_LENGTH-20);
				id_rd_ptr		<= id_instruc(INSTRUCTION_LENGTH-21 downto 0);	
				
				read_sel	<= "111";	
				
				id_wback 	<= '1';
				id_bctrl	<= '0';
				id_jump		<= '0';
				
			when "11" => 
				id_opcode(5 downto 4) 	<= var_id_opcode(5 downto 4);
				if var_id_opcode(3) = '0' then    
					id_opcode(3 downto 0) 	<= id_instruc(INSTRUCTION_LENGTH-7 downto INSTRUCTION_LENGTH-10);
					
					id_rs2_ptr 	<= id_instruc(INSTRUCTION_LENGTH-11 downto INSTRUCTION_LENGTH-15);
					id_rs1_ptr 	<= id_instruc(INSTRUCTION_LENGTH-16 downto INSTRUCTION_LENGTH-20); 
					id_rd_ptr	<= id_instruc(INSTRUCTION_LENGTH-21 downto 0);
					
					read_sel 	<= "011";
					id_bctrl	<= '0';
					id_jump		<= '0';
					id_wback 	<= '1';
					
					case id_instruc(INSTRUCTION_LENGTH-7 downto INSTRUCTION_LENGTH-10) is 
						when "0000" => --NOP instruction	
							id_immed    <= (others => '0');	
							id_wback 	<= '0';	
							
							read_sel	<= "000";
							id_rd_ptr 	<= (others => '0');	 
							
						when "0001" => 	
							id_immed 	<= b"000000000000" & id_instruc(INSTRUCTION_LENGTH-12 downto INSTRUCTION_LENGTH-15); 
							read_sel	<= "001";	
							
						when "1010" =>
							id_immed	<= b"00000000000" & id_instruc(INSTRUCTION_LENGTH-11 downto INSTRUCTION_LENGTH-15);    
							read_sel	<= "001";
							
						when others => 	 
							id_immed    <= (others => '0');	 
					end case;			
					
					
				elsif var_id_opcode(3) = '1' then 
					id_opcode(3 downto 0) <= id_instruc(INSTRUCTION_LENGTH-3 downto INSTRUCTION_LENGTH-6);
					
					id_rs2_ptr 	<= id_instruc(INSTRUCTION_LENGTH-16 downto INSTRUCTION_LENGTH-20);
					id_rs1_ptr 	<= id_instruc(INSTRUCTION_LENGTH-21 downto 0);	 	  
					id_rd_ptr 	<= (others => '-');
					id_immed 	<= std_logic_vector(resize(signed(id_instruc(INSTRUCTION_LENGTH-7 downto INSTRUCTION_LENGTH-15)), 16));
					
					id_wback 	<= '0';	   
					id_bctrl 	<= '1';
					case id_instruc(INSTRUCTION_LENGTH-3 downto INSTRUCTION_LENGTH-6) is
						when "1000" | "1001" | "1010" | "1011" =>
							id_jump <= '0';	
							read_sel 	<= "011";
							
						when "1100" =>
							id_jump <= '1';	
							read_sel <= "000";
							
						when others => 
							id_bctrl <= '0';
							id_jump <= '0';	
							read_sel 	<= "011";
						end case;
				end if;
			when others => 
				null;
			end case;
	end process;
end architecture;