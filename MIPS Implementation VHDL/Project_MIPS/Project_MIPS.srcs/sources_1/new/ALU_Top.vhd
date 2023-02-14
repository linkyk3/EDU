library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_Top is
  Port ( 
        -- Input
        clk_i:                          IN std_logic;
        readData1_ALU_i:                IN std_logic_vector(31 downto 0);
        readData2_ALU_i:                IN std_logic_vector(31 downto 0);
        signExt_ALU_i:                  IN std_logic_vector(31 downto 0);
        instr_ALU_i:                    IN std_logic_vector(31 downto 0); -- for shamt
        -- Control
        ALUControl_i:                   IN std_logic_vector(3 downto 0);
        ALUSrc_i:                       IN std_logic;
        ALUShiftLogic_i:                IN std_logic;
        -- Output
        ALUResult_ALU_o:                OUT std_logic_vector(31 downto 0) := (others => '0');
        Zero_ALU_o:                     OUT std_logic := '0';
        -- UART
        UART_address_ALU_o:             OUT std_logic_vector(31 downto 0) := (others => '0') -- calculated UART address
   );
end ALU_Top;

architecture Behavioral of ALU_Top is
    -- Components
    component ALU is
        Port(
            clk_i:                      IN std_logic;
            input1_i:                   IN std_logic_vector(31 downto 0);
            input2_i:                   IN std_logic_vector(31 downto 0);
            ALUControl_i:               IN std_logic_vector(3 downto 0);
            ALUResult_o:                OUT std_logic_vector(31 downto 0) := (others => '0');
            Zero_o:                     OUT std_logic := '0';
            UART_address_o:             OUT std_logic_vector(31 downto 0) := (others => '0') -- calculated UART address  
        );
    end component;
    
    component MUXALU is
        Port(
            clk_i:                      IN std_logic;
            registerInput_i:            IN std_logic_vector(31 downto 0);
            directInput_i:              IN std_logic_vector(31 downto 0);
            ALUSrc_i:                   IN std_logic;
            muxALUOutput_o:             OUT std_logic_vector(31 downto 0) := (others => '0')

        );
    end component;
    
    component MUXShiftLogic is
        Port (
            clk_i:                      IN std_logic;
            readData1_i:                IN std_logic_vector(31 downto 0);
            instr_i:                    IN std_logic_vector(31 downto 0); -- pass the full instruction -> in ALU: slice the shamt
            ShiftLogic_i:               IN std_logic;
            muxShiftLogicOutput_o:      OUT std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;
    
    -- Internal Signals
    signal muxALUOutput_s:          std_logic_vector(31 downto 0) := (others => '0');
    signal muxShiftLogicOutput_s:   std_logic_vector(31 downto 0) := (others => '0');
 
begin
    ALUComp:ALU 
    port map(
        clk_i                   => clk_i,
        input1_i                => muxShiftLogicOutput_s,
        input2_i                => muxALUOutput_s,
        ALUControl_i            => ALUControl_i,
        ALUResult_o             => ALUResult_ALU_o,
        Zero_o                  => Zero_ALU_o, 
        UART_address_o          => UART_address_ALU_o   
    );
    
    MuxALUComp:MUXALU
    port map(
        clk_i                   => clk_i,
        registerInput_i         => readData2_ALU_i,
        directInput_i           => signExt_ALU_i,
        ALUSrc_i                => ALUSrc_i,
        muxALUOutput_o          => muxALUOutput_s
    );
    
    MuxShift:MUXShiftLogic
    port map(
        clk_i                   => clk_i,
        readData1_i             => readData1_ALU_i,
        instr_i                 => instr_ALU_i,
        ShiftLogic_i            => ALUShiftLogic_i,
        muxShiftLogicOutput_o   => muxShiftLogicOutput_s
    );

end Behavioral;
