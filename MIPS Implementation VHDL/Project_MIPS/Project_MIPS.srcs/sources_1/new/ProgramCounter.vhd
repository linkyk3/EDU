library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ProgramCounter is
  Port ( 
        clk_i:          IN std_logic;
        reset_i:        IN std_logic;
        UART_RX_Busy_i: IN std_logic; -- check if the RX process is done or not
        PCNext_i:       IN std_logic_vector(31 downto 0); -- next PC
        PCCurrent_o:    OUT std_logic_vector(31 downto 0) := x"00000000" -- current PC of instruction
  );
end ProgramCounter;

architecture Behavioral of ProgramCounter is

    signal PCBuffer_s:    std_logic_vector(31 downto 0) := x"00000000"; -- buffer

begin
ProgramCounterProcess:process(clk_i, reset_i)
    variable clkCounter_v:unsigned(7 downto 0) := (others => '0');
    begin
        if(UART_RX_Busy_i = '0') then -- not busy
            if (reset_i = '1') then 
                clkCounter_v := (others => '0'); 
            elsif(rising_edge(clk_i)) then
                clkCounter_v := clkCounter_v + 1;         
                if(clkCounter_v = 4) then -- make sure the buffer is transfered to the output, before the next instruction begins                    
                    PCCurrent_o <= PCBuffer_s;
                elsif(clkCounter_v = 5) then        
                    clkCounter_v := (others => '0'); 
                end if;
            end if;
        elsif(UART_RX_Busy_i = '1') then -- busy -> block PC from updating
            clkCounter_v := (others => '0'); 
        end if;
    end process;
    PCBuffer_s <= PCNext_i;
end Behavioral;
