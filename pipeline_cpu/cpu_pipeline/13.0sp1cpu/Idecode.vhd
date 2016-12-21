LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY Idecode IS
PORT ( 
			Read_Data_1_p : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			Read_Data_2_p : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			Write_Data : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			RegWrite_ppp : IN STD_LOGIC;
			RegWriteOut : OUT STD_LOGIC;
			Write_Address_pp : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			Write_Address_ppp : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			Read_Data_p : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			MemtoReg_ppp : IN STD_LOGIC;
			ALU_Result_pp : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			Instruction_p : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Sign_Extend_p : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			Write_Address_0_p : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			Write_Address_1_p : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			Write_Address_2_p : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			RegWriteData : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			Instruction_pp : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			PC_plus_4_p : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			PC_plus_4_pp : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			--HAZARD DETECTION UNIT
			IDEX_MemRead : IN STD_LOGIC;
			IDEX_Register_Rt : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			IFID_Register_Rs : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			IFID_Register_Rt : IN STD_LOGIC_VECTOR (4 DOWNTO 0);

			IDEXMemRead_out : OUT STD_LOGIC;
			IDEXRegister_Rt_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			IFIDRegister_Rs_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			IFIDRegister_Rt_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			Branch_p : IN STD_LOGIC;
			Branch_NE_p : IN STD_LOGIC;
			Add_Result_p : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);

			Branch_pp : OUT STD_LOGIC;
			Branch_NE_pp : OUT STD_LOGIC;
			Clock, Reset : IN STD_LOGIC);
END Idecode;


ARCHITECTURE behavior OF Idecode IS

	TYPE register_file IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL register_array : register_file;
	SIGNAL read_register_address1 : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL read_register_address2 : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL instruction_15_0 : STD_LOGIC_VECTOR (15 DOWNTO 0);
	--PIPELINE
	SIGNAL write_register_address0: STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL write_register_address1: STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL write_register_address2: STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL sign_extend : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL read_data_1 : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL read_data_2 : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL writedata : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL instruction : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL write_address : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL stall : STD_LOGIC;
	SIGNAL Branch_Add, ADD_Result : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL ifflush : STD_LOGIC;
	SIGNAL bne : STD_LOGIC;
	SIGNAL result : STD_LOGIC_VECTOR (7 DOWNTO 0);
BEGIN
	--Copy Instruction bits to signals
	read_register_address1 <= Instruction_p (25 DOWNTO 21); --Rs
	read_register_address2 <= Instruction_p (20 DOWNTO 16); --Rt
	write_register_address0 <= Instruction_p (20 DOWNTO 16); --Rt
	write_register_address1 <= Instruction_p (15 DOWNTO 11); --Rd
	write_register_address2 <= Instruction_p (25 DOWNTO 21); --Rs
	instruction_15_0 <= Instruction_p (15 DOWNTO 0);
	bne <= Branch_NE_p;
	--Register File: Read_Data_1 Output
	read_data_1 <= register_array(CONV_INTEGER(read_register_address1 (4 DOWNTO 0)));
	--Register File: Read_Data_2 Output
	read_data_2 <= register_array(CONV_INTEGER(read_register_address2 (4 DOWNTO 0)));
	--Sign Extend
	--NOTE: Due to 8-bit data width design
	--No sign extension is NEEDED
	sign_extend <= instruction_15_0 (7 DOWNTO 0);
	--Register File: MUX to select Write Register Data
	writedata <= Read_Data_p WHEN MemtoReg_ppp = '1' ELSE ALU_Result_pp;
	--Copy Instruction
	instruction <= Instruction_p;
	--Process to ensure writes happen on 1st half of clock cycle
PROCESS (Clock, Reset)
BEGIN
	IF (Reset = '1') THEN
	--Reset Registers own Register Number
	FOR i IN 0 TO 31 LOOP
	register_array(i) <= CONV_STD_LOGIC_VECTOR(i,8);
	END LOOP;
	ELSIF (Clock'EVENT AND Clock='0') THEN
	--Write Register File if RegWrite signal asserted
	IF ((RegWrite_ppp = '1') AND (Write_Address_pp /= "00000")) THEN
	register_array(CONV_INTEGER(Write_Address_pp (4 DOWNTO 0)))
	<= writedata;
	END IF;
	END IF;
END PROCESS;
	--Process to ensure read happen on 2nd half of clock cycle
	PROCESS
	BEGIN
	WAIT UNTIL ( Clock'EVENT AND Clock = '1');
	IF Reset = '1' THEN
	Read_Data_1_p <= "00000000";
	Read_Data_2_p <= "00000000";
	Sign_Extend_p <= "00000000";
	Write_Address_0_p <= "00000";
	Write_Address_1_p <= "00000";
	Write_Address_2_p <= "00000";
	RegWriteData <= "00000000";
	Instruction_pp <= "00000000000000000000000000000000";
	Write_Address_ppp <= "00000";
	RegWriteOut <= '0';
	PC_plus_4_pp <= "00000000";
	ELSE
	Read_Data_1_p <= read_data_1;
	Read_Data_2_p <= read_data_2;
	Sign_Extend_p <= sign_extend;
	Write_Address_0_p <= write_register_address0;
	Write_Address_1_p <= write_register_address1;
	Write_Address_2_p <= write_register_address2;
	RegWriteData <= writedata;
	Instruction_pp <= Instruction_p;
	Write_Address_ppp <= Write_Address_pp;
	RegWriteOut <= RegWrite_ppp;
	PC_plus_4_pp <= PC_plus_4_p;
	----HAZARD DETECTION UNIT OUTPUT LINES----
	IDEXMemRead_out <= IDEX_MemRead;
	IDEXRegister_Rt_out <= IDEX_Register_Rt;
	IFIDRegister_Rs_out <= IFID_Register_Rs;
	IFIDRegister_Rt_out <= IFID_Register_Rt;
	---BRANCH HAZARD
	Branch_pp <= Branch_p;
	Branch_NE_pp <= Branch_NE_p;
	END IF;
	END PROCESS;
END behavior;