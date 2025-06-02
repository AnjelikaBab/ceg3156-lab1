LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fpMultiplierDatapath IS
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
END fpMultiplierDatapath;

ARCHITECTURE rtl OF fpMultiplierDatapath IS
    SIGNAL sign1_reg_out, sign2_reg_out: STD_LOGIC;
    SIGNAL exp1_reg_out, exp2_reg_out: STD_LOGIC_VECTOR(6 downto 0);
    SIGNAL man1_reg_out, man2_reg_out: STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL multiplier_in_1, multiplier_in_2: STD_LOGIC_VECTOR(8 downto 0); -- 9-bit inputs for multiplication
    SIGNAL manRes_reg_in, manRes_reg_out: STD_LOGIC_VECTOR(18 downto 0);
    SIGNAL manRes_mux_out, rounded_manRes, man_product: STD_LOGIC_VECTOR(17 downto 0);
    SIGNAL expRes_adder_1_out, expRes_adder_2_out: STD_LOGIC_VECTOR(7 downto 0); -- extra bit to keep track of sign
    SIGNAL overflow: STD_LOGIC_VECTOR(4 downto 0); -- Overflow signals for various components
    SIGNAL reset_n: STD_LOGIC; -- Active low reset signal

    -- stores input signs
    COMPONENT enARdFF_2
        PORT(
            i_resetBar	: IN	STD_LOGIC;
            i_d		: IN	STD_LOGIC;
            i_enable	: IN	STD_LOGIC;
            i_clock		: IN	STD_LOGIC;
            o_q, o_qBar	: OUT	STD_LOGIC);
    END COMPONENT;

    -- stores input exponents, mantissa
    COMPONENT nbitregister
        GENERIC(
            n: INTEGER := 8
        );
	PORT(
		i_resetBar, i_load	: IN	STD_LOGIC;
		i_clock			: IN	STD_LOGIC;
		i_Value			: IN	STD_LOGIC_VECTOR(n-1 downto 0);
		o_Value			: OUT	STD_LOGIC_VECTOR(n-1 downto 0)
        );
    END COMPONENT;

    -- stores result mantissa
    COMPONENT nBitShiftRegister
        GENERIC(
            n: INTEGER := 8
        );
        PORT(
            i_resetBar, i_clock: IN STD_LOGIC;
            i_load, i_shift_right, i_shift_left: IN STD_LOGIC;
            serial_in: IN STD_LOGIC;
            parallel_in: IN	STD_LOGIC_VECTOR(n-1 downto 0);
            parallel_out: OUT STD_LOGIC_VECTOR(n-1 downto 0);
            serial_out: OUT STD_LOGIC
        );
    END COMPONENT;

    -- stores and increments expRes
    COMPONENT nBitIncrementingReg IS
        GENERIC (n : INTEGER := 3);
        PORT ( clk, reset: IN STD_LOGIC; --active high reset and clock
                load, increment, decrement: IN STD_LOGIC; -- load and increment control signals
                loadBits: IN STD_LOGIC_VECTOR(n-1 downto 0); -- bits to load when load is high
                overflow: OUT STD_LOGIC;
                o_out: OUT STD_LOGIC_VECTOR(n-1 downto 0) ) ;
    END COMPONENT;

    -- to compute result exponent
    COMPONENT nBitAdderSubtractor
        GENERIC(
            n: INTEGER := 4
        );
        PORT(
            i_Ai, i_Bi: IN STD_LOGIC_VECTOR(n-1 downto 0);
            operationFlag: IN STD_LOGIC;
            o_CarryOut: OUT STD_LOGIC;
            o_overflow: OUT STD_LOGIC;
            o_Sum: OUT STD_LOGIC_VECTOR(n-1 downto 0)
        );
    END COMPONENT;

    -- unsigned multiplier
    COMPONENT fpMultiplierMultTop
        PORT(
            clk, reset: IN STD_LOGIC; --active high reset
            startMult: IN STD_LOGIC; -- Start multiplication signal
            i_multiplicand, i_multiplier: IN STD_LOGIC_VECTOR(8 downto 0); -- 9-bit inputs
            multRdy: OUT STD_LOGIC; -- Ready signal for multiplication
            overflow: OUT STD_LOGIC; -- Overflow signal
            o_product: OUT STD_LOGIC_VECTOR(17 downto 0) -- 18-bit output for product
        );
    END COMPONENT;

    -- module for rounding using GRS
    COMPONENT GRS_Round
        PORT(
            round_in: IN STD_LOGIC_VECTOR(18 downto 0); -- 19-bit input for rounding
            round_out: OUT STD_LOGIC_VECTOR(17 downto 0); -- 18-bit output after rounding
            overflow: OUT STD_LOGIC -- Overflow flag
        );
    END COMPONENT;

