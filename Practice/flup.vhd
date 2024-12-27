library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity flup is
end entity;

architecture sim of flup is

begin
    process is
        begin
          for i in 0 to 10 loop
            report "Hello Chayathon";
	    report "i =" & integer'image(i); 
         end loop ; 
         wait;
   end process;
end architecture;