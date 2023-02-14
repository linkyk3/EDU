library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Naming Conventions:     
-- input port:              _i
-- output port:             _o
-- signals:                 _s
-- constants:               _c
-- type:                    _t
-- Data ports/signals:                                  dataPort
-- Data ports specific to highest component level:      dataPort_Component
-- Control ports/signals:                               ControlSignal


entity Main_Top is
  Port ( 
        -- Input
        clk_i:                  IN std_logic;
        instr_Main_i:           IN std_logic_vector(31 downto 0);
        -- Output
        JumpReg_o:              OUT std_logic := '0';
        Jump_o:                 OUT std_logic := '0'; 
        BEQ_o:                  OUT std_logic := '0';
        BNE_o:                  OUT std_logic := '0';
        Zero_o:                 OUT std_logic := '0';
        jumpRegister_Main_o:    OUT std_logic_vector(31 downto 0) := (others => '0'); -- for the jr instruction -> PC=R[rs]
        instr_SE_Main_o:        OUT std_logic_vector(31 downto 0) := (others => '0'); -- for branching
        -- UART
        UART_Write_o:            OUT std_logic := '0';
        UART_Read_o:             OUT std_logic := '0';
        UART_address_o:          OUT std_logic_vector(31 downto 0) := (others => '0');
        UART_writeData_o:        OUT std_logic_vector(31 downto 0) := (others => '0');
        UART_readData_i:         IN std_logic_vector(31 downto 0);
        UART_ReadEN_i:           IN std_logic
  );
end Main_Top;

