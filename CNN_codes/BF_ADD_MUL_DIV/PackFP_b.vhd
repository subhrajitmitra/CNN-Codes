LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;


ENTITY PackFP_b IS
   PORT( 
      SIGN  : IN     std_logic;
      EXP   : IN     std_logic_vector (7 DOWNTO 0);
      SIG   : IN     std_logic_vector (6 DOWNTO 0);
      isNaN : IN     std_logic;
      isINF : IN     std_logic;
	  isZ	: IN	 std_logic;
      FP    : OUT    std_logic_vector (15 DOWNTO 0)
   );

-- Declarations

END PackFP_b ;


-- hds interface_end
ARCHITECTURE PackFP OF PackFP_b IS
BEGIN
PROCESS(isNaN,isINF,isZ,SIGN,EXP,SIG)
BEGIN

	IF (isNaN='1') THEN
		FP(15) <= SIGN;
		FP(14 DOWNTO 7) <= X"FF";
		FP(6 DOWNTO 0) <= "100" & X"0";
	ELSIF (isINF='1') THEN
		FP(15) <= SIGN;
		FP(14 DOWNTO 7) <= X"FF";
		FP(6 DOWNTO 0) <= (OTHERS => '0');
	ELSIF (isZ='1') THEN
		FP(15) <= SIGN;
		FP(14 DOWNTO 7) <= X"00";
		FP(6 DOWNTO 0) <= (OTHERS => '0');
    ELSE	
		FP(15) <= SIGN;
		FP(14 DOWNTO 7) <= EXP;
		FP(6 DOWNTO 0) <= SIG;
	END IF;
END PROCESS;

END PackFP;

