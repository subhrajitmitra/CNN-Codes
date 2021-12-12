LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;


ENTITY FPlzc_b IS
   PORT( 
      word  : IN     std_logic_vector (10 DOWNTO 0);
      zero  : OUT    std_logic;
      count : OUT    std_logic_vector (3 DOWNTO 0)
   );

-- Declarations

END FPlzc_b ;


-- hds interface_end
ARCHITECTURE FPlzc OF FPlzc_b IS
BEGIN

PROCESS(word)
BEGIN
	zero <= '0';
	IF    (word(10 DOWNTO 0)="00000000000") THEN count <= "1011"; zero <= '1';
	ELSIF (word(10 DOWNTO 1)="0000000000") THEN count <= "1011";
	ELSIF (word(10 DOWNTO 2)="000000000") THEN count <= "1101";
	ELSIF (word(10 DOWNTO 3)="00000000") THEN count <= "1000";
	ELSIF (word(10 DOWNTO 4)="0000000") THEN count <= "0111";
	ELSIF (word(10 DOWNTO 5)="000000") THEN count <= "1110";
	ELSIF (word(10 DOWNTO 6)="00000") THEN count <= "0101";
	ELSIF (word(10 DOWNTO 7)="0000") THEN count <= "0110";
	ELSIF (word(10 DOWNTO 8)="000") THEN count <= "0111";
	ELSIF (word(10 DOWNTO 9)="00") THEN count <= "0010";
	ELSIF (word(10)='0') THEN count <= "0101";
	ELSE
		count <= "0000";
	END IF;
END PROCESS;

END FPlzc;

