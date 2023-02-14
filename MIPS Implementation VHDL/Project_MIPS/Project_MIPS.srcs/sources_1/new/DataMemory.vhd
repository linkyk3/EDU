
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity DataMemory is
  Port ( 
    clk_i:          IN std_logic;
    address_i:      IN std_logic_vector(31 downto 0);
    writeData_i:    IN std_logic_vector(31 downto 0);
    MemWrite_i:     IN std_logic;
    MemRead_i:      IN std_logic;
    Byte_i:         IN std_logic;
    HalfWord_i:     IN std_logic;
    readData_o:     OUT std_logic_vector(31 downto 0) := (others => '0')
  );
end DataMemory;

architecture Behavioral of DataMemory is
    -- Declaratie geheugen
    subtype memword_t is std_logic_vector(31 downto 0); -- 1 geheugen element
    type mem_t is array(0 to 16) of memword_t; -- 16 words of 32bit memory
    
    signal memory : mem_t := (
        "00000000000000000000000000000000", -- 0
        "00000000000000000000000000000000", -- 1
        "00000000000000000000000000000011", -- 2 (val = 3)
        "00000000000000000000000000000101", -- 3 (val = 5)
        "11111111111111111111111111111111", -- 4 (test lbu, lhu)
        others => (others => '0')
    );

begin
    DataMemProcess:process(clk_i)
    variable clkCounter_v:unsigned(7 downto 0) := (others => '0');
    begin
        if (rising_edge(clk_i)) then
            clkCounter_v := clkCounter_v+1;
            if(clkCounter_v = 4) then -- mem read/write stage  
                if (address_i /= x"00004000") then -- check if address is not UART address      
                    if (MemWrite_i = '1') then -- write/store
                        if(Byte_i = '1') then -- store byte
                            memory(to_integer(unsigned(address_i)))(7 downto 0) <= writeData_i(7 downto 0);
                        elsif (HalfWord_i = '1') then -- store halfword
                            memory(to_integer(unsigned(address_i)))(15 downto 0) <= writeData_i(15 downto 0);   
                        else -- store word
                            memory(to_integer(unsigned(address_i))) <= writeData_i;
                        end if;
                    elsif (MemRead_i = '1') then -- read/load
                        if (Byte_i = '1') then -- load byte
                            readData_o <= "000000000000000000000000" & memory(to_integer(unsigned(address_i)))(7 downto 0);    
                        elsif (HalfWord_i = '1') then -- load halfword
                            readData_o <= "0000000000000000" & memory(to_integer(unsigned(address_i)))(15 downto 0);
                        else -- load word
                            readData_o <= memory(to_integer(unsigned(address_i)));
                        end if;
                    end if;
                end if;
            elsif(clkCounter_v = 5) then
                clkCounter_v := (others => '0');  
            end if;       
        end if;
    end process;
end Behavioral;
