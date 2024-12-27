library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity exam3_Datatype is
end entity;

architecture sim of exam3_Datatype is
    signal dat : std_logic_vector(7 downto 0);
    signal dat2 : std_logic_vector(7 downto 0) := (others => '0');
    signal dat3 : std_logic_vector(7 downto 0) := (others => '1');


begin
    process is
        begin
        
            wait for 10 ns;

        end process;
end architecture;