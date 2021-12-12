library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity exp_x is
	port(
		clk			: in std_logic;
		input_x		: in std_logic_vector(15 downto 0);
		output_exp_x: out std_logic_vector(15 downto 0)
	);
end exp_x;

architecture des of exp_x is

component bf16_to_int is
    port (
		bf16_in			: in std_logic_vector(15 downto 0);
		int_out			: out std_logic_vector(10 downto 0)
	);   
end component;

component addr_calc is
	port(
		fixed_int			: in std_logic_vector(10 downto 0);
		data_to_add			: in std_logic_vector(10 downto 0);
		mem_addr		: out std_logic_vector(8 downto 0)
	);
end component;

component exp_x_mem
	PORT(
		address	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		clock		: IN STD_LOGIC;
		q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
end component;

constant data_to_add		:std_logic_vector(10 downto 0):= "00010111000";
signal fixed_int_out		:std_logic_vector(10 downto 0):=(others=>'0');
signal input_x_s		:std_logic_vector(15 downto 0):=(others=>'0');
signal temp		:std_logic_vector(8 downto 0):=(others=>'0');

begin

process(input_x)
begin
if		(input_x(14 downto 0) > "100001010111100" and input_x(15) = '1') then input_x_s <= '1' & "100001010111100";
elsif	(input_x(14 downto 0) > "100001010111111" and input_x(15) = '0') then input_x_s <= '0' & "100001010101111";
else	input_x_s <= input_x;
end if;
end process;


I0: bf16_to_int 
	PORT MAP (
	bf16_in	=> input_x_s,
	int_out	=> fixed_int_out
);

I1: addr_calc 
	PORT MAP (
	fixed_int	=> fixed_int_out,
	data_to_add	=> data_to_add,
	mem_addr		=> temp
);

I2: exp_x_mem
	PORT MAP (
	address	=> temp,
	clock		=> clk,
	q			=> output_exp_x
);

end des;