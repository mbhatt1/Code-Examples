LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY cpu IS

PORT( 

			PC : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			--PC_Plus_4 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			--Next_PC : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			Instruction_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			--ID
			Read_Data1_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			Read_Data2_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			--EX
			ALU_Input_1_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			ALU_Input_2_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			ALU_Result_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			--Add_Result_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			Branch_out : OUT STD_LOGIC;
			Branch_NE_out : OUT STD_LOGIC;
			Zero_out : OUT STD_LOGIC;
			--MEM
			MemRead_out : OUT STD_LOGIC;
			MemReadData_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			MemWrite_out : OUT STD_LOGIC;
			Mem_Address_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			MemWrite_Data_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			--WB
			RegWrite_out : OUT STD_LOGIC;
			WriteRegister_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			RegWriteData_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			--FORWARDING UNIT LINES
			EXMEM_RegWrite_out : OUT STD_LOGIC;
			EXMEM_ALU_Result_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			EXMEM_Register_Rd_out: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			MEMWB_RegWrite_out : OUT STD_LOGIC;
			MEMWB_Register_Rd_out: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			MEMWB_Read_Data_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IDEX_Register_Rs_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			IDEX_Register_Rt_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			ForwardA_out : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			ForwardB_out : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			--HAZARD DETECTION LINES
			IDEX_MemRead_out : OUT STD_LOGIC;
			
			IFID_Register_Rs_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			IFID_Register_Rt_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			STALL_out : OUT STD_LOGIC;
			HDU_RegWrite_out : OUT STD_LOGIC;
			HDU_MemWrite_out : OUT STD_LOGIC;
			--BRACH HAZARD
			IF_Flush_out : OUT STD_LOGIC;
			IF_ReadData1_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_ReadData2_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_SignExtend_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_Branch_out : OUT STD_LOGIC;
			IF_BranchNE_out : OUT STD_LOGIC;
			IF_PCPlus4_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_AddResult_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_Zero_out : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			Clock, Reset : IN STD_LOGIC);

END cpu;

ARCHITECTURE structure of cpu IS
--Declare all components/units/modules used that
--makeup the MIPS Pipelined processor.
COMPONENT Ifetch
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
			--OUTPUTS FOR branch hazard DEBUG--
			IF_ReadData1 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_ReadData2 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_SignExtend : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_Branch : OUT STD_LOGIC;
			IF_BranchNE : OUT STD_LOGIC;
			IF_PCPlus4 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_AddResult : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			IF_Zero : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			Clock, Reset : IN STD_LOGIC);
END COMPONENT;


COMPONENT Idecode
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
			-------HDU Output lines------
			IDEXMemRead_out : OUT STD_LOGIC;
			IDEXRegister_Rt_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			IFIDRegister_Rs_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			IFIDRegister_Rt_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			Branch_p : IN STD_LOGIC;
			Branch_NE_p : IN STD_LOGIC;
			Add_Result_p : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			--IF_Flush : OUT STD_LOGIC;
			Branch_pp : OUT STD_LOGIC;
			Branch_NE_pp : OUT STD_LOGIC;
			Clock, Reset : IN STD_LOGIC);
END COMPONENT;

COMPONENT control IS
		PORT( Opcode : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		RegDst_p : OUT STD_LOGIC;
		ALU_Op_p : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		ALUSrc_p : OUT STD_LOGIC;
		MemWrite_p : OUT STD_LOGIC;
		Branch_p : OUT STD_LOGIC;
		Branch_NE_p : OUT STD_LOGIC;
		MemRead_p : OUT STD_LOGIC;
		MemtoReg_p : OUT STD_LOGIC;
		RegWrite_p : OUT STD_LOGIC;
		IF_Flush : OUT STD_LOGIC;
		--HAZARD DETECTION UNIT
		IDEX_MemRead : IN STD_LOGIC;
		IDEX_Register_Rt : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		IFID_Register_Rs : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		IFID_Register_Rt : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		Stall_out : OUT STD_LOGIC;
		Clock, Reset : IN STD_LOGIC);
END COMPONENT;

COMPONENT Execute IS
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
END COMPONENT;


