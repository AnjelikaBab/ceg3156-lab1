LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fpAdderDatapath is
    Port(
        clk, reset: IN STD_LOGIC; -- Clock and active high reset signals
        man1, man2: IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Mantissas of the two floating-point numbers
        exp1, exp2: IN STD_LOGIC_VECTOR(6 DOWNTO 0); -- Exponents of the two floating-point numbers
        i_sign1, i_sign2: IN STD_LOGIC; -- Signs of the two floating-point numbers
        shiftRMan1, shiftRMan2, resultShiftR, resultShiftL: IN STD_LOGIC; -- Shift control signals
        loadExpA, loadExpB, loadMan1, loadMan2, loadSign1, loadSign2, loadManRes, loadExpRes: IN STD_LOGIC; -- Load control signals
        opOrder, subMantissas, subResult, selManRes, incExp1, incExp2, incManRes, incExpRes, decExpRes: IN STD_LOGIC; -- Arithmetic control signals
        expEqual, exp1LtExp2, manResNeg, o_sign1, o_sign2, manResMSB, manResLSB : OUT STD_LOGIC; -- Status signals
        o_overflow: OUT STD_LOGIC;
		  signRes: OUT STD_LOGIC; -- Result sign
        expRes: OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- Result exponent
        manRes: OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- Result mantissa
    );
END fpAdderDatapath;

