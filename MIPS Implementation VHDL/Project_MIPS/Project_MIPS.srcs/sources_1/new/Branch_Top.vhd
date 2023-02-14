library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Branch_Top is
   Port ( 
        -- Input
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
   
end Branch_Top;

architecture Behavioral of Branch_Top is
    -- Components        
    component  ShiftLeft2 is
        Port ( 
            clk_i:              IN std_logic;
            directInput_i:      IN std_logic_vector(31 downto 0);
            shiftLeft2Output_o: OUT std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;
    
    component AddBranch is
        Port (
            clk_i:              IN std_logic;
            PC_i:               IN std_logic_vector(31 downto 0); 
            offsetSE_i:         IN std_logic_vector(31 downto 0); 
            addBranchResult_o:  OUT std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;
    
    component LogicBranch is
        Port ( 
            clk_i:              IN std_logic;
            BEQ_i:              IN std_logic;
            BNE_i:              IN std_logic;
            Zero_i:             IN std_logic;
            PCSrc_o:            OUT std_logic := '0'
        );
    end component;
    
    component MUXBranch is
        Port ( 
            clk_i:              IN std_logic;
            PC_i :              IN std_logic_vector(31 downto 0);
            ADDResult_i:        IN std_logic_vector(31 downto 0);
            PCSrc_i:            IN std_logic;
            muxBranchOutput_o:  OUT std_logic_vector(31 downto 0) := (others => '0')
            );
    end component;
    
    -- Internal Signals
    signal ADDResult_s:         std_logic_vector(31 downto 0) := (others => '0');
    signal PCSrc_s:             std_logic := '0'; 
    signal shiftLeft2_s:        std_logic_vector(31 downto 0) := (others => '0');

begin

    Shift_Left2: ShiftLeft2
    port map(
        clk_i               => clk_i,
        directInput_i       => directInput_Branch_i,
        shiftLeft2Output_o  => shiftLeft2_s
    );
    
    Adder: AddBranch
    port map(
        clk_i               => clk_i,
        PC_i                => PC_Branch_i,
        offsetSE_i          => shiftLeft2_s,
        addBranchResult_o   => ADDResult_s
    );
    
    BranchLogic: LogicBranch
    port map(
        clk_i               => clk_i,
        BEQ_i               => BEQ_i,
        BNE_i               => BNE_i,
        Zero_i              => Zero_i,
        PCSrc_o             => PCSrc_s
        );
    Mux: MUXBranch
    port map(
        clk_i               => clk_i,
        PC_i                => PC_Branch_i,
        ADDResult_i         => ADDResult_s,
        PCSrc_i             => PCSrc_s,
        muxBranchOutput_o   => targetAddress_Branch_o
    );
    
end Behavioral;
