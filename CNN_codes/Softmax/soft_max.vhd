library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
USE ieee.std_logic_unsigned.all;

entity soft_max is
	port(
		rst				: in std_logic;
		clk				: in std_logic;
		input_x			: in std_logic_vector(15 downto 0);
		input_x_trig	: in std_logic;
		soft_max_done	: out std_logic;
------------------------------------------------------------		
		class_value		: in std_logic_vector(3 downto 0);
		class_accuracy	: out std_logic_vector(15 downto 0)
	);
end soft_max;

architecture des of soft_max is

component exp_x is
	port(
		clk			: in std_logic;
		input_x		: in std_logic_vector(15 downto 0);
		output_exp_x: out std_logic_vector(15 downto 0)
	);
end component;

component FPadd_single_b IS
   PORT( 
      ADD_SUB : IN     std_logic;
      FP_A    : IN     std_logic_vector (15 DOWNTO 0);
      FP_B    : IN     std_logic_vector (15 DOWNTO 0);
      FPadd_single_b_en     : IN     std_logic;
      FP_Z    : OUT    std_logic_vector (15 DOWNTO 0)
   );
end component;

component FPdiv_b is
    port (
        FP_A: in std_logic_vector(15 downto 0);
        FP_B: in std_logic_vector(15 downto 0);
		  FPdiv_b_en  : IN     std_logic;
        FP_Z: out std_logic_vector(15 downto 0)
	);   
end component;

component bf16_to_fixed is
    port (
		bf16_in        	: in std_logic_vector(15 downto 0);
		fxd_out         : out std_logic_vector(15 downto 0) -- signed(7.9)
	);   
end component;

constant percentage_of_acc : std_logic_vector(15 downto 0):=X"C600";
signal input_x_trig_s	:std_logic:='0';
signal soft_max_done_s	:std_logic:='0';
signal exp_x_output		:std_logic_vector(15 downto 0):=(others=>'0');
signal num_inp_class	:std_logic_vector(3 downto 0):="0000";
signal num_oup_class	:std_logic_vector(3 downto 0):="0000";

type arr is array(0 to 10) of std_logic_vector(15 downto 0);
signal exp_x_op_array	:arr;
signal softmx_acc_array	:arr;

type state_type is (s_0,s_1,s_2,s_3,s_4,s_5,s_6,s_7,s_8);
signal class_sel: state_type;

signal FPadd_a_in		:std_logic_vector(15 downto 0):=(others=>'0');
signal FPadd_b_in		:std_logic_vector(15 downto 0):=(others=>'0');
signal FPadd_op		:std_logic_vector(15 downto 0):=(others=>'0');
signal FPadd_en		:std_logic:='0';

signal FPdiv_a_in		:std_logic_vector(15 downto 0):=(others=>'0');
signal FPdiv_b_in		:std_logic_vector(15 downto 0):=(others=>'0');
signal FPdiv_op		:std_logic_vector(15 downto 0):=(others=>'0');
signal FPdiv_en		:std_logic:='0';

signal bf_to_fxd_in		:std_logic_vector(15 downto 0):=(others=>'0');
signal softmax_acc_out	:std_logic_vector(15 downto 0):=(others=>'0');
signal temp_acc_out		:std_logic_vector(31 downto 0):=(others=>'0');

begin

process(clk,rst)
begin
if rst='0' then input_x_trig_s <= '0';
elsif rising_edge(clk) then
	input_x_trig_s <= input_x_trig;
end if;
end process;

I0: exp_x
	port map (
	clk				=> clk,
	input_x			=> input_x,
	output_exp_x	=> exp_x_output
);

process(input_x_trig_s,rst,num_inp_class)
begin
if (rst='0' or num_inp_class = "1011") then num_inp_class <= "0000";
elsif rising_edge(input_x_trig_s) then
	num_inp_class <= num_inp_class + 1;
	exp_x_op_array(to_integer(unsigned(num_inp_class))) <= exp_x_output;
end if;
end process;

 process(clk,rst,input_x_trig_s,exp_x_output)
 begin
 if rst='0' then class_sel <= s_0;
 elsif rising_edge(clk) then
	 case	class_sel is
		 when s_0 =>
			 if input_x_trig_s = '1' then
				 num_inp_class <= "0001";
				 exp_x_op_array(0) <= exp_x_output;
				 FPadd_a_in <= exp_x_output;
				 FPadd_b_in <= x"0000";
				 FPadd_en <= '1';
				 class_sel <= s_3;
			 else
				 num_inp_class <= "0000";
				 class_sel <= s_0;
			 end if;
			
		 when s_1 =>
			 if input_x_trig_s = '1' then
				 num_inp_class <= num_inp_class + 1;
				 exp_x_op_array(to_integer(unsigned(num_inp_class))) <= exp_x_output;
				 FPadd_a_in <= exp_x_output;
				 FPadd_b_in <= FPadd_op;
				 FPadd_en <= '1';
				 class_sel <= s_2;
			 else
				 class_sel <= s_1;
			 end if; 
			
		 when s_2 =>
			 if (num_inp_class < "1011") then
				 class_sel <= s_3;
			 elsif (num_inp_class = "1011") then
				 num_inp_class <= "0000";
				 num_oup_class <= "0000";
				 FPdiv_b_in <= FPadd_op;
				 class_sel <= s_4;
			 end if;

		 when s_3 =>
			 if input_x_trig_s = '0' then
				 class_sel <= s_1;
			 else
				 class_sel <= s_3;
			 end if;

		 when s_4 =>
			 FPadd_en <= '0';
			 FPdiv_en <= '0';
			 if (num_oup_class < "1011") then
				FPdiv_a_in <= exp_x_op_array(to_integer(unsigned(num_oup_class)));
				class_sel <= s_5;
			 elsif (num_oup_class = "1011") then
				 num_oup_class <= "0000";
				 class_sel <= s_0;	
				 soft_max_done_s <= '1';
			 end if;
		
		 when s_5 =>
			 FPdiv_en <= '1';
			 class_sel <= s_6;				 

		 when s_6 =>
			 FPdiv_en <= '0';
			 bf_to_fxd_in <= FPdiv_op;
			 class_sel <= s_7;

		 when s_7 =>
			 temp_acc_out <= softmax_acc_out * percentage_of_acc;
			 class_sel <= s_8;			 
			 
		 when s_8 =>
			 if (num_oup_class < "1011") then
				 softmx_acc_array(to_integer(unsigned(num_oup_class))) <= temp_acc_out(24 downto 9);
				 num_oup_class <= num_oup_class + 1;
				 class_sel <= s_4;
			 end if;			 
				
		 when others => null;
	 end case;				
 end if;
 end process;

I1: FPadd_single_b 
	PORT MAP (
	ADD_SUB => '1',
	FP_A    => FPadd_a_in,
	FP_B    => FPadd_b_in,
	FPadd_single_b_en  => FPadd_en,
	FP_Z    => FPadd_op
	);
	
I2: FPdiv_b 
	PORT MAP (
	FP_A    => FPdiv_a_in,
	FP_B    => FPdiv_b_in,
	FPdiv_b_en  => FPdiv_en,
	FP_Z    => FPdiv_op
	);	
	
I3: bf16_to_fixed
	PORT MAP (
	bf16_in => bf_to_fxd_in,
	fxd_out => softmax_acc_out
	);
	
process(soft_max_done_s,class_value,softmx_acc_array)
begin
if (soft_max_done_s = '1' and class_value < "1011") then
	class_accuracy <= softmx_acc_array(to_integer(unsigned(class_value)));
end if;	
end process;
soft_max_done <= soft_max_done_s;
end des;