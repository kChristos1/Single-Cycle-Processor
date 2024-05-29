LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CPU_tb IS
END CPU_tb;

ARCHITECTURE behavior OF CPU_tb IS
	-- Component Declaration
	COMPONENT CPU
		PORT (
			PC_rst : IN STD_LOGIC;
			RF_rst : IN STD_LOGIC;
			clk    : IN STD_LOGIC
		);
	END COMPONENT;
	SIGNAL PC_rst       : STD_LOGIC;
	SIGNAL RF_rst       : STD_LOGIC;
	SIGNAL clk          : STD_LOGIC;
	-- Clock period definitions
	CONSTANT clk_period : TIME := 10 ns;
BEGIN
	-- Component Instantiation
	uut : CPU PORT MAP(
		PC_rst => PC_rst,
		RF_rst => RF_rst,
		clk    => clk
	);

	-- Clock process definitions
	clk_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR clk_period/2;
		clk <= '1';
		WAIT FOR clk_period/2;
	END PROCESS;

	--  Test Bench Statements
	tb : PROCESS
	BEGIN
		--RESET
		PC_rst <= '1';
		RF_rst <= '1';
		WAIT FOR clk_period;
		
		--RUN UNTIL PROGRAM ENDS
		PC_rst <= '0';
		RF_rst <= '0';
		WAIT;
	END PROCESS tb;

END;
