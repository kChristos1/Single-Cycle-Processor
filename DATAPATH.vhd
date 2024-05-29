LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DATAPATH IS
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
END DATAPATH;

ARCHITECTURE Behavioral OF DATAPATH IS
	COMPONENT IFSTAGE
		PORT (
			PC_Immed : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			PC_sel   : IN  STD_LOGIC;
			PC_LdEn  : IN  STD_LOGIC;
			Reset    : IN  STD_LOGIC;
			Clk      : IN  STD_LOGIC;
			Instr    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT DECSTAGE
		PORT (
			Instr         : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			RF_WrEn       : IN  STD_LOGIC;
			ALU_out       : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			MEM_out       : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			RF_WrData_sel : IN  STD_LOGIC;
			RF_B_sel      : IN  STD_LOGIC;
			Clk           : IN  STD_LOGIC;
			Reset_regs    : IN  STD_LOGIC;                     --extra added
			Sel_immed     : IN  STD_LOGIC_VECTOR (1 DOWNTO 0); --extra added
			Immed         : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			RF_A          : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			RF_B          : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT exec_unit
		PORT (
			RF_A        : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			RF_B        : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			Immed       : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			ALU_Bin_sel : IN  STD_LOGIC;
			ALU_func    : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
			ALU_out     : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			Zero        : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT MEMSTAGE
		PORT (
			clk          : IN  STD_LOGIC;
			Mem_WrEn     : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
			ALU_MEM_Addr : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			MEM_DataIn   : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			MEM_DataOut  : OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
	END COMPONENT;
	--inbetween signals:
	SIGNAL Instr_sig       : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Immed_sig       : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL RF_A_sig        : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL RF_B_sig        : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MEM_in_data     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out_sig     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MEM_out_sig     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL RF_WRITE_MUX_IN : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL op_code         : STD_LOGIC_VECTOR(5 DOWNTO 0);
BEGIN
	--zerofillers for sb/lb instructions
	Instr   <= Instr_sig;
	op_code <= Instr_sig(31 DOWNTO 26);

	-- MEM_in_data and 
	-- getting zerofilled in
	-- case of store/load byte
	-- respectively

	PROCESS (op_code, RF_B_sig, MEM_out_sig)
	BEGIN
		IF op_code = "000111" THEN
			MEM_in_data(7 DOWNTO 0)  <= RF_B_sig(7 DOWNTO 0);
			MEM_in_data(31 DOWNTO 8) <= (OTHERS => '0');
		ELSE
			MEM_in_data <= RF_B_sig;
		END IF;

		IF op_code = "000011" THEN
			RF_WRITE_MUX_IN(7 DOWNTO 0)  <= MEM_out_sig(7 DOWNTO 0);
			RF_WRITE_MUX_IN(31 DOWNTO 8) <= (OTHERS => '0');
		ELSE
			RF_WRITE_MUX_IN <= MEM_out_sig;
		END IF;
	END PROCESS;

	if_label : IFSTAGE
	PORT MAP(
		PC_Immed => Immed_sig,
		PC_sel   => PC_sel,
		PC_LdEn  => PC_LdEn,
		Reset    => PC_reset,
		Clk      => Clk,
		Instr    => Instr_sig
	);

	dec_label : DECSTAGE
	PORT MAP(
		Instr         => Instr_sig,
		RF_WrEn       => RF_WrEn,
		ALU_out       => ALU_out_sig,
		MEM_out       => RF_WRITE_MUX_IN,
		RF_WrData_sel => RF_WrData_sel,
		RF_B_sel      => RF_B_sel,
		Clk           => Clk,
		Reset_regs    => Reset_regs,
		Sel_immed     => Sel_immed, --for conversion_unit
		Immed         => Immed_sig,
		RF_A          => RF_A_sig,
		RF_B          => RF_B_sig
	);

	exec_unit_label : exec_unit
	PORT MAP(
		RF_A        => RF_A_sig,
		RF_B        => RF_B_sig,
		Immed       => Immed_sig,
		ALU_Bin_sel => ALU_Bin_sel,
		ALU_func    => ALU_func,
		ALU_out     => ALU_out_sig,
		Zero        => Zero
	);

	memstage_label : MEMSTAGE
	PORT MAP(
		clk          => Clk,
		Mem_WrEn     => Mem_WrEn,
		ALU_MEM_Addr => ALU_out_sig,
		MEM_DataIn   => MEM_in_data,
		MEM_DataOut  => MEM_out_sig
	);
END Behavioral;
