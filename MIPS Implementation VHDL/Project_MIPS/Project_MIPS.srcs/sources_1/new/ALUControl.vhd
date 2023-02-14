library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ALUControl is
    Port (
        clk_i:              IN std_logic;
        ALUOp_i:            IN std_logic_vector(2 downto 0);
        instr_ALUC_i:       IN std_logic_vector(5 downto 0); -- funct field
        ALUControl_o:       OUT std_logic_vector(3 downto 0) := (others => '0');
        ALUShiftLogic_o:    OUT std_logic := '0'
    );
end ALUControl;

architecture Behavioral of ALUControl is

begin
    ALUControlProcess:process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            -- first check ALUOp_i
            if (ALUOp_i = "000") then -- I-type: addi, lw/sw
                ALUControl_o <= "0010"; -- add
                ALUShiftLogic_o <= '0';
            elsif (ALUOp_i = "001") then -- I-type: beq, bne
                ALUControl_o <= "0110"; -- sub
                ALUShiftLogic_o <= '0';
            elsif (ALUOp_i = "011") then -- I-type: andi
                ALUControl_o <= "0000"; -- and
                ALUShiftLogic_o <= '0';
            elsif (ALUOp_i = "101") then -- I-type: ori
                ALUControl_o <= "0001"; -- or
                ALUShiftLogic_o <= '0';
            elsif (ALUOp_i = "100") then -- I-type: slti
                ALUControl_o <= "0111"; -- slt
                ALUShiftLogic_o <= '0';
            elsif (ALUOp_i = "110") then
                ALUControl_o <= "1011"; -- I-type: lui
                ALUShiftLogic_o <= '0';
            elsif (ALUOp_i = "010") then -- R-type instr 
                case instr_ALUC_i is
                    when "100000" => -- 0/0x20
                        ALUControl_o <= "0010"; -- add
                        ALUShiftLogic_o <= '0';
                    when "100100" => -- 0/0x24
                        ALUControl_o <= "0000"; -- and
                        ALUShiftLogic_o <= '0';
                    when "100111" => -- 0/0x27
                        ALUControl_o <= "0100"; -- nor
                        ALUShiftLogic_o <= '0';
                    when "100101" => -- 0/0x25
                        ALUControl_o <= "0001"; -- or
                        ALUShiftLogic_o <= '0';
                    when "101010" => -- 0/0x2a
                        ALUControl_o <= "0111"; -- set on less than
                        ALUShiftLogic_o <= '0';
                    when "000000" => -- 0/0x00
                        ALUControl_o <= "1000"; -- shift left logical
                        ALUShiftLogic_o <= '1';
                    when "000010" => -- 0/0x02                     
                        ALUControl_o <= "0011"; -- shift right logical
                        ALUShiftLogic_o <= '1';
                    when "100010" => -- 0/0x22
                        ALUControl_o <= "0110"; -- sub
                        ALUShiftLogic_o <= '0';   
                    when "010000" => -- 0/0x10
                        ALUControl_o <= "1100"; -- move from Hi
                        ALUShiftLogic_o <= '0';
                    when "010010" => -- 0/0x12
                        ALUControl_o <= "1001"; -- move from Lo
                        ALUShiftLogic_o <= '0';
                    when "011000" => -- 0/0x18
                        ALUControl_o <= "1010"; -- multiply
                        ALUShiftLogic_o <= '0';
                    when "011010" => -- 0/0x1a
                        ALUControl_o <= "1101"; -- divide
                        ALUShiftLogic_o <= '0';
                    when others =>
                        ALUControl_o <= "1111"; -- error code
                        ALUShiftLogic_o <= '0';                              
                end case;
            else
                ALUControl_o <= "1111"; -- error code
                ALUShiftLogic_o <= '0'; 
            end if;
        end if;
    end process;
end Behavioral;
