library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Control is
  Port ( 
        clk_i:          IN std_logic ;
        instr_Ctrl_i:   IN std_logic_vector(31 downto 0);
        RegDst_o:       OUT std_logic_vector(1 downto 0) := (others => '0'); -- expand to allow for jal to write to R[31]
        Jump_o:         OUT std_logic := '0';
        JumpReg_o:      OUT std_logic := '0';
        BEQ_o:          OUT std_logic := '0';
        BNE_o:          OUT std_logic := '0';
        MemRead_o:      OUT std_logic := '0';
        MemToReg_o:     OUT std_logic_vector(1 downto 0) := (others => '0'); -- expand for jal PC+4 to R[31]
        ALUOp_o:        OUT std_logic_vector(2 downto 0) := (others => '0');
        MemWrite_o:     OUT std_logic := '0';
        ALUSrc_o:       OUT std_logic := '0';
        RegWrite_o:     OUT std_logic := '0';
        Byte_o:         OUT std_logic := '0';
        HalfWord_o:     OUT std_logic := '0';
        UART_Write_o:   OUT std_logic := '0';
        UART_Read_o:    OUT std_logic := '0';
        WBMux_EN_o:     OUT std_logic := '0' -- control signal for write back mux
  );
end Control;

architecture Behavioral of Control is

