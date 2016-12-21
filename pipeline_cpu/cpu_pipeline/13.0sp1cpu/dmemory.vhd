LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
ENTITY dmemory IS
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
END dmemory;


ARCHITECTURE behavior OF dmemory IS
--Internal Signals
			SIGNAL MEM1WRITE : STD_LOGIC;
			SIGNAL ReadData : STD_LOGIC_VECTOR (7 DOWNTO 0);
BEGIN

data_memory : altsyncram
GENERIC MAP (
			operation_mode => "SINGLE_PORT",
			width_a => 8,
			widthad_a => 8,
			lpm_type => "altsyncram",
			outdata_reg_a => "UNREGISTERED",
			init_file => "dmemory.mif",
			intended_device_family => "Cyclone"
)
--READ DATA MEMORY
PORT MAP(
			wren_a => MemWrite_pp AND (NOT Clock),
			clock0 => Clock,
			address_a => address,
			data_a => Write_Data,
			q_a => ReadData );

PROCESS
BEGIN
			WAIT UNTIL Clock'EVENT AND Clock = '1';
			IF Reset = '1' THEN
					Read_Data_p <= "00000000";
					MemtoReg_ppp <= '0';
					RegWrite_ppp <= '0';
					ALU_Result_pp <= "00000000";
					Write_Address_pp <= "00000";
					MemRead_ppp <= '0';
					MemWrite_ppp <= '0';
					Read_Data_2_ppp <= "00000000";
			ELSE
					Read_Data_p <= readdata;
					MemtoReg_ppp <= MemtoReg_pp;
					RegWrite_ppp <= RegWrite_pp;
					ALU_Result_pp <= ALU_Result_p;
					Write_Address_pp <= Write_Address_p;
					MemRead_ppp <= MemRead_pp;
					MemWrite_ppp <= MemWrite_pp;
					Read_Data_2_ppp <= Write_Data;
						IF (MemtoReg_pp = '1') THEN
							Reg_WriteData <= ReadData;
						ELSE
							Reg_WriteData <= ALU_Result_p;
						END IF;
			END IF;
END PROCESS;
END behavior;