LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;


ENTITY FPswap_b IS
   GENERIC( 
      width : integer := 13
   );
   PORT( 
      A_in    : IN     std_logic_vector (width-1 DOWNTO 0);
      B_in    : IN     std_logic_vector (width-1 DOWNTO 0);
      swap_AB : IN     std_logic;
      A_out   : OUT    std_logic_vector (width-1 DOWNTO 0);
      B_out   : OUT    std_logic_vector (width-1 DOWNTO 0)
   );

-- Declarations

END FPswap_b ;


-- hds interface_end
ARCHITECTURE FPswap OF FPswap_b IS
BEGIN

PROCESS(A_in, B_in, swap_AB)
BEGIN
   IF (swap_AB='1') THEN
      A_out <= B_in;
      B_out <= A_in;
   ELSE
      A_out <= A_in;
      B_out <= B_in;
   END IF;
END PROCESS;

END FPswap;

