LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
ENTITY Execute IS
		PORT( Read_Data_1 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		Read_Data_2 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		Sign_Extend_p : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		ALUSrc_p : IN STD_LOGIC;
		Zero_p : OUT STD_LOGIC;
		ALU_Result_p : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		Funct_field : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		ALU_Op_p : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		PC_plus_4_pp : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		RegDst_p : IN STD_LOGIC;
		Write_Address_0_p : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		Write_Address_1_p : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		Write_Address_p : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
		MemtoReg_p : IN STD_LOGIC;
		MemtoReg_pp : OUT STD_LOGIC;
		Read_Data_2_pp : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		MemRead_p : IN STD_LOGIC;
		RegWrite_p : IN STD_LOGIC;
		MemRead_pp : OUT STD_LOGIC;
		RegWrite_pp : OUT STD_LOGIC;
		MemWrite_p : IN STD_LOGIC;
		MemWrite_pp : OUT STD_LOGIC;
		--FORWARDING UNIT SIGNALS
		EXMEM_RegWrite : IN STD_LOGIC;
		EXMEM_ALU_Result : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		EXMEM_Register_Rd : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		MEMWB_RegWrite : IN STD_LOGIC;
		MEMWB_Register_Rd : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		MEMWB_Read_Data : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		IDEX_Register_Rs : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		IDEX_Register_Rt : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		ALU1 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		ALU2 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		forwardA : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		forwardB : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		EXMEMRegWrite : OUT STD_LOGIC;
		EXMEMALU_Result : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		EXMEMRegister_Rd : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
		MEMWBRegWrite : OUT STD_LOGIC;
		MEMWBRegister_Rd : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
		MEMWBRead_Data : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		IDEXRegister_Rs : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
		IDEXRegister_Rt : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
		Clock, Reset : IN STD_LOGIC);
END Execute;


ARCHITECTURE behavior of Execute IS
			SIGNAL A_input, B_input, Binput : STD_LOGIC_VECTOR (7 DOWNTO 0);
			SIGNAL ALU_output : STD_LOGIC_VECTOR (7 DOWNTO 0);
			SIGNAL ALU_Control : STD_LOGIC_VECTOR (2 DOWNTO 0);
			--PIPELINED SIGNALS
			SIGNAL ALU_Result : STD_LOGIC_VECTOR (7 DOWNTO 0);
			SIGNAL Zero : STD_LOGIC;
			SIGNAL Write_Address : STD_LOGIC_VECTOR (4 DOWNTO 0);
			--FORWARDING SIGNALS
			SIGNAL Forward_A, Forward_B : STD_LOGIC_VECTOR (1 DOWNTO 0);
BEGIN
--FORWARDING UNIT PART II

PROCESS (EXMEM_RegWrite, EXMEM_ALU_Result, EXMEM_Register_Rd, MEMWB_RegWrite,
		MEMWB_Register_Rd, MEMWB_Read_Data, IDEX_Register_Rs, IDEX_Register_Rt)


BEGIN
-- Forward A
		IF ( (MEMWB_RegWrite = '1') AND
		(MEMWB_Register_Rd /= "00000") AND
		(EXMEM_Register_Rd /= IDEX_Register_Rs) AND
		(MEMWB_Register_Rd = IDEX_Register_Rs) ) THEN
		Forward_A <= "01"; --MEM HAZARD
		ELSIF ( (EXMEM_RegWrite = '1') AND
		(EXMEM_Register_Rd /= "00000") AND
		(EXMEM_Register_Rd = IDEX_Register_Rs) ) THEN
		Forward_A <= "10"; --EX HAZARD
		ELSE
		Forward_A <= "00"; --NO HAZARD
		END IF;
		-- Forward B
		IF ( (MEMWB_RegWrite = '1') AND
		(MEMWB_Register_Rd /= "00000") AND
		(EXMEM_Register_Rd /= IDEX_Register_Rt) AND
		(MEMWB_Register_Rd = IDEX_Register_Rt) ) THEN
		Forward_B <= "01"; --MEM HAZARD
		ELSIF ( (EXMEM_RegWrite = '1') AND
		(EXMEM_Register_Rd /= "00000") AND
		(EXMEM_Register_Rd = IDEX_Register_Rt) ) THEN
		Forward_B <= "10"; --EX HAZARD
		ELSE
		Forward_B <= "00"; --NO HAZARD
		END IF;
END PROCESS;