COMPONENT dmemory IS
		PORT( Read_Data_p : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		Address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		Write_Data : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		Read_Data_2_ppp : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		MemRead_pp : IN STD_LOGIC;
		MemWrite_pp : IN STD_LOGIC;
		MemRead_ppp : OUT STD_LOGIC;
		MemWrite_ppp : OUT STD_LOGIC;
		MemtoReg_pp : IN STD_LOGIC;
		RegWrite_pp : IN STD_LOGIC;
		MemtoReg_ppp : OUT STD_LOGIC;
		RegWrite_ppp : OUT STD_LOGIC;
		ALU_Result_p : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		ALU_Result_pp : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		Write_Address_p : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		Write_Address_pp : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
		Reg_WriteData : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		Clock, Reset : IN STD_LOGIC);
END COMPONENT;


		SIGNAL ALU_Op_p : STD_LOGIC_VECTOR (1 DOWNTO 0);
		SIGNAL Add_Result_p : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL Add_Result_pp : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL ALU_Result_p : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL ALU_Result_pp : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL ALU1 : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL ALU2 : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL ALUSrc_p : STD_LOGIC;
		SIGNAL Branch_p : STD_LOGIC;
		SIGNAL Branch_pp : STD_LOGIC;
		SIGNAL Branch_NE_p : STD_LOGIC;
		SIGNAL Branch_NE_pp : STD_LOGIC;
		SIGNAL forwardA : STD_LOGIC_VECTOR (1 DOWNTO 0);
		SIGNAL forwardB : STD_LOGIC_VECTOR (1 DOWNTO 0);
		SIGNAL Instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL Instruction_p : STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL Instruction_pp : STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL MemRead_p : STD_LOGIC;
		SIGNAL MemRead_pp : STD_LOGIC;
		SIGNAL MemRead_ppp : STD_LOGIC;
		SIGNAL MemtoReg_p : STD_LOGIC;
		SIGNAL MemtoReg_pp : STD_LOGIC;
		SIGNAL MemtoReg_ppp : STD_LOGIC;
		SIGNAL MemWrite_p : STD_LOGIC;
		SIGNAL MemWrite_pp : STD_LOGIC;
		SIGNAL MemWrite_ppp : STD_LOGIC;
		SIGNAL PC_Out : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL PC_plus_4_p : STD_LOGIC_VECTOR(7 DOWNTO 0);
		SIGNAL PC_plus_4_pp : STD_LOGIC_VECTOR(7 DOWNTO 0);
		SIGNAL NXT_PC : STD_LOGIC_VECTOR(7 DOWNTO 0);
		SIGNAL Read_Data_1_p : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL Read_Data_2_p : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL Read_Data_p : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL Read_Data_2_pp : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL Read_Data_2_ppp : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL RegDst_p : STD_LOGIC;
		SIGNAL RegWrite_p : STD_LOGIC;
		SIGNAL RegWrite_pp : STD_LOGIC;
		SIGNAL RegWrite_ppp : STD_LOGIC;
		SIGNAL RegWriteOut : STD_LOGIC;
		SIGNAL RegWriteData : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL Reg_WriteData : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL Sign_Extend_p : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL Write_Address_0_p : STD_LOGIC_VECTOR (4 DOWNTO 0); --Rd
		SIGNAL Write_Address_1_p : STD_LOGIC_VECTOR (4 DOWNTO 0); --Rt
		SIGNAL Write_Address_2_p : STD_LOGIC_VECTOR (4 DOWNTO 0); --Rs
		SIGNAL Write_Address_p : STD_LOGIC_VECTOR (4 DOWNTO 0);
		SIGNAL Write_Address_pp : STD_LOGIC_VECTOR (4 DOWNTO 0);
		SIGNAL Write_Address_ppp : STD_LOGIC_VECTOR (4 DOWNTO 0);
		SIGNAL Zero_p : STD_LOGIC;
		---FORWARDING UNIT SIGNALS
		SIGNAL EXMEMRegWrite : STD_LOGIC;
		SIGNAL EXMEMALU_Result : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL EXMEMRegister_Rd : STD_LOGIC_VECTOR (4 DOWNTO 0);
		SIGNAL MEMWBRegWrite : STD_LOGIC;
		SIGNAL MEMWBRegister_Rd : STD_LOGIC_VECTOR (4 DOWNTO 0);
		SIGNAL MEMWBRead_Data : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL IDEXRegister_Rs : STD_LOGIC_VECTOR (4 DOWNTO 0);
		SIGNAL IDEXRegister_Rt : STD_LOGIC_VECTOR (4 DOWNTO 0);
		SIGNAL STALLout : STD_LOGIC;
		SIGNAL IDEXMemRead_out : STD_LOGIC;
		SIGNAL IDEXRegister_Rt_out : STD_LOGIC_VECTOR (4 DOWNTO 0);
		SIGNAL IFIDRegister_Rs_out : STD_LOGIC_VECTOR (4 DOWNTO 0);
		SIGNAL IFIDRegister_Rt_out : STD_LOGIC_VECTOR (4 DOWNTO 0);
		SIGNAL StallInstruction : STD_LOGIC_VECTOR (31 DOWNTO 0);
		--BRANCH HAZARD
		SIGNAL IF_Flush : STD_LOGIC;
		SIGNAL IF_Flush_p : STD_LOGIC;
		SIGNAL IF_Flush_pp : STD_LOGIC;
		SIGNAL IF_Flush_ppp : STD_LOGIC;
		SIGNAL IF_ReadData1 : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL IF_ReadData2 : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL IF_SignExtend : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL IF_Branch : STD_LOGIC;
		SIGNAL IF_BranchNE : STD_LOGIC;
		SIGNAL IF_PCPlus4 : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL IF_AddResult : STD_LOGIC_VECTOR (7 DOWNTO 0);
		SIGNAL IF_Zero : STD_LOGIC_VECTOR (7 DOWNTO 0);


		BEGIN
		--Signals to assign to output pins for SIMULATOR
		Instruction_out <= Instruction;
		PC <= PC_Out;
		--PC_Plus_4 <= PC_plus_4_p;
		--Next_PC <= NXT_PC;
		Read_Data1_out <= Read_Data_1_p;
		Read_Data2_out <= Read_Data_2_p;
		ALU_Input_1_out <= ALU1;
		ALU_Input_2_out <= ALU2;
		ALU_Result_out <= ALU_Result_p;
		--Add_Result_out <= Add_Result_p;
		Zero_out <= Zero_p;
		MemRead_out <= MemRead_ppp;
		MemReadData_out <= Read_Data_p WHEN MemRead_ppp = '1' ELSE "00000000";
		MemWrite_out <= MemWrite_ppp;
		Mem_Address_out <= ALU_Result_pp WHEN MemRead_ppp = '1'
		OR MemWrite_ppp = '1' ELSE "00000000";
		MemWrite_Data_out <= Read_Data_2_ppp WHEN MemWrite_ppp = '1' ELSE "00000000";
		RegWrite_out <= '0' WHEN Write_Address_ppp = "00000" ELSE RegWriteOut;
		WriteRegister_out <= Write_Address_ppp;
		RegWriteData_out <= RegWriteData;
		--FORWARDING UNIT LINES
		EXMEM_RegWrite_out <= EXMEMRegWrite;
		EXMEM_ALU_Result_out <= EXMEMALU_Result;
		EXMEM_Register_Rd_out<= EXMEMRegister_Rd;
		MEMWB_RegWrite_out <= MEMWBRegWrite;
		MEMWB_Register_Rd_out<= MEMWBRegister_Rd;
		MEMWB_Read_Data_out <= MEMWBRead_Data;
		IDEX_Register_Rs_out <= IDEXRegister_Rs;
		IDEX_Register_Rt_out <= IDEXRegister_Rt;
		ForwardA_out <= forwardA;
		ForwardB_out <= forwardB;
		--HAZARD DETECTION LINES
		IDEX_MemRead_out <= IDEXMemRead_out;
		--IDEX_Register_Rt_out <= IDEXRegister_Rt_out;
		IFID_Register_Rs_out <= IFIDRegister_Rs_out;
		IFID_Register_Rt_out <= IFIDRegister_Rt_out;
		STALL_out <= STALLout;
		StallInstruction <= Instruction WHEN STALLout = '0' ELSE Instruction_pp;
		HDU_RegWrite_out <= RegWrite_p;
		HDU_MemWrite_out <= MemWrite_p;
		--BRANCH HAZARD
		IF_Flush_out <= IF_Flush_p;
		Branch_out <= Branch_p;
		Branch_NE_out <= Branch_NE_p;
		IF_ReadData1_out <= IF_ReadData1;
		IF_ReadData2_out <= IF_ReadData2;
		IF_SignExtend_out <= IF_SignExtend;
		IF_Branch_out <= IF_Branch;
		IF_BranchNE_out <= IF_BranchNE;
		IF_PCPlus4_out <= IF_PCPlus4;
		IF_AddResult_out <= IF_AddResult;
		IF_Zero_out <= IF_Zero;
		
		--Connect the MIPS Components
