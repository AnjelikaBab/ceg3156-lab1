 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shiftright1 is
    Port (
        data_in  : in  STD_LOGIC_VECTOR(7 downto 0); 
        data_out : out STD_LOGIC_VECTOR(7 downto 0)  
    );
end shiftright1;

architecture structural of shiftright1 is
begin
    -- Shift right by 1 by taking the 6 msbs of the input and concatenating a 0
    data_out <= '0' & data_in(7 downto 1);
end structural;