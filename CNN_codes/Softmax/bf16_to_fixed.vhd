library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity bf16_to_fixed is
    port (
		bf16_in        	: in std_logic_vector(15 downto 0);
		fxd_out         : out std_logic_vector(15 downto 0) -- signed(7.9)
	);   
end bf16_to_fixed;

architecture rtl of bf16_to_fixed is
signal fxd_conv : std_logic_vector(15 downto 0):=(Others=>'0');
begin
process(bf16_in)
variable exp : std_logic_vector(7 downto 0);
variable mantissa : std_logic_vector(15 downto 0);
variable pos_neg : std_logic;
begin
	mantissa := "000000" & '1' & bf16_in(6 downto 0) & "00";
	
	if (bf16_in(14 downto 7) >= "01111111") then
		exp := bf16_in(14 downto 7) - "01111111";
		pos_neg := '0';
	else
		exp := "01111111" - bf16_in(14 downto 7);
		pos_neg := '1';
	end if;
	
	for i in 0 to 7 loop
		if (exp = "00000000") then exit;
		else
			exp := exp - 1;
			if   (pos_neg = '0') then
				mantissa := mantissa(14 downto 0) & '0';
			elsif(pos_neg = '1') then
				mantissa := '0' & mantissa(15 downto 1);
			end if;				
		end if;
	end loop;
	fxd_conv <= mantissa(15 downto 0);
end process;

fxd_out <= (not(fxd_conv)+1) when bf16_in(15)='1' else fxd_conv;

end rtl;