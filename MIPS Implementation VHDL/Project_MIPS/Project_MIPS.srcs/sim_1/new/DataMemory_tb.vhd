library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity DataMemory_tb is
end DataMemory_tb;

architecture Behavioral of DataMemory_tb is
    component DataMemory is
        Port (
            clk:        IN std_logic;
            address:    IN std_logic_vector(31 downto 0);
            write_data: IN std_logic_vector(31 downto 0);
            MemWrite:   IN std_logic;
            MemRead:    IN std_logic;
            read_data:  OUT std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;
    
    -- Input Signals
    signal clk:         std_logic;
    signal address:     std_logic_vector(31 downto 0);
    signal write_data:  std_logic_vector(31 downto 0);
    -- Control Signals
    signal MemWrite:    std_logic;
    signal MemRead:     std_logic;
    -- Output Signal
    signal read_data:   std_logic_vector(31 downto 0);
    
    --Clock divider constant
    constant clk_period : time := 10 ns;
    
begin
    UUT:DataMemory
    port map(
        clk         => clk,
        address     => address,
        write_data  => write_data,
        MemWrite    => MemWrite,
        MemRead     => MemRead,
        read_data   => read_data
    );
    
    clk_process:process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    stim_proc:process
    begin
        wait for 5ns;
        MemWrite    <= '1';
        MemRead     <= '0';
        address     <= "00000000000000000000000000000010";
        write_data  <= "11111111110000000000001111111111";
        wait for 10ns;
        MemWrite    <= '0';
        MemRead     <= '1';
        address     <= "00000000000000000000000000000010";
        wait;
    end process;

end Behavioral;