begin
    ControlProcess:process(clk_i, instr_Ctrl_i)
    begin
        case instr_Ctrl_i(31 downto 26) is
            when "000000" => -- R-type: add, addu, and, jr, nor, or, slt, sltu, sll, srl, sub, subu : 0x00
                if (instr_Ctrl_i(5 downto 0) = "001000") then -- Jump Register(jr): 0/0x08
                    RegDst_o        <= "00";
                    Jump_o          <= '0';
                    JumpReg_o       <= '1';
                    BEQ_o           <= '0';
                    BNE_o           <= '0';
                    MemRead_o       <= '0';
                    MemToReg_o      <= "00";
                    ALUOp_o         <= "111"; -- other
                    MemWrite_o      <= '0';
                    ALUSrc_o        <= '0';
                    RegWrite_o      <= '0';
                    Byte_o          <= '0';
                    HalfWord_o      <= '0';  
                    UART_Write_o    <= '0';
                    WBMux_EN_o      <= '0';
                    UART_Read_o     <= '0';                          
                else -- add, addu, and, nor, or, slt, sltu, sll, srl, sub, subu
                    RegDst_o        <= "01";
                    Jump_o          <= '0';
                    JumpReg_o       <= '0';
                    BEQ_o           <= '0';
                    BNE_o           <= '0';
                    MemRead_o       <= '0';
                    MemToReg_o      <= "00";
                    ALUOp_o         <= "010"; -- R-type
                    MemWrite_o      <= '0';
                    ALUSrc_o        <= '0';
                    RegWrite_o      <= '1';
                    Byte_o          <= '0';
                    HalfWord_o      <= '0';
                    UART_Write_o    <= '0';
                    WBMux_EN_o      <= '0';
                    UART_Read_o     <= '0';  
                end if;
            
            when "001000" => -- I-type: Add Immediate(addi): 0x08
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '0';
                MemToReg_o          <= "00";
                ALUOp_o             <= "000"; -- add
                MemWrite_o          <= '0';
                ALUSrc_o            <= '1';
                RegWrite_o          <= '1';
                Byte_o              <= '0';
                HalfWord_o          <= '0';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0';    
                
            when "001001" => -- I-type: Add Immediate Unsigned (addiu): 0x09
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '0';
                MemToReg_o          <= "00";
                ALUOp_o             <= "000"; -- add
                MemWrite_o          <= '0';
                ALUSrc_o            <= '1';
                RegWrite_o          <= '1';
                Byte_o              <= '0';
                HalfWord_o          <= '0';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0';              
            
            when "101100" => -- I-type: And Immediate (andi): 0x0c
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '0';
                MemToReg_o          <= "00";
                ALUOp_o             <= "011"; -- and
                MemWrite_o          <= '0';
                ALUSrc_o            <= '1';
                RegWrite_o          <= '1';
                Byte_o              <= '0'; 
                HalfWord_o          <= '0';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0'; 
                
            when "100100" => -- I-type: Load Byte Unsigned(lbu): 0x24
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '1';
                MemToReg_o          <= "01";
                ALUOp_o             <= "000"; -- add
                MemWrite_o          <= '0';
                ALUSrc_o            <= '1';
                RegWrite_o          <= '1';   
                Byte_o              <= '1'; 
                HalfWord_o          <= '0';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '1';
                UART_Read_o         <= '1'; 
                
            when "100101" => -- I-type: Load Halfword Unsigned(lbu): 0x25
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '1';
                MemToReg_o          <= "01";
                ALUOp_o             <= "000"; -- add
                MemWrite_o          <= '0';
                ALUSrc_o            <= '1';
                RegWrite_o          <= '1';   
                Byte_o              <= '0'; 
                HalfWord_o          <= '1';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0'; 
           
           when "001111" => -- I-type: Load Upper Immediate(lui): 0x25
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '0';
                MemToReg_o          <= "00";
                ALUOp_o             <= "110"; -- add
                MemWrite_o          <= '0';
                ALUSrc_o            <= '1';
                RegWrite_o          <= '1';   
                Byte_o              <= '0'; 
                HalfWord_o          <= '0'; 
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0'; 
           
            
            when "100011" => -- I-type: Load Word(lw): 0x23
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '1';
                MemToReg_o          <= "01";
                ALUOp_o             <= "000"; -- add
                MemWrite_o          <= '0';
                ALUSrc_o            <= '1';
                RegWrite_o          <= '1';
                Byte_o              <= '0'; 
                HalfWord_o          <= '0';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0'; 
                
           when "001101" => -- I-type: Or Immediate(or): 0x0d
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '0';
                MemToReg_o          <= "00";
                ALUOp_o             <= "101"; -- or
                MemWrite_o          <= '0';
                ALUSrc_o            <= '1';
                RegWrite_o          <= '1';
                Byte_o              <= '0'; 
                HalfWord_o          <= '0';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0'; 
                
            when "001010" => -- I-type: Set Less Than Immediate(slti): 0x0a
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '0';
                MemToReg_o          <= "00";
                ALUOp_o             <= "100"; -- slti
                MemWrite_o          <= '0';
                ALUSrc_o            <= '1';
                RegWrite_o          <= '1';
                Byte_o              <= '0'; 
                HalfWord_o          <= '0';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0'; 
            
            when "101000" => -- I-type: Store Byte(sb): 0x28
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '0';
                MemToReg_o          <= "00";
                ALUOp_o             <= "000"; -- add
                MemWrite_o          <= '1';
                ALUSrc_o            <= '1';
                RegWrite_o          <= '0';
                Byte_o              <= '1'; 
                HalfWord_o          <= '0';
                UART_Write_o        <= '1';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0'; 
            
            when "101001" => -- I-type: Store Halfword(sh): 0x29
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '0';
                MemToReg_o          <= "00";
                ALUOp_o             <= "000"; -- add
                MemWrite_o          <= '1';
                ALUSrc_o            <= '1';
                RegWrite_o          <= '0';
                Byte_o              <= '0'; 
                HalfWord_o          <= '1';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0'; 
                
            when "101011" => -- I-type: Store Word(sw): 0x2b
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '0';
                MemToReg_o          <= "00";
                ALUOp_o             <= "000"; -- add
                MemWrite_o          <= '1';
                ALUSrc_o            <= '1';
                RegWrite_o          <= '0';
                Byte_o              <= '0'; 
                HalfWord_o          <= '0';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0'; 
                
            when "000100" => -- I-type: Branch on equal(beq): 0x04
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '1';
                BNE_o               <= '0';
                MemRead_o           <= '0';
                MemToReg_o          <= "00";
                ALUOp_o             <= "001"; -- sub
                MemWrite_o          <= '0';
                ALUSrc_o            <= '0';
                RegWrite_o          <= '0';
                Byte_o              <= '0'; 
                HalfWord_o          <= '0';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0'; 
            
            when "000101" => -- I-type: Branch on not equal(bne): 0x05
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '1';
                MemRead_o           <= '0';
                MemToReg_o          <= "00";
                ALUOp_o             <= "001"; -- sub
                MemWrite_o          <= '0';
                ALUSrc_o            <= '0';
                RegWrite_o          <= '0';
                Byte_o              <= '0'; 
                HalfWord_o          <= '0';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0'; 
            
            when "000010" => -- J-type: Jump(j): 0x02
                RegDst_o            <= "00";
                Jump_o              <= '1';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '0';
                MemToReg_o          <= "00";
                ALUOp_o             <= "111"; -- other
                MemWrite_o          <= '0';
                ALUSrc_o            <= '0';
                RegWrite_o          <= '0';
                Byte_o              <= '0'; 
                HalfWord_o          <= '0';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0'; 
            
            when "000011" => -- J-type: Jump and Link (jal): 0x03
                RegDst_o            <= "10"; -- R[31]
                Jump_o              <= '1';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '0';
                MemToReg_o          <= "10";
                ALUOp_o             <= "111"; -- other
                MemWrite_o          <= '0';
                ALUSrc_o            <= '0';
                RegWrite_o          <= '1'; -- write to reg!
                Byte_o              <= '0'; 
                HalfWord_o          <= '0';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0'; 
               
            when others => 
                RegDst_o            <= "00";
                Jump_o              <= '0';
                JumpReg_o           <= '0';
                BEQ_o               <= '0';
                BNE_o               <= '0';
                MemRead_o           <= '0';
                MemToReg_o          <= "00";
                ALUOp_o             <= "111"; -- other
                MemWrite_o          <= '0';
                ALUSrc_o            <= '0';
                RegWrite_o          <= '0';
                Byte_o              <= '0'; 
                HalfWord_o          <= '0';
                UART_Write_o        <= '0';
                WBMux_EN_o          <= '0';
                UART_Read_o         <= '0'; 
        end case;
    end process;
end Behavioral;
