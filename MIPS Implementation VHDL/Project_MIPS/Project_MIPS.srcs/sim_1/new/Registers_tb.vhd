library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Registers_tb is
end Registers_tb;

architecture Behavioral of Registers_tb is
    component Registers is
        Port (
            clk_i:          IN std_logic;
            readReg1_i:     IN std_logic_vector(4 downto 0); -- R, I: rs
            readReg2_i:     IN std_logic_vector(4 downto 0); -- R, I: rt
            writeReg_i:     IN std_logic_vector(4 downto 0); -- R: rd 
            writeData_i:    IN std_logic_vector(31 downto 0);
            RegWrite_i:     IN std_logic;
            readData1_o:    OUT std_logic_vector(31 downto 0) := (others => '0');
            readData2_o:    OUT std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;
    
    -- Input Signals 
    signal clk_s:         std_logic;
    signal readReg1_s:   std_logic_vector(4 downto 0);
    signal readReg2_s:   std_logic_vector(4 downto 0);
    signal writeReg_s:   std_logic_vector(4 downto 0);
    signal writeData_s:  std_logic_vector(31 downto 0);
    signal RegWrite_s:    std_logic;
    -- Output Signals
    signal readData1_s:  std_logic_vector(31 downto 0);
    signal readData2_s:  std_logic_vector(31 downto 0);
    -- Fake Connections
    --Clock divider constant
    constant clkPeriod_c : time := 10 ns;

begin
    UUT:Registers
    port map(
        clk_i        => clk_s,
        readReg1_i   => readReg1_s,
        readReg2_i   => readReg2_s,
        writeReg_i   => writeReg_s,
        writeData_i  => writeData_s,
        RegWrite_i   => RegWrite_s,
        readData1_o  => readData1_s,
        readData2_o  => readData2_s
    );
    
    clk_process:process
    begin
        clk_s <= '0';
        wait for clkPeriod_c/2;
        clk_s <= '1';
        wait for clkPeriod_c/2;
    end process;
    
    stim_proc:process
    begin
         wait for 5ns;--synch
        -- Simulating R format
        RegWrite_s    <= '1';
        readReg1_s   <= "10001";
        readReg2_s   <= "10010";
        writeReg_s   <= "01000";
        wait for 10ns; -- wait 1 clock cycle for the data from the ALU
        writeData_s  <= "11111111111111111111111111111111";
        wait for 10ns;
        -- Using the data stored from the previous operation
        RegWrite_s    <= '1';
        readReg1_s   <= "01000"; -- write reg from previous
        readReg2_s   <= "10010";
        writeReg_s   <= "00100";
        wait for 10ns;
        writeData_s  <= "11111111111111111111111111111111";
        wait for 10ns;
        -- Simulating I Format
        RegWrite_s    <= '1';
        readReg1_s   <= "00100"; -- 4
        readReg2_s   <= "01010"; -- 10
        writeReg_s   <= "01010"; -- 10
        wait for 10ns;
        writeData_s  <= "11111111110000000000001111111111";
        wait for 10ns;
        -- Using the data stored from the previous operation
        RegWrite_s    <= '1';
        readReg1_s   <= "01010"; -- read from previous writeReg_s  (4)
        readReg2_s   <= "01000"; -- read from writeReg_s from first R instruction
        writeReg_s   <= "01000"; -- overwrite this reg
        wait for 10ns;
        writeData_s  <= "11111111110000111000001111111111";
        -- Simulating Reg Write 0
        wait for 10ns;
        RegWrite_s    <= '0';
        readReg1_s   <= "01010";
        readReg2_s   <= "01000";
        -- Still deliver new writeReg_s and writeData_s to see if we ignore it
        writeReg_s   <= "01110"; -- overwrite this reg
        wait for 10ns;
        writeData_s  <= "11000011110000111000001111111111";
        wait;
    end process;

end Behavioral;
