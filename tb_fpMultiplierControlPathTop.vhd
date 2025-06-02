LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_fpMultiplierControlPathTop IS
END ENTITY;

ARCHITECTURE behavior OF tb_fpMultiplierControlPathTop IS

    COMPONENT fpMultiplierControlPathTop IS
        PORT (
            clk, reset: IN STD_LOGIC;
            multRdy, manResMSB: IN STD_LOGIC;
            ldExp1, ldExp2, ldMan1, ldMan2, ldSign1, ldSign2, ldManRes, ldExpRes: OUT STD_LOGIC;
            shiftRManRes: OUT STD_LOGIC;
            roundManRes, incExpRes, startMult: OUT STD_LOGIC;
            greset: OUT STD_LOGIC;
            done: OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL clk         : STD_LOGIC := '0';
    SIGNAL reset       : STD_LOGIC := '0';
    SIGNAL multRdy     : STD_LOGIC := '0';
    SIGNAL manResMSB   : STD_LOGIC := '0';
    SIGNAL ldExp1, ldExp2, ldMan1, ldMan2, ldSign1, ldSign2 : STD_LOGIC;
    SIGNAL ldManRes, ldExpRes, shiftRManRes : STD_LOGIC;
    SIGNAL roundManRes, incExpRes, startMult : STD_LOGIC;
    SIGNAL greset, done : STD_LOGIC;

    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Clock generation
    clk_process : PROCESS
    BEGIN
        WHILE TRUE LOOP
            clk <= '0';
            WAIT FOR clk_period / 2;
            clk <= '1';
            WAIT FOR clk_period / 2;
        END LOOP;
    END PROCESS;

    -- Instantiate the unit under test (UUT)
    uut: fpMultiplierControlPathTop
        PORT MAP (
            clk         => clk,
            reset       => reset,
            multRdy     => multRdy,
            manResMSB   => manResMSB,
            ldExp1      => ldExp1,
            ldExp2      => ldExp2,
            ldMan1      => ldMan1,
            ldMan2      => ldMan2,
            ldSign1     => ldSign1,
            ldSign2     => ldSign2,
            ldManRes    => ldManRes,
            ldExpRes    => ldExpRes,
            shiftRManRes=> shiftRManRes,
            roundManRes => roundManRes,
            incExpRes   => incExpRes,
            startMult   => startMult,
            greset      => greset,
            done        => done
        );

    -- Main test process
    stim_proc : PROCESS
    BEGIN
        -- Reset the system
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        WAIT FOR clk_period;

        -- Hold in state 1 by keeping multRdy low
        multRdy <= '0';
        WAIT FOR clk_period;

        -- Move to state 2
        multRdy <= '1';
        WAIT FOR clk_period;

        -- Take the path: 2 → 3 → 4 → 5
        manResMSB <= '1';  -- triggers state 3
        WAIT FOR clk_period;

        -- State 3 will transition to 4 automatically
        WAIT FOR clk_period;

        -- State 4 with manResMSB = 1 will go to state 5
        manResMSB <= '1';
        WAIT FOR clk_period;

        -- Wait for done signal from state 5
        WAIT UNTIL done = '1';
        REPORT "Completed path: 2 → 3 → 4 → 5" SEVERITY NOTE;

        -- Reset again
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        WAIT FOR clk_period;

        -- Move to state 2
        multRdy <= '1';
        WAIT FOR clk_period;

        -- Take the path: 2 → 4 → 6
        manResMSB <= '0'; -- skips state 3
        WAIT FOR clk_period;

        -- State 4 with manResMSB = 0 should go to state 6
        WAIT FOR clk_period;

        -- Wait for done signal from state 6
        WAIT UNTIL done = '1';
        REPORT "Completed path: 2 → 4 → 6" SEVERITY NOTE;

        WAIT;
    END PROCESS;

END ARCHITECTURE;
