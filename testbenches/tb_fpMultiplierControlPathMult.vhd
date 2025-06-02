LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_fpMultiplierControlPathMult IS
END ENTITY;

ARCHITECTURE behavior OF tb_fpMultiplierControlPathMult IS

    -- Component under test
    COMPONENT fpMultiplierControlPathMult
        PORT(
            clk               : IN  STD_LOGIC;
            reset             : IN  STD_LOGIC;
            startMult         : IN  STD_LOGIC;
            multiplierLSB     : IN  STD_LOGIC;
            countEq8          : IN  STD_LOGIC;
            ldMultiplicand    : OUT STD_LOGIC;
            ldMultiplier      : OUT STD_LOGIC;
            ldProduct         : OUT STD_LOGIC;
            shiftRProduct     : OUT STD_LOGIC;
            shiftRMultiplier  : OUT STD_LOGIC;
            incCount          : OUT STD_LOGIC;
            multRdy           : OUT STD_LOGIC;
            greset            : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Signals to connect to DUT
    SIGNAL clk               : STD_LOGIC := '0';
    SIGNAL reset             : STD_LOGIC := '1';
    SIGNAL startMult         : STD_LOGIC := '0';
    SIGNAL multiplierLSB     : STD_LOGIC := '0';
    SIGNAL countEq8          : STD_LOGIC := '0';
    SIGNAL ldMultiplicand    : STD_LOGIC;
    SIGNAL ldMultiplier      : STD_LOGIC;
    SIGNAL ldProduct         : STD_LOGIC;
    SIGNAL shiftRProduct     : STD_LOGIC;
    SIGNAL shiftRMultiplier  : STD_LOGIC;
    SIGNAL incCount          : STD_LOGIC;
    SIGNAL multRdy           : STD_LOGIC;
    SIGNAL greset            : STD_LOGIC;

    -- Clock period
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: fpMultiplierControlPathMult
        PORT MAP (
            clk               => clk,
            reset             => reset,
            startMult         => startMult,
            multiplierLSB     => multiplierLSB,
            countEq8          => countEq8,
            ldMultiplicand    => ldMultiplicand,
            ldMultiplier      => ldMultiplier,
            ldProduct         => ldProduct,
            shiftRProduct     => shiftRProduct,
            shiftRMultiplier  => shiftRMultiplier,
            incCount          => incCount,
            multRdy           => multRdy,
            greset            => greset
        );

    -- Clock generation
    clk_process: PROCESS
    BEGIN
        WHILE true LOOP
            clk <= '0';
            WAIT FOR clk_period / 2;
            clk <= '1';
            WAIT FOR clk_period / 2;
        END LOOP;
    END PROCESS;

    -- Stimulus process
    stim_proc: PROCESS
    BEGIN
        -- Initial reset
        WAIT FOR 20 ns;
        reset <= '0';

        -- Start multiplication, multiplierLSB = 1 (simulate LSB of multiplier is 1)
        startMult <= '1';
        multiplierLSB <= '1';
        WAIT FOR clk_period;

        -- Transition to ldProduct, then shifting starts
        startMult <= '0'; -- simulate start signal going low
        multiplierLSB <= '0'; -- LSB doesn't trigger addition
        WAIT FOR 3 * clk_period;

        -- Loop: simulate intermediate multiply cycles
        FOR i IN 1 TO 5 LOOP
            multiplierLSB <= (i MOD 2 = 0) ? '1' : '0'; -- toggle LSB
            countEq8 <= '0'; -- not done
            WAIT FOR clk_period;
        END LOOP;

        -- End condition (count == 8)
        countEq8 <= '1';
        WAIT FOR clk_period;

        -- Hold to observe outputs
        WAIT FOR 50 ns;

        -- End simulation
        WAIT;
    END PROCESS;

END behavior;
