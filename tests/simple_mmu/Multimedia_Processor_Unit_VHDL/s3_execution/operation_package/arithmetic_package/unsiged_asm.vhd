library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package unsigned_asm is 		 
	procedure mult_16_unsigned(
		a16, b16	: in std_logic_vector(15 downto 0);	-- 32 bits or half-long	
		ret32		: out std_logic_vector(31 downto 0));
	
	procedure add_32_unsigned(
		a32, b32 	: in std_logic_vector(31 downto 0);
		ret32		: out std_logic_vector(31 downto 0));

	procedure sub_32_unsigned(
		a32, b32 	: in std_logic_vector(31 downto 0);
		ret32		: out std_logic_vector(31 downto 0)); 
		
end package unsigned_asm;

package body unsigned_asm is  
	constant MAX_32_unsigned : unsigned(31 downto 0) := (others => '1');
	constant MIN_32_unsigned : unsigned(31 downto 0) := (others => '0');   
	
-----Unsigned-Multiple_16-bits----------------------------------------------------------	
	procedure mult_16_unsigned(
		a16, b16	: in std_logic_vector(15 downto 0);	-- 32 bits or half-long	
		ret32		: out std_logic_vector(31 downto 0)
	) is 
		variable prod : unsigned(31 downto 0);
	begin 
		prod := unsigned(a16) * unsigned(b16);
		ret32 := std_logic_vector(prod);
	end procedure;

-----Unsigned-Addition_32-bits----------------------------------------------------------
	procedure add_32_unsigned(
		a32, b32 	: in std_logic_vector(31 downto 0);
		ret32		: out std_logic_vector(31 downto 0)
	) is 
		variable sum : unsigned(32 downto 0);
	begin
	    sum := unsigned('0' & a32) + unsigned('0' & b32);
	
	    if sum(32) = '1' then
	        ret32 := std_logic_vector(MAX_32_UNSIGNED);  
	    else
	        ret32 := std_logic_vector(sum(31 downto 0)); 
	    end if;	
	end procedure;			   
	
-----Unsigned-Subtraction_32-bits----------------------------------------------------------
	procedure sub_32_unsigned(
		a32, b32 	: in std_logic_vector(31 downto 0);
		ret32		: out std_logic_vector(31 downto 0)
	) is   
		variable diff : unsigned(32 downto 0);
	begin	 	
		diff :=  unsigned('0' & a32) - unsigned('0' & b32);
		
	    if diff(32) = '1' then
	        ret32 := std_logic_vector(MIN_32_UNSIGNED); 
	    else
	        ret32 := std_logic_vector(diff(31 downto 0));  
	    end if;
	end procedure;
end package body unsigned_asm;