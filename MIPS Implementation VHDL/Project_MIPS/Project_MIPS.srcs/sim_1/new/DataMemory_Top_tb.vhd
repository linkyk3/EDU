library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataMemory_Top_tb is
end DataMemory_Top_tb;

architecture Behavioral of DataMemory_Top_tb is
    component DataMemory_top is
        Port (
        -- Input
        clk_i:          IN std_logic;
        address_DM_i:   IN std_logic_vector(31 downto 0);
        writeData_DM_i: IN std_logic_vector(31 downto 0);
        -- Control
        MemtoReg_i:     IN std_logic;
        MemWrite_i:     IN std_logic;
        MemRead_i:      IN std_logic;
        -- Output
        writeData_DM_o: OUT std_logic_vector(31 downto 0)
        );
    end component;

    -- Input Signals
    signal clk_s:       std_logic := '0';
    signal address_s:   std_logic_vector(31 downto 0) := (others => '0');
    signal writeData_s: std_logic_vector(31 downto 0) := (others => '0');
    -- Control Signals
    signal MemtoReg_s:  std_logic := '0';
    signal MemWrite_s:  std_logic := '0';
    signal MemRead_s:   std_logic := '0';
    -- Output Signals
    signal writeDataOutput_s: std_logic_vector(31 downto 0) := (others => '0');
    
    --Clock divider constant
    constant clkPeriod_s : time := 10 ns;
    
begin
    UUT:DataMemory_Top
    port map(
        clk_i           => clk_s,
        address_DM_i    => address_s,
        writeData_DM_i  => writeData_s,
        MemtoReg_i      => MemtoReg_s,
        MemWrite_i      => MemWrite_s,
        MemRead_i       => MemRead_s,
        writeData_DM_o  => writeDataOutput_s
    );
    
    clk_process:process
    begin
        clk_s <= '0';
        wait for clkPeriod_s/2;
        clk_s <= '1';
        wait for clkPeriod_s/2;
    end process;

    stim_proc:process
    begin
        wait for 5ns;
        -- Write to memory
        MemWrite_s   <= '1';
        MemRead_s    <= '0';
        MemtoReg_s   <= '0';
        address_s    <= "00000000000000000000000000000010";
        writeData_s  <= "11111111110000000000001111111111";
        wait for 10ns;
        -- Read from memory -> takes 2 clock cycles to get to the writeData_s of the Mux
        MemWrite_s   <= '0';
        MemRead_s    <= '1';
        MemtoReg_s   <= '1';
        address_s    <= "00000000000000000000000000000010";
        wait;
    end process;

end Behavioral;
