library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Eerste 3 blokken van MIPS diagram

entity ProgramCounter_Top is
  Port ( 
        clk_i:              IN std_logic ;
        reset_PC_i:         IN std_logic;
        UART_RX_Busy_i:     IN std_logic; 
        PC_PC_i:            IN std_logic_vector (31 downto 0) := x"00000000";
        PC_Pc_o:            OUT std_logic_vector(31 downto 0) := (others => '0');
        instr_PC_o:         OUT std_logic_vector(31 downto 0) := (others => '0')
  );
end ProgramCounter_Top;

architecture Behavioral of ProgramCounter_Top is
    -- Components
    component ProgramCounter is
    Port ( 
        clk_i:              IN std_logic;
        reset_i:            IN std_logic;
        UART_RX_Busy_i:     IN std_logic;
        PCNext_i:           IN std_logic_vector(31 downto 0);
        PCCurrent_o:        OUT std_logic_vector(31 downto 0) := x"00000000"
    );
    end component;

    component  Adder is
    Port ( 
        clk_i:              IN std_logic ;
        PC_i:               IN std_logic_vector(31 downto 0);
        addCte_i:           IN std_logic_vector(31 downto 0);
        addPCResult_o:      OUT std_logic_vector(31 downto 0) := (others => '0')
    );
    end component ;
    
    
    component  InstructionMemory is
    Port ( 
        clk_i:              IN std_logic;
        address_i:          IN std_logic_vector(31 downto 0);
        instr_o:            OUT std_logic_vector(31 downto 0) := (others => '0') -- NOP instructie, bij opstart uitvoeren tot je instructie krijgt -> zie reference card
    );
    end component ;
    
    -- Internal signals
    signal PC_s :std_logic_vector(31 downto 0) := x"00000000";

begin
    PC:ProgramCounter 
    port map(
        clk_i           => clk_i, 
        reset_i         => reset_PC_i,
        UART_RX_Busy_i  => UART_RX_Busy_i, 
        PCNext_i        => PC_PC_i,
        PCCurrent_o     => PC_s
    );
      
    Add:Adder
    port map( 
        clk_i           => clk_i,
        PC_i            => PC_s,
        addCte_i        => x"00000004", 
        addPCResult_o   => PC_PC_o
    );
    
    InstrMem:InstructionMemory 
    port map( 
        clk_i           => clk_i,             
        address_i       => PC_s,    
        instr_o         => instr_PC_o  
    );
    
    
end Behavioral;
