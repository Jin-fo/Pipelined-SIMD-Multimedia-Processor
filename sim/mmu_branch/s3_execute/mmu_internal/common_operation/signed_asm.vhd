library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package signed_asm is 
	procedure mult_16(
		a16, b16 	: in std_logic_vector(15 downto 0);
		ret32		: out std_logic_vector(31 downto 0));
	
	procedure mult_32(
		a32, b32 	: in std_logic_vector(31 downto 0);
		ret64		: out std_logic_vector(63 downto 0));

	procedure add_16(
		a16, b16 	: in std_logic_vector(15 downto 0);
		ret16		: out std_logic_vector(15 downto 0));

	procedure sub_16(
		a16, b16 	: in std_logic_vector(15 downto 0);
		ret16		: out std_logic_vector(15 downto 0));

	procedure add_32(
		a32, b32 	: in std_logic_vector(31 downto 0);
		ret32		: out std_logic_vector(31 downto 0));

	procedure sub_32(
		a32, b32 	: in std_logic_vector(31 downto 0);
		ret32		: out std_logic_vector(31 downto 0));

	procedure add_64(
		a64, b64 	: in std_logic_vector(63 downto 0);
		ret64		: out std_logic_vector(63 downto 0));

	procedure sub_64(
		a64, b64 	: in std_logic_vector(63 downto 0);
		ret64		: out std_logic_vector(63 downto 0));

end package signed_asm;

package body signed_asm is 
	constant MAX16 : signed(15 downto 0) := not(shift_left(to_signed(1, 16), 15));
	constant MIN16 : signed(15 downto 0) := shift_left(to_signed(1, 16), 15);
	constant MAX32 : signed(31 downto 0) := not(shift_left(to_signed(1, 32), 31));
	constant MIN32 : signed(31 downto 0) := shift_left(to_signed(1, 32), 31);
	constant MAX64 : signed(63 downto 0) := not(shift_left(to_signed(1, 64), 63));
	constant MIN64 : signed(63 downto 0) := shift_left(to_signed(1, 64), 63);
	
-----Multiple_16-bits----------------------------------------------------------
	procedure mult_16(
		a16, b16 	: in std_logic_vector(15 downto 0);
		ret32		: out std_logic_vector(31 downto 0)
	) is 
		variable a_s, b_s : signed(15 downto 0);
		variable prod     : signed(31 downto 0);
	begin
		a_s := signed(a16);
		b_s := signed(b16);
		prod := a_s * b_s;
		ret32 := std_logic_vector(prod);
	end procedure;


-----Multiple_32-bits----------------------------------------------------------
	procedure mult_32(
		a32, b32 	: in std_logic_vector(31 downto 0);
		ret64		: out std_logic_vector(63 downto 0)
	) is 
		variable prod : signed(63 downto 0);
	begin
		prod := signed(a32) * signed(b32);
		ret64 := std_logic_vector(prod);
	end procedure;		  
	
-----Addition_16-bits----------------------------------------------------------	
	procedure add_16(
		a16, b16 	: in std_logic_vector(15 downto 0);
		ret16		: out std_logic_vector(15 downto 0)
	) is
		variable sum : signed(16 downto 0);
	begin 
		sum := resize(signed(a16), 17) + resize(signed(b16), 17);
		
		if sum > resize(MAX16, 17) then
			ret16 := std_logic_vector(MAX16);	 
		elsif sum < resize(MIN16, 17) then 
			ret16 := std_logic_vector(MIN16);
		else 
			ret16 := std_logic_vector(sum(15 downto 0));
		end if;
	end procedure;

-----Subtraction_16-bits---------------------------------------------------------	
	procedure sub_16(
		a16, b16 	: in std_logic_vector(15 downto 0);
		ret16		: out std_logic_vector(15 downto 0)
	) is   
		variable sum : signed(16 downto 0);
	begin	 	
		sum :=  resize(signed(a16), 17) - resize(signed(b16), 17);
		
		if sum < resize(MIN16, 17) then
			ret16 := std_logic_vector(MIN16);	
		elsif sum > resize(MAX16, 17) then
			ret16 := std_logic_vector(MAX16);
		else 
			ret16 := std_logic_vector(sum(15 downto 0));
		end if;
	end procedure;

-----Addition_32-bits----------------------------------------------------------		
	procedure add_32(
		a32, b32 	: in std_logic_vector(31 downto 0);
		ret32		: out std_logic_vector(31 downto 0)
	) is  
		variable sum : signed(32 downto 0);
	begin	 	
		sum := resize(signed(a32), 33) + resize(signed(b32), 33);
		
		if sum > resize(MAX32, 33) then
			ret32 := std_logic_vector(MAX32);	
		elsif sum < resize(MIN32, 33) then
			ret32 := std_logic_vector(MIN32);
		else 
			ret32 := std_logic_vector(sum(31 downto 0));
		end if;
	end procedure;

-----Subtraction_32-bits---------------------------------------------------------	
	procedure sub_32(
		a32, b32 	: in std_logic_vector(31 downto 0);
		ret32		: out std_logic_vector(31 downto 0)
	) is   
		variable diff : signed(32 downto 0);
	begin	 			
		diff := resize(signed(a32), 33) - resize(signed(b32), 33);
		
		if diff < resize(MIN32, 33) then
			ret32 := std_logic_vector(MIN32);	
		elsif diff > resize(MAX32, 33) then
			ret32 := std_logic_vector(MAX32);
		else 
			ret32 := std_logic_vector(diff(31 downto 0));
		end if;

	end procedure;			   
	
-----Addition_64-bits----------------------------------------------------------		
	procedure add_64( 
		a64, b64	: in std_logic_vector(63 downto 0);  
		ret64		: out std_logic_vector(63 downto 0)
	) is   		  
		variable sum : signed(64 downto 0);
	begin	 	
		sum := resize(signed(a64), 65) + resize(signed(b64), 65);
		
		if sum > resize(MAX64, 65) then
			ret64 := std_logic_vector(MAX64);
		elsif sum < resize(MIN64, 65) then
			ret64 := std_logic_vector(MIN64);
		else 
			ret64 := std_logic_vector(sum(63 downto 0));
		end if;	  
	end procedure; 
	
-----Subtraction_64-bits---------------------------------------------------------	
	procedure sub_64( 
		a64, b64	: in std_logic_vector(63 downto 0);
		ret64		: out std_logic_vector(63 downto 0)
	) is
		variable diff : signed(64 downto 0);
	begin	 	
		
		diff := resize(signed(a64), 65) - resize(signed(b64), 65);
		
		if diff < resize(MIN64, 65) then
			ret64 := std_logic_vector(MIN64);
		elsif diff > resize(MAX64, 65) then
			ret64 := std_logic_vector(MAX64);
		else 
			ret64 := std_logic_vector(diff(63 downto 0));
		end if;	
	end procedure;
end package body signed_asm;