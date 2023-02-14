library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity MIPSwUART_tb is
end MIPSwUART_tb;

architecture Behavioral of MIPSwUART_tb is
    component MIPSwUART is
        Port(
            clk:                    IN std_logic;
            reset_PC:               IN std_logic;
            -- UART
            UART_RX_pin_i:          IN std_logic; 
            UART_RX_Serial_i:       IN std_logic;
            UART_RX_Receiving_o:    OUT std_logic := '0';
            UART_TX_Active_o:       OUT std_logic := '0';
            UART_TX_Serial_o:       OUT std_logic := '0';
            UART_TX_Done_o:         OUT std_logic := '0';
            UART_TX_pin_o:          OUT std_logic := '0'
        );
    end component;
    
    signal clk_s:               std_logic := '0';
    signal reset_PC_s:          std_logic := '0';
    signal UART_RX_Serial_s:    std_logic := '1'; -- RX input
    signal UART_RX_pin_s:       std_logic := '0'; 
    signal UART_RX_Receiving_s: std_logic := '0';
    signal UART_TX_Active_s:    std_logic := '0';
    signal UART_TX_Serial_s:    std_logic := '0';
    signal UART_TX_Done_s:      std_logic := '0';
    signal UART_TX_pin_s:       std_logic := '0';
    
    constant clkPeriod_c : time := 100 ns; -- 10MHz
    constant clksPerBit_c : integer := 87;
    constant bitPeriod_c : time := 8680 ns;
    
    procedure UART_WRITE_BYTE (
        i_data_in       : in  std_logic_vector(7 downto 0);
        signal o_serial : out std_logic) is
        begin
            -- Send Start Bit
            o_serial <= '0';
            wait for bitPeriod_c;
 
            -- Send Data Byte
            for ii in 0 to 7 loop
              o_serial <= i_data_in(ii);
              wait for bitPeriod_c;
            end loop;  -- ii
 
            -- Send Stop Bit
            o_serial <= '1'; wait for bitPeriod_c; 
    end UART_WRITE_BYTE;
    
begin
    UUT:MIPSwUART
        port map(
            clk                 => clk_s,
            reset_PC            => reset_PC_s,
            UART_RX_pin_i       => UART_RX_pin_s,
            UART_RX_Serial_i    => UART_RX_Serial_s,
            UART_RX_Receiving_o => UART_RX_Receiving_s,
            UART_TX_Active_o    => UART_TX_Active_s,
            UART_TX_Serial_o    => UART_TX_Serial_s,
            UART_TX_Done_o      => UART_TX_Done_s,
            UART_TX_pin_o       => UART_TX_pin_s
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
    wait for 50ns;
    wait;
    end process;   
end Behavioral;
