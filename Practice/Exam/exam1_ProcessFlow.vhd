Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity exam1_ProcessFlow is
end entity;


architecture sim of exam1_ProcessFlow is
    signal countdown : integer := 10;
    signal countup : integer := 0;

begin
        -- Process reset
        process is
        begin
            wait until countup = 10;
            report "Kaboom! reseto";
            --countup <= 0;
            wait for 10 ns;
        end process;

        --  Process Counting 
        process is 
        begin
           if countup < 10 then
            countup <= countup+1;
            report "Counting working!!";
            else
                wait;
            end if;
            wait for 10 ns;
        end process;
        
        process is 
        begin 
            wait until countup = countdown;
            report "Ending !!";
            wait;
        end process;


end architecture;
