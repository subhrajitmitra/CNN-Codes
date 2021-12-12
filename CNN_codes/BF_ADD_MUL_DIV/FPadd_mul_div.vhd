LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY FPadd_single_b IS
   PORT( 
      ADD_SUB : IN     std_logic;
      FP_A    : IN     std_logic_vector (15 DOWNTO 0);
      FP_B    : IN     std_logic_vector (15 DOWNTO 0);
      FPadd_single_b_en     : IN     std_logic;
      FP_Z    : OUT    std_logic_vector (15 DOWNTO 0)
   );

-- Declarations

END FPadd_single_b ;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ARCHITECTURE single_cycle OF FPadd_single_b IS

   -- Architecture declarations
      -- Non hierarchical truthtable declarations
    

      -- Non hierarchical truthtable declarations
    

      -- Non hierarchical truthtable declarations
   --SIGNAL FP_A     : std_logic_vector(31 DOWNTO 0):= "01000001110100000000000000000000";
   --SIGNAL FP_B     : std_logic_vector(31 DOWNTO 0):= "01000001110100000000000000000000";
   --SIGNAL FP_A     : std_logic_vector(31 DOWNTO 0):= "01000001011000000000000000000000";
	
   SIGNAL FP_OP     : std_logic_vector(15 DOWNTO 0);

   -- Internal signal declarations
   SIGNAL A_CS      : std_logic_vector(12 DOWNTO 0);
   SIGNAL A_EXP     : std_logic_vector(7 DOWNTO 0);
   SIGNAL A_SIG     : std_logic_vector(15 DOWNTO 0);
   SIGNAL A_SIGN    : std_logic;
   SIGNAL A_in      : std_logic_vector(12 DOWNTO 0);
   SIGNAL A_isDN    : std_logic;
   SIGNAL A_isINF   : std_logic;
   SIGNAL A_isNaN   : std_logic;
   SIGNAL A_isZ     : std_logic;
   SIGNAL B_CS      : std_logic_vector(12 DOWNTO 0);
   SIGNAL B_EXP     : std_logic_vector(7 DOWNTO 0);
   SIGNAL B_SIG     : std_logic_vector(15 DOWNTO 0);
   SIGNAL B_SIGN    : std_logic;
   SIGNAL B_XSIGN   : std_logic;
   SIGNAL B_in      : std_logic_vector(12 DOWNTO 0);
   SIGNAL B_isDN    : std_logic;
   SIGNAL B_isINF   : std_logic;
   SIGNAL B_isNaN   : std_logic;
   SIGNAL B_isZ     : std_logic;
   SIGNAL EXP_base  : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_diff  : std_logic_vector(8 DOWNTO 0);
   SIGNAL EXP_isINF : std_logic;
   SIGNAL EXP_norm  : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_round : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_selC  : std_logic_vector(7 DOWNTO 0);
   SIGNAL OV        : std_logic;
   SIGNAL SIG_norm  : std_logic_vector(11 DOWNTO 0);
   SIGNAL SIG_norm2 : std_logic_vector(11 DOWNTO 0);
   SIGNAL SIG_round : std_logic_vector(11 DOWNTO 0);
   SIGNAL SIG_selC  : std_logic_vector(11 DOWNTO 0);
   SIGNAL Z_EXP     : std_logic_vector(7 DOWNTO 0);
   SIGNAL Z_SIG     : std_logic_vector(6 DOWNTO 0);
   SIGNAL Z_SIGN    : std_logic;
   SIGNAL a_align   : std_logic_vector(12 DOWNTO 0);
   SIGNAL a_exp_in  : std_logic_vector(8 DOWNTO 0);
   SIGNAL a_inv     : std_logic_vector(12 DOWNTO 0);
   SIGNAL add_out   : std_logic_vector(12 DOWNTO 0);
   SIGNAL b_align   : std_logic_vector(12 DOWNTO 0);
   SIGNAL b_exp_in  : std_logic_vector(8 DOWNTO 0);
   SIGNAL b_inv     : std_logic_vector(12 DOWNTO 0);
   SIGNAL cin       : std_logic;
   SIGNAL cin_sub   : std_logic;
   SIGNAL invert_A  : std_logic;
   SIGNAL invert_B  : std_logic;
   SIGNAL isINF     : std_logic;
   SIGNAL isINF_tab : std_logic;
   SIGNAL isNaN     : std_logic;
   SIGNAL isZ       : std_logic;
   SIGNAL isZ_tab   : std_logic;
   SIGNAL mux_sel   : std_logic;
   SIGNAL zero      : std_logic;


   -- ModuleWare signal declarations(v1.1) for instance 'I13' of 'mux'
   SIGNAL mw_I13din0 : std_logic_vector(7 DOWNTO 0);
   SIGNAL mw_I13din1 : std_logic_vector(7 DOWNTO 0);

   -- Component Declarations
   COMPONENT FPadd_normalize_b
   PORT (
      EXP_in  : IN     std_logic_vector (7 DOWNTO 0);
      SIG_in  : IN     std_logic_vector (11 DOWNTO 0);
      EXP_out : OUT    std_logic_vector (7 DOWNTO 0);
      SIG_out : OUT    std_logic_vector (11 DOWNTO 0);
      zero    : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT FPalign_b
   PORT (
      A_in  : IN     std_logic_vector (12 DOWNTO 0);
      B_in  : IN     std_logic_vector (12 DOWNTO 0);
      cin   : IN     std_logic ;
      diff  : IN     std_logic_vector (8 DOWNTO 0);
      A_out : OUT    std_logic_vector (12 DOWNTO 0);
      B_out : OUT    std_logic_vector (12 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT FPinvert_b
   GENERIC (
      width : integer := 13
   );
   PORT (
      A_in     : IN     std_logic_vector (width-1 DOWNTO 0);
      B_in     : IN     std_logic_vector (width-1 DOWNTO 0);
      invert_A : IN     std_logic ;
      invert_B : IN     std_logic ;
      A_out    : OUT    std_logic_vector (width-1 DOWNTO 0);
      B_out    : OUT    std_logic_vector (width-1 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT FPnormalize_b
   GENERIC (
      SIG_width : integer := 12
   );
   PORT (
      SIG_in  : IN     std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_in  : IN     std_logic_vector (7 DOWNTO 0);
      SIG_out : OUT    std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_out : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT FPround_b
   GENERIC (
      SIG_width : integer := 12
   );
   PORT (
      SIG_in  : IN     std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_in  : IN     std_logic_vector (7 DOWNTO 0);
      SIG_out : OUT    std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_out : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT FPselComplement_b
   GENERIC (
      SIG_width : integer := 12
   );
   PORT (
      SIG_in  : IN     std_logic_vector (SIG_width DOWNTO 0);
      EXP_in  : IN     std_logic_vector (7 DOWNTO 0);
      SIG_out : OUT    std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_out : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT FPswap_b
   GENERIC (
      width : integer := 13
   );
   PORT (
      A_in    : IN     std_logic_vector (width-1 DOWNTO 0);
      B_in    : IN     std_logic_vector (width-1 DOWNTO 0);
      swap_AB : IN     std_logic ;
      A_out   : OUT    std_logic_vector (width-1 DOWNTO 0);
      B_out   : OUT    std_logic_vector (width-1 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT PackFP_b
   PORT (
      SIGN  : IN     std_logic ;
      EXP   : IN     std_logic_vector (7 DOWNTO 0);
      SIG   : IN     std_logic_vector (6 DOWNTO 0);
      isNaN : IN     std_logic ;
      isINF : IN     std_logic ;
      isZ   : IN     std_logic ;
      FP    : OUT    std_logic_vector (15 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT UnpackFP_b
   PORT (
      FP    : IN     std_logic_vector (15 DOWNTO 0);
      SIG   : OUT    std_logic_vector (15 DOWNTO 0);
      EXP   : OUT    std_logic_vector (7 DOWNTO 0);
      SIGN  : OUT    std_logic ;
      isNaN : OUT    std_logic ;
      isINF : OUT    std_logic ;
      isZ   : OUT    std_logic ;
      isDN  : OUT    std_logic 
   );
   END COMPONENT;

BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   -- eb1 1
   cin_sub <= (A_isDN OR A_isZ) XOR 
   (B_isDN OR B_isZ);

   -- HDL Embedded Text Block 2 eb2
   -- eb2 2
   Z_SIG <= SIG_norm2(9 DOWNTO 3);

   -- HDL Embedded Block 3 eb3
   -- Non hierarchical truthtable
   ---------------------------------------------------------------------------
   eb3_truth_process: PROCESS(ADD_SUB, A_isINF, A_isNaN, A_isZ, B_isINF, B_isNaN, B_isZ)
   ---------------------------------------------------------------------------
   BEGIN
      -- Block 1
      IF (A_isNaN = '1') THEN
         isINF_tab <= '0';
         isNaN <= '1';
         isZ_tab <= '0';
      ELSIF (B_isNaN = '1') THEN
         isINF_tab <= '0';
         isNaN <= '1';
         isZ_tab <= '0';
      ELSIF (ADD_SUB = '1') AND (A_isINF = '1') AND (B_isINF = '1') THEN
         isINF_tab <= '1';
         isNaN <= '0';
         isZ_tab <= '0';
      ELSIF (ADD_SUB = '0') AND (A_isINF = '1') AND (B_isINF = '1') THEN
         isINF_tab <= '0';
         isNaN <= '1';
         isZ_tab <= '0';
      ELSIF (A_isINF = '1') THEN
         isINF_tab <= '1';
         isNaN <= '0';
         isZ_tab <= '0';
      ELSIF (B_isINF = '1') THEN
         isINF_tab <= '1';
         isNaN <= '0';
         isZ_tab <= '0';
      ELSIF (A_isZ = '1') AND (B_isZ = '1') THEN
         isINF_tab <= '0';
         isNaN <= '0';
         isZ_tab <= '1';
      ELSE
         isINF_tab <= '0';
         isNaN <= '0';
         isZ_tab <= '0';
      END IF;

   END PROCESS eb3_truth_process;

   -- Architecture concurrent statements
    


   -- HDL Embedded Text Block 4 eb4
   -- eb4 4 
   mux_sel <= EXP_diff(8);

   -- HDL Embedded Block 5 InvertLogic
   -- Non hierarchical truthtable
   ---------------------------------------------------------------------------
   InvertLogic_truth_process: PROCESS(A_SIGN, B_XSIGN, EXP_diff)
   ---------------------------------------------------------------------------
   BEGIN
      -- Block 1
      IF (A_SIGN = '0') AND (B_XSIGN = '0') THEN
         invert_A <= '0';
         invert_B <= '0';
      ELSIF (A_SIGN = '1') AND (B_XSIGN = '1') THEN
         invert_A <= '0';
         invert_B <= '0';
      ELSIF (A_SIGN = '0') AND (B_XSIGN = '1') AND (EXP_diff(8) = '0') THEN
         invert_A <= '0';
         invert_B <= '1';
      ELSIF (A_SIGN = '0') AND (B_XSIGN = '1') AND (EXP_diff(8) = '1') THEN
         invert_A <= '1';
         invert_B <= '0';
      ELSIF (A_SIGN = '1') AND (B_XSIGN = '0') AND (EXP_diff(8) = '0') THEN
         invert_A <= '1';
         invert_B <= '0';
      ELSIF (A_SIGN = '1') AND (B_XSIGN = '0') AND (EXP_diff(8) = '1') THEN
         invert_A <= '0';
         invert_B <= '1';
      ELSE
         invert_A <= '0';
         invert_B <= '0';
      END IF;

   END PROCESS InvertLogic_truth_process;

   -- Architecture concurrent statements
    


   -- HDL Embedded Block 6 SignLogic
   -- Non hierarchical truthtable
   ---------------------------------------------------------------------------
   SignLogic_truth_process: PROCESS(A_SIGN, B_XSIGN, add_out)
   ---------------------------------------------------------------------------
      VARIABLE b1_A_SIGNB_XSIGNadd_out_12 : std_logic_vector(2 DOWNTO 0);
   BEGIN
      -- Block 1
      b1_A_SIGNB_XSIGNadd_out_12 := A_SIGN & B_XSIGN & add_out(12);

      CASE b1_A_SIGNB_XSIGNadd_out_12 IS
      WHEN "000" =>
         OV <= '0';
         Z_SIGN <= '0';
      WHEN "001" =>
         OV <= '1';
         Z_SIGN <= '0';
      WHEN "010" =>
         OV <= '0';
         Z_SIGN <= '0';
      WHEN "011" =>
         OV <= '0';
         Z_SIGN <= '1';
      WHEN "100" =>
         OV <= '0';
         Z_SIGN <= '0';
      WHEN "101" =>
         OV <= '0';
         Z_SIGN <= '1';
      WHEN "110" =>
         OV <= '0';
         Z_SIGN <= '1';
      WHEN "111" =>
         OV <= '1';
         Z_SIGN <= '1';
      WHEN OTHERS =>
         OV <= '0';
         Z_SIGN <= '0';
      END CASE;

   END PROCESS SignLogic_truth_process;

   -- Architecture concurrent statements
    


   -- HDL Embedded Text Block 7 eb5
   -- eb5 7 
   A_in <= "00" & A_SIG(7 DOWNTO 0) & "000";

   -- HDL Embedded Text Block 8 eb6
   -- eb6 8                      
   B_in <= "00" & B_SIG(7 DOWNTO 0) & "000";

   -- HDL Embedded Text Block 9 eb7
   -- eb7 9
   EXP_isINF <= '1' WHEN (OV='1' OR Z_EXP=X"FF") ELSE '0';

   -- HDL Embedded Text Block 10 eb8
   -- eb8 10
   a_exp_in <= "0" & A_EXP;

   -- HDL Embedded Text Block 11 eb9
   -- eb9 11
   b_exp_in <= "0" & B_EXP;


   -- ModuleWare code(v1.1) for instance 'I4' of 'add'
   I4combo: PROCESS (a_inv, b_inv, cin)
   VARIABLE mw_I4t0 : std_logic_vector(13 DOWNTO 0);
   VARIABLE mw_I4t1 : std_logic_vector(13 DOWNTO 0);
   VARIABLE mw_I4sum : signed(13 DOWNTO 0);
   VARIABLE mw_I4carry : std_logic;
   BEGIN
      mw_I4t0 := a_inv(12) & a_inv;
      mw_I4t1 := b_inv(12) & b_inv;
      mw_I4carry := cin;
      mw_I4sum := signed(mw_I4t0) + signed(mw_I4t1) + mw_I4carry;
      add_out <= conv_std_logic_vector(mw_I4sum(12 DOWNTO 0),13);
   END PROCESS I4combo;

   -- ModuleWare code(v1.1) for instance 'I13' of 'mux'
   I13combo: PROCESS(mw_I13din0, mw_I13din1, mux_sel)
   VARIABLE dtemp : std_logic_vector(7 DOWNTO 0);
   BEGIN
      CASE mux_sel IS
      WHEN '0'|'L' => dtemp := mw_I13din0;
      WHEN '1'|'H' => dtemp := mw_I13din1;
      WHEN OTHERS => dtemp := (OTHERS => 'X');
      END CASE;
      EXP_base <= dtemp;
   END PROCESS I13combo;
   mw_I13din0 <= A_EXP;
   mw_I13din1 <= B_EXP;

   -- ModuleWare code(v1.1) for instance 'I7' of 'or'
   isINF <= EXP_isINF OR isINF_tab;

   -- ModuleWare code(v1.1) for instance 'I15' of 'or'
   cin <= invert_B OR invert_A;

   -- ModuleWare code(v1.1) for instance 'I17' of 'or'
   isZ <= zero OR isZ_tab;

   -- ModuleWare code(v1.1) for instance 'I3' of 'sub'
   I3combo: PROCESS (a_exp_in, b_exp_in, cin_sub)
   VARIABLE mw_I3t0 : std_logic_vector(9 DOWNTO 0);
   VARIABLE mw_I3t1 : std_logic_vector(9 DOWNTO 0);
   VARIABLE diff : signed(9 DOWNTO 0);
   VARIABLE borrow : std_logic;
   BEGIN
      mw_I3t0 := a_exp_in(8) & a_exp_in;
      mw_I3t1 := b_exp_in(8) & b_exp_in;
      borrow := cin_sub;
      diff := signed(mw_I3t0) - signed(mw_I3t1) - borrow;
      EXP_diff <= conv_std_logic_vector(diff(8 DOWNTO 0),9);
   END PROCESS I3combo;

   -- ModuleWare code(v1.1) for instance 'I16' of 'xnor'
   B_XSIGN <= NOT(B_SIGN XOR ADD_SUB);

   -- Instance port mappings.
   I8 : FPadd_normalize_b
      PORT MAP (
         EXP_in  => EXP_selC,
         SIG_in  => SIG_selC,
         EXP_out => EXP_norm,
         SIG_out => SIG_norm,
         zero    => zero
      );
   I6 : FPalign_b
      PORT MAP (
         A_in  => A_CS,
         B_in  => B_CS,
         cin   => cin_sub,
         diff  => EXP_diff,
         A_out => a_align,
         B_out => b_align
      );
   I14 : FPinvert_b
      GENERIC MAP (
         width => 13
      )
      PORT MAP (
         A_in     => a_align,
         B_in     => b_align,
         invert_A => invert_A,
         invert_B => invert_B,
         A_out    => a_inv,
         B_out    => b_inv
      );
   I11 : FPnormalize_b
      GENERIC MAP (
         SIG_width => 12
      )
      PORT MAP (
         SIG_in  => SIG_round,
         EXP_in  => EXP_round,
         SIG_out => SIG_norm2,
         EXP_out => Z_EXP
      );
   I10 : FPround_b
      GENERIC MAP (
         SIG_width => 12
      )
      PORT MAP (
         SIG_in  => SIG_norm,
         EXP_in  => EXP_norm,
         SIG_out => SIG_round,
         EXP_out => EXP_round
      );
   I12 : FPselComplement_b
      GENERIC MAP (
         SIG_width => 12
      )
      PORT MAP (
         SIG_in  => add_out,
         EXP_in  => EXP_base,
         SIG_out => SIG_selC,
         EXP_out => EXP_selC
      );
   I5 : FPswap_b
      GENERIC MAP (
         width => 13
      )
      PORT MAP (
         A_in    => A_in,
         B_in    => B_in,
         swap_AB => EXP_diff(8),
         A_out   => A_CS,
         B_out   => B_CS
      );
   I2 : PackFP_b
      PORT MAP (
         SIGN  => Z_SIGN,
         EXP   => Z_EXP,
         SIG   => Z_SIG,
         isNaN => isNaN,
         isINF => isINF,
         isZ   => isZ,
         FP    => FP_OP
      );
   I0 : UnpackFP_b
      PORT MAP (
         FP    => FP_A,
         SIG   => A_SIG,
         EXP   => A_EXP,
         SIGN  => A_SIGN,
         isNaN => A_isNaN,
         isINF => A_isINF,
         isZ   => A_isZ,
         isDN  => A_isDN
      );
   I1 : UnpackFP_b
      PORT MAP (
         FP    => FP_B,
         SIG   => B_SIG,
         EXP   => B_EXP,
         SIGN  => B_SIGN,
         isNaN => B_isNaN,
         isINF => B_isINF,
         isZ   => B_isZ,
         isDN  => B_isDN
      );

process(FP_OP,FPadd_single_b_en)
begin
	if FPadd_single_b_en = '1' then 
		FP_Z <= FP_OP;
	else
		FP_Z <= (others=>'0');
	end if;
end process;

END single_cycle;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY FPmul_b IS
   PORT( 
      FP_A : IN     std_logic_vector (15 DOWNTO 0);
      FP_B : IN     std_logic_vector (15 DOWNTO 0);
      FPmul_b_en  : IN     std_logic;
      FP_Z : OUT    std_logic_vector (15 DOWNTO 0)
   );

-- Declarations

END FPmul_b ;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ARCHITECTURE single_cycle OF FPmul_b IS

   -- Architecture declarations
      -- Non hierarchical truthtable declarations
   --SIGNAL FP_A     : std_logic_vector(31 DOWNTO 0):= "01000001110100000000000000000000";
   --SIGNAL FP_B     : std_logic_vector(31 DOWNTO 0):= "01000001011000000000000000000000";    

   signal FP_OP			: std_logic_vector(15 DOWNTO 0);

   -- Internal signal declarations
   SIGNAL A_EXP         : std_logic_vector(7 DOWNTO 0);
   SIGNAL A_SIG         : std_logic_vector(15 DOWNTO 0);
   SIGNAL A_SIGN        : std_logic;
   SIGNAL A_isINF       : std_logic;
   SIGNAL A_isNaN       : std_logic;
   SIGNAL A_isZ         : std_logic;
   SIGNAL B_EXP         : std_logic_vector(7 DOWNTO 0);
   SIGNAL B_SIG         : std_logic_vector(15 DOWNTO 0);
   SIGNAL B_SIGN        : std_logic;
   SIGNAL B_isINF       : std_logic;
   SIGNAL B_isNaN       : std_logic;
   SIGNAL B_isZ         : std_logic;
   SIGNAL EXP_addout    : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_in        : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_out       : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_out_norm  : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_out_round : std_logic_vector(7 DOWNTO 0);
   SIGNAL SIGN_out      : std_logic;
   SIGNAL SIG_in        : std_logic_vector(11 DOWNTO 0);
   SIGNAL SIG_isZ       : std_logic;
   SIGNAL SIG_out       : std_logic_vector(6 DOWNTO 0);
   SIGNAL SIG_out_norm  : std_logic_vector(11 DOWNTO 0);
   SIGNAL SIG_out_norm2 : std_logic_vector(11 DOWNTO 0);
   SIGNAL SIG_out_round : std_logic_vector(11 DOWNTO 0);
   SIGNAL dout          : std_logic;
   SIGNAL isINF         : std_logic;
   SIGNAL isINF_tab     : std_logic;
   SIGNAL isNaN         : std_logic;
   SIGNAL isZ           : std_logic;
   SIGNAL isZ_tab       : std_logic;
   SIGNAL prod          : std_logic_vector(31 DOWNTO 0);


   -- Component Declarations
   COMPONENT FPnormalize_b
   GENERIC (
      SIG_width : integer := 12
   );
   PORT (
      SIG_in  : IN     std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_in  : IN     std_logic_vector (7 DOWNTO 0);
      SIG_out : OUT    std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_out : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT FPround_b
   GENERIC (
      SIG_width : integer := 12
   );
   PORT (
      SIG_in  : IN     std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_in  : IN     std_logic_vector (7 DOWNTO 0);
      SIG_out : OUT    std_logic_vector (SIG_width-1 DOWNTO 0);
      EXP_out : OUT    std_logic_vector (7 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT PackFP_b
   PORT (
      SIGN  : IN     std_logic ;
      EXP   : IN     std_logic_vector (7 DOWNTO 0);
      SIG   : IN     std_logic_vector (6 DOWNTO 0);
      isNaN : IN     std_logic ;
      isINF : IN     std_logic ;
      isZ   : IN     std_logic ;
      FP    : OUT    std_logic_vector (15 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT UnpackFP_b
   PORT (
      FP    : IN     std_logic_vector (15 DOWNTO 0);
      SIG   : OUT    std_logic_vector (15 DOWNTO 0);
      EXP   : OUT    std_logic_vector (7 DOWNTO 0);
      SIGN  : OUT    std_logic ;
      isNaN : OUT    std_logic ;
      isINF : OUT    std_logic ;
      isZ   : OUT    std_logic ;
      isDN  : OUT    std_logic 
   );
   END COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   -- FOR ALL : FPnormalize USE ENTITY work.FPnormalize;
   -- FOR ALL : FPround USE ENTITY work.FPround;
   -- FOR ALL : PackFP USE ENTITY work.PackFP;
   -- FOR ALL : UnpackFP USE ENTITY work.UnpackFP;
   -- pragma synthesis_on


BEGIN
   -- Architecture concurrent statements
   -- HDL Embedded Text Block 1 eb1
   -- eb1 1
   SIG_in <= prod(15 DOWNTO 4);

   -- HDL Embedded Text Block 2 eb2
   -- eb2 
------------------need_to_change------------------   
   SIG_out <= SIG_out_norm2(9 DOWNTO 3);
------------------need_to_change------------------

   -- HDL Embedded Text Block 3 eb3
   -- eb3 3
   PROCESS(isZ,isINF_tab, A_EXP, B_EXP, EXP_out)
   BEGIN
      IF isZ='0' THEN
         IF isINF_tab='1' THEN
            isINF <= '1';
         ELSIF EXP_out=X"FF" THEN
            isINF <='1';
         ELSIF (A_EXP(7)='1' AND B_EXP(7)='1' AND (EXP_out(7)='0'))  THEN
            isINF <='1';
         ELSE
            isINF <= '0';
         END IF;
      ELSE
         isINF <= '0';
      END IF;
   END PROCESS;

   -- HDL Embedded Block 4 eb4
   -- Non hierarchical truthtable
   ---------------------------------------------------------------------------
   eb4_truth_process: PROCESS(A_isINF, A_isNaN, A_isZ, B_isINF, B_isNaN, B_isZ)
   ---------------------------------------------------------------------------
   BEGIN
      -- Block 1
      IF (A_isINF = '0') AND (A_isNaN = '0') AND (A_isZ = '0') AND (B_isINF = '0') AND (B_isNaN = '0') AND (B_isZ = '0') THEN
         isZ_tab <= '0';
         isINF_tab <= '0';
         isNaN <= '0';
      ELSIF (A_isINF = '1') AND (B_isZ = '1') THEN
         isZ_tab <= '0';
         isINF_tab <= '0';
         isNaN <= '1';
      ELSIF (A_isZ = '1') AND (B_isINF = '1') THEN
         isZ_tab <= '0';
         isINF_tab <= '0';
         isNaN <= '1';
      ELSIF (A_isINF = '1') THEN
         isZ_tab <= '0';
         isINF_tab <= '1';
         isNaN <= '0';
      ELSIF (B_isINF = '1') THEN
         isZ_tab <= '0';
         isINF_tab <= '1';
         isNaN <= '0';
      ELSIF (A_isNaN = '1') THEN
         isZ_tab <= '0';
         isINF_tab <= '0';
         isNaN <= '1';
      ELSIF (B_isNaN = '1') THEN
         isZ_tab <= '0';
         isINF_tab <= '0';
         isNaN <= '1';
      ELSIF (A_isZ = '1') THEN
         isZ_tab <= '1';
         isINF_tab <= '0';
         isNaN <= '0';
      ELSIF (B_isZ = '1') THEN
         isZ_tab <= '1';
         isINF_tab <= '0';
         isNaN <= '0';
      ELSE
         isZ_tab <= '0';
         isINF_tab <= '0';
         isNaN <= '0';
      END IF;

   END PROCESS eb4_truth_process;

   -- Architecture concurrent statements
    


   -- HDL Embedded Text Block 5 eb5
   -- eb5 5
   EXP_in <= (NOT EXP_addout(7)) & EXP_addout(6 DOWNTO 0);
------------------need_to_change------------------
   -- HDL Embedded Text Block 6 eb6
   -- eb6 6
   PROCESS(SIG_out_norm2,A_EXP,B_EXP, EXP_out)
   BEGIN
      IF ( EXP_out(7)='1' AND 
		    ( (A_EXP(7)='0' AND NOT (A_EXP=X"7F")) AND 
			   (B_EXP(7)='0' AND NOT (B_EXP=X"7F")) ) ) OR
         (SIG_out_norm2(10 DOWNTO 3)=X"00") THEN
         -- Underflow or zero significand
         SIG_isZ <= '1';
      ELSE
         SIG_isZ <= '0';
      END IF;
   END PROCESS;
------------------need_to_change------------------

   -- ModuleWare code(v1.1) for instance 'I4' of 'add'
   I4combo: PROCESS (A_EXP, B_EXP, dout)
   VARIABLE mw_I4t0 : std_logic_vector(8 DOWNTO 0);
   VARIABLE mw_I4t1 : std_logic_vector(8 DOWNTO 0);
   VARIABLE mw_I4sum : unsigned(8 DOWNTO 0);
   VARIABLE mw_I4carry : std_logic;
   BEGIN
      mw_I4t0 := '0' & A_EXP;
      mw_I4t1 := '0' & B_EXP;
      mw_I4carry := dout;
      mw_I4sum := unsigned(mw_I4t0) + unsigned(mw_I4t1) + mw_I4carry;
      EXP_addout <= conv_std_logic_vector(mw_I4sum(7 DOWNTO 0),8);
   END PROCESS I4combo;

   -- ModuleWare code(v1.1) for instance 'I2' of 'mult'
   I2combo : PROCESS (A_SIG, B_SIG)
   VARIABLE dtemp : unsigned(31 DOWNTO 0);
   BEGIN
      dtemp := (unsigned(A_SIG) * unsigned(B_SIG));
      prod <= std_logic_vector(dtemp);
   END PROCESS I2combo;

   -- ModuleWare code(v1.1) for instance 'I7' of 'or'
   isZ <= SIG_isZ OR isZ_tab;

   -- ModuleWare code(v1.1) for instance 'I6' of 'vdd'
   dout <= '1';

   -- ModuleWare code(v1.1) for instance 'I3' of 'xor'
   SIGN_out <= A_SIGN XOR B_SIGN;

   -- Instance port mappings.
   I9 : FPnormalize_b
      GENERIC MAP (
         SIG_width => 12
      )
      PORT MAP (
         SIG_in  => SIG_in,
         EXP_in  => EXP_in,
         SIG_out => SIG_out_norm,
         EXP_out => EXP_out_norm
      );
   I10 : FPnormalize_b
      GENERIC MAP (
         SIG_width => 12
      )
      PORT MAP (
         SIG_in  => SIG_out_round,
         EXP_in  => EXP_out_round,
         SIG_out => SIG_out_norm2,
         EXP_out => EXP_out
      );
   I11 : FPround_b
      GENERIC MAP (
         SIG_width => 12
      )
      PORT MAP (
         SIG_in  => SIG_out_norm,
         EXP_in  => EXP_out_norm,
         SIG_out => SIG_out_round,
         EXP_out => EXP_out_round
      );
   I5 : PackFP_b
      PORT MAP (
         SIGN  => SIGN_out,
         EXP   => EXP_out,
         SIG   => SIG_out,
         isNaN => isNaN,
         isINF => isINF,
         isZ   => isZ,
         FP    => FP_OP
      );
   I0 : UnpackFP_b
      PORT MAP (
         FP    => FP_A,
         SIG   => A_SIG,
         EXP   => A_EXP,
         SIGN  => A_SIGN,
         isNaN => A_isNaN,
         isINF => A_isINF,
         isZ   => A_isZ,
         isDN  => OPEN
      );
   I1 : UnpackFP_b
      PORT MAP (
         FP    => FP_B,
         SIG   => B_SIG,
         EXP   => B_EXP,
         SIGN  => B_SIGN,
         isNaN => B_isNaN,
         isINF => B_isINF,
         isZ   => B_isZ,
         isDN  => OPEN
      );

process(FP_OP,FPmul_b_en)
begin
	if FPmul_b_en = '1' then 
		FP_Z <= FP_OP;
	else
		FP_Z <= (others=>'0');
	end if;
end process;
	  
END single_cycle;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;


entity FPdiv_b is
    port (
        FP_A: in std_logic_vector(15 downto 0);
        FP_B: in std_logic_vector(15 downto 0);
		  FPdiv_b_en  : IN     std_logic;
        FP_Z: out std_logic_vector(15 downto 0)
	);   
end FPdiv_b;

architecture rtl of FPdiv_b is

	component pre_norm_div is
	port(
			 opa_i			: in std_logic_vector(15 downto 0);
			 opb_i			: in std_logic_vector(15 downto 0);
			 exp_10_o		: out std_logic_vector(9 downto 0);
			 dvdnd_18_o		: out std_logic_vector(17 downto 0); 
			 dvsor_11_o		: out std_logic_vector(10 downto 0)
		);
	end component;
	
	component serial_div is
	port(
			 dvdnd_i			: in std_logic_vector(17 downto 0);
			 dvsor_i			: in std_logic_vector(10 downto 0);
			 sign_dvd_i 		: in std_logic;
			 sign_div_i 		: in std_logic;
			 qutnt_o			: out std_logic_vector(10 downto 0);
			 sign_o 			: out std_logic
		);
	end component;	
	
	component post_norm_div is
	port(
			 opa_i				: in std_logic_vector(15 downto 0);
			 opb_i				: in std_logic_vector(15 downto 0);
			 qutnt_i			: in std_logic_vector(10 downto 0);
			 exp_10_i			: in std_logic_vector(9 downto 0);
			 sign_i				: in std_logic;
			 output_o			: out std_logic_vector(15 downto 0)
		);
	end component;	


	signal s_opa_i, s_opb_i : std_logic_vector(15 downto 0);
	signal s_infa, s_infb, FPdiv_b_done_s : std_logic:='0';

	
	signal pre_norm_div_dvdnd : std_logic_vector(17 downto 0);
	signal pre_norm_div_dvsor : std_logic_vector(10 downto 0);
	signal pre_norm_div_exp	: std_logic_vector(9 downto 0);
	
	signal serial_div_qutnt : std_logic_vector(10 downto 0);
	signal serial_div_sign : std_logic;
	signal post_norm_div_output : std_logic_vector(15 downto 0);
	
begin	

	
	i_pre_norm_div : pre_norm_div
	port map(
			 opa_i => s_opa_i,
			 opb_i => s_opb_i,
			 exp_10_o => pre_norm_div_exp,
			 dvdnd_18_o	=> pre_norm_div_dvdnd,
			 dvsor_11_o	=> pre_norm_div_dvsor);
			 
	i_serial_div : serial_div
	port map(
			 dvdnd_i => pre_norm_div_dvdnd,
			 dvsor_i => pre_norm_div_dvsor,
			 sign_dvd_i => s_opa_i(15),
			 sign_div_i => s_opb_i(15),
			 qutnt_o => serial_div_qutnt,
			 sign_o => serial_div_sign
			 );
	
	i_post_norm_div : post_norm_div
	port map(
			 opa_i => s_opa_i,
			 opb_i => s_opb_i,
			 qutnt_i =>	serial_div_qutnt,
			 exp_10_i => pre_norm_div_exp,
			 sign_i	=> serial_div_sign,
			 output_o => post_norm_div_output
			 );
		

	process(FPdiv_b_en)
	begin
		if rising_edge(FPdiv_b_en) then	
			s_opa_i <= FP_A;
			s_opb_i <= FP_B;
		end if;
	end process;
	FP_Z <= post_norm_div_output;

end rtl;