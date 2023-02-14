library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity MUXJumpReg_tb is
end MUXJumpReg_tb;

architecture Behavioral of MUXJumpReg_tb is
    component MUXJumpReg is
        Port(
            clk:            IN std_logic;
            read_data1:     IN std_logic_vector(31 downto 0); -- rs register
            mux_end:        IN std_logic_vector(31 downto 0);
            JumpRegister:   IN std_logic;
            PC:             OUT std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;
    
    -- Input Signals
    signal clk:             std_logic := '0';
    signal read_data1:      std_logic_vector(31 downto 0) := (others => '0');
    signal mux_end:         std_logic_vector(31 downto 0) := (others => '0');
    -- Control Signals
    signal JumpRegister:    std_logic := '0';
    -- Output Signals
    signal PC:              std_logic_vector(31 downto 0) := (others => '0');
    --Clock divider constant
    constant clk_period : time := 10 ns;
    
begin
    UUT:MuxJumpReg
    port map(
        clk             => clk,
        read_data1      => read_data1,
        mux_end         => mux_end,
        JumpRegister    => JumpRegister,
        PC              => PC
    );
    
    clk_prcoess:process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc:process
    begin
        wait for 5ns;
            JumpRegister    <= '0';
            read_data1      <= "00000000000000001111111111111111"; 
            mux_end         <= "11111111111111110000000000000000";
            wait for 10ns;
            JumpRegister    <= '1';
        wait;
    end process;

end Behavioral;