-- Mux for A Input
			WITH Forward_A SELECT
			A_input <= Read_Data_1 WHEN "00",
			MEMWB_Read_Data WHEN "01",
			EXMEM_ALU_Result WHEN "10",
			"11111111" WHEN others;
			-- Mux for B Input
			WITH Forward_B SELECT
			Binput <= Read_Data_2 WHEN "00",
			MEMWB_Read_Data WHEN "01",
			EXMEM_ALU_Result WHEN "10",
			"11111111" WHEN others;
			--ALU Input MUX -- Need to Allow ALUSrc to Select Sign_Extend or from ForwardB Mux
			B_input <= (Sign_Extend_p (7 DOWNTO 0)) WHEN (ALUSrc_p = '1') ELSE Binput;
			--ALU Control Bits
			ALU_Control(2) <= ( Funct_field(1) AND ALU_Op_p(1) ) OR ALU_Op_p(0);
			ALU_Control(1) <= ( NOT Funct_field(2) ) OR ( NOT ALU_Op_p(1) );
			ALU_Control(0) <= ( Funct_field(1) AND Funct_field(3) AND ALU_Op_p(1) ) OR
			( Funct_field(0) AND Funct_field(2) AND ALU_Op_p(1) );
			--Set ALU_Zero
			Zero <= '1' WHEN ( ALU_output (7 DOWNTO 0) = "00000000") ELSE '0';
			--Register File : Write Address
			Write_Address <= Write_Address_0_p WHEN RegDst_p = '0' ELSE Write_Address_1_p;
			--ALU Output: Must check for SLT instruction and set correct ALU_output
			ALU_Result <= "0000000" & ALU_output (7) WHEN ALU_Control = "111"
			ELSE ALU_output (7 DOWNTO 0);
			--Compute the ALU_output use the ALU_Control signals
			PROCESS (ALU_Control, A_input, B_input)
			BEGIN --ALU Operation
			CASE ALU_Control IS
			--Function: A_input AND B_input
			WHEN "000" => ALU_output <= A_input AND B_input;
			--Function: A_input OR B_input
			WHEN "001" => ALU_output <= A_input OR B_input;
			--Function: A_input ADD B_input
			WHEN "010" => ALU_output <= A_input + B_input;
			--Function: A_input ? B_input
			WHEN "011" => ALU_output <= "00000000";
			--Function: A_input ? B_input
			WHEN "100" => ALU_output <= "00000000";
			--Function: A_input ? B_input
			WHEN "101" => ALU_output <= "00000000";
			--Function: A_input SUB B_input
			WHEN "110" => ALU_output <= A_input - B_input;
			--Function: SLT (set less than)
			WHEN "111" => ALU_output <= A_input - B_input;
			WHEN OTHERS => ALU_output <= "00000000";
			END CASE;
END PROCESS;

PROCESS
BEGIN
			WAIT UNTIL(Clock'EVENT) AND (Clock = '1');
			IF Reset = '1' THEN
			Zero_p <= '0';
			ALU_Result_p <= "00000000";
			Write_Address_p <= "00000";
			MemtoReg_pp <= '0';
			RegWrite_pp <= '0';
			Read_Data_2_pp <= "00000000";
			MemRead_pp <= '0';
			MemWrite_pp <= '0';
			ELSE
			Zero_p <= Zero;
			ALU_Result_p <= ALU_Result;
			Write_Address_p <= Write_Address;
			MemtoReg_pp <= MemtoReg_p;
			Read_Data_2_pp <= Read_Data_2;
			MemRead_pp <= MemRead_p;
			RegWrite_pp <= RegWrite_p;
			MemWrite_pp <= MemWrite_p;
			ALU1 <= A_input;
			ALU2 <= B_input;
			forwardA <= Forward_A;
			forwardB <= Forward_B;
			EXMEMRegWrite <= EXMEM_RegWrite;
			EXMEMALU_Result <= EXMEM_ALU_Result;
			EXMEMRegister_Rd <= EXMEM_Register_Rd;
			MEMWBRegWrite <= MEMWB_RegWrite;
			MEMWBRegister_Rd <= MEMWB_Register_Rd;
			MEMWBRead_Data <= MEMWB_Read_Data;
			IDEXRegister_Rs <= IDEX_Register_Rs;
			IDEXRegister_Rt <= IDEX_Register_Rt;
			END IF;
	END PROCESS;
END behavior;
