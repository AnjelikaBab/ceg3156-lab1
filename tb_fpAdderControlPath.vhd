LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.env.stop;

ENTITY tb_fpAdderControlPath IS
END tb_fpAdderControlPath;

ARCHITECTURE behavior OF tb_fpAdderControlPath IS

    -- Component declaration
    COMPONENT fpAdderControlPath
        PORT(
            clk, reset: IN STD_LOGIC;
            expEqual, exp1LtExp2, manResNeg, sign1, sign2, cOut, overflow, manResMSB, manResLSB : IN STD_LOGIC;
            loadExpA, loadExpB, loadMan1, loadMan2, loadSign1, loadSign2, loadManRes, loadExpRes: OUT STD_LOGIC;
            shiftRMan1, shiftRMan2, resultShiftR, resultShiftL: OUT STD_LOGIC;
            opOrder, subMantissas, subResult, selManRes, incExp1, incExp2, incManRes, incExpRes, decExpRes, overflowFlag: OUT STD_LOGIC;
            greset: OUT STD_LOGIC
        );
    END COMPONENT;

    -- Signals
    SIGNAL clk          : STD_LOGIC := '0';
    SIGNAL reset        : STD_LOGIC := '0';
    SIGNAL expEqual     : STD_LOGIC := '0';
    SIGNAL exp1LtExp2   : STD_LOGIC := '0';
    SIGNAL manResNeg    : STD_LOGIC := '0';
    SIGNAL sign1        : STD_LOGIC := '0';
    SIGNAL sign2        : STD_LOGIC := '0';
    SIGNAL cOut         : STD_LOGIC := '0';
    SIGNAL overflow     : STD_LOGIC := '0';
    SIGNAL manResMSB    : STD_LOGIC := '0';
    SIGNAL manResLSB    : STD_LOGIC := '0';

    -- Output signals
    SIGNAL loadExpA, loadExpB, loadMan1, loadMan2, loadSign1, loadSign2, loadManRes, loadExpRes : STD_LOGIC;
    SIGNAL shiftRMan1, shiftRMan2, resultShiftR, resultShiftL : STD_LOGIC;
    SIGNAL opOrder, subMantissas, subResult, selManRes : STD_LOGIC;
    SIGNAL incExp1, incExp2, incManRes, incExpRes, decExpRes, overflowFlag : STD_LOGIC;
    SIGNAL greset : STD_LOGIC;

    -- Clock generation
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- DUT instantiation
    uut: fpAdderControlPath PORT MAP (
        clk => clk,
        reset => reset,
        expEqual => expEqual,
        exp1LtExp2 => exp1LtExp2,
        manResNeg => manResNeg,
        sign1 => sign1,
        sign2 => sign2,
        cOut => cOut,
        overflow => overflow,
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
        overflowFlag => overflowFlag,
        greset => greset
    );

    -- Clock process
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc: PROCESS
    BEGIN
        -- Reset pulse
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';

        -- State 1: state_out(1)
        expEqual <= '0';
        exp1LtExp2 <= '1';
        WAIT FOR clk_period;

        -- State 2: state_out(2)
        exp1LtExp2 <= '0';
        WAIT FOR clk_period;

        -- State 3: state_out(3)
        expEqual <= '1';
        sign1 <= '0';
        sign2 <= '1';
        WAIT FOR clk_period;

        -- State 4: state_out(4)
        sign1 <= '1';
        sign2 <= '0';
        WAIT FOR clk_period;

        -- State 5: state_out(5)
        sign1 <= '1';
        sign2 <= '1';
        WAIT FOR clk_period;

        -- State 6: state_out(6)
        cOut <= '1';
        WAIT FOR clk_period;

        -- State 7: state_out(7)
        overflow <= '1';
        sign1 <= '0';
        sign2 <= '1';
        WAIT FOR clk_period;

        -- State 8: state_out(8)
        overflow <= '0';
        manResNeg <= '1';
        WAIT FOR clk_period;

        -- State 9: state_out(9)
        manResNeg <= '0';
        cOut <= '0';
        manResLSB <= '1';
        WAIT FOR clk_period;

        -- State 10: state_out(10)
        manResMSB <= '0';
        WAIT FOR clk_period;

        -- State 11: state_out(11)
        overflow <= '1';
        WAIT FOR clk_period;

        -- State 12: state_out(12)
        manResMSB <= '1';
        manResNeg <= '0';
        sign1 <= '0';
        sign2 <= '1';
        overflow <= '0';
        WAIT FOR clk_period;

        WAIT FOR 5 * clk_period;

        report "Calling 'stop' - simulation complete";
        stop; 
    END PROCESS;

END behavior;
