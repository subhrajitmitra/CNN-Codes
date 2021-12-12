library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;


entity pre_norm_div is
	port(
			 opa_i			: in std_logic_vector(15 downto 0);
			 opb_i			: in std_logic_vector(15 downto 0);
			 exp_10_o		: out std_logic_vector(9 downto 0);
			 dvdnd_18_o		: out std_logic_vector(17 downto 0); 
			 dvsor_11_o		: out std_logic_vector(10 downto 0)
		);
end pre_norm_div;

architecture rtl of pre_norm_div is

signal s_dvd_zeros, s_div_zeros: std_logic_vector(5 downto 0);
signal s_expa_in, s_expb_in	: std_logic_vector(9 downto 0);
signal s_opa_dn, s_opb_dn : std_logic;
signal s_fracta_8, s_fractb_8 : std_logic_vector(7 downto 0);

    -- count the  zeros starting from left
	function count_l_zeros (signal s_vector: std_logic_vector) return std_logic_vector is
		variable v_count : std_logic_vector(5 downto 0);	
	begin
		v_count := "000000";
		for i in s_vector'range loop
			case s_vector(i) is
				when '0' => v_count := v_count + "000001";
				when others => exit;
			end case;
		end loop;
		return v_count;	
	end count_l_zeros;


	-- count the zeros starting from right
	function count_r_zeros (signal s_vector: std_logic_vector) return std_logic_vector is
		variable v_count : std_logic_vector(5 downto 0);	
	begin
		v_count := "000000";
		for i in 0 to s_vector'length-1 loop
			case s_vector(i) is
				when '0' => v_count := v_count + "000001";
				when others => exit;
			end case;
		end loop;
		return v_count;	
	end count_r_zeros;

begin


	
	s_opa_dn <= not or_reduce(opa_i(14 downto 7));
	s_opb_dn <= not or_reduce(opb_i(14 downto 7));
	
	s_fracta_8 <= (not s_opa_dn) & opa_i(6 downto 0);
	s_fractb_8 <= (not s_opb_dn) & opb_i(6 downto 0);

	s_dvd_zeros <= count_l_zeros( s_fracta_8 );
	s_div_zeros <= count_l_zeros( s_fractb_8 );

	dvdnd_18_o <= shl(s_fracta_8, s_dvd_zeros) & "0000000000";
	dvsor_11_o <= "000" & shl(s_fractb_8, s_div_zeros);	
	
	s_expa_in <= ("00"&opa_i(14 downto 7)) + ("000000000"&s_opa_dn);
	s_expb_in <= ("00"&opb_i(14 downto 7)) + ("000000000"&s_opb_dn);	
	exp_10_o <= s_expa_in - s_expb_in + "0011111111" -("0000"&s_dvd_zeros) + ("0000"&s_div_zeros);	



end rtl;
