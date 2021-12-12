library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY pipelined_cnn_computation_core IS
   PORT( 
	-------------------Convolution-------------------------
    clk 			: in	std_logic;
	trigg_in		: IN    std_logic;
    input_data		: IN    std_logic_vector (15 downto 0);
    kernel_data		: IN    std_logic_vector (15 downto 0);
	mac_itr_val		: in 	std_logic_vector (9 downto 0);
    bias_data		: IN    std_logic_vector (15 DOWNTO 0);
	-------------------    ReLU    -------------------------
	ReLU_en			: IN    std_logic;
	-------------------   Maxpool  -------------------------
	maxpool_en		: IN    std_logic;
	maxpool_input_length	: in	std_logic_vector(11 downto 0);
	maxpool_output_length	: IN	std_logic_vector(11 downto 0);
	pool_val		: IN    std_logic_vector(3 downto 0);
	output_data		: out 	std_logic_vector(15 downto 0);
	process_done	: out   std_logic
   );

END pipelined_cnn_computation_core ;


ARCHITECTURE des OF pipelined_cnn_computation_core IS
  

   COMPONENT conv_core IS
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
   END COMPONENT;
   
   COMPONENT ReLU_core IS
   PORT( 
    conv_done_in	: in	std_logic;
	ReLU_en			: IN    std_logic;
    input_data		: IN    std_logic_vector(15 downto 0);
	output_data		: out 	std_logic_vector(15 downto 0);
	process_done	: out   std_logic
   );
   END COMPONENT;
   
   component maxpool_core IS
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
   END component;
   
   signal data_input_to_ReLU	: std_logic_vector (15 DOWNTO 0);
   signal data_input_to_maxpool	: std_logic_vector (15 DOWNTO 0);
   signal conv_process_done		: std_logic:='0';
   signal ReLU_process_done		: std_logic:='0';

BEGIN

   Ins1	: conv_core
      PORT MAP (
         clk			=>	clk,
		 trigg_in		=>	trigg_in,
		 input_data		=>	input_data,
		 kernel_data	=>	kernel_data,
		 mac_itr_val	=>	mac_itr_val,
		 bias_data		=>	bias_data,
		 conv_data		=>	data_input_to_ReLU,
		 process_done	=>	conv_process_done
      ); 
---------------------------------------------------
   Ins2	: ReLU_core 
      PORT MAP (
         conv_done_in	=>	conv_process_done,
		 ReLU_en		=>	ReLU_en,
		 input_data		=>	data_input_to_ReLU,
		 output_data	=>	data_input_to_maxpool,
		 process_done	=>	ReLU_process_done
      );
---------------------------------------------------
   Ins3	: maxpool_core 
      PORT MAP (
       input_length	=>	maxpool_input_length,
		 output_length	=>	maxpool_output_length,
		 actv_done_in	=>	ReLU_process_done,
		 maxpool_en		=>	maxpool_en,
		 pool_val		=>	pool_val,
		 input_data		=>	data_input_to_maxpool,
		 output_data	=>	output_data,
		 process_done	=>	process_done
      );	  

END des;
