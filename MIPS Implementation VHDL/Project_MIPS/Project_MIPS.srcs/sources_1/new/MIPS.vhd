library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPS is
    Port ( 
        clk:                        IN std_logic;
        reset_PC_i:                 IN std_logic;
        -- UART
        UART_Write_o:               OUT std_logic := '0';
        UART_Read_o:                OUT std_logic := '0';
        UART_address_o:             OUT std_logic_vector(31 downto 0) := (others => '0');
        UART_writeData_o:           OUT std_logic_vector(31 downto 0) := (others => '0');
        UART_readData_i:            IN std_logic_vector(31 downto 0);
        UART_ReadEN_i:              IN std_logic;
        UART_RX_Busy_i:             IN std_logic
    );
end MIPS;

architecture Behavioral of MIPS is
    -- ProgramCounterTop containing the PC, Adder and Instruction Memory
    component ProgramCounter_Top is
        Port (
            clk_i:                  IN std_logic;
            reset_PC_i:             IN std_logic;
            UART_RX_Busy_i:         IN std_logic;
            PC_PC_i:                IN std_logic_vector (31 downto 0);
            PC_PC_o:                OUT std_logic_vector(31 downto 0) := (others => '0');
            instr_PC_o:             OUT std_logic_vector(31 downto 0) := (others => '0')        
        );
    end component;
    -- Control module 
    component Control is
        Port (
            clk_i:                  IN std_logic ;
            instr_Ctrl_i:           IN std_logic_vector(31 downto 0);
            RegDst_o:               OUT std_logic_vector(1 downto 0) := (others => '0');
            Jump_o:                 OUT std_logic := '0';
            JumpReg_o:              OUT std_logic := '0';
            BEQ_o:                  OUT std_logic := '0';
            BNE_o:                  OUT std_logic := '0';
            MemRead_o:              OUT std_logic := '0';
            MemToReg_o:             OUT std_logic_vector(1 downto 0) := (others => '0');
            ALUOp_o:                OUT std_logic_vector(2 downto 0) := (others => '0');
            MemWrite_o:             OUT std_logic := '0';
            ALUSrc_o:               OUT std_logic := '0';
            RegWrite_o:             OUT std_logic := '0';
            Byte_o:                 OUT std_logic := '0';
            HalfWord_o:             OUT std_logic := '0';
            UART_Write_o:           OUT std_logic := '0';
            WBMux_EN_o:             OUT std_logic := '0';
            UART_Read_o:            OUT std_logic := '0'
        );
    end component;
    -- Register Module with Mux
    component Registers_Top is
        Port(
            clk_i:                  IN std_logic;
            instr_RegT_i:           IN std_logic_vector(31 downto 0);
            writeData_RegT_i:       IN std_logic_vector(31 downto 0);
            RegDst_i:               IN std_logic_vector(1 downto 0);
            RegWrite_i:             IN std_logic;
            readData1_RegT_o:       OUT std_logic_vector(31 downto 0) := (others => '0');
            readData2_RegT_o:       OUT std_logic_vector(31 downto 0) := (others => '0');
            UART_writeData_RegT_o:  OUT std_logic_vector(31 downto 0) := (others => '0') -- copy of readData2 for UART write  
        );
    end component;
    -- ALU Module with Muxs
    component ALU_Top is
        Port (
            -- Input
            clk_i:                  IN std_logic;
            readData1_ALU_i:        IN std_logic_vector(31 downto 0);
            readData2_ALU_i:        IN std_logic_vector(31 downto 0);
            signExt_ALU_i:          IN std_logic_vector(31 downto 0);
            instr_ALU_i:            IN std_logic_vector(31 downto 0); -- for shamt
            -- Control
            ALUControl_i:           IN std_logic_vector(3 downto 0);
            ALUSrc_i:               IN std_logic;
            ALUShiftLogic_i:        IN std_logic;
            -- Output
            ALUResult_ALU_o:        OUT std_logic_vector(31 downto 0) := (others => '0');
            Zero_ALU_o:             OUT std_logic := '0';
            -- UART
            UART_address_ALU_o:     OUT std_logic_vector(31 downto 0) := (others => '0') -- calculated UART address
        );
    end component;
    -- Sign Extend Module
    component SignExtend is
        Port (
            clk_i:                  IN std_logic;
            instr_SE_i:             IN std_logic_vector(15 downto 0);
            immediate_SE_o:         OUT std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;
    -- ALU Control Module
    component ALUControl is
        Port (
            clk_i:                  IN std_logic;
            ALUOp_i:                IN std_logic_vector(2 downto 0);
            instr_ALUC_i:           IN std_logic_vector(5 downto 0); 
            ALUControl_o:           OUT std_logic_vector(3 downto 0) := (others => '0');
            ALUShiftLogic_o:        OUT std_logic := '0'  
        );
    end component;
    -- Data Memory module with Mux
    component DataMemory_Top is
        Port (
            clk_i:                  IN std_logic;
            address_DM_i:           IN std_logic_vector(31 downto 0);
            writeData_DM_i:         IN std_logic_vector(31 downto 0);
            PC_DM_i:                IN std_logic_vector(31 downto 0);
            MemtoReg_i:             IN std_logic_vector(1 downto 0);
            MemWrite_i:             IN std_logic;
            MemRead_i:              IN std_logic;
            Byte_i:                 IN std_logic;
            HalfWord_i:             IN std_logic;
            readWriteData_DM_o:     OUT std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;
    -- Write Back Mux -> choses between UART input or Data Memory input
    component MUXWriteBack is
        Port (
            clk_i:                  IN std_logic;
            readWriteData_i:        IN std_logic_vector(31 downto 0); -- ALU Result/Read data from mem
            UART_readData_i:        IN std_logic_vector(31 downto 0); -- UART read data
            ReadEN:                 IN std_logic;
            writeData_o:            OUT std_logic_vector(31 downto 0) := (others => '0')    
        );
    end component;    
    -- Jump module calculates jump address
    component JumpBlock is
        Port (
            clk_i:                  IN std_logic;
            instr_i:                IN std_logic_vector(31 downto 0); -- slice to 25-0
            PC_i:                   IN std_logic_vector(31 downto 0);
            jumpAddress_o:          OUT std_logic_vector(31 downto 0) := (others => '0')   
        );
    end component;
    -- Branch module calculates the branch address
    component Branch_Top is
        Port (
            clk_i:                  IN std_logic;
            PC_Branch_i:            IN std_logic_vector(31 downto 0);
            directInput_Branch_i:   IN std_logic_vector(31 downto 0);
            -- Control
            BEQ_i:                  IN std_logic;
            BNE_i:                  IN std_logic;
            Zero_i:                 IN std_logic;
            -- Output
            targetAddress_Branch_o: OUT std_logic_vector(31 downto 0) := (others => '0')           
        );
    end component;
    -- End Mux choses between the branch or jump address
    component MUXEnd is
        Port (
            clk_i:                  IN std_logic;
            targetAddress_i:        IN std_logic_vector(31 downto 0);
            jumpAddress_i:          IN std_logic_vector(31 downto 0);
            Jump_i:                 IN std_logic;
            endAddress_o:           OUT std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;
    -- Jump Reg Mux choses between the end address or the register address
    component MUXJumpReg is
        Port (
            clk_i:                  IN std_logic;
            registerAddress_i:      IN std_logic_vector(31 downto 0); 
            endAddress_i:           IN std_logic_vector(31 downto 0); 
            JumpRegister_i:         IN std_logic;
            PCAddress_o:            OUT std_logic_vector(31 downto 0) := (others => '0')    
        );
    end component;
    
    -- Internal Signals:
    -- Data Signals
    signal PCAddress_s:             std_logic_vector(31 downto 0) := (others => '0'); 
    signal PC_s:                    std_logic_vector(31 downto 0) := (others => '0');
    signal instr_s:                 std_logic_vector(31 downto 0) := (others => '0'); 
    signal jumpAddress_s:           std_logic_vector(31 downto 0) := (others => '0');
    signal targetAddress_s:         std_logic_vector(31 downto 0) := (others => '0');
    signal endAddress_s:            std_logic_vector(31 downto 0) := (others => '0');
     -- Control Signals:
    signal RegDst_s:                std_logic_vector(1 downto 0) := (others => '0');
    signal MemRead_s:               std_logic := '0';
    signal MemToReg_s:              std_logic_vector(1 downto 0) := (others => '0');
    signal ALUOp_s:                 std_logic_vector(2 downto 0) := (others => '0');
    signal MemWrite_s:              std_logic := '0';
    signal ALUSrc_s:                std_logic := '0';
    signal RegWrite_s:              std_logic := '0';
    signal Byte_s:                  std_logic := '0';
    signal HalfWord_s:              std_logic := '0';
    signal JumpReg_s:               std_logic := '0';
    signal Jump_s:                  std_logic := '0';
    signal BEQ_s:                   std_logic := '0';
    signal BNE_s:                   std_logic := '0';
    signal Zero_s:                  std_logic := '0';
    signal WBMux_EN_s:              std_logic := '0';
    -- Registers Top:
    signal readData1_s:             std_logic_vector(31 downto 0) := (others => '0');
    signal readData2_s:             std_logic_vector(31 downto 0) := (others => '0');
    -- Sign extend:
    signal signExtend_s:            std_logic_vector(31 downto 0) := (others => '0');
    -- ALU Control
    signal ALUControl_s:            std_logic_vector(3 downto 0) := (others => '0');
    signal ALUShiftLogic_s:         std_logic := '0';
    -- ALU:
    signal ALUResult_s:             std_logic_vector(31 downto 0) := (others => '0');
    -- Data Mem Mux:
    signal dataMemMuxOutput_s:      std_logic_vector(31 downto 0) := (others => '0');
    -- Write Back Mux:
    signal writeDataWBMux_s:        std_logic_vector(31 downto 0) := (others => '0');
    
begin
    ProgramCounterTop:ProgramCounter_Top
    port map(
        clk_i                       => clk,
        reset_PC_i                  => reset_PC_i,
        UART_RX_Busy_i              => UART_RX_Busy_i,
        PC_PC_i                     => PCAddress_s,
        PC_PC_o                     => PC_s,
        instr_PC_o                  => instr_s
    );
    
    ControlBlock:Control
    port map(
        clk_i                       => clk,
        instr_Ctrl_i                => instr_s,
        RegDst_o                    => RegDst_s,
        Jump_o                      => Jump_s,
        JumpReg_o                   => JumpReg_s,
        BEQ_o                       => BEQ_s,
        BNE_o                       => BNE_s,
        MemRead_o                   => MemRead_s,
        MemToReg_o                  => MemToReg_s,
        ALUOp_o                     => ALUOp_s,
        MemWrite_o                  => MemWrite_s,
        ALUSrc_o                    => ALUSrc_s,
        RegWrite_o                  => RegWrite_s,
        Byte_o                      => Byte_s,
        HalfWord_o                  => HalfWord_s,
        UART_Write_o                => UART_Write_o,
        WBMux_EN_o                  => WBMux_EN_s,
        UART_Read_o                 => UART_Read_o
    );
    
    RegistersTop:Registers_Top
    port map(
        clk_i                       => clk,
        instr_RegT_i                => instr_s,
        writeData_RegT_i            => writeDataWBMux_s,
        RegDst_i                    => RegDst_s,
        RegWrite_i                  => RegWrite_s,
        readData1_RegT_o            => readData1_s,
        readData2_RegT_o            => readData2_s,
        UART_writeData_RegT_o       => UART_writeData_o
    );
    
    ALUTop:ALU_Top
    port map(
        clk_i                       => clk,
        readData1_ALU_i             => readData1_s,
        readData2_ALU_i             => readData2_s,
        signExt_ALU_i               => signExtend_s,
        instr_ALU_i                 => instr_s,
        ALUControl_i                => ALUControl_s,
        ALUSrc_i                    => ALUSrc_s,
        ALUShiftLogic_i             => ALUShiftLogic_s,
        ALUResult_ALU_o             => ALUResult_s,
        Zero_ALU_o                  => Zero_s,
        UART_address_ALU_o          => UART_address_o 
    );
    
    SignExt:SignExtend
    port map(
        clk_i                       => clk,
        instr_SE_i                  => instr_s(15 downto 0),
        immediate_SE_o              => signExtend_s
    );
    
    ALUCtrl:ALUControl
    port map(
        clk_i                       => clk,
        ALUOp_i                     => ALUOp_s,
        instr_ALUC_i                => instr_s(5 downto 0),
        ALUControl_o                => ALUControl_s,
        ALUShiftLogic_o             => ALUShiftLogic_s
    );
    
    DataMemoryTop:DataMemory_Top
    port map(
        clk_i                       => clk,
        address_DM_i                => ALUResult_s,
        writeData_DM_i              => readData2_s,
        PC_DM_i                     => PC_s,
        MemtoReg_i                  => MemToReg_s,
        MemWrite_i                  => MemWrite_s,
        MemRead_i                   => MemRead_s,
        Byte_i                      => Byte_s,
        HalfWord_i                  => HalfWord_s,
        readWriteData_DM_o          => dataMemMuxOutput_s
    );
    
    Mux_WriteBack:MUXWriteBack
    port map(
        clk_i                       => clk,
        readWriteData_i             => dataMemMuxOutput_s,
        UART_readData_i             => UART_readData_i,
        ReadEN                      => WBMux_EN_s,
        writeData_o                 => writeDataWBMux_s
    );
   
   Jump_Block:JumpBlock
   port map(
        clk_i                       => clk,
        instr_i                     => instr_s,
        PC_i                        => PC_s,
        jumpAddress_o               => jumpAddress_s
   );
   
   BranchTop:Branch_Top
   port map(
        clk_i                       => clk,
        PC_Branch_i                 => PC_s,
        directInput_Branch_i        => signExtend_s,
        BEQ_i                       => BEQ_s,
        BNE_i                       => BNE_s,
        Zero_i                      => Zero_s,
        targetAddress_Branch_o      => targetAddress_s
   );
   
   Mux_End:MUXEnd
   port map(
        clk_i                       => clk,
        targetAddress_i             => targetAddress_s,
        jumpAddress_i               => jumpAddress_s,
        Jump_i                      => Jump_s,
        endAddress_o                => endAddress_s    
   );
   
   Mux_JumpReg:MUXJumpReg
   port map(
        clk_i                       => clk,
        registerAddress_i           => readData1_s,
        endAddress_i                => endAddress_s,
        JumpRegister_i              => JumpReg_s,
        PCAddress_o                 => PCAddress_s
   );

end Behavioral;
