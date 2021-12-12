library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY conv_core IS
   PORT( 
    clk 			: in	std_logic;
	trigg_in		: IN    std_logic;
    input_data		: IN    std_logic_vector (15 downto 0);
    kernel_data		: IN    std_logic_vector (15 downto 0);
	mac_itr_val		: in 	std_logic_vector (9 downto 0);
    bias_data		: IN    std_logic_vector (15 DOWNTO 0);
	conv_data		: OUT	std_logic_vector (15 DOWNTO 0);
	process_done	: out   std_logic
   );

END conv_core ;


ARCHITECTURE des OF conv_core IS

   SIGNAL mac_itr_cnt		: std_logic_vector (9 DOWNTO 0):=(others=>'0');
   SIGNAL bias_reg			: std_logic_vector (15 DOWNTO 0);
   SIGNAL FPadd_b_in		: std_logic_vector (15 DOWNTO 0);
   SIGNAL FPadd_b_op		: std_logic_vector (15 DOWNTO 0);
   SIGNAL FPmul_b_op		: std_logic_vector (15 DOWNTO 0);
   constant ADD_signal		: std_logic:='1';
   signal bias_sel			: std_logic:='0';
   signal clk_en			: std_logic:='0';
   signal process_done_s	: std_logic:='0';
   
   type state is (bias_add,mac_itr,data_out);
   signal core_fsm : state;
   

   COMPONENT FPadd_single_b IS
   PORT( 
      ADD_SUB 	: IN     std_logic;
      FP_A    	: IN     std_logic_vector (15 DOWNTO 0);
      FP_B    	: IN     std_logic_vector (15 DOWNTO 0);
      FPadd_single_b_en    : IN     std_logic;
      FP_Z    	: OUT    std_logic_vector (15 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT FPmul_b IS
   PORT( 
      FP_A 		: IN     std_logic_vector (15 DOWNTO 0);
      FP_B 		: IN     std_logic_vector (15 DOWNTO 0);
      FPmul_b_en  	: IN     std_logic;
      FP_Z 		: OUT    std_logic_vector (15 DOWNTO 0)
   );
   END COMPONENT;

BEGIN

   Ins1	: FPmul_b
      PORT MAP (
         FP_A    => input_data,
         FP_B    => kernel_data,
         FPmul_b_en  => clk_en,
         FP_Z    => FPmul_b_op
      ); 
---------------------------------------------------
   Ins2	: FPadd_single_b 
      PORT MAP (
         ADD_SUB => ADD_signal,
		 FP_A    => bias_reg,
         FP_B    => FPmul_b_op,
		 FPadd_single_b_en  => clk_en,
         FP_Z    => FPadd_b_op
      );

bias_sel <= (not clk) and (clk_en xor (mac_itr_cnt(9) or mac_itr_cnt(8) or mac_itr_cnt(7) or mac_itr_cnt(6) or mac_itr_cnt(5) or mac_itr_cnt(4) or mac_itr_cnt(3) or mac_itr_cnt(2) or mac_itr_cnt(1) or mac_itr_cnt(0)));
process(bias_sel,FPadd_b_in)
begin
if bias_sel = '1' then bias_reg <= bias_data;
elsif bias_sel = '0' then bias_reg <= FPadd_b_in;
end if;
end process;

process(trigg_in,process_done_s)
begin
if process_done_s = '1' then 
	clk_en <='0';
elsif rising_edge(trigg_in) then 
	clk_en <= '1';
end if;
end process;

process(clk)
begin
if rising_edge(clk) then
	case core_fsm is
		when bias_add =>
			if clk_en = '1' then
				FPadd_b_in <= FPadd_b_op;
				process_done_s <= '0';
				mac_itr_cnt <= "0000000001";
				core_fsm <= mac_itr;
			else
				core_fsm <= bias_add;
			end if;
		
		when mac_itr =>
			if (mac_itr_cnt < mac_itr_val-1) then
				FPadd_b_in <= FPadd_b_op;
				process_done_s <= '0';
				mac_itr_cnt <= mac_itr_cnt+1;
				core_fsm <= mac_itr;
			else
				conv_data <= FPadd_b_op;
				process_done_s <= '1';
				mac_itr_cnt <= "0000000000";
				core_fsm <= data_out;
			end if;
		
		when data_out =>
			process_done_s <= '0';
			core_fsm <= bias_add;
			
		when others => null;
	end case;
end if;
end process;

process_done <= process_done_s;

END des;
