----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.04.2026 21:30:16
-- Design Name: 
-- Module Name: main_loop_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_main_loop is
end tb_main_loop;

architecture tb of tb_main_loop is

    -- ==========================================
    -- Component Declaration
    -- ==========================================
    component main_loop
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            mode_up   : in  std_logic;
            mode_down : in  std_logic;
            set_btn   : in  std_logic;
            up_btn    : in  std_logic;
            down_btn  : in  std_logic;
            ce_1s     : in  std_logic;
            view_sel  : out std_logic_vector(1 downto 0);
            run_time  : out std_logic;
            set_en    : out std_logic;
            set_hh    : out std_logic;
            set_mm    : out std_logic;
            dot_on    : out std_logic;
            view_dbg  : out std_logic_vector(1 downto 0);
            set_dbg   : out std_logic_vector(1 downto 0)
        );
    end component;

    -- ==========================================
    -- Signal Declarations
    -- ==========================================
    signal clk        : std_logic;
    signal rst        : std_logic;
    signal mode_up    : std_logic;
    signal mode_down  : std_logic;
    signal set_btn    : std_logic;
    signal up_btn     : std_logic;
    signal down_btn   : std_logic;
    signal ce_1s      : std_logic;
    signal view_sel   : std_logic_vector(1 downto 0);
    signal run_time   : std_logic;
    signal set_en     : std_logic;
    signal set_hh     : std_logic;
    signal set_mm     : std_logic;
    signal dot_on     : std_logic;
    signal view_dbg   : std_logic_vector(1 downto 0);
    signal set_dbg    : std_logic_vector(1 downto 0);

    -- Simulation control signals
    constant TbPeriod : time := 10 ns; 
    signal TbClock    : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    -- ==========================================
    -- Device Under Test (DUT) Instantiation
    -- ==========================================
    dut : main_loop
        port map (
            clk       => clk,
            rst       => rst,
            mode_up   => mode_up,
            mode_down => mode_down,
            set_btn   => set_btn,
            up_btn    => up_btn,
            down_btn  => down_btn,
            ce_1s     => ce_1s,
            view_sel  => view_sel,
            run_time  => run_time,
            set_en    => set_en,
            set_hh    => set_hh,
            set_mm    => set_mm,
            dot_on    => dot_on,
            view_dbg  => view_dbg,
            set_dbg   => set_dbg
        );

    -- ==========================================
    -- Clock Generation
    -- ==========================================
    TbClock <= not TbClock after TbPeriod / 2 when TbSimEnded /= '1' else '0';
    clk     <= TbClock;

    -- ==========================================
    -- Background ce_1s Generator (Blinking Dot)
    -- Toggles extremely fast (every 500 us) to save simulation time
    -- ==========================================
    p_ce_1s_gen : process
    begin
        while TbSimEnded = '0' loop
            ce_1s <= '1';
            wait for 500 us;
            ce_1s <= '0';
            wait for 500 us;
        end loop;
        wait;
    end process;

    -- ==========================================
    -- Stimuli Process
    -- ==========================================
    stimuli : process
    begin
        -- Initialize all inputs
        mode_up   <= '0';
        mode_down <= '0';
        set_btn   <= '0';
        up_btn    <= '0';
        down_btn  <= '0';

        -- Reset generation
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- =================================================================
        -- PART 1: FAST NAVIGATION TESTS
        -- =================================================================
        
        report "TEST: Waiting 2 ms to observe fast dot blinking";
        wait for 2 ms;
        
        report "TEST: Switching to AL1_VIEW";
        mode_up <= '1'; 
        wait for 20 ns; 
        mode_up <= '0'; 
        wait for 100 us;
        
        report "TEST: Switching to AL2_VIEW";
        mode_up <= '1'; 
        wait for 20 ns; 
        mode_up <= '0'; 
        wait for 100 us;

        report "TEST: Switching to AL3_VIEW";
        mode_up <= '1'; 
        wait for 20 ns; 
        mode_up <= '0'; 
        wait for 100 us;

        report "TEST: Switching back to TIME_VIEW";
        mode_up <= '1'; 
        wait for 20 ns; 
        mode_up <= '0'; 
        wait for 100 us;
        
        wait for 500 us; -- VISUAL GAP

        -- =================================================================
        -- PART 2: ENTERING SETUP MODE 
        -- =================================================================
        
        report "WARNING: Starting 3 ms button hold to enter setup.";
        
        -- Hold center button for 3 ms to trigger LONG_PRESS (which is now 2)
        set_btn <= '1';
        wait for 3 ms; 
        set_btn <= '0';
        
        wait for 500 us; -- VISUAL GAP (observe solid dot_on)

        -- =================================================================
        -- PART 3: MODIFYING MAIN TIME
        -- =================================================================

        report "TEST: Modifying HOURS";
        up_btn <= '1'; 
        wait for 100 us; -- 100 mikrosekund bohatì staèí pro zøetelnost
        up_btn <= '0'; 
        
        wait for 200 us; -- VISUAL GAP

        report "TEST: Switching to MINUTES setup";
        mode_up <= '1'; 
        wait for 20 ns; 
        mode_up <= '0'; 
        
        wait for 200 us; -- VISUAL GAP

        report "TEST: Modifying MINUTES";
        down_btn <= '1'; 
        wait for 100 us; 
        down_btn <= '0'; 
        
        wait for 500 us; -- VISUAL GAP

        -- =================================================================
        -- PART 4: EXITING SETUP MODE
        -- =================================================================

        report "TEST: Exiting setup mode.";
        set_btn <= '1'; 
        wait for 20 ns; 
        set_btn <= '0'; 
        
        wait for 1 ms; -- Èekáme 1 ms, abychom vidìli, že teèka zase bliká

        -- =================================================================
        -- PART 5: ALARM SETUP TEST
        -- =================================================================
        
        report "TEST: Switching to AL1_VIEW for alarm setup.";
        mode_up <= '1'; 
        wait for 20 ns; 
        mode_up <= '0'; 
        
        wait for 500 us; -- VISUAL GAP

        report "WARNING: Starting 3 ms hold for Alarm setup.";
        set_btn <= '1';
        wait for 3 ms; 
        set_btn <= '0';
        
        wait for 500 us; -- VISUAL GAP

        report "TEST: Modifying Alarm 1 HOURS";
        up_btn <= '1'; 
        wait for 100 us; 
        up_btn <= '0'; 
        
        wait for 200 us; -- VISUAL GAP

        report "TEST: Exiting Alarm setup mode.";
        set_btn <= '1'; 
        wait for 20 ns; 
        set_btn <= '0'; 
        
        wait for 1 ms;

        -- End of simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

configuration cfg_tb_main_loop of tb_main_loop is
    for tb
    end for;
end cfg_tb_main_loop;
