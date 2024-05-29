LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY DATAPATH_tb IS
END DATAPATH_tb;

ARCHITECTURE behavior OF DATAPATH_tb IS
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT DATAPATH
		PORT (
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
	--inputs
	SIGNAL PC_sel        : STD_LOGIC                     := '0';
	SIGNAL PC_LdEn       : STD_LOGIC                     := '0';
	SIGNAL RF_B_sel      : STD_LOGIC                     := '0';
	SIGNAL RF_WrData_sel : STD_LOGIC                     := '0';
	SIGNAL ALU_Bin_sel   : STD_LOGIC                     := '0';
	SIGNAL ALU_func      : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
	SIGNAL MEM_WrEn      : STD_LOGIC_VECTOR(0 DOWNTO 0)  := (OTHERS => '0');
	SIGNAL RF_WrEn       : STD_LOGIC                     := '0';
	SIGNAL Sel_immed     : STD_LOGIC_VECTOR(1 DOWNTO 0)  := (OTHERS => '0');
	SIGNAL Reset_regs    : STD_LOGIC                     := '0';
	SIGNAL PC_reset      : STD_LOGIC                     := '0';
	SIGNAL Clk           : STD_LOGIC                     := '0';
	--outputs
	SIGNAL Instr         : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Zero          : STD_LOGIC;
	CONSTANT Clk_period  : TIME := 10ns;
BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut : DATAPATH PORT MAP(
		PC_sel        => PC_sel,
		PC_LdEn       => PC_LdEn,
		RF_B_sel      => RF_B_sel,
		RF_WrData_sel => RF_WrData_sel,
		ALU_Bin_sel   => ALU_Bin_sel,
		ALU_func      => ALU_func,
		MEM_WrEn      => MEM_WrEn,
		RF_WrEn       => RF_WrEn,
		Sel_immed     => Sel_immed,
		Reset_regs    => Reset_regs,
		PC_reset      => PC_reset,
		Clk           => Clk,
		Instr         => Instr,
		Zero          => Zero
	);
	-- Clock process definitions
	Clk_process : PROCESS
	BEGIN
		Clk <= '0';
		WAIT FOR Clk_period/2;
		Clk <= '1';
		WAIT FOR Clk_period/2;
	END PROCESS;
	-- Stimulus process
	stim_proc : PROCESS
	BEGIN
		-- hold reset
		PC_reset   <= '1';
		Reset_regs <= '1';
		WAIT FOR Clk_period;

		-- testing
		PC_reset      <= '0';
		Reset_regs    <= '0';


		--li r1, 6:
		RF_WrEn       <= '1';
		PC_sel        <= '0';
		PC_LdEn       <= '1';
		RF_B_sel      <= 'U';
		RF_WrData_sel <= '0';
		ALU_Bin_sel   <= '1';
		MEM_WrEn      <= "0";
		ALU_func      <= "0000";
		Sel_immed     <= "01";
		WAIT FOR Clk_period;
		
		--li r2, 6:
		PC_sel        <= '0';
		PC_LdEn       <= '1';
		RF_B_sel      <= 'U';
		RF_WrData_sel <= '0';
		ALU_Bin_sel   <= 'U';
		ALU_func      <= "UUUU";
		MEM_WrEn      <= "0";
		Sel_immed     <= "00";
		RF_WrEn       <= '1';
		WAIT FOR Clk_period;
		
		--add r1, r3, r2: (r3=r1+r2)
		RF_WrEn       <= '1';
		PC_sel        <= '0';
		PC_LdEn       <= '1';
		RF_B_sel      <= '0';
		RF_WrData_sel <= '0';
		ALU_Bin_sel   <= '0';
		MEM_WrEn      <= "0";
		ALU_func      <= "0000";
		Sel_immed     <= "UU";
		WAIT FOR Clk_period;
		
		--bne r1, r2, 0
		PC_sel        <= '0';
		RF_WrEn       <= '0';
		PC_LdEn       <= '1';
		RF_B_sel      <= '1';
		RF_WrData_sel <= 'U';
		ALU_Bin_sel   <= '0';
		MEM_WrEn      <= "0";
		ALU_func      <= "0001";
		Sel_immed     <= "10";
		WAIT FOR Clk_period;
		
		--beq r1, r2, 0
		PC_sel        <= '1';
		RF_WrEn       <= '0';
		PC_LdEn       <= '1';
		RF_B_sel      <= '1';
		RF_WrData_sel <= 'U';
		ALU_Bin_sel   <= '0';
		MEM_WrEn      <= "0";
		ALU_func      <= "0001";
		Sel_immed     <= "10";
		WAIT FOR Clk_period;
		
		--lui r8, 4
		PC_sel        <= '0';
		PC_LdEn       <= '1';
		RF_B_sel      <= 'U';
		RF_WrData_sel <= '0';
		ALU_Bin_sel   <= 'U';
		ALU_func      <= "UUUU";
		MEM_WrEn      <= "0";
		Sel_immed     <= "11";
		RF_WrEn       <= '1';
		WAIT FOR Clk_period;
		
		--lui r10, 16
		PC_sel        <= '0';
		PC_LdEn       <= '1';
		RF_B_sel      <= 'U';
		RF_WrData_sel <= '0';
		ALU_Bin_sel   <= 'U';
		ALU_func      <= "UUUU";
		MEM_WrEn      <= "0";
		Sel_immed     <= "11";
		RF_WrEn       <= '1';
		WAIT FOR Clk_period;
		
		--or r8, r5, r10
		RF_WrEn       <= '1';
		PC_sel        <= '0';
		PC_LdEn       <= '1';
		RF_B_sel      <= 'U';
		RF_WrData_sel <= '0';
		ALU_Bin_sel   <= '1';
		MEM_WrEn      <= "0";
		ALU_func      <= "0011";
		Sel_immed     <= "00";
		WAIT FOR Clk_period;
		
		--rol r5, r6, 1
		RF_WrEn       <= '1';
		PC_sel        <= '0';
		PC_LdEn       <= '1';
		RF_B_sel      <= '0';
		RF_WrData_sel <= '0';
		ALU_Bin_sel   <= '0';
		MEM_WrEn      <= "0";
		ALU_func      <= "1100";
		Sel_immed     <= "UU";
		WAIT FOR Clk_period;
		
		--ror r6, r5, 1
		RF_WrEn       <= '1';
		PC_sel        <= '0';
		PC_LdEn       <= '1';
		RF_B_sel      <= '0';
		RF_WrData_sel <= '0';
		ALU_Bin_sel   <= '0';
		MEM_WrEn      <= "0";
		ALU_func      <= "1101";
		Sel_immed     <= "UU";
		WAIT FOR Clk_period;
		
		--sw r5, 4(r10)
		RF_WrEn       <= '0';
		PC_sel        <= '0';
		PC_LdEn       <= '1';
		RF_B_sel      <= '1';
		RF_WrData_sel <= 'U';
		ALU_Bin_sel   <= '1';
		MEM_WrEn      <= "1";
		ALU_func      <= "0000";
		Sel_immed     <= "01";
		WAIT FOR Clk_period;
	END PROCESS;
END;
