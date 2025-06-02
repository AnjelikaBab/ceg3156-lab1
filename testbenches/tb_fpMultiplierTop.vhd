LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_fpMultiplierTop IS
END tb_fpMultiplierTop;

ARCHITECTURE behavior OF fpMultiplierTop_tb IS

    -- Component Declaration
    COMPONENT fpMultiplierTop
        PORT(
            clk         : IN  STD_LOGIC;
            reset       : IN  STD_LOGIC;
            i_signA     : IN  STD_LOGIC;
            i_signB     : IN  STD_LOGIC;
            i_expA      : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
            i_expB      : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
            i_manA      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            i_manB      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_signOut   : OUT STD_LOGIC;
            o_expOut    : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            o_manOut    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_overflow  : OUT STD_LOGIC;
            done        : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Signals
    SIGNAL clk         : STD_LOGIC := '0';
    SIGNAL reset       : STD_LOGIC := '1';
    SIGNAL i_signA     : STD_LOGIC;
    SIGNAL i_signB     : STD_LOGIC;
    SIGNAL i_expA      : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL i_expB      : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL i_manA      : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL i_manB      : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL o_signOut   : STD_LOGIC;
    SIGNAL o_expOut    : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL o_manOut    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL o_overflow  : STD_LOGIC;
    SIGNAL done        : STD_LOGIC;

    -- Clock generation
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: fpMultiplierTop
        PORT MAP (
            clk => clk,
            reset => reset,
            i_signA => i_signA,
            i_signB => i_signB,
            i_expA => i_expA,
            i_expB => i_expB,
            i_manA => i_manA,
            i_manB => i_manB,
            o_signOut => o_signOut,
            o_expOut => o_expOut,
            o_manOut => o_manOut,
            o_overflow => o_overflow,
            done => done
        );

    -- Clock Process
    clk_process : PROCESS
    BEGIN
        WHILE TRUE LOOP
            clk <= '0';
            WAIT FOR clk_period / 2;
            clk <= '1';
            WAIT FOR clk_period / 2;
        END LOOP;
    END PROCESS;

    -- Stimulus Process
    stim_proc: PROCESS
    BEGIN
        -- Case: 0.25 * 0.5
        -- 0.25 = 1.0 × 2^-2 → exponent = -2 + 63 = 61 (0111101), mantissa = 1.0 → 10000000
        -- 0.5  = 1.0 × 2^-1 → exponent = -1 + 63 = 62 (0111110), mantissa = 1.0 → 10000000
        reset <= '1';
        i_signA <= '0';
        i_expA  <= "0111101";  -- 61
        i_manA  <= "00000000"; -- 1.0

        i_signB <= '0';
        i_expB  <= "0111110";  -- 62
        i_manB  <= "00000000"; -- 1.0-- Apply reset

        WAIT FOR 20 ns;
        reset <= '0';

        -- Wait for completion
        WAIT UNTIL done = '1';
        WAIT FOR 20 ns;

        -- Check result manually or visually in waveform:
        -- Expected Output:
        --   o_signOut = '0'
        --   o_expOut  = "0111100" (60 = -3)
        --   o_manOut  = "10000000"
        --   o_overflow = '0'

        WAIT; -- Wait forever
    END PROCESS;

END behavior;

