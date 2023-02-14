library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Registers_Top_tb is
end Registers_Top_tb;

architecture Behavioral of Registers_Top_tb is
    
    component Registers_Top is
      Port ( 
        -- Input 
        clk_RegT_i:         IN std_logic;
        instr_RegT_i:       IN std_logic_vector(31 downto 0);
        writeData_RegT_i:   IN std_logic_vector(31 downto 0);
        -- Control 
        RegDst_i:           IN std_logic;
        RegWrite_i:         IN std_logic;
        -- Outpu
        readData1_RegT_o:   OUT std_logic_vector(31 downto 0) := (others => '0');
        readData2_RegT_o:   OUT std_logic_vector(31 downto 0) := (others => '0') 
    );
    end component;
    
    -- Input Signals
    signal clk_s:           std_logic := '0';
    signal instr_s:         std_logic_vector(31 downto 0);
    signal writeData_s:     std_logic_vector(31 downto 0);
    -- Control Signals
    signal RegDst_s:        std_logic := '0';
    signal RegWrite_s:      std_logic := '0';
    -- Output Signals
    signal readData1_s:     std_logic_vector(31 downto 0);
    signal readData2_s:     std_logic_vector(31 downto 0);
    
    --Clock divider constant
    constant clkPeriod_s : time := 10 ns;
    
begin
    UUT:Registers_Top
    port map(
        clk_RegT_i          => clk_s,
        instr_RegT_i        => instr_s,
        writeData_RegT_i    => writeData_s,
        RegDst_i            => RegDst_s,
        RegWrite_i          => RegWrite_s,
        readData1_RegT_o    => readData1_s,
        readData2_RegT_o    => readData2_s
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
        -- Simulating R format
        RegWrite_s   <= '1';
        RegDst_s     <= '1';
        instr_s      <= "00000010001100100100000000000000"; -- read_reg1 = 10001(11), read_reg2 = 10010(12), write_reg = 01000(08)
        wait for 10ns; -- wait 1 clock cycle for the data from the ALU
        writeData_s  <= "11111111111111111111111111111111";
        wait for 10ns;
        -- Using the data stored from the previous operation
        RegWrite_s   <= '1';
        RegDst_s     <= '1';
        instr_s      <= "00000001000100100010000000000000"; -- read_reg1 = 01000(08), read_reg2 = 10010(12), write_reg = 00100(04)
        wait for 10ns; 
        writeData_s  <= "11111111111111111111111111111111";
        wait for 10ns;
        -- Simulating I format
        RegWrite_s   <= '1';
        RegDst_s     <= '0';
        instr_s      <= "00000000100010100101000000000000"; -- read_reg1 = 00100(4), read_reg2 = 01010(10), write_reg = 01010(10)(dont care)
        wait for 10ns; 
        writeData_s  <= "11111111110000000000001111111111";
        wait for 10ns;
        -- using the data stored from the previous operation
        RegWrite_s   <= '1';
        RegDst_s     <= '0';
        instr_s      <= "00000001010010000100000000000000"; -- read_reg1 = 01010(10), read_reg2 = 01000(08), write_reg = 01000(08)(dont care)
        wait for 10ns; 
        writeData_s  <= "11111111110000000000001111111111";
        wait for 10ns;
        -- Simulating Reg Write 0
        RegWrite_s   <= '0';
        RegDst_s     <= '1'; -- 1 of iets anders 
        instr_s      <= "00000001000001000100000000000000"; -- read_reg1 = 01000(), read_reg2 = 00100(), write_reg = 01000()(dont care)
        wait for 10ns; 
        -- Still deliver new write_reg and writeData_s to see if we ignore it
        writeData_s  <= "11111111110000000000001111111111";
        wait;
    end process;
    

end Behavioral;
