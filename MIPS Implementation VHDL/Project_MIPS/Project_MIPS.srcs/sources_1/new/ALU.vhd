library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
  Port ( 
        clk_i:          IN std_logic;
        input1_i:       IN std_logic_vector(31 downto 0);
        input2_i:       IN std_logic_vector(31 downto 0);
        ALUControl_i:   IN std_logic_vector(3 downto 0);
        ALUResult_o:    OUT std_logic_vector(31 downto 0) := (others => '0');
        Zero_o:         OUT std_logic := '0';
        -- UART
        UART_address_o: OUT std_logic_vector(31 downto 0) := (others => '0') -- calculated UART address
  );
end ALU;

architecture Behavioral of ALU is
    signal tempResult_s: std_logic_vector(31 downto 0) := (others => '0'); --temp result
    signal productReg_S: std_logic_vector(63 downto 0) := (others => '0'); -- 64-bit product register for mul and div
begin
    ALUProcess:process(clk_i)
    variable clkCounter_v: unsigned(7 downto 0) := (others => '0');
    variable shamt: integer;
    begin
        if(rising_edge(clk_i)) then 
            clkCounter_v := clkCounter_v+1;
            if (clkCounter_v = 3) then
                case ALUControl_i is 
                    when "0010" => -- add
                        tempResult_s <= std_logic_vector(signed(input1_i) + signed(input2_i));       
                    when "0000" => -- and
                        tempResult_s <= input1_i and input2_i;
                    when "0100" => -- nor
                        tempResult_s <= input1_i nor input2_i;    
                    when "0001" => -- or
                        tempResult_s <= input1_i or input2_i;                                                    
                    when "0111" => -- slt
                        if(input1_i < input2_i) then
                            tempResult_s <= x"00000001";
                        else
                            tempResult_s <= x"00000000";
                        end if;
                    when "1000" => -- sll
                        shamt := to_integer(unsigned(input1_i(10 downto 6)));
                        tempResult_s <= std_logic_vector(unsigned(input2_i) sll shamt);
                    when "0011" => -- srl
                        shamt := to_integer(unsigned(input1_i(10 downto 6)));
                        tempResult_s <= std_logic_vector(unsigned(input2_i) srl shamt);
                    when "0110" => -- sub
                        tempResult_s <= std_logic_vector(signed(input1_i) - signed(input2_i));   
                    when "1011" => -- lui
                        tempResult_s <= input2_i(15 downto 0) & "0000000000000000";  
                    when "1100" => -- mfhi
                        tempResult_s <= productReg_S(63 downto 32); 
                    when "1001" => -- mflo
                        tempResult_s <= productReg_S(31 downto 0);
                    when "1010" => -- mul
                        productReg_s <= std_logic_vector(signed(input1_i) * signed(input2_i)); 
                    when "1101" => -- divide
                        productReg_s(31 downto 0)  <= std_logic_vector(signed(signed(input1_i) / signed(input2_i))); 
                        productReg_s(63 downto 31) <= std_logic_vector(signed(input1_i) mod signed(input2_i));      
                    when others => null;
                        tempResult_s <= x"00000000";
                end case;
            elsif(clkCounter_v = 5) then
                clkCounter_v := (others => '0');
            end if;
        end if; 
    end process;
    -- Set ALUResult_o to tempResult_s
    ALUResult_o         <= tempResult_s;
    UART_address_o      <= tempResult_s;
    Zero_o <= '1' when tempResult_s = x"00000000" else '0';
end Behavioral ;