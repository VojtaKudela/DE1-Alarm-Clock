----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 14:56:27
-- Design Name: 
-- Module Name: debounce - Behavioral
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

entity debounce is
    generic (C_SHIFT_LEN : positive := 4;
             C_MAX       : positive := 1_000_000  -- ~10 ms při 100 MHz
             );
    port (clk       : in  std_logic;
          rst       : in  std_logic;
          btn_in    : in  std_logic;
          btn_state : out std_logic;  
          btn_press : out std_logic   
          );
    
end entity debounce;

architecture Behavioral of debounce is
    signal sync0, sync1 : std_logic := '0';
    signal shift_reg    : std_logic_vector(C_SHIFT_LEN-1 downto 0) := (others => '0');
    signal debounced    : std_logic := '0';
    signal debounced_d  : std_logic := '0';
    signal ce_sample    : std_logic;
    
    constant ALL_ONES  : std_logic_vector(C_SHIFT_LEN-1 downto 0) := (others => '1');
    constant ALL_ZEROS : std_logic_vector(C_SHIFT_LEN-1 downto 0) := (others => '0');
    
begin

    clk_en_inst : entity work.clk_en
        generic map (G_MAX => C_MAX
                     )
        port map (clk => clk, 
                  rst => rst, 
                  ce => ce_sample
                  );

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sync0 <= '0'; sync1 <= '0';
                shift_reg <= (others => '0');
                debounced <= '0'; debounced_d <= '0';
            else
                sync0 <= btn_in;
                sync1 <= sync0;

                if ce_sample = '1' then
                    shift_reg <= shift_reg(C_SHIFT_LEN-2 downto 0) & sync1;
                    if shift_reg = ALL_ONES then
                        debounced <= '1';
                    elsif shift_reg = ALL_ZEROS then
                        debounced <= '0';
                    end if;
                end if;

                debounced_d <= debounced;
            end if;
        end if;
    end process;

    btn_state <= debounced;
    btn_press <= debounced and not debounced_d;

end Behavioral;
