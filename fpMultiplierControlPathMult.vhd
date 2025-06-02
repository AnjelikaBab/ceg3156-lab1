LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fpMultiplierControlPathMult is
    PORT(
        clk, reset: IN STD_LOGIC;
        startMult, multiplierLSB, countEq8: IN STD_LOGIC; -- Status signals
        ldMultiplicand, ldMultiplier, ldProduct: OUT STD_LOGIC; -- Load control signals
        shiftRProduct, shiftRMultiplier: OUT STD_LOGIC; -- Shift control signals
        incCount, multRdy: OUT STD_LOGIC; -- Arithmetic control signals
        greset: OUT STD_LOGIC); 
END fpMultiplierControlPathMult;

ARCHITECTURE rtl OF fpMultiplierControlPathMult is
    SIGNAL state_in, state_out: STD_LOGIC_VECTOR(3 downto 0);
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
    stateRegloop: FOR i IN 1 TO 3 GENERATE
        state_n: enardFF_2 PORT MAP(
            i_resetBar => control_path_reset,
            i_d => state_in(i),
            i_enable => '1',
            i_clock => clk,
            o_q => state_out(i),
            o_qBar => open);
    END GENERATE stateRegloop;

    -- State Input Signals
    state_in(0) <= (NOT startMult) OR reset;
    state_in(1) <= (state_out(0) AND startMult AND multiplierLSB) OR (state_out(2) AND (NOT countEq8) AND multiplierLSB);
    state_in(2) <= state_out(1) OR (state_out(0) AND startMult AND (NOT multiplierLSB)) OR (state_out(2) AND (NOT countEq8) AND (NOT multiplierLSB));;
    state_in(3) <= state_out(2) AND countEq8;


    control_path_reset <= NOT reset;

    -- Output Control Signals
    ldMultiplicand  <= state_out(0);
    ldMultiplier  <= state_out(0);
    ldProduct  <= state_out(1);

    greset <= state_out(0);

    shiftRMultiplier <= state_out(2);
    shiftRProduct <= state_out(2);
    incCount <= state_out(2);

    multRdy <= state_out(3)

end rtl;