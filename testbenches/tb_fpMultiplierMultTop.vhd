LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_fpMultiplierMultTop IS
END tb_fpMultiplierMultTop;

ARCHITECTURE behavior OF tb_fpMultiplierMultTop IS

    -- Component Declaration
    COMPONENT fpMultiplierMultTop
        PORT(
            clk         : IN  STD_LOGIC;
            reset       : IN  STD_LOGIC;
            startMult   : IN  STD_LOGIC;
            i_multiplicand : IN  STD_LOGIC_VECTOR(8 downto 0);
            i_multiplier   : IN  STD_LOGIC_VECTOR(8 downto 0);
            multRdy     : OUT STD_LOGIC;
            overflow    : OUT STD_LOGIC;
            o_product   : OUT STD_LOGIC_VECTOR(17 downto 0)
        );
    END COMPONENT;

    -- Testbench signals
    SIGNAL clk         : STD_LOGIC := '0';
    SIGNAL reset       : STD_LOGIC := '0';
    SIGNAL startMult   : STD_LOGIC := '0';
    SIGNAL i_multiplicand : STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
    SIGNAL i_multiplier   : STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
    SIGNAL multRdy     : STD_LOGIC;
    SIGNAL overflow    : STD_LOGIC;
    SIGNAL o_product   : STD_LOGIC_VECTOR(17 downto 0);

    -- Clock period
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: fpMultiplierMultTop
        PORT MAP (
            clk => clk,
            reset => reset,
            startMult => startMult,
            i_multiplicand => i_multiplicand,
            i_multiplier => i_multiplier,
            multRdy => multRdy,
            overflow => overflow,
            o_product => o_product
        );

    -- Clock generation
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
        -- Apply reset
        reset <= '1';
        WAIT FOR 20 ns;
        reset <= '0';

        -- Test Case 1: 5 x 3 = 15
        i_multiplicand <= std_logic_vector(to_unsigned(5, 9));
        i_multiplier <= std_logic_vector(to_unsigned(3, 9));
        startMult <= '1';
        WAIT FOR clk_period;
        startMult <= '0';

        -- Wait for multRdy
        WAIT UNTIL multRdy = '1';
        WAIT FOR clk_period;
        ASSERT unsigned(o_product) = 15
            REPORT "Test 1 Failed: 5 x 3 /= " & INTEGER'image(to_integer(unsigned(o_product)))
            SEVERITY error;

        -- Apply reset
        reset <= '1';
        WAIT FOR 20 ns;
        reset <= '0';
        -- Test Case 2: 127 x 2 = 254
        i_multiplicand <= std_logic_vector(to_unsigned(127, 9));
        i_multiplier <= std_logic_vector(to_unsigned(2, 9));
        startMult <= '1';
        WAIT FOR clk_period;
        startMult <= '0';

        WAIT UNTIL multRdy = '1';
        WAIT FOR clk_period;
        ASSERT unsigned(o_product) = 254
            REPORT "Test 2 Failed: 127 x 2 /= " & INTEGER'image(to_integer(unsigned(o_product)))
            SEVERITY error;

        -- Apply reset
        reset <= '1';
        WAIT FOR 20 ns;
        reset <= '0';
        -- Test Case 3: 255 x 255 = 65025
        i_multiplicand <= std_logic_vector(to_unsigned(255, 9));
        i_multiplier <= std_logic_vector(to_unsigned(255, 9));
        startMult <= '1';
        WAIT FOR clk_period;
        startMult <= '0';

        WAIT UNTIL multRdy = '1';
        WAIT FOR clk_period;
        ASSERT unsigned(o_product) = 65025
            REPORT "Test 3 Failed: 255 x 255 /= " & INTEGER'image(to_integer(unsigned(o_product)))
            SEVERITY error;

        -- Done
        REPORT "All tests passed." SEVERITY note;
        WAIT;

    END PROCESS;

END behavior;