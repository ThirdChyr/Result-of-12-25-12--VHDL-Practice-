library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity lupp is

end entity;

architecture sim of lupp is


begin
    process is
	begin

        report "Welcome to VHDL";

        loop
            report "Go in Loop";
            wait for 10 ns;
            exit;
        end loop;

            report "Good bye Loop and go out!";
            wait;

    end process;
end architecture;