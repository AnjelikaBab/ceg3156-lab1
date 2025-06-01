LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fpAdderControlPath is
    PORT(
        clk, reset: IN STD_LOGIC;
        expEqual, exp1LtExp2, manResNeg, sign1, sign2, cOut1, cOut2, overflow, manResMSB, manResLSB : IN STD_LOGIC; -- Status signals
        loadExpA, loadExpB, loadMan1, loadMan2, loadSign1, loadSign2, loadManRes, loadExpRes: OUT STD_LOGIC; -- Load control signals
        shiftRMan1, shiftRMan2, resultShiftR, resultShiftL: OUT STD_LOGIC; -- Shift control signals
        opOrder, subMantissas, subResult, selManRes, incExp1, incExp2, incManRes, incExpRes, decExpRes, overflowFlag: OUT STD_LOGIC; -- Arithmetic control signals
        greset: OUT STD_LOGIC); 
END fpAdderControlPath;

ARCHITECTURE rtl OF fpAdderControlPath is
    SIGNAL state_in, state_out: STD_LOGIC_VECTOR(12 downto 0);
    SIGNAL control_path_reset: STD_LOGIC;

    COMPONENT enardFF_2
        PORT(
            i_resetBar	: IN	STD_LOGIC;
            i_d		: IN	STD_LOGIC;
            i_enable	: IN	STD_LOGIC;
            i_clock		: IN	STD_LOGIC;
            o_q, o_qBar	: OUT	STD_LOGIC);
    END COMPONENT;

BEGIN 
    stateReg0: enardFF_2 PORT MAP(
        i_resetBar => '1',
        i_d => state_in(0),
        i_enable => '1',
        i_clock => clk,
        o_q => state_out(0),
        o_qBar => open);

    -- State registers
    stateRegloop: FOR i IN 1 TO 12 GENERATE
        state_n: enardFF_2 PORT MAP(
            i_resetBar => control_path_reset,
            i_d => state_in(i),
            i_enable => '1',
            i_clock => clk,
            o_q => state_out(i),
            o_qBar => open);
    END GENERATE stateRegloop;

    -- State Input Signals
    state_in(0) <= reset;
    state_in(1) <= state_out(0) AND exp1LtExp2 AND (NOT expEqual);
    state_in(2) <= state_out(0) AND (NOT exp1LtExp2) AND (NOT expEqual);
    state_in(3) <= state_out(0) AND expEqual AND (sign1 XOR sign2) AND (NOT sign1);
    state_in(4) <= state_out(0) AND expEqual AND (sign1 XOR sign2) AND sign1;
    state_in(5) <= state_out(0) AND expEqual AND (NOT (sign1 XOR sign2));
    state_in(6) <= state_out(5) AND cOut1;
    state_in(7) <= (state_out(3) OR state_out(4)) AND overflow;
    state_in(8) <= (state_out(3) OR state_out(4)) AND (NOT overflow) AND manResNeg;
    state_in(9) <= (state_out(6) OR state_out(12) OR (state_out(5) AND (NOT cOut1))) AND manResLSB;
    state_in(10) <= state_out(8) AND (NOT manResMSB);
    state_in(11) <= state_out(9) AND cOut2;
    state_in(12) <= (state_out(3) OR state_out(4)) AND (NOT manResNeg) AND manResMSB;

    control_path_reset <= NOT reset;

    -- Output Control Signals
    loadExpA  <= state_out(0);
    loadExpB  <= state_out(0);
    loadMan1  <= state_out(0);
    loadMan2  <= state_out(0);
    loadSign1 <= state_out(0);
    loadSign2 <= state_out(0);

    greset <= state_out(0);

    shiftRMan1 <= state_out(1);
    incExp1 <= state_out(1);
    shiftRMan2 <= state_out(2) ;
    incExp2 <= state_out(2);
    opOrder <= state_out(3);

    resultShiftR <= state_out(6);
    overflowFlag <= state_out(7);
    subResult <= state_out(8);
    incManRes <= state_out(9);
    resultShiftL <= state_out(10);
    decExpRes <= state_out(10);

    subMantissas <= state_out(3) OR state_out(4);
    subResult <= state_out(8);
    loadManRes <= state_out(3) OR state_out(4) OR state_out(5) OR state_out(8) OR state_out(9);
    selManRes <= state_out(8) OR state_out(9);
    incExpRes <= state_out(6) OR state_out(11);
    loadExpRes <= state_out(3) OR state_out(4) OR state_out(5);



end rtl;