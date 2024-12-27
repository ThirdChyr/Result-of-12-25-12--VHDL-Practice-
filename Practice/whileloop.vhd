library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity whileloop is
end entity;

architecture sim of whileloop is

    begin
        process is
            variable j : integer := 0;
            variable i : integer := 0;
            begin
         while i < 10 loop
            report "Hello Chayathon";
                while j<5 loop
                report "in j loop";
                j := j + 1;
            end loop ;  
            j := 0;
            i := i + 1;
        end loop ; 
        wait;
    end process;
end architecture;