BEGIN
    reset_n <= NOT reset; -- Active low reset signal

    -- Instantiate registers for sign, exponent, and mantissa inputs
    sign1_ff: enARdFF_2
        PORT MAP (
            i_resetBar => reset_n,
            i_d => i_sign1,
            i_enable => ldSign1,
            i_clock => clk,
            o_q => sign1_reg_out,
            o_qBar => open
        );

    sign2_ff: enARdFF_2
        PORT MAP (
            i_resetBar => reset_n,
            i_d => i_sign2,
            i_enable => ldSign2,
            i_clock => clk,
            o_q => sign2_reg_out,
            o_qBar => open
        );

    exp1_reg: nbitregister
        GENERIC MAP (n => 7)
        PORT MAP (
            i_resetBar => reset_n,
            i_load => ldExp1,
            i_clock => clk,
            i_Value => i_exp1,
            o_Value => exp1_reg_out
        );

    exp2_reg: nbitregister
        GENERIC MAP (n => 7)
        PORT MAP (
            i_resetBar => reset_n,
            i_load => ldExp2,
            i_clock => clk,
            i_Value => i_exp2,
            o_Value => exp2_reg_out
        );

    man1_reg: nbitregister
        GENERIC MAP (n => 8)
        PORT MAP (
            i_resetBar => reset_n,
            i_load => ldMan1,
            i_clock => clk,
            i_Value => i_man1,
            o_Value => man1_reg_out
        );

    man2_reg: nbitregister
        GENERIC MAP (n => 8)
        PORT MAP (
            i_resetBar => reset_n,
            i_load => ldMan2,
            i_clock => clk,
            i_Value => i_man2,
            o_Value => man2_reg_out
        );

    -- Prepare inputs for multiplication
    multiplier_in_1 <= "1" & man1_reg_out; -- Add implicit leading 1 for normalized mantissa
    multiplier_in_2 <= "1" & man2_reg_out; -- Add implicit leading 1 for normalized mantissa

    -- Instantiate the multiplier
    multiplier: fpMultiplierMultTop
        PORT MAP (
            clk => clk,
            reset => reset,
            startMult => startMult,
            i_multiplicand => multiplier_in_1,
            i_multiplier => multiplier_in_2,
            overflow => overflow(0), -- Overflow for multiplication
            multRdy => multRdy,
            o_product => man_product
        );

    -- Mantissa result register
    manRes_reg: nBitShiftRegister
        GENERIC MAP (n => 19)
        PORT MAP (
            i_resetBar => reset_n,
            i_clock => clk,
            i_load => ldManRes,
            i_shift_right => shiftRManRes,
            i_shift_left => '0', -- No left shift
            serial_in => '0', -- No serial input
            parallel_in => manRes_reg_in,
            parallel_out => manRes_reg_out,
            serial_out => open
        );
    -- mantissa reg input mux
    manRes_mux_out <= rounded_manRes when roundManRes = '1' else man_product;
    manRes_reg_in <= manRes_mux_out & "0"; -- Append 0 so last bit is saved for normalization

    -- Rounding the mantissa result
    rounding: GRS_Round
        PORT MAP (
            round_in => manRes_reg_out,
            round_out => rounded_manRes,
            overflow => overflow(1) -- Overflow for rounding
        );

    -- output mantissa and status signal
    o_manRes <= manRes_reg_out(16 downto 9); -- Use remove the bits before the radix and round away the last few bits
    manResMSB <= manRes_reg_in(18); -- MSB of mantissa result


    -- exponent result adders
    expRes_adder_1: nBitAdderSubtractor
        GENERIC MAP (n => 8)
        PORT MAP (
            i_Ai => '0' & exp1_reg_out, -- Add sign bit
            i_Bi => '0' & exp2_reg_out, -- Add sign bit
            operationFlag => '0', -- Addition operation
            o_CarryOut => open, -- Carry out not used
            o_overflow => overflow(2), -- Overflow for exponent addition
            o_Sum => expRes_adder_1_out
        );

    expRes_adder_2: nBitAdderSubtractor
        GENERIC MAP (n => 8)
        PORT MAP (
            i_Ai => expRes_adder_1_out,
            i_Bi => "00111111", -- Bias for exponent (63)
            operationFlag => '1', -- Subtraction operation
            o_CarryOut => open, -- Carry out not used
            o_overflow => overflow(3), -- Overflow for exponent subtraction
            o_Sum => expRes_adder_2_out
        );

    -- Exponent result register
    exp_res_reg: nBitIncrementingReg
        GENERIC MAP (n => 7)
        PORT MAP (
            clk => clk,
            reset => reset,
            load => ldExpRes,
            increment => incExpRes, -- Increment if needed
            decrement => '0', -- No decrement operation
            loadBits => expRes_adder_2_out(6 downto 0), -- Load exponent result
            overflow => overflow(4), -- Overflow for exponent result
            o_out => o_expRes -- Output exponent
        );

    -- Output sign result
    o_signRes <= sign1_reg_out XOR sign2_reg_out; -- Sign of the result is XOR of input signs
    -- Output overflow signal
    -- Condition: overflow occurs if any of the adders or if exponent result becomes negative
    o_overflow <= overflow(0) OR overflow(1) OR overflow(2) OR overflow(3) OR overflow(4) OR expRes_adder_2_out(7);  
end rtl;