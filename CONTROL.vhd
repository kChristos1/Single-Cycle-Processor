LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY CONTROL IS
	PORT (
		-- input signals:
		Instr         : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
		Zero          : IN  STD_LOGIC;
		-- output signals:
		PC_sel        : OUT STD_LOGIC;
		PC_LdEn       : OUT STD_LOGIC;
		RF_B_sel      : OUT STD_LOGIC;
		RF_WrData_sel : OUT STD_LOGIC;
		ALU_Bin_sel   : OUT STD_LOGIC;
		ALU_func      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --alu's opcode
		MEM_WrEn      : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
		Sel_immed     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		RF_WrEn       : OUT STD_LOGIC);
END CONTROL;
--                 		Instruction format is:
-- 			(6BITS) - (5 BITS) - (5BITS) - (5BITS) - (5BITS) - (6BITS)
-- R-TYPE:  OPCODE  -    RS    -    RD   -    RT   - NOTUSED -  FUNC
-- I-TYPE:	OPCODE  -    RS    -    RD   - ========IMMEDIATE==========
--
-- To determine the ALU operation we keep the 4 MS bits of the instruction.
-- In cases such as lb/sb or beq/bne we use the following values:
-- "0000" is for addition
-- "0001" is for dubtraction
-- "0010" is for logic and
-- "0011" is for logic or

ARCHITECTURE Behavioral OF CONTROL IS
	SIGNAL opcode       : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL func         : STD_LOGIC_VECTOR(3 DOWNTO 0);
	--values for opcode (as constants):
	CONSTANT NOP        : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
	CONSTANT ALU_R_type : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100000";
	CONSTANT li         : STD_LOGIC_VECTOR(5 DOWNTO 0) := "111000";
	CONSTANT lui        : STD_LOGIC_VECTOR(5 DOWNTO 0) := "111001";
	CONSTANT addi       : STD_LOGIC_VECTOR(5 DOWNTO 0) := "110000";
	CONSTANT andi       : STD_LOGIC_VECTOR(5 DOWNTO 0) := "110010";
	CONSTANT ori        : STD_LOGIC_VECTOR(5 DOWNTO 0) := "110011";
	CONSTANT branch     : STD_LOGIC_VECTOR(5 DOWNTO 0) := "111111";
	CONSTANT beq        : STD_LOGIC_VECTOR(5 DOWNTO 0) := "010000";
	CONSTANT bne        : STD_LOGIC_VECTOR(5 DOWNTO 0) := "010001";
	CONSTANT lb         : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000011";
	CONSTANT lw         : STD_LOGIC_VECTOR(5 DOWNTO 0) := "001111";
	CONSTANT sb         : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000111";
	CONSTANT sw         : STD_LOGIC_VECTOR(5 DOWNTO 0) := "011111";
