library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Registers is
  Port ( 
        clk_i:              IN std_logic;
        readReg1_i:         IN std_logic_vector(4 downto 0); -- R, I: rs
        readReg2_i:         IN std_logic_vector(4 downto 0); -- R, I: rt
        writeReg_i:         IN std_logic_vector(4 downto 0); -- R: rd 
        writeData_i:        IN std_logic_vector(31 downto 0);
        RegWrite_i:         IN std_logic;
        readData1_o:        OUT std_logic_vector(31 downto 0) := (others => '0');
        readData2_o:        OUT std_logic_vector(31 downto 0) := (others => '0');
        -- UART
        UART_writeData_o:   OUT std_logic_vector(31 downto 0) := (others => '0') -- copy of readData2_o
  );
end Registers;

architecture Behavioral of Registers is
    -- Declaratie geheugen: 32x32bits memory word
    subtype memword_t is std_logic_vector(31 downto 0); -- 1 geheugen element
    type mem_t is array(0 to 31) of memword_t; -- 32 general puprose registers, 32bit wide
    
    signal registers : mem_t := (
	   "00000000000000000000000000000000", -- 0
	   "00000000000000000000000000000001", -- 1
	   "00000000000000000000000000000011", -- 2 (val = 3)
	   "00000000000000000000000000000101", -- 3 (val = 5)
	   "01111111111111111111111111111111", -- 4 (test sb, sh)
	   "00000000000000000000000000101000", -- 5 (val = 0x00400028 -> jr) -> 10th instruction 
	   "00000000000000000000000000000001", -- 6 (for beq, bne)
        others => (others => '0')
    );
    
begin
    RegistersProcess:process(clk_i)
    variable clkCounter_v:unsigned(7 downto 0) := (others => '0');
    begin
        if (rising_edge(clk_i)) then
            clkCounter_v := clkCounter_v+1;
            if(clkCounter_v = 2) then -- read from register
                -- reads doorgeven naar outputs
                readData1_o     <= registers(to_integer(unsigned(readReg1_i)));
                readData2_o     <= registers(to_integer(unsigned(readReg2_i)));
                UART_writeData_o <= registers(to_integer(unsigned(readReg2_i)));
            -- depending on R or I type instruction -> write to registers in 4th or 5th cycle                
            elsif(clkCounter_v = 4) then
                if (RegWrite_i = '1' and writeReg_i /= readReg2_i) then -- R format
                    registers(to_integer(unsigned(writeReg_i))) <= writeData_i;
                elsif(RegWrite_i = '1' and writeReg_i = readReg2_i) then  -- I-format
                   registers(to_integer(unsigned(readReg2_i))) <= writeData_i;
                end if;
            elsif(clkCounter_v = 5) then    
                clkCounter_v := (others => '0'); 
            end if; 
        end if;                
    end process;
end Behavioral;
