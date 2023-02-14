library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPSwUART is
  Port ( 
        clk:                    IN std_logic;
        reset_PC:               IN std_logic;
        -- UART -> UART in and outputs
        UART_RX_pin_i:          IN std_logic; 
        UART_RX_Serial_i:       IN std_logic;
        UART_RX_Receiving_o:    OUT std_logic := '0';
        UART_TX_Active_o:       OUT std_logic := '0';
        UART_TX_Serial_o:       OUT std_logic := '0';
        UART_TX_Done_o:         OUT std_logic := '0';
        UART_TX_pin_o:          OUT std_logic := '0';
        UART_RX_Busy_o:         OUT std_logic := '0'
  );
end MIPSwUART;

architecture Behavioral of MIPSwUART is
    
    component MIPS is
        Port (
            clk:                IN std_logic;
            reset_PC_i:         IN std_logic;
            -- UART -> from MIPS to UART and UART to MIPS
            UART_Write_o:       OUT std_logic := '0';
            UART_Read_o:        OUT std_logic := '0';
            UART_address_o:     OUT std_logic_vector(31 downto 0) := (others => '0');
            UART_writeData_o:   OUT std_logic_vector(31 downto 0) := (others => '0');
            UART_readData_i:    IN std_logic_vector(31 downto 0);
            UART_ReadEN_i:      IN std_logic;
            UART_RX_Busy_i:     IN std_logic
        );
    end component;
    
    component UART_Top is
        Port (
            clk:                IN std_logic;
            -- RX
            RX_frame_o:         OUT std_logic_vector(31 downto 0) := (others => '0'); -- ReadData MIPS
            FPGA_RX_pin_i:      IN std_logic; --Dummy "pin" that would physically receives the serial Rx signal
            RX_Serial_i:        IN  std_logic; 
            RX_receiving_o:     OUT std_logic := '0'; --ReadEN for MIPS MUX        
            -- TX
            TX_frame_i:         IN std_logic_vector(31 downto 0); -- WriteData MIPS
            TX_Active_o:        OUT std_logic := '0';
            TX_Serial_o:        OUT std_logic := '0';
            TX_Done_o:          OUT std_logic := '0';
            FPGA_TX_pin_o:      OUT std_logic := '0'; --Dummy "pin" that would physically transmits the serial Tx signal 
            -- Other
            TX_EN_i:            IN std_logic; -- Write for MIPS, TX for UART
            RX_EN_i:            IN std_logic; -- Read for MIPS, RX for UART
            UART_address_i:     IN std_logic_vector(31 downto 0);       
            Read_EN_o:          OUT std_logic := '0' --Drives R/W MUX outside of UART module
        );
    end component;
    
    -- Corresponding Signals
    signal Write_TX_EN_s:       std_logic := '0';
    signal Read_RX_En_s:        std_logic := '0';
    signal UART_address_s:      std_logic_vector(31 downto 0) := (others => '0');
    signal writeData_TXframe_s: std_logic_vector(31 downto 0) := (others => '0');
    signal readData_RXframe_s:  std_logic_vector(31 downto 0) := (others => '0');
    signal ReadEN_s:            std_logic := '0';
    signal UART_RX_Busy_s:      std_logic := '0';
    
begin
    
    MIPSModule:MIPS
    port map(
        clk                 => clk,
        reset_PC_i          => reset_PC,
        UART_Write_o        => Write_TX_EN_s,
        UART_Read_o         => Read_RX_EN_s,
        UART_address_o      => UART_address_s,
        UART_writeData_o    => writeData_TXframe_s,
        UART_readData_i     => readData_RXframe_s,
        UART_ReadEN_i       => UART_RX_Busy_s,
        UART_RX_Busy_i      => UART_RX_Busy_s
    );
    
    UARTModule:UART_Top
    port map(
        clk             => clk,
        -- RX
        RX_frame_o      => readData_RXframe_s,
        FPGA_RX_pin_i   => UART_RX_pin_i,
        RX_Serial_i     => UART_RX_Serial_i,
        RX_Receiving_o  => UART_RX_Receiving_o,
        -- TX
        TX_frame_i      => writeData_TXframe_s, 
        TX_Active_o     => UART_TX_Active_o,
        TX_Serial_o     => UART_TX_Serial_o,
        TX_Done_o       => UART_TX_Done_o,
        FPGA_TX_pin_o   => UART_TX_pin_o,
        -- Other
        TX_EN_i         => Write_TX_EN_s,
        RX_EN_i         => Read_RX_EN_s,
        UART_address_i  => UART_address_s, 
        Read_EN_o       => UART_RX_Busy_s
    );

end Behavioral;
