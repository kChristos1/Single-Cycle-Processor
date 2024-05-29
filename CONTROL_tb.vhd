LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CONTROL_tb IS
END CONTROL_tb;

ARCHITECTURE behavior OF CONTROL_tb IS
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT CONTROL
		PORT (
			Instr         : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			Zero          : IN  STD_LOGIC;
			PC_sel        : OUT STD_LOGIC;
			PC_LdEn       : OUT STD_LOGIC;
			RF_B_sel      : OUT STD_LOGIC;
			RF_WrData_sel : OUT STD_LOGIC;
			ALU_Bin_sel   : OUT STD_LOGIC;
			ALU_func      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			MEM_WrEn      : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
			Sel_immed     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			RF_WrEn       : OUT STD_LOGIC
		);
	END COMPONENT;

	--Inputs
	SIGNAL Instr         : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL Zero          : STD_LOGIC                     := '0';

	--Outputs
	SIGNAL PC_sel        : STD_LOGIC;
	SIGNAL PC_LdEn       : STD_LOGIC;
	SIGNAL RF_B_sel      : STD_LOGIC;
	SIGNAL RF_WrData_sel : STD_LOGIC;
	SIGNAL ALU_Bin_sel   : STD_LOGIC;
	SIGNAL ALU_func      : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL MEM_WrEn      : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL Sel_immed     : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL RF_WrEn       : STD_LOGIC;

BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut : CONTROL PORT MAP(
		Instr         => Instr,
		Zero          => Zero,
		PC_sel        => PC_sel,
		PC_LdEn       => PC_LdEn,
		RF_B_sel      => RF_B_sel,
		RF_WrData_sel => RF_WrData_sel,
		ALU_Bin_sel   => ALU_Bin_sel,
		ALU_func      => ALU_func,
		MEM_WrEn      => MEM_WrEn,
		Sel_immed     => Sel_immed,
		RF_WrEn       => RF_WrEn
	);
	-- Stimulus process
	stim_proc : PROCESS
	BEGIN
		--                 Instruction format is:
		-- (6BITS) - (5 BITS) - (5BITS) - (5BITS) - (5BITS)	- (6BITS)
		-- OPCODE  -    RS    -    RD   -    RT   - NOTUSED -  FUNC
		-- OPCODE  -    RS    -    RD   - ========IMMEDIATE==========

		-- li r1,6
		Instr <= "11100000000000010000000000000110";
		Zero  <= '0';
		WAIT FOR 10 ns;
		--li r2,6
		Instr <= "11100000000000100000000000000110";
		Zero  <= '0';
		WAIT FOR 10 ns;
		--add r1,r3,r2
		Instr <= "10000000001000110001000000110000";
		Zero  <= '0';
		WAIT FOR 10 ns;
		--bne r1,r2, 0
		Instr <= "01000100001000100000000000000000";
		Zero  <= '1';
		WAIT FOR 10 ns;
		--beq r1,r2, 0
		Instr <= "01000000001000100000000000000000";
		Zero  <= '1';
		WAIT FOR 10 ns;
		--lui r8,4
		Instr <= "11100100000010000000000000000100";
		Zero  <= '0';
		WAIT FOR 10 ns;
		--lui r10,16
		Instr <= "11100100000010100000000000010000";
		Zero  <= '0';
		WAIT FOR 10 ns;
		--or r8,r5,r10
		Instr <= "10000001000001010101000000110011";
		Zero  <= '0';
		WAIT FOR 10 ns;
		--rol r5,r6,1
		Instr <= "10000000101001100000000000111100";
		Zero  <= '0';
		WAIT FOR 10 ns;
		--ror r6,r5,1
		Instr <= "10000000110001010000000000111101";
		Zero  <= '0';
		WAIT FOR 10 ns;
		--sw r5,4(r10)
		Instr <= "01111100101010100000000000000100";
		Zero  <= '0';
		WAIT FOR 10 ns;
		WAIT;
	END PROCESS;
END;
