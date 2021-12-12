library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


ENTITY maxpool_core IS
   PORT( 
      input_length  : in	std_logic_vector(11 downto 0);
		output_length : in	std_logic_vector(11 downto 0);
	  actv_done_in	: in	std_logic;
	  maxpool_en	: IN    std_logic;
      pool_val		: IN    std_logic_vector(3 downto 0);
      input_data	: IN    std_logic_vector(15 downto 0);
	  output_data	: out 	std_logic_vector(15 downto 0);
	  process_done	: out   std_logic
   );
END maxpool_core;


ARCHITECTURE des OF maxpool_core IS

   type state is (data_capt,max_calc,max_halt);
   signal core_fsm : state;
   SIGNAL pool_cnt		: std_logic_vector (3 DOWNTO 0):="0000";
   SIGNAL temp_output_len: std_logic_vector (11 DOWNTO 0):=(others=>'0');
   SIGNAL temp_max		: std_logic_vector (15 DOWNTO 0);
   signal process_done_s: std_logic:='0';
   signal maxpool_active: std_logic:='0';
   signal rst_temp_output_len: std_logic:='0';
   --constant input_length: std_logic_vector (11 DOWNTO 0):="001001010111";
   SIGNAL maxpool_halt_cnt	: std_logic_vector (3 DOWNTO 0):="0000";
   SIGNAL maxpool_halt_cnt_state	: std_logic_vector (3 DOWNTO 0):="0000";
   SIGNAL temp_maxpool_halt_cnt	: std_logic_vector (23 DOWNTO 0):=(others=>'0');
   

BEGIN

temp_maxpool_halt_cnt <= (("000000000000" & input_length) - (output_length * ("00000000" & pool_val)));
maxpool_halt_cnt <= temp_maxpool_halt_cnt(3 downto 0);

process(maxpool_en,actv_done_in,temp_output_len,output_length,pool_cnt,pool_val,maxpool_halt_cnt)
begin
if maxpool_en = '0' then
	temp_max <= (others=>'0');
	core_fsm <= data_capt;

 elsif rising_edge(actv_done_in) then
	 case core_fsm is
		 when data_capt =>	
			 if (temp_output_len = output_length and pool_cnt = pool_val) then
----------------------------------new version------------------------------------
				if (maxpool_halt_cnt="0000") then
					temp_max <= input_data;
					pool_cnt <= "0001";
					rst_temp_output_len <= '1';
					--process_done_s <= '0';
					core_fsm <= max_calc;
				else
----------------------------------new version------------------------------------						 
					 temp_max <= (others=>'0');
					 pool_cnt <= "0000";
					 maxpool_active <= '0';
					 maxpool_halt_cnt_state <= "0000";
					 core_fsm <= max_halt;
				end if;
			 else
				 temp_max <= input_data;
				 pool_cnt <= "0000";
				 --process_done_s <= '0';
				 core_fsm <= max_calc;
			 end if;
			 
		when max_calc =>
			maxpool_active <= '1';
			rst_temp_output_len <= '0';
			if (pool_cnt<pool_val-1) then
				if   ((temp_max(15) xor input_data(15))='0') then
					if    input_data(14)='0' then
						if (input_data(14 downto 0) >= temp_max(14 downto 0)) then
							temp_max <= input_data;
						end if;
					elsif input_data(15)='1' then
						if (input_data(14 downto 0) <= temp_max(14 downto 0)) then
							temp_max <= input_data;
						end if;
					end if;
				elsif ((temp_max(15) xor input_data(15))='1') then
					if input_data(15)='0' then
						temp_max <= input_data;
					end if;
				end if;
				pool_cnt <= pool_cnt +1;
				--process_done_s <= '0';
				core_fsm <= max_calc;
			elsif (pool_cnt=pool_val-1) then
				if   ((temp_max(15) xor input_data(15))='0') then
					if    input_data(14)='0' then
						if (input_data(14 downto 0) >= temp_max(14 downto 0)) then
							temp_max <= input_data;
						end if;
					elsif input_data(15)='1' then
						if (input_data(14 downto 0) <= temp_max(14 downto 0)) then
							temp_max <= input_data;
						end if;
					end if;
				elsif ((temp_max(15) xor input_data(15))='1') then
					if input_data(15)='0' then
						temp_max <= input_data;
					end if;
				end if;
				pool_cnt <= pool_cnt +1;
				--process_done_s <= '1';
				core_fsm <= data_capt;
			end if;	
		
		when max_halt =>
			pool_cnt <= "0001";
			rst_temp_output_len <= '1';
			if (maxpool_halt_cnt_state < maxpool_halt_cnt) then
				maxpool_halt_cnt_state <= maxpool_halt_cnt_state + 1;
				temp_max <= (others=>'0');
				maxpool_active <= '0';
				core_fsm <= max_halt;
----------------------------------new version------------------------------------
			elsif (maxpool_halt_cnt_state = maxpool_halt_cnt) then
				temp_max <= input_data;
				--process_done_s <= '0';
				core_fsm <= max_calc;
----------------------------------new version------------------------------------							
			else
				core_fsm <= max_calc;
			end if;
		
		when others => null;
	end case;
end if;
end process;

process(actv_done_in,pool_val,maxpool_en,pool_cnt,temp_max,input_data)
begin
if maxpool_en = '1' then
	if ((pool_cnt = pool_val) and (actv_done_in = '0')) then 
		process_done_s <= '1';
		output_data <= temp_max;
	else
		process_done_s <= '0';
	end if;
elsif maxpool_en = '0' then
	process_done_s <= actv_done_in;
	output_data <= input_data;
end if;
end process;

process(process_done_s,rst_temp_output_len)
begin
if rst_temp_output_len = '1' then temp_output_len <= (others=>'0');
elsif rising_edge(process_done_s) then temp_output_len <= temp_output_len +1;
end if;
end process;

process(maxpool_en,process_done_s,maxpool_active)
begin
if maxpool_en = '0' then
	process_done <= process_done_s and maxpool_active;
else 
	process_done <= process_done_s;
end if;
end process;

END des;