IFE : Ifetch PORT MAP (
		PC_Out => PC_Out,
		Instruction_p => Instruction,
		PC_plus_4_p => PC_plus_4_p,
		NXT_PC => NXT_PC,
		Stall => STALLout,
		--BRANCH HAZARD
		Read_Data_1 => Read_Data_1_p,
		Read_Data_2 => Read_Data_2_p,
		Sign_Extend => Sign_Extend_p,
		Branch => Branch_p,
		Branch_NE => Branch_NE_p,
		PC_plus_4 => PC_plus_4_p,
		IFFlush => IF_Flush,
		IFFlush_p => IF_Flush_p,
		IFFlush_pp => IF_Flush_p,
		IFFlush_ppp => IF_Flush_ppp,
		IF_ReadData1 => IF_ReadData1,
		IF_ReadData2 => IF_ReadData2,
		IF_SignExtend => IF_SignExtend,
		IF_Branch => IF_Branch,
		IF_BranchNE => IF_BranchNE,
		IF_PCPlus4 => IF_PCPlus4,
		IF_AddResult => IF_AddResult,
		IF_Zero => IF_Zero,
		Clock => Clock,
		Reset => Reset );
		
ID : Idecode PORT MAP (
		Read_Data_1_p => Read_Data_1_p,
		Read_Data_2_p => Read_Data_2_p,
		Write_Data => Reg_WriteData,
		RegWrite_ppp => RegWrite_ppp,
		RegWriteOut => RegWriteOut,
		Write_Address_pp => Write_Address_pp,
		Write_Address_ppp => Write_Address_ppp,
		Read_Data_p => Read_Data_p,
		MemtoReg_ppp => MemtoReg_ppp,
		ALU_Result_pp => ALU_Result_pp,
		Instruction_p => StallInstruction,
		Sign_Extend_p => Sign_Extend_p,
		Write_Address_0_p => Write_Address_0_p,
		Write_Address_1_p => Write_Address_1_p,
		Write_Address_2_p => Write_Address_2_p,
		RegWriteData => RegWriteData,
		Instruction_pp => Instruction_pp,
		PC_plus_4_p => PC_plus_4_p,
		PC_plus_4_pp => PC_plus_4_pp,
		--HAZARD DETECTION UNIT
		IDEX_MemRead => MemRead_p,
		IDEX_Register_Rt => Write_Address_0_p,
		IFID_Register_Rs => Instruction (25 DOWNTO 21), --Rs
		IFID_Register_Rt => Instruction (20 DOWNTO 16), --Rt
		-------HDU Output lines------
		IDEXMemRead_out => IDEXMemRead_out,
		IDEXRegister_Rt_out => IDEXRegister_Rt_out,
		IFIDRegister_Rs_out => IFIDRegister_Rs_out,
		IFIDRegister_Rt_out => IFIDRegister_Rt_out,
		--BRANCH HAZARDS
		Branch_p => Branch_p,
		Branch_NE_p => Branch_NE_p,
		Branch_pp => Branch_pp,
		Branch_NE_pp => Branch_NE_pp,
		Clock => Clock,
		Reset => Reset );

