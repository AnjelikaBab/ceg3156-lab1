library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shiftleft1 is
    Port (
        data_in  : in  STD_LOGIC_VECTOR(7 downto 0); 
        data_out : out STD_LOGIC_VECTOR(7 downto 0)  
    );
end shiftleft1;

architecture structural of shiftleft1 is
begin
    -- Shift left by 1 by taking the 6 lsbs of the input and concatenating a 0
    data_out <= data_in(6 downto 0) & '0';
end structural;