ARCHITECTURE rtl OF fpAdderDatapath IS
    SIGNAL exp1_reg_out, exp2_reg_out: STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL exp1_reg_out1: STD_LOGIC_VECTOR(7 DOWNTO 0); -- Extended exponent for result
    SIGNAL man1_reg_out, man2_reg_out: STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL man1_reg_in, man2_reg_in: STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL sign1_reg_out, sign2_reg_out: STD_LOGIC;
    SIGNAL mux1_out, mux2_out: STD_LOGIC_VECTOR(8 DOWNTO 0); -- Mux outputs for mantissa selection
    SIGNAL man_addIn_1, man_addIn_2, man_sum_out: STD_LOGIC_VECTOR(10 DOWNTO 0); -- 11-bit inputs for addition    
    SIGNAL man_sum_out2: STD_LOGIC_VECTOR(11 DOWNTO 0); -- 11-bit output for mantissa sum
    SIGNAL manRes_reg_in, manRes_reg_out: STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL manResRoundBits: STD_LOGIC_VECTOR(11 DOWNTO 0); 
    SIGNAL rounded_manRes: STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL int_expRes: STD_LOGIC_VECTOR(7 DOWNTO 0); -- Intermediate exponent result
    SIGNAL overflow: STD_LOGIC_VECTOR(4 DOWNTO 0); -- Overflow signals for various components
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

    -- stores input and output mantissa
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

    -- stores and increments input and output exponents
    COMPONENT nBitIncrementingReg IS
        GENERIC (n : INTEGER := 3);
        PORT ( clk, reset: IN STD_LOGIC; --active high reset and clock
                load, increment, decrement: IN STD_LOGIC; -- load and increment control signals
                loadBits: IN STD_LOGIC_VECTOR(n-1 downto 0); -- bits to load when load is high
                overflow: OUT STD_LOGIC;
                o_out: OUT STD_LOGIC_VECTOR(n-1 downto 0) ) ;
    END COMPONENT;

    -- to compute result mantissa, and also to round and complement it
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

    -- to compare exponents
    COMPONENT nbitcomparator
        GENERIC(n : INTEGER := 4);
        PORT(
            i_A, i_B	: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
            o_AeqB, o_AgtB, o_AltB : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT nbitmux21
        GENERIC ( n: INTEGER := 8 );
        PORT ( s: IN STD_LOGIC ;
               x0, x1: IN STD_LOGIC_VECTOR(n-1 downto 0) ;
               y: OUT STD_LOGIC_VECTOR(n-1 downto 0) 
        );
    END COMPONENT;

begin
    -- Active low reset signal
    reset_n <= not reset;

    -- Register for input sign, exponent, and mantissa values
    sign1_reg: enARdFF_2
        PORT MAP (
            i_resetBar => reset_n,
            i_d => i_sign1,
            i_enable => loadSign1,
            i_clock => clk,
            o_q => sign1_reg_out,
            o_qBar => open
        );

    sign2_reg: enARdFF_2
        PORT MAP (
            i_resetBar => reset_n,
            i_d => i_sign2,
            i_enable => loadSign2,
            i_clock => clk,
            o_q => sign2_reg_out,
            o_qBar => open
        );

    exp1_reg: nBitIncrementingReg
        GENERIC MAP (n => 7)
        PORT MAP (
            clk => clk,
            reset => reset,
            load => loadExpA,
            increment => incExp1,
            decrement => '0', -- No decrement operation
            loadBits => exp1,
            overflow => overflow(0),
            o_out => exp1_reg_out
        );

    exp2_reg: nBitIncrementingReg
        GENERIC MAP (n => 7)
        PORT MAP (
            clk => clk,
            reset => reset,
            load => loadExpB,
            increment => incExp2,
            decrement => '0', -- No decrement operation
            loadBits => exp2,
            overflow => overflow(1),
            o_out => exp2_reg_out
        );

    man1_reg_in <= '1' & man1; -- Input mantissa for first number
    man2_reg_in <= '1' & man2; -- Input mantissa for second number

    man1_reg: nBitShiftRegister
        GENERIC MAP (n => 9)
        PORT MAP (
            i_resetBar => reset_n,
            i_clock => clk,
            i_load => loadMan1,
            i_shift_right => shiftRMan1,
            i_shift_left => '0',
            serial_in => '0',
            parallel_in => man1_reg_in,
            parallel_out => man1_reg_out,
            serial_out => open
        );

    man2_reg: nBitShiftRegister
        GENERIC MAP (n => 9)
        PORT MAP (
            i_resetBar => reset_n,
            i_clock => clk,
            i_load => loadMan2,
            i_shift_right => shiftRMan2,
            i_shift_left => '0',
            serial_in => '0',
            parallel_in => man2_reg_in,
            parallel_out => man2_reg_out,
            serial_out => open
        );

    exp1_reg_out1 <= '0' & exp1_reg_out;
    -- resultant exponent and sign
    expRes_reg: nBitIncrementingReg
        GENERIC MAP (n => 8)
        PORT MAP (
            clk => clk,
            reset => reset,
            load => loadExpRes,
            increment => incExpRes,
            decrement => decExpRes,
            loadBits => exp1_reg_out1, -- No bits to load, just increment
            overflow => overflow(2),
            o_out => int_expRes
        );

    signRes <= manRes_reg_out(11) OR (sign1_reg_out AND sign2_reg_out);

    --compare exponents
    expComparator: nbitcomparator
        GENERIC MAP (n => 7)
        PORT MAP (
            i_A => exp1_reg_out,
            i_B => exp2_reg_out,
            o_AeqB => expEqual,
            o_AgtB => open,
            o_AltB => exp1LtExp2
        );

    -- mantissa result circuit
    -- these muxes feed into the adder that computes the mantissa
    mux1: nbitmux21
        GENERIC MAP (n => 9)
        PORT MAP (
            s => opOrder,
            x0 => man2_reg_out,
            x1 => man1_reg_out,
            y => mux1_out
        );

    mux2: nbitmux21
        GENERIC MAP (n => 9)
        PORT MAP (
            s => opOrder,
            x0 => man1_reg_out,
            x1 => man2_reg_out,
            y => mux2_out
        );

    -- add sign bit and extra bit in front of radix
    man_addIn_1 <= "00" & mux1_out; 
    man_addIn_2 <= "00" & mux2_out; 

    mux_sum_adder: nBitAdderSubtractor
        GENERIC MAP (n => 11)
        PORT MAP (
            i_Ai => man_addIn_1,
            i_Bi => man_addIn_2,
            operationFlag => subMantissas,
            o_CarryOut => open,
            o_overflow => overflow(3),
            o_Sum => man_sum_out
        );
    -- extra bit at the end for normalization
    man_sum_out2 <= man_sum_out & '0';

    manRes_mux: nbitmux21
        GENERIC MAP (n => 12)
        PORT MAP (
            s => selManRes,
            x0 => man_sum_out2,
            x1 => rounded_manRes,
            y => manRes_reg_in
        );

    manRes_reg: nBitShiftRegister
        GENERIC MAP (n => 12)
        PORT MAP (
            i_resetBar => reset_n,
            i_clock => clk,
            i_load => loadManRes,
            i_shift_right => resultShiftR,
            i_shift_left => resultShiftL,
            serial_in => '0',
            parallel_in => manRes_reg_in,
            parallel_out => manRes_reg_out,
            serial_out => open
        );

    -- rounding and complimenting (if needed)
    roundBits_mux: nbitmux21
        GENERIC MAP (n => 12)
        PORT MAP (
            s => incManRes,
            x0 => "000000000000",
            x1 => "000000000001", -- No second input for rounding
            y => manResRoundBits
        );

    manResRoundComp: nBitAdderSubtractor
        GENERIC MAP (n => 12)
        PORT MAP (
            i_Ai => manResRoundBits,
            i_Bi => manRes_reg_out,
            operationFlag => subResult,
            o_CarryOut => open,
            o_overflow => overflow(4),
            o_Sum => rounded_manRes
        );

    -- Output mantissa and status signals
    manRes <= rounded_manRes(8 DOWNTO 1); 
    manResNeg <= rounded_manRes(11); -- sign bit
    manResMSB <= rounded_manRes(10); -- second bit before radix
    manResLSB <= rounded_manRes(0); -- last bit after radix
    o_sign1 <= sign1_reg_out;
    o_sign2 <= sign2_reg_out;

    expRes <= int_expRes(6 DOWNTO 0); -- Result exponent

    -- checks if adders overflowed or sign of exponent result is negative
    o_overflow <= overflow(4) OR overflow(3) OR overflow(2) OR overflow(1) OR overflow(0) OR int_expRes(7); 
end rtl;