LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fpMultiplierTop IS
    PORT(
        clk, reset, start: IN STD_LOGIC;
        i_manA, i_manB: IN STD_LOGIC_VECTOR(7 downto 0); -- Mantissa inputs
        i_expA, i_expB: IN STD_LOGIC_VECTOR(6 downto 0); -- Exponent inputs
        i_signA, i_signB: IN STD_LOGIC; -- Sign inputs
        o_signOut: OUT STD_LOGIC; -- Sign output
        o_expOut: OUT STD_LOGIC_VECTOR(6 downto 0); -- Exponent
        o_manOut: OUT STD_LOGIC_VECTOR(7 downto 0); -- Mantissa output
        o_overflow: OUT STD_LOGIC; -- Overflow flag
        done: OUT STD_LOGIC -- Done signal
    );
END fpMultiplierTop;

ARCHITECTURE rtl OF fpMultiplierTop IS
    SIGNAL multRdy, manResMSB : STD_LOGIC; 
    SIGNAL ldExp1, ldExp2, ldMan1, ldMan2, ldSign1, ldSign2, ldManRes, ldExpRes: STD_LOGIC; 
    SIGNAL shiftRManRes: STD_LOGIC; 
    SIGNAL roundManRes, incExpRes, startMult: STD_LOGIC; 

    COMPONENT fpMultiplierControlPathTop
        PORT(
            clk, reset, start: IN STD_LOGIC;
            multRdy, manResMSB : IN STD_LOGIC; -- Status signals
            ldExp1, ldExp2, ldMan1, ldMan2, ldSign1, ldSign2, ldManRes, ldExpRes: OUT STD_LOGIC; -- Load control signals
            shiftRManRes: OUT STD_LOGIC; -- Shift control signals
            roundManRes, incExpRes, startMult: OUT STD_LOGIC; -- Arithmetic control signals
            done: OUT STD_LOGIC); 
    END COMPONENT;

    COMPONENT fpMultiplierDatapath
    PORT(
        clk, reset: IN STD_LOGIC;
        ldExp1, ldExp2, ldMan1, ldMan2, ldSign1, ldSign2, ldManRes, ldExpRes: IN STD_LOGIC; -- Load control signals
        roundManRes, incExpRes, startMult: IN STD_LOGIC; -- Arithmetic control signals
        i_sign1, i_sign2: IN STD_LOGIC; -- Sign inputs
        i_exp1, i_exp2: IN STD_LOGIC_VECTOR(6 downto 0); -- Exponent inputs
        i_man1, i_man2: IN STD_LOGIC_VECTOR(7 downto 0); -- Mantissa inputs
        shiftRManRes: IN STD_LOGIC; -- Shift control signals
        multRdy, manResMSB: OUT STD_LOGIC; -- Status signals for control path
        o_overflow: OUT STD_LOGIC;
        o_signRes: OUT STD_LOGIC; -- Sign output
        o_expRes: OUT STD_LOGIC_VECTOR(6 downto 0); -- Exponent
        o_manRes: OUT STD_LOGIC_VECTOR(7 downto 0) -- Mantissa output
    );
    END COMPONENT;

BEGIN

    -- Instantiate the control path
    controlPath: fpMultiplierControlPathTop
        PORT MAP(
            clk => clk,
            reset => reset,
            start => start,
            multRdy => multRdy,
            manResMSB => manResMSB,
            ldExp1 => ldExp1,
            ldExp2 => ldExp2,
            ldMan1 => ldMan1,
            ldMan2 => ldMan2,
            ldSign1 => ldSign1,
            ldSign2 => ldSign2,
            ldManRes => ldManRes,
            ldExpRes => ldExpRes,
            shiftRManRes => shiftRManRes,
            roundManRes => roundManRes,
            incExpRes => incExpRes,
            startMult => startMult,
            done => done
        );

    -- Instantiate the datapath
    datapath: fpMultiplierDatapath
        PORT MAP(
            clk => clk,
            reset => reset,
            ldExp1 => ldExp1,
            ldExp2 => ldExp2,
            ldMan1 => ldMan1,
            ldMan2 => ldMan2,
            ldSign1 => ldSign1,
            ldSign2 => ldSign2,
            ldManRes => ldManRes,
            ldExpRes => ldExpRes,
            roundManRes => roundManRes,
            incExpRes => incExpRes,
            startMult => startMult,
            i_sign1 => i_signA, 
            i_sign2 => i_signB, 
            i_exp1 => i_expA, 
            i_exp2 => i_expB, 
            i_man1 => i_manA, 
            i_man2 => i_manB, 
            shiftRManRes => shiftRManRes, 
            multRdy => multRdy, 
            manResMSB => manResMSB, 
            o_overflow => o_overflow, 
            o_signRes => o_signOut, 
            o_expRes => o_expOut, 
            o_manRes => o_manOut
        );
END rtl;