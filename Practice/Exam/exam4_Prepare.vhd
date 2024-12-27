library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity exam4_Prepare is
end entity;

architecture sim of exam4_Prepare is
    signal sig1 : std_logic := '0';
begin
    process is
    begin
        wait for 10 ns;
        sig1 <= not sig1;
    end process;
end architecture;