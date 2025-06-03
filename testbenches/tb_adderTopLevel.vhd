LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_fpAdderTopLvl IS
END ENTITY;

ARCHITECTURE behavior OF tb_fpAdderTopLvl IS

    -- Component Declaration
    COMPONENT fpAdderTopLvl
        PORT(
            clk, reset: IN STD_LOGIC;
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

    -- Signals for DUT
    SIGNAL clk         : STD_LOGIC := '0';
    SIGNAL reset       : STD_LOGIC := '1';
    SIGNAL i_manA      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    SIGNAL i_manB      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    SIGNAL i_expA      : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
    SIGNAL i_expB      : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
    SIGNAL i_signA     : STD_LOGIC := '0';
    SIGNAL i_signB     : STD_LOGIC := '0';
    SIGNAL o_signOut   : STD_LOGIC;
    SIGNAL o_expOut    : STD_LOGIC_VECTOR(6 downto 0);
    SIGNAL o_manOut    : STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL o_overflow  : STD_LOGIC;
    SIGNAL done        : STD_LOGIC;

    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate DUT
    uut: fpAdderTopLvl
        PORT MAP(
            clk => clk,
            reset => reset,
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

    -- Clock process
    clk_process : PROCESS
    BEGIN
        WHILE true LOOP
            clk <= '0';
            WAIT FOR clk_period / 2;
            clk <= '1';
            WAIT FOR clk_period / 2;
        END LOOP;
    END PROCESS;

    -- Test Process
    stim_proc : PROCESS
    BEGIN
        -- -- === Test Case 1 ===
        -- -- 1.75
        -- -- +3.125
        -- -- = 4.875
        -- reset <= '1';

        -- i_signA <= '0';  -- Positive
        -- i_expA  <= std_logic_vector(to_unsigned(63, 7)); -- 0 actual exponent
        -- i_manA  <= "11000000"; -- 1.75

        -- i_signB <= '0';  -- Positive
        -- i_expB  <= std_logic_vector(to_unsigned(64, 7)); -- +1 exponent
        -- i_manB  <= "10010000"; --3.125  -- Initial reset
        -- WAIT FOR clk_period;

        -- reset <= '0';

        -- WAIT UNTIL done = '1';

        -- === Test Case 2 ===
        -- 10.5
        -- -6.1
        -- = 4.4
        reset <= '1';

        i_signA <= '0';                         -- +10.5
        i_expA  <= "1000010";                   -- 66
        i_manA  <= "01010000";

        i_signB <= '1';                         -- +6.1
        i_expB  <= "1000001";                   -- 65
        i_manB  <= "10000110";
        WAIT FOR clk_period;

        reset <= '0';

        WAIT UNTIL done = '1';
        WAIT;
    END PROCESS;

END ARCHITECTURE;
