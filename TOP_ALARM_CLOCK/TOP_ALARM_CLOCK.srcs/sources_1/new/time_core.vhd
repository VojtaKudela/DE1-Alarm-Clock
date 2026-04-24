----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 15:05:29
-- Design Name: 
-- Module Name: time_core - Behavioral
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

entity time_core is
    port (
        clk        : in std_logic;
        rst        : in std_logic;
        btnL       : in std_logic; btnR : in std_logic; btn_c : in std_logic;
        btn_up     : in std_logic; btn_down : in std_logic;
        HH         : out std_logic_vector(4 downto 0);
        MM         : out std_logic_vector(5 downto 0);
        SS         : out std_logic_vector(5 downto 0);
        ce_1s_out  : out std_logic;
        view_mode  : out std_logic_vector(1 downto 0);
        set_en_out : out std_logic; 
        set_hh_out : out std_logic;
        set_mm_out : out std_logic
    );
end time_core;

architecture Behavioral of time_core is

    component clk_en
        generic (G_MAX : positive := 50_000_000);
        port (clk : in std_logic; rst : in std_logic; ce : out std_logic);
    end component;

    signal ce_1s, sig_set_en, sig_run_time, sig_set_hh, sig_set_mm : std_logic;
    signal sig_view_sel : std_logic_vector(1 downto 0);
    signal reg_hh : integer range 0 to 23 := 0;
    signal reg_mm : integer range 0 to 59 := 0;
    signal reg_ss : integer range 0 to 59 := 0;
    signal btn_up_last, btn_down_last : std_logic := '0';

begin
    ce_1s_out <= ce_1s;
    view_mode <= sig_view_sel;
    set_en_out <= sig_set_en;
    set_hh_out <= sig_set_hh;
    set_mm_out <= sig_set_mm;

    CLKDIV : clk_en 
        generic map (G_MAX => 100_000_000
                     ) 
        port map (clk=>clk,
                  rst=>rst, 
                  ce=>ce_1s
                  );

    FSM : entity work.main_loop
        port map (clk => clk, 
                  rst => rst,
                  mode_up => btnR, 
                  mode_down => btnL, 
                  set_btn => btn_c, 
                  up_btn => btn_up, 
                  down_btn => btn_down, 
                  ce_1s => ce_1s,
                  view_sel => sig_view_sel,     
                  run_time => sig_run_time,
                  set_en => sig_set_en, 
                  set_hh => sig_set_hh, 
                  set_mm => sig_set_mm, 
                  dot_on => open
                  );

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                reg_hh <= 0; reg_mm <= 0; reg_ss <= 0;
                btn_up_last <= '0'; btn_down_last <= '0';
            else
                btn_up_last <= btn_up;
                btn_down_last <= btn_down;

                if sig_run_time = '1' and ce_1s = '1' then
                    if reg_ss = 59 then
                        reg_ss <= 0;
                        if reg_mm = 59 then
                            reg_mm <= 0;
                            if reg_hh = 23 then reg_hh <= 0; else reg_hh <= reg_hh + 1; end if;
                        else reg_mm <= reg_mm + 1; end if;
                    else reg_ss <= reg_ss + 1; end if;
                end if;

                if sig_set_en = '1' and sig_view_sel = "00" then
                    if sig_set_hh = '1' then
                        if btn_up = '1' and btn_up_last = '0' then
                            if reg_hh = 23 then reg_hh <= 0; else reg_hh <= reg_hh + 1; end if;
                        elsif btn_down = '1' and btn_down_last = '0' then
                            if reg_hh = 0 then reg_hh <= 23; else reg_hh <= reg_hh - 1; end if;
                        end if;
                    elsif sig_set_mm = '1' then
                        if btn_up = '1' and btn_up_last = '0' then
                            if reg_mm = 59 then reg_mm <= 0; else reg_mm <= reg_mm + 1; end if;
                        elsif btn_down = '1' and btn_down_last = '0' then
                            if reg_mm = 0 then reg_mm <= 59; else reg_mm <= reg_mm - 1; end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    HH <= std_logic_vector(to_unsigned(reg_hh, 5));
    MM <= std_logic_vector(to_unsigned(reg_mm, 6));
    SS <= std_logic_vector(to_unsigned(reg_ss, 6));

end Behavioral;
