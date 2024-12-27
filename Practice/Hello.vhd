
entity Hello is
end entity;

architecture sim of Hello is

begin
    process is
    begin
            report "Hello Vhdl";
            wait for 10 ns;
    end process;
end architecture;