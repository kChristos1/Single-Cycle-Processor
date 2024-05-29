LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY CPU IS
	PORT (
		PC_rst : IN STD_LOGIC;
		RF_rst : IN STD_LOGIC;
		clk    : IN STD_LOGIC);
END CPU;

ARCHITECTURE Behavioral OF CPU IS
	COMPONENT DATAPATH PORT (
		--input signals are:
		--the control signals (generated from CONTROL unit)
		PC_sel        : IN  STD_LOGIC;
		PC_LdEn       : IN  STD_LOGIC;
		RF_B_sel      : IN  STD_LOGIC;
		RF_WrData_sel : IN  STD_LOGIC;
		ALU_Bin_sel   : IN  STD_LOGIC;
		ALU_func      : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
		MEM_WrEn      : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
		RF_WrEn       : IN  STD_LOGIC;
		Sel_immed     : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		--reset signals used for
		--1)registers in RF in DECSTAGE:
		Reset_regs    : IN  STD_LOGIC;
		--2)program counter in IFSTAGE
		PC_reset      : IN  STD_LOGIC;
		--we also need a clock.
		Clk           : IN  STD_LOGIC;
		--output signals are:
		--the 32bit instruction (fetched from IFSTAGE)
		Instr         : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		--signal used for branch instructions...
		Zero          : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT CONTROL PORT (--input signals:
		Instr         : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
		Zero          : IN  STD_LOGIC;
		--output signals:
		PC_sel        : OUT STD_LOGIC;
		PC_LdEn       : OUT STD_LOGIC;
		RF_B_sel      : OUT STD_LOGIC;
		RF_WrData_sel : OUT STD_LOGIC;
		ALU_Bin_sel   : OUT STD_LOGIC;
		ALU_func      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --alu's opcode
		MEM_WrEn      : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
		Sel_immed     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		RF_WrEn       : OUT STD_LOGIC
		);
	END COMPONENT;
	SIGNAL sigInstr         : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL sigZero          : STD_LOGIC;
	SIGNAL sigPC_sel        : STD_LOGIC;
	SIGNAL sigPC_LdEn       : STD_LOGIC;
	SIGNAL sigRF_B_sel      : STD_LOGIC;
	SIGNAL sigRF_WrData_sel : STD_LOGIC;
	SIGNAL sigALU_Bin_sel   : STD_LOGIC;
	SIGNAL sigALU_func      : STD_LOGIC_VECTOR(3 DOWNTO 0); --alu's opcode
	SIGNAL sigMEM_WrEn      : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL sigSel_immed     : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL sigRF_WrEn       : STD_LOGIC;
BEGIN
	datapath_lbl : DATAPATH PORT MAP(
		PC_sel        => sigPC_sel,
		PC_LdEn       => sigPC_LdEn,
		RF_B_sel      => sigRF_B_sel,
		RF_WrData_sel => sigRF_WrData_sel,
		ALU_Bin_sel   => sigALU_Bin_sel,
		ALU_func      => sigALU_func,
		MEM_WrEn      => sigMEM_WrEn,
		RF_WrEn       => sigRF_WrEn,
		Sel_immed     => sigSel_immed,
		Reset_regs    => RF_rst,
		PC_reset      => PC_rst,
		Clk           => clk,
		Instr         => sigInstr,
		Zero          => sigZero
	);
	control_lbl : CONTROL PORT MAP(
		Instr         => sigInstr,
		Zero          => sigZero,
		PC_sel        => sigPC_sel,
		PC_LdEn       => sigPC_LdEn,
		RF_B_sel      => sigRF_B_sel,
		RF_WrData_sel => sigRF_WrData_sel,
		ALU_Bin_sel   => sigALU_Bin_sel,
		ALU_func      => sigALU_func,
		MEM_WrEn      => sigMEM_WrEn,
		Sel_immed     => sigSel_immed,
		RF_WrEn       => sigRF_WrEn
	);
END Behavioral;
