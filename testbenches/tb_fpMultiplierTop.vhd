LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_fpMultiplierTop IS
END tb_fpMultiplierTop;

ARCHITECTURE behavior OF tb_fpMultiplierTop IS

    -- Component Declaration
    COMPONENT fpMultiplierTop
        PORT(
            clk, reset, start: IN STD_LOGIC;
            i_manA, i_manB: IN STD_LOGIC_VECTOR(7 downto 0);
            i_expA, i_expB: IN STD_LOGIC_VECTOR(6 downto 0);
            i_signA, i_signB: IN STD_LOGIC;
            o_signOut: OUT STD_LOGIC;
            o_expOut: OUT STD_LOGIC_VECTOR(6 downto 0);
            o_manOut: OUT STD_LOGIC_VECTOR(7 downto 0);
            o_overflow: OUT STD_LOGIC;
            done: OUT STD_LOGIC
        );
    END COMPONENT;

    -- Signals
    SIGNAL clk, reset, start       : STD_LOGIC := '0';
    SIGNAL i_manA, i_manB          : STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL i_expA, i_expB          : STD_LOGIC_VECTOR(6 downto 0);
    SIGNAL i_signA, i_signB        : STD_LOGIC;
    SIGNAL o_signOut               : STD_LOGIC;
    SIGNAL o_expOut                : STD_LOGIC_VECTOR(6 downto 0);
    SIGNAL o_manOut                : STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL o_overflow              : STD_LOGIC;
    SIGNAL done                    : STD_LOGIC;

    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: fpMultiplierTop PORT MAP (
        clk => clk,
        reset => reset,
        start => start,
        i_manA => i_manA,
        i_manB => i_manB,
        i_expA => i_expA,
        i_expB => i_expB,
        i_signA => i_signA,
        i_signB => i_signB,
        o_signOut => o_signOut,
        o_expOut => o_expOut,
        o_manOut => o_manOut,
        o_overflow => o_overflow,
        done => done
    );

    -- Clock Process
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period / 2;
        clk <= '1';
        WAIT FOR clk_period / 2;
    END PROCESS;

    -- Test Process
    stim_proc: PROCESS
    BEGIN
        -- Initial Reset
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        WAIT FOR clk_period;

        ----------------------------------------------------------------------
        -- Test 1: 10.5 * 6.1 = 64.05
        i_signA <= '0';                         -- +10.5
        i_expA  <= "1000010";                   -- 66
        i_manA  <= "01010000";

        i_signB <= '0';                         -- +6.1
        i_expB  <= "1000001";                   -- 65
        i_manB  <= "10000110";

        start <= '1';
        WAIT FOR clk_period;
        start <= '0';

        WAIT UNTIL done = '1';

        IF (o_signOut = '0' AND o_expOut = "1000100" AND o_manOut = "11111111") THEN
            REPORT "Test 1 passed" SEVERITY NOTE;
        ELSE
            REPORT "Test 1 FAILED!" SEVERITY ERROR;
        END IF;

        ----------------------------------------------------------------------
        WAIT FOR clk_period;
        -- Reset between tests
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        WAIT FOR clk_period;

        ----------------------------------------------------------------------
        -- Test 2: -2.0 * 3.5 = -7.0
        i_signA <= '1';                         -- -2.0
        i_expA  <= "1000000";                   -- 64
        i_manA  <= "00000000";

        i_signB <= '0';                         -- 7.0
        i_expB  <= "1000001";                   -- 65
        i_manB  <= "11000000";

        start <= '1';
        WAIT FOR clk_period;
        start <= '0';

        WAIT UNTIL done = '1';

        IF (o_signOut = '1' AND o_expOut = "1000010" AND o_manOut = "11000000") THEN
            REPORT "Test 2 passed" SEVERITY NOTE;
        ELSE
            REPORT "Test 2 FAILED!" SEVERITY ERROR;
        END IF;

        ----------------------------------------------------------------------
        WAIT;
    END PROCESS;

END behavior;
