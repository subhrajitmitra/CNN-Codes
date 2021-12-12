LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


ENTITY FPround_b IS
   GENERIC( 
      SIG_width : integer := 12
   );
   PORT( 
      SIG_in  : IN     std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_in  : IN     std_logic_vector (7 DOWNTO 0);
      SIG_out : OUT    std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_out : OUT    std_logic_vector (7 DOWNTO 0)
   );

-- Declarations

END FPround_b ;


-- hds interface_end
ARCHITECTURE FPround OF FPround_b IS
BEGIN
	EXP_out <= EXP_in;

PROCESS(SIG_in)
BEGIN
--   IF ((SIG_in(2)='0') OR ((SIG_in(3)='0') AND (SIG_in(1)='0') AND (SIG_in(0)='0'))) THEN
--   IF ((SIG_in(2)='0') OR ((SIG_in(3)='0') AND (SIG_in(2)='1') AND (SIG_in(1)='0') AND (SIG_in(0)='0'))) THEN
   IF (SIG_in(2)='0') THEN
		SIG_out <= SIG_in;
   ELSE
 		SIG_out <= (SIG_in(SIG_width-1 DOWNTO 3) + 1) & "010";
	END IF;
END PROCESS;

END FPround;