architecture Behavioral of Main_Top is
    --Components
    component Control is
        Port (
            clk_i:          IN std_logic ;
            instr_Ctrl_i:   IN std_logic_vector(31 downto 0);
            RegDst_o:       OUT std_logic := '0';
            Jump_o:         OUT std_logic := '0';
            JumpReg_o:      OUT std_logic := '0';
            BEQ_o:          OUT std_logic := '0';
            BNE_o:          OUT std_logic := '0';
            MemRead_o:      OUT std_logic := '0';
            MemToReg_o:     OUT std_logic := '0';
            ALUOp_o:        OUT std_logic_vector(2 downto 0) := (others => '0');
            MemWrite_o:     OUT std_logic := '0';
            ALUSrc_o:       OUT std_logic := '0';
            RegWrite_o:     OUT std_logic := '0';
            Byte_o:         OUT std_logic := '0';
            HalfWord_o:     OUT std_logic := '0';
            UART_Write_o:    OUT std_logic := '0';
            UART_Read_o:     OUT std_logic := '0'
        );
    end component;
    
    component Registers_Top is
        Port(
            clk_i:                  IN std_logic;
            instr_RegT_i:           IN std_logic_vector(31 downto 0);
            writeData_RegT_i:       IN std_logic_vector(31 downto 0);
            RegDst_i:               IN std_logic;
            RegWrite_i:             IN std_logic;
            readData1_RegT_o:       OUT std_logic_vector(31 downto 0) := (others => '0');
            jumpRegister_RegT_o:    OUT std_logic_vector(31 downto 0) := (others => '0'); -- for the jr instruction
            readData2_RegT_o:       OUT std_logic_vector(31 downto 0) := (others => '0');
            UART_writeData_RegT_o:   OUT std_logic_vector(31 downto 0) := (others => '0') -- copy of readData2 for UART write  
        );
    end component;
    
    component ALU_Top is
        Port (
            -- Input
            clk_i:              IN std_logic;
            readData1_ALU_i:    IN std_logic_vector(31 downto 0);
            readData2_ALU_i:    IN std_logic_vector(31 downto 0);
            signExt_ALU_i:      IN std_logic_vector(31 downto 0);
            instr_ALU_i:        IN std_logic_vector(31 downto 0); -- for shamt
            -- Control
            ALUControl_i:       IN std_logic_vector(3 downto 0);
            ALUSrc_i:           IN std_logic;
            ALUShiftLogic_i:    IN std_logic;
            -- Output
            ALUResult_ALU_o:    OUT std_logic_vector(31 downto 0) := (others => '0');
            Zero_ALU_o:         OUT std_logic := '0';
            -- UART
            UART_address_ALU_o:  OUT std_logic_vector(31 downto 0) := (others => '0') -- calculated UART address
        );
    end component;
    
    component SignExtend is
        Port (
            clk_i:              IN std_logic;
            instr_SE_i:         IN std_logic_vector(15 downto 0);
            output_SE_o:        OUT std_logic_vector(31 downto 0) := (others => '0');
            immediate_SE_o:     OUT std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;
    
    component ALUControl is
        Port (
            clk_i:              IN std_logic;
            ALUOp_i:            IN std_logic_vector(2 downto 0);
            instr_ALUC_i:       IN std_logic_vector(5 downto 0); 
            ALUControl_o:       OUT std_logic_vector(3 downto 0) := (others => '0');
            ALUShiftLogic_o:    OUT std_logic := '0'  
        );
    end component;
    
    component DataMemory_Top is
        Port (
            clk_i:              IN std_logic;
            address_DM_i:       IN std_logic_vector(31 downto 0);
            writeData_DM_i:     IN std_logic_vector(31 downto 0);
            MemtoReg_i:         IN std_logic;
            MemWrite_i:         IN std_logic;
            MemRead_i:          IN std_logic;
            Byte_i:             IN std_logic;
            HalfWord_i:         IN std_logic;
            readWriteData_DM_o: OUT std_logic_vector(31 downto 0) 
        );
    end component;
    
    component MUXWriteBack is
        Port (
            clk_i:              IN std_logic;
            readWriteData_i:    IN std_logic_vector(31 downto 0); -- ALU Result/Read data from mem
            UART_readData_i:    IN std_logic_vector(31 downto 0); -- UART read data (8bit)
            ReadEN:             IN std_logic;
            writeData_o:        OUT std_logic_vector(31 downto 0) := (others => '0')    
        );
    end component;

    -- Internal Signals -> Coming from:
    -- Control:
    signal RegDst_s:            std_logic := '0'; 
    signal MemRead_s:           std_logic := '0';
    signal MemToReg_s:          std_logic := '0';
    signal ALUOp_s:             std_logic_vector(2 downto 0) := (others => '0');
    signal MemWrite_s:          std_logic := '0';
    signal ALUSrc_s:            std_logic := '0';
    signal RegWrite_s:          std_logic := '0';
    signal Byte_s:              std_logic := '0';
    signal HalfWord_s:          std_logic := '0';
    -- Registers Top:
    signal readData1_s:         std_logic_vector(31 downto 0) := (others => '0');
    signal readData2_s:         std_logic_vector(31 downto 0) := (others => '0');
    -- Sign extend:
    signal signExtend_s:        std_logic_vector(31 downto 0) := (others => '0');
    -- ALU Control
    signal ALUControl_s:        std_logic_vector(3 downto 0) := (others => '0');
    signal ALUShiftLogic_s:     std_logic := '0';
    -- ALU:
    signal ALUResult_s:         std_logic_vector(31 downto 0) := (others => '0');
    -- Data Mem Mux:
    signal dataMemMuxOutput_s:  std_logic_vector(31 downto 0) := (others => '0');
    -- Write Back Mux:
    signal writeDataWBMux_s:    std_logic_vector(31 downto 0) := (others => '0');
    
begin
    ControlBlock:Control
    port map(
        clk_i               => clk_i,
        instr_Ctrl_i        => instr_Main_i,
        RegDst_o            => RegDst_s,
        Jump_o              => Jump_o,
        JumpReg_o           => JumpReg_o,
        BEQ_o               => BEQ_o,
        BNE_o               => BNE_o,
        MemRead_o           => MemRead_s,
        MemToReg_o          => MemToReg_s,
        ALUOp_o             => ALUOp_s,
        MemWrite_o          => MemWrite_s,
        ALUSrc_o            => ALUSrc_s,
        RegWrite_o          => RegWrite_s,
        Byte_o              => Byte_s,
        HalfWord_o          => HalfWord_s,
        UART_Write_o         => UART_Write_o,
        UART_Read_o          => UART_Read_o
    );
    
    RegistersTop:Registers_Top
    port map(
        clk_i                   => clk_i,
        instr_RegT_i            => instr_Main_i,
        writeData_RegT_i        => writeDataWBMux_s,
        RegDst_i                => RegDst_s,
        RegWrite_i              => RegWrite_s,
        readData1_RegT_o        => readData1_s,
        jumpRegister_RegT_o     => jumpRegister_Main_o,
        readData2_RegT_o        => readData2_s,
        UART_writeData_RegT_o    => UART_writeData_o
    );
    
    ALUTop:ALU_Top
    port map(
        clk_i               => clk_i,
        readData1_ALU_i     => readData1_s,
        readData2_ALU_i     => readData2_s,
        signExt_ALU_i       => signExtend_s,
        instr_ALU_i         => instr_Main_i,
        ALUControl_i        => ALUControl_s,
        ALUSrc_i            => ALUSrc_s,
        ALUShiftLogic_i     => ALUShiftLogic_s,
        ALUResult_ALU_o     => ALUResult_s,
        Zero_ALU_o          => Zero_o,
        UART_address_ALU_o   => UART_address_o 
    );
    
    SignExt:SignExtend
    port map(
        clk_i               => clk_i,
        instr_SE_i          => instr_Main_i(15 downto 0),
        output_SE_o         => instr_SE_Main_o,
        immediate_SE_o      => signExtend_s
    );
    
    ALUCtrl:ALUControl
    port map(
        clk_i               => clk_i,
        ALUOp_i             => ALUOp_s,
        instr_ALUC_i        => instr_Main_i(5 downto 0),
        ALUControl_o        => ALUControl_s,
        ALUShiftLogic_o     => ALUShiftLogic_s
    );
    
    DataMemoryTop:DataMemory_Top
    port map(
        clk_i               => clk_i,
        address_DM_i        => ALUResult_s,
        writeData_DM_i      => readData2_s,
        MemtoReg_i          => MemToReg_s,
        MemWrite_i          => MemWrite_s,
        MemRead_i           => MemRead_s,
        Byte_i              => Byte_s,
        HalfWord_i          => HalfWord_s,
        readWriteData_DM_o  => dataMemMuxOutput_s
    );
    
    Mux_WriteBack:MUXWriteBack
    port map(
        clk_i               => clk_i,
        readWriteData_i     => dataMemMuxOutput_s,
        UART_readData_i     => UART_readData_i,
        ReadEN              => UART_ReadEN_i,
        writeData_o         => writeDataWBMux_s
    );

end Behavioral;