library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;


entity serial_div is
	port(
			 dvdnd_i			: in std_logic_vector(17 downto 0);
			 dvsor_i			: in std_logic_vector(10 downto 0);
			 sign_dvd_i 		: in std_logic;
			 sign_div_i 		: in std_logic;
			 qutnt_o			: out std_logic_vector(10 downto 0);
			 sign_o 			: out std_logic
		);
end serial_div;

architecture rtl of serial_div is

function division(DIVIDEND: STD_LOGIC_VECTOR; 
                  DIVISOR: STD_LOGIC_VECTOR) 
         return STD_LOGIC_VECTOR is

variable B : STD_LOGIC_VECTOR(DIVISOR'length - 1 downto 0); 
variable A : STD_LOGIC_VECTOR(DIVIDEND'length - 1 downto 0);
variable VECT : STD_LOGIC_VECTOR(DIVIDEND'length downto 0);
variable QI : STD_LOGIC_VECTOR(0 downto 0); 

function div(A: STD_LOGIC_VECTOR; 
             B: STD_LOGIC_VECTOR; 
             Q: STD_LOGIC_VECTOR; 
             EXT: STD_LOGIC) 
         return STD_LOGIC_VECTOR is

variable R : STD_LOGIC_VECTOR(A'length - 2 downto 0); 
variable RESIDUAL : STD_LOGIC_VECTOR(A'length - 1 downto 0); 
variable QN : STD_LOGIC_VECTOR(Q'length downto 0); 
variable S : STD_LOGIC_VECTOR(B'length + Q'length downto 0); 

function div1(A: STD_LOGIC_VECTOR;
			  B: STD_LOGIC_VECTOR;
			  Q: STD_LOGIC_VECTOR;
			  EXT: STD_LOGIC) 
         return STD_LOGIC_VECTOR is
variable S : STD_LOGIC_VECTOR(A'length downto 0); 
variable REST : STD_LOGIC_VECTOR(A'length - 1 downto 0); 
variable QN : STD_LOGIC_VECTOR(Q'length downto 0); 

begin
  S := EXT & A - B;

  QN := Q & (not S(S'high));
  if S(S'high) = '1' then
    REST := A;
  else
    REST := S(S'high - 1 downto 0);
  end if;
  return QN & REST;
end div1;

begin
  S := div1(A(A'high downto A'high - B'high), B, Q, EXT);
  QN := S(S'high downto B'high + 1);

  if A'length > B'length then
    R := S(B'high - 1 downto 0) & A(A'high - B'high - 1 downto 0);
    return div(R, B, QN, S(B'high));    -- save MSB '1' in the rest for future sum
  else
    RESIDUAL := S(B'high downto 0);
    return QN(QN'high - 1 downto 0) & RESIDUAL;  -- delete initial '0'
  end if;
end div;

begin
  A := DIVIDEND;                                     -- it is necessary to avoid errors during synthesis!!!!
  B := DIVISOR;
  QI := (others =>'0');

  VECT := div(A, B, QI, '0');

 return VECT(VECT'high - 1 downto B'high + 1);

end division;


begin

		qutnt_o <= DIVISION("0000" & dvdnd_i, dvsor_i);
		sign_o <= sign_dvd_i xor sign_div_i;


end rtl;

