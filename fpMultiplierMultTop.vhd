LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fpMultiplierMultTop IS
    PORT(
        clk, reset: IN STD_LOGIC; --active high reset
        startMult: IN STD_LOGIC; -- Start multiplication signal
        i_multiplicand, i_multiplier: IN STD_LOGIC_VECTOR(8 downto 0); -- 9-bit inputs
        multRdy: OUT STD_LOGIC; -- Ready signal for multiplication
        overflow: OUT STD_LOGIC; -- Overflow signal
        o_product: OUT STD_LOGIC_VECTOR(17 downto 0) -- 18-bit output for product
    );
END fpMultiplierMultTop;

ARCHITECTURE rtl OF fpMultiplierMultTop IS
    SIGNAL ldMultiplicand, ldMultiplier, ldProduct: STD_LOGIC; -- Load control signals
    SIGNAL shiftRProduct, shiftRMultiplier: STD_LOGIC; -- Shift control signals
    SIGNAL incCount, lastIteration, multiplierLSB: STD_LOGIC; -- Arithmetic control signals

    component fpMultiplierControlPathMult
        PORT(
            clk, reset: IN STD_LOGIC;
            startMult, multiplierLSB, lastIteration: IN STD_LOGIC; -- Status signals
            ldMultiplicand, ldMultiplier, ldProduct: OUT STD_LOGIC; -- Load control signals
            shiftRProduct, shiftRMultiplier: OUT STD_LOGIC; -- Shift control signals
            incCount, multRdy: OUT STD_LOGIC -- Arithmetic control signals
        );
    END COMPONENT;

    component fpMultiplierDatapathMult
        PORT(
            clk, reset: IN STD_LOGIC; --active high reset
            ldMultiplicand, ldMultiplier, ldProduct: IN STD_LOGIC; -- Load control signals
            shiftRProduct, shiftRMultiplier: IN STD_LOGIC; -- Shift control signals
            incCount: IN STD_LOGIC; -- Increment control signal
            i_multiplicand, i_multiplier: IN STD_LOGIC_VECTOR(8 downto 0); -- 9-bit inputs
            o_overflow: OUT STD_LOGIC;
            lastIteration, multiplierLSB: OUT STD_LOGIC; -- Status signals for control path
            o_product: OUT STD_LOGIC_VECTOR(17 downto 0) -- 18-bit output for product
        );
    END COMPONENT;

BEGIN
    -- Instantiate the control path
    controlPath: fpMultiplierControlPathMult
        PORT MAP(
            clk => clk,
            reset => reset,
            startMult => startMult,
            multiplierLSB => multiplierLSB,
            lastIteration => lastIteration,
            ldMultiplicand => ldMultiplicand,
            ldMultiplier => ldMultiplier,
            ldProduct => ldProduct,
            shiftRProduct => shiftRProduct,
            shiftRMultiplier => shiftRMultiplier,
            incCount => incCount,
            multRdy => multRdy
        );

    -- Instantiate the datapath
    datapath: fpMultiplierDatapathMult
        PORT MAP(
            clk => clk,
            reset => reset,
            ldMultiplicand => ldMultiplicand,
            ldMultiplier => ldMultiplier,
            ldProduct => ldProduct,
            shiftRProduct => shiftRProduct,
            shiftRMultiplier => shiftRMultiplier,
            incCount => incCount,
            i_multiplicand => i_multiplicand,
            i_multiplier => i_multiplier,
            o_overflow => overflow,
            lastIteration => lastIteration,
            multiplierLSB => multiplierLSB,
            o_product => o_product
        );
END rtl;