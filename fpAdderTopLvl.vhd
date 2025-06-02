LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fpAdderTopLvl is
    PORT(
        clk, reset: IN STD_LOGIC;
        i_manA, i_manB: IN STD_LOGIC_VECTOR(7 downto 0); -- Mantissa inputs
        i_expA, i_expB: IN STD_LOGIC_VECTOR(6 downto 0); -- Exponent inputs
        i_signA, i_signB: IN STD_LOGIC; -- Sign inputs
        o_signOut: OUT STD_LOGIC; -- Sign output
        o_expOut: OUT STD_LOGIC_VECTOR(6 downto 0); -- Exponent
        o_manOut: OUT STD_LOGIC_VECTOR(7 downto 0); -- Mantissa output
        o_overflow: OUT STD_LOGIC; -- Overflow flag
        done: OUT STD_LOGIC -- Done signal
    );
END fpAdderTopLvl;

ARCHITECTURE rtl OF fpAdderTopLvl is
    SIGNAL expEqual, exp1LtExp2, manResNeg, sign1, sign2, manResMSB, manResLSB : STD_LOGIC;
    SIGNAL loadExpA, loadExpB, loadMan1, loadMan2, loadSign1, loadSign2, loadManRes, loadExpRes: STD_LOGIC;
    SIGNAL shiftRMan1, shiftRMan2, resultShiftR, resultShiftL: STD_LOGIC; -- Shift control signals
    SIGNAL opOrder, subMantissas, subResult, selManRes, incExp1, incExp2, incManRes, incExpRes, decExpRes: STD_LOGIC; -- Arithmetic control signals

    COMPONENT fpAdderControlPath
        PORT(
            clk, reset: IN STD_LOGIC;
            expEqual, exp1LtExp2, manResNeg, sign1, sign2, manResMSB, manResLSB : IN STD_LOGIC; -- Status signals
            loadExpA, loadExpB, loadMan1, loadMan2, loadSign1, loadSign2, loadManRes, loadExpRes: OUT STD_LOGIC; -- Load control signals
            shiftRMan1, shiftRMan2, resultShiftR, resultShiftL: OUT STD_LOGIC; -- Shift control signals
            opOrder, subMantissas, subResult, selManRes, incExp1, incExp2, incManRes, incExpRes, decExpRes: OUT STD_LOGIC; -- Arithmetic control signals
            done: OUT STD_LOGIC -- Asserted when the operation is complete
        ); 
    END COMPONENT;

    COMPONENT fpAdderDatapath
        Port(
            clk, reset: IN STD_LOGIC; -- Clock and active high reset signals
            man1, man2: IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Mantissas of the two floating-point numbers
            exp1, exp2: IN STD_LOGIC_VECTOR(6 DOWNTO 0); -- Exponents of the two floating-point numbers
            i_sign1, i_sign2: IN STD_LOGIC; -- Signs of the two floating-point numbers
            shiftRMan1, shiftRMan2, resultShiftR, resultShiftL: IN STD_LOGIC; -- Shift control signals
            loadExpA, loadExpB, loadMan1, loadMan2, loadSign1, loadSign2, loadManRes, loadExpRes: IN STD_LOGIC; -- Load control signals
            opOrder, subMantissas, subResult, selManRes, incExp1, incExp2, incManRes, incExpRes, decExpRes: IN STD_LOGIC; -- Arithmetic control signals
            expEqual, exp1LtExp2, manResNeg, o_sign1, o_sign2, manResMSB, manResLSB : OUT STD_LOGIC; -- Status signals
            o_overflow: OUT STD_LOGIC;
            signRes: OUT STD_LOGIC; -- Result sign
            expRes: OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- Result exponent
            manRes: OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- Result mantissa
        );
    END COMPONENT;

BEGIN
    -- Instantiate the control path
    controlPath: fpAdderControlPath
        PORT MAP(
            clk => clk,
            reset => reset,
            expEqual => expEqual,
            exp1LtExp2 => exp1LtExp2,
            manResNeg => manResNeg,
            sign1 => sign1,
            sign2 => sign2,
            manResMSB => manResMSB,
            manResLSB => manResLSB,
            loadExpA => loadExpA,
            loadExpB => loadExpB,
            loadMan1 => loadMan1,
            loadMan2 => loadMan2,
            loadSign1 => loadSign1,
            loadSign2 => loadSign2,
            loadManRes => loadManRes,
            loadExpRes => loadExpRes,
            shiftRMan1 => shiftRMan1,
            shiftRMan2 => shiftRMan2,
            resultShiftR => resultShiftR,
            resultShiftL => resultShiftL,
            opOrder => opOrder,
            subMantissas => subMantissas,
            subResult => subResult,
            selManRes => selManRes,
            incExp1 => incExp1,
            incExp2 => incExp2,
            incManRes => incManRes,
            incExpRes => incExpRes,
            decExpRes => decExpRes,
            done => done
        );
    -- Instantiate the datapath
    datapath: fpAdderDatapath
        PORT MAP(
            clk => clk,
            reset => reset,
            man1 => i_manA,
            man2 => i_manB,
            exp1 => i_expA,
            exp2 => i_expB,
            i_sign1 => i_signA,
            i_sign2 => i_signB,
            shiftRMan1 => shiftRMan1,
            shiftRMan2 => shiftRMan2,
            resultShiftR => resultShiftR,
            resultShiftL => resultShiftL,
            loadExpA => loadExpA,
            loadExpB => loadExpB,
            loadMan1 => loadMan1,
            loadMan2 => loadMan2,
            loadSign1 => loadSign1,
            loadSign2 => loadSign2,
            loadManRes => loadManRes,
            loadExpRes => loadExpRes,
            opOrder => opOrder,
            subMantissas => subMantissas,
            subResult => subResult,
            selManRes => selManRes,
            incExp1 => incExp1,
            incExp2 => incExp2,
            incManRes => incManRes,
            incExpRes => incExpRes,
            decExpRes => decExpRes,
            expEqual => expEqual,
            exp1LtExp2 => exp1LtExp2,
            manResNeg => manResNeg,
            o_sign1 => sign1, -- Output sign 1
            o_sign2 => sign2, -- Output sign 2
            manResMSB => manResMSB, -- Most significant bit of mantissa result
            manResLSB => manResLSB, -- Least significant bit of mantissa result
            o_overflow => o_overflow, -- Overflow flag
            signRes => o_signOut, -- Result sign output
            expRes => o_expOut, -- Result exponent output
            manRes => o_manOut -- Result mantissa output
        );
end rtl;