----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.04.2026 18:06:45
-- Design Name: 
-- Module Name: alarm_control_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_alarm_control is
end tb_alarm_control;

architecture tb of tb_alarm_control is

    -- ==========================================
    -- Component Declaration
    -- ==========================================
    component alarm_control
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            ce_1s    : in  std_logic;
            en_al1   : in  std_logic;
            en_al2   : in  std_logic;
            en_al3   : in  std_logic;
            btn_stop : in  std_logic;
            curr_hh  : in  unsigned(4 downto 0);
            curr_mm  : in  unsigned(5 downto 0);
            curr_ss  : in  unsigned(5 downto 0);
            al1_h    : in  unsigned(4 downto 0);
            al1_m    : in  unsigned(5 downto 0);
            al2_h    : in  unsigned(4 downto 0);
            al2_m    : in  unsigned(5 downto 0);
            al3_h    : in  unsigned(4 downto 0);
            al3_m    : in  unsigned(5 downto 0);
            ringing  : out std_logic;
            led_al1  : out std_logic;
            led_al2  : out std_logic;
            led_al3  : out std_logic
        );
    end component;

    -- ==========================================
    -- Signal Declarations
    -- ==========================================
    signal clk      : std_logic;
    signal rst      : std_logic;
    signal ce_1s    : std_logic;
    signal en_al1   : std_logic;
    signal en_al2   : std_logic;
    signal en_al3   : std_logic;
    signal btn_stop : std_logic;
    signal curr_hh  : unsigned(4 downto 0);
    signal curr_mm  : unsigned(5 downto 0);
    signal curr_ss  : unsigned(5 downto 0);
    signal al1_h    : unsigned(4 downto 0);
    signal al1_m    : unsigned(5 downto 0);
    signal al2_h    : unsigned(4 downto 0);
    signal al2_m    : unsigned(5 downto 0);
    signal al3_h    : unsigned(4 downto 0);
    signal al3_m    : unsigned(5 downto 0);
    signal ringing  : std_logic;
    signal led_al1  : std_logic;
    signal led_al2  : std_logic;
    signal led_al3  : std_logic;

    -- Simulation control signals
    constant TbPeriod : time := 10 ns; -- Clock period 10 ns (100 MHz)
    signal TbClock    : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    -- ==========================================
    -- Device Under Test (DUT) Instantiation
    -- ==========================================
    dut : alarm_control
        port map (
            clk      => clk,
            rst      => rst,
            ce_1s    => ce_1s,
            en_al1   => en_al1,
            en_al2   => en_al2,
            en_al3   => en_al3,
            btn_stop => btn_stop,
            curr_hh  => curr_hh,
            curr_mm  => curr_mm,
            curr_ss  => curr_ss,
            al1_h    => al1_h,
            al1_m    => al1_m,
            al2_h    => al2_h,
            al2_m    => al2_m,
            al3_h    => al3_h,
            al3_m    => al3_m,
            ringing  => ringing,
            led_al1  => led_al1,
            led_al2  => led_al2,
            led_al3  => led_al3
        );

    -- ==========================================
    -- Clock Generation
    -- ==========================================
    TbClock <= not TbClock after TbPeriod / 2 when TbSimEnded /= '1' else '0';
    clk     <= TbClock;

    -- ==========================================
    -- Background ce_1s Generator
    -- Starts automatically after reset and pulses continuously
    -- ==========================================
    p_ce_1s_gen : process
    begin
        ce_1s <= '0';
        -- Wait for the reset phase in the main process to finish (100 ns high + 100 ns low)
        wait for 200 ns; 
        
        while TbSimEnded = '0' loop
            ce_1s <= '1';
            wait for TbPeriod;
            ce_1s <= '0';
            -- Accelerated time: 1 simulation microsecond = 1 real-world second
            wait for 1 us; 
        end loop;
        wait;
    end process;

    -- ==========================================
    -- Stimuli Process
    -- ==========================================
    stimuli : process
    begin
        -- Input initialization
        en_al1   <= '0';
        en_al2   <= '0';
        en_al3   <= '0';
        btn_stop <= '0';
        
        -- Default current time: 06:29:58
        curr_hh  <= to_unsigned(6, 5);
        curr_mm  <= to_unsigned(29, 6);
        curr_ss  <= to_unsigned(58, 6);
        
        -- Alarm settings
        al1_h    <= to_unsigned(6, 5); al1_m <= to_unsigned(30, 6); -- AL1 = 06:30
        al2_h    <= to_unsigned(7, 5); al2_m <= to_unsigned(0, 6);  -- AL2 = 07:00
        al3_h    <= to_unsigned(8, 5); al3_m <= to_unsigned(15, 6); -- AL3 = 08:15

        -- Reset generation
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- =================================================================
        -- TEST 1: Alarm 1 activation (Time transition 06:29:59 to 06:30:00)
        -- =================================================================
        report "TEST 1: Waiting for Alarm 1 activation (06:30:00)";
        
        en_al1 <= '1'; -- Enable Alarm 1
        wait for 50 ns;
        
        curr_ss <= to_unsigned(59, 6);
        wait for 50 ns;
        
        curr_mm <= to_unsigned(30, 6);
        curr_ss <= to_unsigned(0, 6);  -- 'ringing' should trigger here
        wait for 200 ns; 

        -- =================================================================
        -- TEST 2: Snooze function activation (Mute via button)
        -- =================================================================
        report "TEST 2: Pressing btn_stop -> Snooze mode";
        
        btn_stop <= '1';
        wait for 2 * TbPeriod;
        btn_stop <= '0';
        wait for 200 ns; 
        
        -- Time run simulation during Snooze (Shift real time to avoid exact match)
        curr_ss <= to_unsigned(15, 6);

        -- =================================================================
        -- TEST 3: Return from Snooze (Automatic wait for background generator)
        -- =================================================================
        report "TEST 3: Waiting for background ce_1s pulses to reach Snooze limit (300)";
        
        -- The background process generates a pulse every 1 us.
        -- We need 300 pulses, so we wait slightly more than 300 us.
        wait for 310 us; 
        
        wait for 200 ns; -- The buzzer should be ringing again now

        -- =================================================================
        -- TEST 4: Alarm cancellation by turning off the switch
        -- =================================================================
        report "TEST 4: Forced alarm shutdown via switch (en_al1 -> '0')";
        
        en_al1 <= '0';
        wait for 200 ns; -- 'ringing' must fall to 0

        -- End of simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- ==============================================================================
-- Configuration block
-- ==============================================================================
configuration cfg_tb_alarm_control of tb_alarm_control is
    for tb
    end for;
end cfg_tb_alarm_control;
