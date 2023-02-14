library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity MIPS_tb is
end MIPS_tb;

architecture Behavioral of MIPS_tb is
    component MIPS is
        Port(
            clk:                IN std_logic;
            reset_PC_i:         IN std_logic;
            -- UART
            UART_Write_o:       OUT std_logic := '0';
            UART_Read_o:        OUT std_logic := '0';
            UART_address_o:     OUT std_logic_vector(31 downto 0) := (others => '0');
            UART_writeData_o:   OUT std_logic_vector(31 downto 0) := (others => '0');
            UART_readData_i:    IN std_logic_vector(31 downto 0);
            UART_ReadEN_i:      IN std_logic
        );
    end component;
    
    signal clk_s:               std_logic := '0';
    signal reset_PC_s:          std_logic := '0';
    signal UART_Write_o:        std_logic := '0';
    signal UART_Read_o:         std_logic := '0';
    signal UART_address_o:      std_logic_vector(31 downto 0) := (others => '0');
    signal UART_writeData_o:    std_logic_vector(31 downto 0) := (others => '0');
    signal UART_readData_i:     std_logic_vector(31 downto 0);
    signal UART_ReadEN_i:       std_logic;
    
    constant clkPeriod_s : time := 10 ns;
    
begin
    UUT:MIPS
    port map(
        clk                 => clk_s,
        reset_PC_i          => reset_PC_s,
        UART_Write_o        => UART_Write_o,
        UART_Read_o         => UART_Read_o,
        UART_address_o      => UART_address_o,
        UART_writeData_o    => UART_writeData_o,
        UART_readData_i     => UART_readData_i,
        UART_ReadEN_i       => UART_ReadEN_i
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
        UART_ReadEN_i <= '0';
        wait;
    end process;
    

end Behavioral;
