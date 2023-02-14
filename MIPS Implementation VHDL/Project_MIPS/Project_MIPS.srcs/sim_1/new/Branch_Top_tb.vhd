library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Branch_Top_tb is
end Branch_Top_tb;

architecture Behavioral of Branch_Top_tb is

    component Branch_Top is
        Port (
            -- Input
            clk_i:                  IN std_logic;
            PC_Branch_i:            IN std_logic_vector(31 downto 0);
            directInput_Branch_i:   IN std_logic_vector(31 downto 0);
            -- Control
            Branch_i:               IN std_logic;
            Zero_i:                 IN std_logic;
            -- Output
            targetAddress_Branch_o: OUT std_logic_vector(31 downto 0) := (others => '0')  
        );
    end component;
    
    -- Input Signals
    signal clk_s:                   std_logic := '0';
    signal PC_s:                    std_logic_vector(31 downto 0) := (others => '0');
    signal directInput_s:           std_logic_vector(31 downto 0) := (others => '0');
    signal Branch_s:                std_logic := '0';
    signal Zero_s:                  std_logic := '0';
    signal targetAddress_s:         std_logic_vector(31 downto 0) := (others => '0');
    
    -- Clock divider constant
    constant clkPeriod_s : time := 10 ns;

begin
    UUT:Branch_Top
    port map(
        clk_i                   => clk_s,
        PC_Branch_i             => PC_s,
        directInput_Branch_i    => directInput_s,
        Branch_i                => Branch_s,
        Zero_i                  => Zero_s,
        targetAddress_Branch_o  => targetAddress_s
    );
    
    clk_s_process:process
    begin
        clk_s <= '0';
        wait for clkPeriod_s/2;
        clk_s <= '1';
        wait for clkPeriod_s/2;
    end process;
    
    stim_proc:process
    begin
        wait for 5ns;
        -- 2 Input signals
        PC_s            <= "00000000000000000000000000000001";
        directInput_s   <= "00011111111111111111111111111111";
        -- Changing Control signals
        Branch_s    <= '0';
        Zero_s      <= '0';
        wait for 10ns;
        Branch_s    <= '0';
        Zero_s      <= '1';
        wait for 10ns; -- change both back to 0 to clearly see the difference
        Branch_s    <= '0';
        Zero_s      <= '0';
        wait for 10ns;
        Branch_s    <= '1';
        Zero_s      <= '0';
        wait for 10ns;
        Branch_s    <= '0';
        Zero_s      <= '0';
        wait for 10ns;
        Branch_s    <= '1';
        Zero_s      <= '1';
        
        wait;
    end process;

end Behavioral;
