
entity test is
end entity;

architecture sim of test is

begin
    process is
    begin
            report "Hello 1";
            wait for 10 ns;
            report "Hello 2";

    end process;
end architecture;