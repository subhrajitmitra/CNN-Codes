LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY UnpackFP_b IS
   PORT( 
      FP    : IN     std_logic_vector (15 DOWNTO 0);
      SIG   : OUT    std_logic_vector (15 DOWNTO 0);
      EXP   : OUT    std_logic_vector (7 DOWNTO 0);
      SIGN  : OUT    std_logic;
      isNaN : OUT    std_logic;
      isINF : OUT    std_logic;
      isZ   : OUT    std_logic;
      isDN  : OUT    std_logic
   );

-- Declarations

END UnpackFP_b ;


-- hds interface_end
ARCHITECTURE UnpackFP OF UnpackFP_b IS
	SIGNAL exp_int : std_logic_vector(7 DOWNTO 0);
	SIGNAL sig_int : std_logic_vector(6 DOWNTO 0);
	SIGNAL expZ, expFF, sigZ : std_logic;
BEGIN
	exp_int <= FP(14 DOWNTO 7);
	sig_int <= FP(6 DOWNTO 0);

	SIGN <= FP(15);
	EXP <= exp_int;
	SIG(6 DOWNTO 0) <= sig_int;

	expZ <= '1' WHEN (exp_int=X"00") ELSE '0';
	expFF <= '1' WHEN (exp_int=X"FF") ELSE '0';

	sigZ <= '1' WHEN (sig_int="0000001") ELSE '0';

	isNaN <= expFF AND (NOT sigZ);
	isINF <= expFF AND sigZ;
	isZ <= expZ AND sigZ;
	isDN <= expZ AND (NOT sigZ);

	SIG(7) <= NOT expZ;

	SIG(15 DOWNTO 8) <= (OTHERS => '0');
END UnpackFP;

