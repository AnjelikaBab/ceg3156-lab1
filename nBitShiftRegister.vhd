LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY nBitShiftRegister IS
    GENERIC(n : INTEGER := 8);
    PORT(
        i_resetBar, i_clock: IN STD_LOGIC;
        i_load, i_shift_right, i_shift_left: IN STD_LOGIC;
        serial_in: IN STD_LOGIC;
        parallel_in: IN	STD_LOGIC_VECTOR(n-1 downto 0);
        parallel_out: OUT STD_LOGIC_VECTOR(n-1 downto 0);
        serial_out: OUT STD_LOGIC);
END nBitShiftRegister;

ARCHITECTURE rtl OF nBitShiftRegister IS
    SIGNAL int_ff_out, int_mux_out: STD_LOGIC_VECTOR(n-1 downto 0);
    SIGNAL int_enable: STD_LOGIC;

    COMPONENT mux41
        PORT(
            s0, s1: IN STD_LOGIC;
            x0, x1, x2, x3: IN STD_LOGIC;
            y: OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT enardFF_2
        PORT(
            i_resetBar: IN STD_LOGIC;
            i_d: IN STD_LOGIC;
            i_enable: IN STD_LOGIC;
            i_clock: IN STD_LOGIC;
            o_q, o_qBar: OUT STD_LOGIC);
    END COMPONENT;

BEGIN 
    -- register instatiations
    regloop: for i in 0 to n-1 generate
        bit_n: enardFF_2
            PORT MAP(
                i_resetBar => i_resetBar,
                i_d => int_mux_out(i),
                i_enable => int_enable,
                i_clock => i_clock,
                o_q => int_ff_out(i),
                o_qBar => open);
    end generate;

    -- LSB(bit 0) mux
    mux_0: mux41
        PORT MAP(
            s0 => i_shift_left,
            s1 => i_shift_right,
            x0 => parallel_in(0),
            x1 => serial_in,
            x2 => int_ff_out(1),
            x3 => '0',
            y => int_mux_out(0));
    
    -- MSB(bit n-1) mux
    mux_msb: mux41
        PORT MAP(
            s0 => i_shift_left,
            s1 => i_shift_right,
            x0 => parallel_in(n-1),
            x1 => int_ff_out(n-2),
            x2 => serial_in,
            x3 => '0',
            y => int_mux_out(n-1));

    -- bit 1 to n-2 mux 
    muxloop: for i in 1 to n-2 generate
        mux_n: mux41
            PORT MAP(
                s0 => i_shift_left,
                s1 => i_shift_right,
                x0 => parallel_in(i),
                x1 => int_ff_out(i-1),
                x2 => int_ff_out(i+1),
                x3 => '0',
                y => int_mux_out(i));
    end generate;

	-- Enable Signal
	int_enable <= i_shift_left OR i_shift_right OR i_load;
	 
    -- Output Driver
    parallel_out<= int_ff_out;
	serial_out <= int_ff_out(n-1) when i_shift_left ='1' else int_ff_out(0);
	 
END rtl;