library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity exam2_Transaction is
end entity;

architecture sim of exam2_transaction is 
    signal start : integer := 0;
    signal ending : integer := 10;

begin

    --Process single or double
    process is
    begin
        if start < ending then
            if (start mod 2 = 0) then
                 report "is Double";
            elsif (start mod 2 /= 0) then
                report "is Single";     
            else 
                report"nothing";
            end if;
        else
            wait;
        end if;
        
        start <= start + 1;
        wait for 10 ns;
    end process;
 
    --Break and ending;
  process is
    begin
            wait until start = ending;
           if start < ending then
                report "Process2 working";
            else
                report "Goodbye!!!";
                wait;
            end if;
    end process;

end architecture;