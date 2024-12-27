library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity Delay is


end entity;

architecture sim of Delay is

begin
    process is
        begin
            report "Delay started!!";
            --wait for 10 ns;
        end process;
end architecture;
