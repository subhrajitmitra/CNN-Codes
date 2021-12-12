library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


ENTITY ReLU_core IS
   PORT( 
      conv_done_in	: in	std_logic;
	  ReLU_en		: IN    std_logic;
      input_data	: IN    std_logic_vector(15 downto 0);
	  output_data	: out 	std_logic_vector(15 downto 0);
	  process_done	: out   std_logic
   );
END ReLU_core;


ARCHITECTURE des OF ReLU_core IS

BEGIN


process(ReLU_en,conv_done_in,input_data)
begin
if ReLU_en = '1' then
	if conv_done_in = '1' then 
		process_done <= '1';
		if input_data(15)='1' then
			output_data <= (others=>'0');
		elsif input_data(15)='0' then
			output_data <= input_data;
		end if;
	else
		process_done <= '0';
	end if;
elsif ReLU_en = '0' then
	process_done <= conv_done_in;
	output_data <= input_data;
end if;
end process;
--process_done <= process_done_s;

END des;
