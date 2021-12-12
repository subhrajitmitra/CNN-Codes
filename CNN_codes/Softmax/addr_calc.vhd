library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity addr_calc is
	port(
		fixed_int			: in std_logic_vector(10 downto 0);
		data_to_add			: in std_logic_vector(10 downto 0);
		mem_addr		: out std_logic_vector(8 downto 0)
	);
end addr_calc;

architecture des of addr_calc is
signal mem_addr_s : std_logic_vector(10 downto 0);
begin
mem_addr_s <= std_logic_vector(signed(signed(fixed_int)+signed(data_to_add)));
mem_addr <= mem_addr_s(8 downto 0);
end des;
