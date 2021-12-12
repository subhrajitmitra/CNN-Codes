library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;


entity post_norm_div is
	port(
			 opa_i				: in std_logic_vector(15 downto 0);
			 opb_i				: in std_logic_vector(15 downto 0);
			 qutnt_i			: in std_logic_vector(10 downto 0);
			 exp_10_i			: in std_logic_vector(9 downto 0);
			 sign_i				: in std_logic;
			 output_o			: out std_logic_vector(15 downto 0)
		);
end post_norm_div;

architecture rtl of post_norm_div is

signal s_overflow : std_logic;
signal s_qutdn : std_logic;
signal s_exp_10b : std_logic_vector(9 downto 0);
signal s_shr2 : std_logic;
signal s_expo1, s_expo2, s_expo3 : std_logic_vector(8 downto 0);
signal s_fraco1 : std_logic_vector(10 downto 0);
signal s_frac_rnd, s_fraco2 : std_logic_vector(8 downto 0);
signal s_op_0, s_opab_0, s_opb_0 : std_logic;
signal s_infa, s_infb : std_logic;
signal s_nan_in, s_nan_op, s_nan_a, s_nan_b : std_logic;
signal s_inf_result: std_logic;

	--Zero vector
	constant ZERO_VECTOR: std_logic_vector(14 downto 0) := "000000000000000";
	
	-- Infinty FP format
	constant INF  : std_logic_vector(14 downto 0) := "111111111000000";
	
	-- QNaN (Quit Not a Number) FP format (without sign bit)
    constant QNAN : std_logic_vector(14 downto 0) := "111111110000000";
    
    -- SNaN (Signaling Not a Number) FP format (without sign bit)
    constant SNAN : std_logic_vector(14 downto 0) := "111111111000001";

begin
	
	s_qutdn <= not qutnt_i(10);
	s_exp_10b <= exp_10_i - ("000000001"&s_qutdn);		


	process(s_exp_10b,s_qutdn,qutnt_i)
		variable v_shr, v_shl : std_logic_vector(9 downto 0); 
	begin
		if s_exp_10b(9)='1' or s_exp_10b="0000000000" then
			v_shr := ("0000000001" - s_exp_10b) - s_qutdn;
			v_shl := (others =>'0');
			s_expo1 <= "000000001";
		elsif s_exp_10b(8)='1' then
			v_shr := (others =>'0');
			v_shl := (others =>'0');
			s_expo1 <= s_exp_10b(8 downto 0);
		else
			v_shr := (others =>'0');
			v_shl :=  "000000000"& s_qutdn;
			s_expo1 <= s_exp_10b(8 downto 0);
		end if;
		if  v_shr(6)='1' then
			s_fraco1 <= shr(qutnt_i, "111111");
		elsif v_shr(5 downto 0)>"000000" then
			s_fraco1 <= shr(qutnt_i, v_shr(5 downto 0));
		elsif v_shr(5 downto 0)="000000" then
			s_fraco1 <= shl(qutnt_i, v_shl(5 downto 0));
		end if;
	end process;
	
	s_expo2 <= s_expo1 - "000000001" when s_fraco1(10)='0' else s_expo1;
	s_frac_rnd <= '0' & s_fraco1(10 downto 3);	
	s_shr2 <= s_frac_rnd(8);


	process(s_shr2,s_expo2,s_frac_rnd)
	begin
			if s_shr2='1' then
				s_expo3 <= s_expo2 + "1";
				s_fraco2 <= "0"&s_frac_rnd(8 downto 1);
			else 
				s_expo3 <= s_expo2;
				s_fraco2 <= s_frac_rnd;
			end if;
	end process;

		
	s_op_0 <= not ( or_reduce(opa_i(14 downto 0)) and or_reduce(opb_i(14 downto 0)) );
	s_opab_0 <= not ( or_reduce(opa_i(14 downto 0)) or or_reduce(opb_i(14 downto 0)) );
	s_opb_0 <= not or_reduce(opb_i(14 downto 0));
	
	s_infa <= '1' when opa_i(14 downto 7)="11111111"  else '0';
	s_infb <= '1' when opb_i(14 downto 7)="11111111"  else '0';

	s_nan_a <= '1' when (s_infa='1' and or_reduce (opa_i(6 downto 0))='1') else '0';
	s_nan_b <= '1' when (s_infb='1' and or_reduce (opb_i(6 downto 0))='1') else '0';
	s_nan_in <= '1' when s_nan_a='1' or  s_nan_b='1' else '0';
	s_nan_op <= '1' when (s_infa and s_infb)='1' or s_opab_0='1' else '0';

	s_inf_result <= '1' when (and_reduce(s_expo3(7 downto 0)) or s_expo3(8))='1' or s_opb_0='1' else '0';

	s_overflow <= '1' when s_inf_result='1'  and (s_infa or s_infb)='0' and s_opb_0='0' else '0';
	
	process(sign_i, s_expo3, s_fraco2, s_nan_in, s_nan_op, s_infa, s_infb, s_overflow, s_inf_result, s_op_0)
	begin
		if (s_nan_in or s_nan_op)='1' then
			output_o <= '1' & QNAN;
		elsif (s_infa or s_infb)='1' or s_overflow='1' or s_inf_result='1' then
				output_o <= sign_i & INF;
		elsif s_op_0='1' then
				output_o <= sign_i & ZERO_VECTOR;					
		else
				output_o <= sign_i & s_expo3(7 downto 0) & s_fraco2(6 downto 0);
		end if;
	end process;

end rtl;