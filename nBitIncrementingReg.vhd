LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY nBitIncrementingReg IS
    GENERIC (n : INTEGER := 3);
    PORT ( clk, reset: IN STD_LOGIC; --active high reset and clock
            load, increment, decrement: IN STD_LOGIC; -- load and increment control signals
            loadBits: IN STD_LOGIC_VECTOR(n-1 downto 0); -- bits to load when load is high
            overflow: OUT STD_LOGIC;
            o_out: OUT STD_LOGIC_VECTOR(n-1 downto 0) ) ;
END nBitIncrementingReg;

ARCHITECTURE rtl OF nBitIncrementingReg is
    SIGNAL adder_out, int_reg_out, int_reg_in: STD_LOGIC_VECTOR(n-1 downto 0);
    SIGNAL incrementBits: STD_LOGIC_VECTOR(n-1 downto 0);
    SIGNAL int_clear: STD_LOGIC;
    SIGNAL reg_load: STD_LOGIC;
    SIGNAL operation: STD_LOGIC; -- 0 for addition, 1 for subtraction

    COMPONENT nBitAdderSubtractor
        GENERIC (n : INTEGER := 3);
        PORT(
            i_Ai, i_Bi     : IN  STD_LOGIC_VECTOR(n-1 downto 0);
            operationFlag  : IN  STD_LOGIC;
            o_CarryOut     : OUT STD_LOGIC;
            o_Sum          : OUT STD_LOGIC_VECTOR(n-1 downto 0));
    END COMPONENT;

    COMPONENT nBitRegister
        GENERIC(n : INTEGER := 3);
        PORT(
            i_resetBar, i_load    : IN  STD_LOGIC;
            i_clock             : IN  STD_LOGIC;
            i_Value             : IN  STD_LOGIC_VECTOR(n-1 downto 0);
            o_Value             : OUT STD_LOGIC_VECTOR(n-1 downto 0));
    END COMPONENT;

BEGIN 
    int_clear <= not reset;

    adder: nBitAdderSubtractor
        GENERIC MAP (n => n)
        PORT MAP (i_Ai => int_reg_out, i_Bi => incrementBits, operationFlag => operation, o_CarryOut => overflow, o_Sum => adder_out);

    reg: nBitRegister
        GENERIC MAP (n => n)
        PORT MAP (i_resetBar => int_clear, i_load => reg_load, i_clock => clk, i_Value => int_reg_in, o_Value => int_reg_out);

    reg_load <= load OR increment; -- Load if load is high or increment is requested
    
    int_reg_in <= loadBits when load = '1' else adder_out; -- Load bits if load is high, else use adder output
    operation <= '1' when decrement = '1' else '0'; -- Set operation to subtraction if decrement is high, else addition
    incrementBits <= (n-1 downto 1 => '0') & '1';

    -- Output Driver
    o_out <= int_reg_out;
END rtl;