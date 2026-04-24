----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 15:03:56
-- Design Name: 
-- Module Name: main_loop - Behavioral
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

entity main_loop is
    port (
        clk       : in  std_logic; rst       : in  std_logic;
        mode_up   : in  std_logic; mode_down : in  std_logic;
        set_btn   : in  std_logic; up_btn    : in  std_logic;
        down_btn  : in  std_logic; ce_1s     : in  std_logic;
        view_sel  : out std_logic_vector(1 downto 0);
        run_time  : out std_logic; set_en    : out std_logic;
        set_hh    : out std_logic; set_mm    : out std_logic;
        dot_on    : out std_logic;
        view_dbg  : out std_logic_vector(1 downto 0);
        set_dbg   : out std_logic_vector(1 downto 0)
    );
end entity;

architecture Behavioral of main_loop is

    type view_type is (TIME_VIEW, AL1_VIEW, AL2_VIEW, AL3_VIEW);
    signal view_state : view_type := TIME_VIEW;

    type set_type is (S_OFF, S_HH, S_MM);
    signal set_state : set_type := S_OFF;

    signal set_btn_d      : std_logic := '0';
    signal mode_up_d      : std_logic := '0';
    signal mode_down_d    : std_logic := '0';
    signal set_btn_rise   : std_logic;
    signal mode_up_rise   : std_logic;
    signal mode_down_rise : std_logic;
    
    -- OPRAVA DRŽENÍ: Mìøiè milisekund
    signal ms_cnt : integer range 0 to 100_000 := 0;
    signal tick_1ms : std_logic := '0';
    
    -- Zmìnìno na 2000 milisekund = 2 sekundy
    signal hold_cnt : integer range 0 to 2000 := 0;
    constant LONG_PRESS : integer := 2000;

begin

    -- Generování 1ms tikání
    process(clk)
    begin
        if rising_edge(clk) then
            if ms_cnt = 99_999 then
                ms_cnt <= 0;
                tick_1ms <= '1';
            else
                ms_cnt <= ms_cnt + 1;
                tick_1ms <= '0';
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            set_btn_rise   <= set_btn and not set_btn_d;
            mode_up_rise   <= mode_up and not mode_up_d;
            mode_down_rise <= mode_down and not mode_down_d;

            set_btn_d   <= set_btn;
            mode_up_d   <= mode_up;
            mode_down_d <= mode_down;
        end if;
    end process;

    -- OPRAVA: Èítáme pouze když pøijde 1ms tik
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                hold_cnt <= 0;
            else
                if set_btn = '1' then
                    if tick_1ms = '1' and hold_cnt < LONG_PRESS then
                        hold_cnt <= hold_cnt + 1;
                    end if;
                else
                    hold_cnt <= 0;
                end if;
            end if;
        end if;
    end process;

    -- Tvoje pùvodní stavová mašina beze zmìn, pouze reaguje na opravený èasovaè
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                view_state <= TIME_VIEW;
            elsif set_state = S_OFF then
                if mode_up_rise = '1' then
                    case view_state is
                        when TIME_VIEW => view_state <= AL1_VIEW;
                        when AL1_VIEW  => view_state <= AL2_VIEW;
                        when AL2_VIEW  => view_state <= AL3_VIEW;
                        when AL3_VIEW  => view_state <= TIME_VIEW;
                    end case;
                elsif mode_down_rise = '1' then
                    case view_state is
                        when TIME_VIEW => view_state <= AL3_VIEW;
                        when AL1_VIEW  => view_state <= TIME_VIEW;
                        when AL2_VIEW  => view_state <= AL1_VIEW;
                        when AL3_VIEW  => view_state <= AL2_VIEW;
                    end case;
                end if;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                set_state <= S_OFF;
            else
                case set_state is
                    when S_OFF =>
                        if hold_cnt = LONG_PRESS then
                            set_state <= S_HH;
                        end if;
                        
                    when S_HH =>
                        if mode_up_rise = '1' then
                            set_state <= S_MM;
                        elsif set_btn_rise = '1' then
                            set_state <= S_OFF;
                        end if;
                        
                    when S_MM =>
                        if mode_down_rise = '1' then
                            set_state <= S_HH;
                        elsif set_btn_rise = '1' then
                            set_state <= S_OFF;
                        end if;                        
                end case;
            end if;
        end if;
    end process;

    -- Tvoje pùvodní výstupní logika beze zmìn
    process(view_state, set_state, ce_1s, up_btn, down_btn)
    begin
        run_time <= '1';
        set_en   <= '0';
        set_hh   <= '0'; 
        set_mm   <= '0'; 
        dot_on   <= '1';
        
        case view_state is
            when TIME_VIEW => view_sel <= "00"; 
                view_dbg <= "00";
            when AL1_VIEW  => view_sel <= "01"; 
                view_dbg <= "01";
            when AL2_VIEW  => view_sel <= "10"; 
                view_dbg <= "10";
            when AL3_VIEW  => view_sel <= "11"; 
                view_dbg <= "11";
        end case;

        case set_state is
            when S_OFF => set_dbg <= "00";
            when S_HH  => set_dbg <= "01";
            when S_MM  => set_dbg <= "10";
        end case;

        case set_state is
            when S_OFF => run_time <= '1'; 
                 dot_on <= ce_1s;
                 
            when S_HH => run_time <= '0'; 
                 set_en <= '1'; set_hh <= up_btn or down_btn;
                 
            when S_MM => run_time <= '0'; 
                 set_en <= '1'; 
                 set_mm <= up_btn or down_btn;
        end case;
    end process;

end Behavioral;