BEGIN
	PROCESS (opcode, Instr, func, Zero)
	BEGIN
		opcode <= Instr(31 DOWNTO 26);
		func   <= Instr(3 DOWNTO 0);--used for alu's r-type instructions to determin the function (add,sub..)
		CASE opcode IS
			WHEN NOP =>
				RF_WrEn       <= '0';
				PC_sel        <= '0';
				PC_LdEn       <= '1'; --just fetch next instruction...
				RF_B_sel      <= '0';
				RF_WrData_sel <= '0';
				ALU_Bin_sel   <= '0';
				MEM_WrEn      <= "0";
				ALU_func      <= "UUUU";
				Sel_immed     <= "UU";
			WHEN ALU_R_type =>
				RF_WrEn       <= '1';
				PC_sel        <= '0';
				PC_LdEn       <= '1';
				RF_B_sel      <= '0';
				RF_WrData_sel <= '0';
				ALU_Bin_sel   <= '0';
				MEM_WrEn      <= "0";
				ALU_func      <= func;
				Sel_immed     <= "UU";
			WHEN li =>
				RF_WrEn       <= '1';
				PC_sel        <= '0';
				PC_LdEn       <= '1';
				RF_B_sel      <= 'U';
				RF_WrData_sel <= '0';
				ALU_Bin_sel   <= '1';
				MEM_WrEn      <= "0";
				ALU_func      <= "0000";
				Sel_immed     <= "01"; --sign extend
			WHEN lui =>
				RF_WrEn       <= '1';
				PC_sel        <= '0';
				PC_LdEn       <= '1';
				RF_B_sel      <= 'U';
				RF_WrData_sel <= '0';
				ALU_Bin_sel   <= '1';
				MEM_WrEn      <= "0";
				ALU_func      <= "0000";
				Sel_immed     <= "11"; --16shift+zerofill
			WHEN addi =>
				RF_WrEn       <= '1';
				PC_sel        <= '0';
				PC_LdEn       <= '1';
				RF_B_sel      <= 'U';
				RF_WrData_sel <= '0';
				ALU_Bin_sel   <= '1';
				MEM_WrEn      <= "0";
				ALU_func      <= "0000"; --do addition
				Sel_immed     <= "01";   --signextend
			WHEN andi =>
				RF_WrEn       <= '1';
				PC_sel        <= '0';
				PC_LdEn       <= '1';
				RF_B_sel      <= 'U';
				RF_WrData_sel <= '0';
				ALU_Bin_sel   <= '1';
				MEM_WrEn      <= "0";
				ALU_func      <= "0010"; --do logic and
				Sel_immed     <= "00";   --zerofill
			WHEN ori =>
				RF_WrEn       <= '1';
				PC_sel        <= '0';
				PC_LdEn       <= '1';
				RF_B_sel      <= 'U';
				RF_WrData_sel <= '0';
				ALU_Bin_sel   <= '1';
				MEM_WrEn      <= "0";
				ALU_func      <= "0011"; --do logic or
				Sel_immed     <= "00";   --zerofill
			WHEN branch =>
				RF_WrEn       <= '0';
				PC_sel        <= '1';
				PC_LdEn       <= '1';
				RF_B_sel      <= 'U';
				RF_WrData_sel <= 'U';
				ALU_Bin_sel   <= 'U';
				MEM_WrEn      <= "0";
				ALU_func      <= "UUUU";
				Sel_immed     <= "10"; --sign extend+shift 2

			WHEN beq =>
				IF Zero = '1' THEN
					PC_sel <= '1'; --PC=PC+4+Immed
				ELSE
					PC_sel <= '0'; --PC=PC+4
				END IF;
				RF_WrEn       <= '0';
				PC_LdEn       <= '1';
				RF_B_sel      <= '1';
				RF_WrData_sel <= 'U';
				ALU_Bin_sel   <= '0'; -- do RF[rs]-RF[rd]
				MEM_WrEn      <= "0";
				ALU_func      <= "0001"; --opcode for subtraction
				Sel_immed     <= "10";   --sign extend + shift 2

			WHEN bne =>
				IF Zero = '0' THEN
					PC_sel <= '1'; --PC=PC+4+Immed
				ELSE
					PC_sel <= '0'; --PC=PC+4
				END IF;
				RF_WrEn       <= '0';
				PC_LdEn       <= '1';
				RF_B_sel      <= '1';
				RF_WrData_sel <= 'U';
				ALU_Bin_sel   <= '0'; -- do RF[rs]-RF[rd]
				MEM_WrEn      <= "0";
				ALU_func      <= "0001"; --opcode for subtraction
				Sel_immed     <= "10";   --sign extend + shift 2

			WHEN lb =>
				RF_WrEn       <= '1';
				PC_sel        <= '0';
				PC_LdEn       <= '1';
				RF_B_sel      <= 'U';
				RF_WrData_sel <= '1';
				ALU_Bin_sel   <= '1';
				MEM_WrEn      <= "0";
				ALU_func      <= "0000"; --do addition
				Sel_immed     <= "01";   --sign extend
			WHEN sb =>
				RF_WrEn       <= '0';
				PC_sel        <= '0';
				PC_LdEn       <= '1';
				RF_B_sel      <= '1';
				RF_WrData_sel <= 'U';
				ALU_Bin_sel   <= '1';
				MEM_WrEn      <= "1";
				ALU_func      <= "0000"; --do addition
				Sel_immed     <= "01";   --sign extend
			WHEN lw =>
				RF_WrEn       <= '1';
				PC_sel        <= '0';
				PC_LdEn       <= '1';
				RF_B_sel      <= 'U';
				RF_WrData_sel <= '1';
				ALU_Bin_sel   <= '1';
				MEM_WrEn      <= "0";
				ALU_func      <= "0000"; --do addition
				Sel_immed     <= "01";   --sign extend
			WHEN sw =>
				RF_WrEn       <= '0';
				PC_sel        <= '0';
				PC_LdEn       <= '1';
				RF_B_sel      <= '1';
				RF_WrData_sel <= 'U';
				ALU_Bin_sel   <= '1';
				MEM_WrEn      <= "1";
				ALU_func      <= "0000"; --do addition
				Sel_immed     <= "01";   --sign extend
			WHEN OTHERS =>
				--treat it as NOP.
				RF_WrEn       <= '0';
				PC_sel        <= '0';
				PC_LdEn       <= '1'; --just fetch next instruction...
				RF_B_sel      <= '0';
				RF_WrData_sel <= '0';
				ALU_Bin_sel   <= '0';
				MEM_WrEn      <= "0";
				ALU_func      <= "UUUU";
				Sel_immed     <= "UU";
		END CASE;
	END PROCESS;
END Behavioral;