CTRL : control PORT MAP (
		Opcode => Instruction (31 DOWNTO 26),
		RegDst_p => RegDst_p,
		ALU_Op_p => ALU_Op_p,
		ALUSrc_p => ALUSrc_p,
		MemWrite_p => MemWrite_p,
		Branch_p => Branch_p,
		Branch_NE_p => Branch_NE_p,
		MemRead_p => MemRead_p,
		MemtoReg_p => MemtoReg_p,
		RegWrite_p => RegWrite_p,
		IF_Flush => IF_Flush,
		--HAZARD DETECTION UNIT
		IDEX_MemRead => MemRead_p,
		IDEX_Register_Rt => Write_Address_0_p,
		IFID_Register_Rs => Instruction (25 DOWNTO 21), --Rs
		IFID_Register_Rt => Instruction (20 DOWNTO 16), --Rt
		Stall_out => STALLout,
		Clock => Clock,
		Reset => Reset);
		
EX : Execute PORT MAP (
		Read_Data_1 => Read_Data_1_p,
		Read_Data_2 => Read_Data_2_p,
		Sign_Extend_p => Sign_Extend_p,
		ALUSrc_p => ALUSrc_p,
		Zero_p => Zero_p,
		ALU_Result_p => ALU_Result_p,
		Funct_field => Instruction_pp (5 DOWNTO 0),
		ALU_Op_p => ALU_Op_p,
		PC_plus_4_pp => PC_plus_4_pp,
		RegDst_p => RegDst_p,
		Write_Address_0_p => Write_Address_0_p,
		Write_Address_1_p => Write_Address_1_p,
		Write_Address_p => Write_Address_p,
		MemtoReg_p => MemtoReg_p,
		MemtoReg_pp => MemtoReg_pp,
		Read_Data_2_pp => Read_Data_2_pp,
		MemRead_p => MemRead_p,
		RegWrite_p => RegWrite_p,
		MemRead_pp => MemRead_pp,
		RegWrite_pp => RegWrite_pp,
		MemWrite_p => MemWrite_p,
		MemWrite_pp => MemWrite_pp,
		EXMEM_RegWrite => RegWrite_pp,
		EXMEM_ALU_Result => ALU_Result_p,
		EXMEM_Register_Rd => Write_Address_p,
		MEMWB_RegWrite => RegWrite_ppp,
		MEMWB_Register_Rd => Write_Address_pp,
		MEMWB_Read_Data => Reg_WriteData,
		IDEX_Register_Rs => Write_Address_2_p,
		IDEX_Register_Rt => Write_Address_0_p,
		ALU1 => ALU1,
		ALU2 => ALU2,
		forwardA => forwardA,
		forwardB => forwardB,
		EXMEMRegWrite => EXMEMRegWrite,
		EXMEMALU_Result => EXMEMALU_Result,
		EXMEMRegister_Rd => EXMEMRegister_Rd,
		MEMWBRegWrite => MEMWBRegWrite,
		MEMWBRegister_Rd => MEMWBRegister_Rd,
		MEMWBRead_Data => MEMWBRead_Data,
		IDEXRegister_Rs => IDEXRegister_Rs,
		IDEXRegister_Rt => IDEXRegister_Rt,
		Clock => Clock,
		Reset => Reset );
		
MEM : dmemory PORT MAP (
		Read_Data_p => Read_Data_p,
		Address => ALU_Result_p,
		Write_Data => Read_Data_2_pp,
		Read_Data_2_ppp => Read_Data_2_ppp,
		MemRead_pp => MemRead_pp,
		MemWrite_pp => MemWrite_pp,
		MemRead_ppp => MemRead_ppp,
		MemWrite_ppp => MemWrite_ppp,
		MemtoReg_pp => MemtoReg_pp,
		RegWrite_pp => RegWrite_pp,
		MemtoReg_ppp => MemtoReg_ppp,
		RegWrite_ppp => RegWrite_ppp,
		ALU_Result_p => ALU_Result_p,
		ALU_Result_pp => ALU_Result_pp,
		Write_Address_p => Write_Address_p,
		Write_Address_pp => Write_Address_pp,
		Reg_WriteData => Reg_WriteData,
		Clock => Clock,
		Reset => Reset);

END structure;
