LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
ENTITY control IS
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
END control;

ARCHITECTURE behavior OF control IS
		SIGNAL R_format, LW, SW, BEQ, BNE, ADDI : STD_LOGIC;
		SIGNAL Opcode_Out : STD_LOGIC_VECTOR (5 DOWNTO 0);
		SIGNAL ifflush : STD_LOGIC;
		--PIPELINED SIGNAL
		--EX
		SIGNAL RegDst, ALU_Op0, ALU_Op1, ALUSrc : STD_LOGIC;
		--MEM
		SIGNAL Branch, Branch_NE, MemWrite, MemRead : STD_LOGIC;
		--WB
		SIGNAL MemtoReg, RegWrite : STD_LOGIC;
		--HDU
		SIGNAL stall : STD_LOGIC;
BEGIN
		--Decode the Instruction OPCode to determine type
		--and set all corresponding control signals &
		--ALUOP function signals.
		R_format <= '1' WHEN Opcode = "000000" ELSE '0';
		LW <= '1' WHEN Opcode = "100011" ELSE '0';
		SW <= '1' WHEN Opcode = "101011" ELSE '0';
		BEQ <= '1' WHEN Opcode = "000100" ELSE '0';
		BNE <= '1' WHEN Opcode = "000101" ELSE '0';
		ADDI <= '1' WHEN Opcode = "001000" ELSE '0';
		--EX
		RegDst <= R_format;
		ALU_Op1 <= R_format;
		ALU_Op0 <= BEQ OR BNE;
		ALUSrc <= LW OR SW OR ADDI;
		--MEM
		Branch <= BEQ;
		Branch_NE <= BNE;
		ifflush <= BEQ OR BNE;
		MemRead <= LW;
		MemWrite <= SW;
		--WB
		MemtoReg <= LW;
		RegWrite <= R_format OR LW OR ADDI;

		--HAZARD DETECTION UNIT
G1: PROCESS
BEGIN
--DETECT A LOAD/USE HAZARD 
		WAIT UNTIL ( Clock'EVENT ) AND ( Clock = '1' );
		IF ( (IDEX_MemRead = '1') AND((IDEX_Register_Rt = IFID_Register_Rs) OR(IDEX_Register_Rt = IFID_Register_Rt))) THEN
		stall <= '1'; 
		ELSE
		stall <= '0'; --NO HAZARD
		END IF;
END PROCESS;

G2: PROCESS

BEGIN
		WAIT UNTIL ( Clock'EVENT ) AND ( Clock = '1' );
		IF (Reset = '1' OR stall = '1') THEN
		--WB
		MemtoReg_p <= '0';
		RegWrite_p <= '0';
		--Mem
		MemWrite_p <= '0';
		MemRead_p <= '0';
		Branch_p <= '0';
		Branch_NE_p <= '0';
		--EX
		RegDst_p <= '0';
		ALU_Op_p(1) <= '0';
		ALU_Op_p(0) <= '0';
		ALUSrc_p <= '0';
		IF_Flush <= '0';
		--HDU
		Stall_out <= stall;
		ELSE
		--WB
		MemtoReg_p <= MemtoReg;
		RegWrite_p <= RegWrite;
		--Mem
		MemWrite_p <= MemWrite;
		MemRead_p <= MemRead;
		Branch_p <= Branch;
		Branch_NE_p <= Branch_NE;
		--EX
		RegDst_p <= RegDst;
		ALU_Op_p(1) <= ALU_Op1;
		ALU_Op_p(0) <= ALU_Op0;
		ALUSrc_p <= ALUSrc;
		IF_Flush <= ifflush;
		--HDU
		Stall_out <= stall;
		END IF;
END PROCESS;
END behavior;