library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity Loop is

end entity;

architecture sim of Loop is


begin
    process is

        report "Welcome to VHDL";

        loop
            report "Go in Loop";
            wait for 10 ns;
        end loop;

            report "Good bye Loop and go out!";
            wait;

    end process;
end architecture;