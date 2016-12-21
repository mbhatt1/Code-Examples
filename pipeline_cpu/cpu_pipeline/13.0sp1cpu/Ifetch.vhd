LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
ENTITY Ifetch IS
PORT( PC_Out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			Instruction_p : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			PC_plus_4_p : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			NXT_PC : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			Stall : IN STD_LOGIC;
			--BRANCH HAZARD
			Read_Data_1 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			Read_Data_2 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			Sign_Extend : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			Branch : IN STD_LOGIC;
			Branch_NE : IN STD_LOGIC;
			PC_plus_4 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			IFFlush : IN STD_LOGIC;
			IFFlush_p : OUT STD_LOGIC;
			IFFlush_pp : IN STD_LOGIC;
			IFFlush_ppp : OUT STD_LOGIC;
			--OUTPUTS 
			IF_ReadData1 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_ReadData2 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_SignExtend : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_Branch : OUT STD_LOGIC;
			IF_BranchNE : OUT STD_LOGIC;
			IF_PCPlus4 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_AddResult : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_Zero : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			Clock, Reset : IN STD_LOGIC);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
			SIGNAL PC : STD_LOGIC_VECTOR (9 DOWNTO 0);
			SIGNAL PCplus4 : STD_LOGIC_VECTOR (9 DOWNTO 0);
			SIGNAL Next_PC : STD_LOGIC_VECTOR (7 DOWNTO 0);
			SIGNAL Instruction : STD_LOGIC_VECTOR (31 DOWNTO 0);
			SIGNAL zero : STD_LOGIC_VECTOR (7 DOWNTO 0);
			SIGNAL add_result : STD_LOGIC_VECTOR (7 DOWNTO 0);
BEGIN

inst_memory: altsyncram
GENERIC MAP (
			operation_mode => "ROM",
			width_a => 32,
			widthad_a => 8,
			lpm_type => "altsyncram",
			outdata_reg_a => "UNREGISTERED",
			--init_file => "program.mif",
			--init_file => "pipelining_example.mif",
			--init_file => "hazard_stalling_example.mif",
			init_file => "branch_hazard_detection_example.mif",
			--init_file => "forwarding_example.mif",
			intended_device_family => "Cyclone")


	
	
PORT MAP (

		address_a => PC (9 DOWNTO 2),
		q_a => Instruction,
		clock0 => clock );


		PC_Out <= PC (7 DOWNTO 0);
		NXT_PC <= Next_PC;
		-- Adder
		PCplus4 (9 DOWNTO 2) <= PC (9 DOWNTO 2) + 1;
		PCplus4 (1 DOWNTO 0) <= "00";
		--New Branch Compare 
		zero <= Read_Data_1 (7 DOWNTO 0) XOR Read_Data_2 (7 DOWNTO 0);
		add_result <= PC_plus_4 (7 DOWNTO 2) + Sign_Extend (7 DOWNTO 0);
		-- Mux 
		Next_PC <= add_result WHEN ( IFFlush_pp = '1' AND ( zero = "00000000" )
									AND ( Branch = '1') ) OR ( IFFlush_pp = '1'
									AND ( zero /= "00000000" ) AND ( Branch_NE = '1') )
						ELSE PCplus4 (9 DOWNTO 2);
			IF_ReadData1 <= Read_Data_1;
			IF_ReadData2 <= Read_Data_2;
			IF_SignExtend <= Sign_Extend;
			IF_Branch <= Branch;
			IF_BranchNE <= Branch_NE;
			IF_PCPlus4 <= PC_plus_4;
			IF_AddResult <= add_result;
			IF_Zero <= zero;
			IFFlush_p <= IFFlush;

			--Branch Flushing Unit to flush IF/ID Pipeline Register
			Instruction_p <= "00000000000000000000000000000000"
			WHEN (Reset = '1')
						OR ( IFFlush_pp = '1' AND ( zero = "00000000" )
						AND ( Branch = '1') ) OR ( IFFlush_pp = '1'
						AND ( zero /= "00000000" ) AND ( Branch_NE = '1') )
			ELSE Instruction;
PROCESS
			BEGIN
				WAIT UNTIL ( Clock'EVENT ) AND ( Clock = '1' );
				IF Reset = '1' THEN
						PC <= "0000000000";
						PC_plus_4_p <= "00000000";
						IFFlush_ppp <= '0';
				ELSE
				IF (Stall = '1') THEN
				
				ELSE
						PC (9 DOWNTO 2) <= Next_PC (7 DOWNTO 0);
						PC_plus_4_p <= PCplus4 (7 DOWNTO 0);
						
				IF ( IFFlush_pp = '1' AND ( zero = "00000000" )
						AND ( Branch = '1') ) OR
						( IFFlush_pp = '1' AND ( zero /= "00000000" )
						AND ( Branch_NE = '1') ) 
				THEN
							IFFlush_ppp <= '1';
				ELSE
						IFFlush_ppp <= '0';
				END IF;
				END IF;
				END IF;
END PROCESS;
END behavior;
