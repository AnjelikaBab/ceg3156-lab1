LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fpMultiplierControlPathTop is
    PORT(
        clk, reset: IN STD_LOGIC;
        multRdy, manResMSB : IN STD_LOGIC; -- Status signals
        ldExp1, ldExp2, ldMan1, ldMan2, ldSign1, ldSign2, ldManRes, ldExpRes: OUT STD_LOGIC; -- Load control signals
        shiftRManRes: OUT STD_LOGIC; -- Shift control signals
        roundManRes, incExpRes, startMult: OUT STD_LOGIC; -- Arithmetic control signals
        greset: OUT STD_LOGIC
        done: OUT STD_LOGIC); 
END fpMultiplierControlPathTop;

ARCHITECTURE rtl OF fpMultiplierControlPathTop is
    SIGNAL state_in, state_out: STD_LOGIC_VECTOR(6 downto 0);
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
    stateRegloop: FOR i IN 1 TO 6 GENERATE
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
    state_in(1) <= state_out(0) OR (state_out(1) AND (NOT multRdy));
    state_in(2) <= state_out(1) AND multRdy;
    state_in(3) <= state_out(2) AND manResMSB;
    state_in(4) <= state_out(3) OR (state_out(2) AND (NOT manResMSB));
    state_in(5) <= state_out(4) AND manResMSB;
    state_in(6) <= state_out(4) AND (NOT manResMSB);

    control_path_reset <= NOT reset;

    -- Output Control Signals
    ldExp1  <= state_out(0);
    ldExp2  <= state_out(0);
    ldMan1  <= state_out(0);
    ldMan2  <= state_out(0);
    ldSign1 <= state_out(0);
    ldSign2 <= state_out(0);

    greset <= state_out(0);
    done <= state_out(6) OR <= state_out(5);

    roundManRes <= state_out(4);
    shiftRManRes <= state_out(3);

    ldManRes <= state_out(2) OR state_out(4);
    incExpRes <= state_out(3) OR state_out(5);




end rtl;