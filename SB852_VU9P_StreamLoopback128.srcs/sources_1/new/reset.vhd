----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.02.2020 17:49:28
-- Design Name: 
-- Module Name: reset - Behavioral
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


entity reset is
port (
        clk_free     : in  std_logic;
        clk_algo : in std_logic;
        clk_i2c      : in  std_logic;
        clk_axi : in std_logic;
        rst_global   : in  std_logic;
        rst_i2c : out std_logic;
        rst_rx       : out std_logic;   -- clk_free domain
        rst_algo     : out std_logic;   -- clk_algo domain
        rst_packager : out std_logic   -- clk_axi domain
        );
end reset;

architecture Behavioral of reset is


-- The 500's are a guesstimate
    constant I2C_READY_WAIT    : natural := 500;             
    constant I2C_RST_WAIT      : natural := I2C_READY_WAIT+500;
    constant I2C_WR_WAIT       : natural := I2C_RST_WAIT+500;  
    constant PLL_RST_WAIT      : natural := I2C_WR_WAIT+500; 
    constant TX_RST_WAIT       : natural := PLL_RST_WAIT+500;
    constant RX_RST_WAIT       : natural := TX_RST_WAIT+500;
    constant ALGO_RST_WAIT     : natural := RX_RST_WAIT+500;  
    constant FIFO_RST_WAIT     : natural := ALGO_RST_WAIT+500;
    constant PACKAGER_RST_WAIT : natural := FIFO_RST_WAIT+500;


    signal rst_global_i2c, rst_global_free, rst_global_algo, rst_global_axi : std_logic;


begin

sync_rst_to_clk_i2c : entity work.synchroniser
        port map(
            clk => clk_i2c,
            d   => rst_global,
            q   => rst_global_i2c);

    reset_i2c : process(clk_i2c)
        variable wait_count : natural range 0 to 10000;
    begin
        if clk_i2c'event and clk_i2c = '1' then
            if rst_global_i2c = '1' then
                wait_count := 0;

            else
                wait_count := wait_count + 1;
                if wait_count = I2C_READY_WAIT then
                    rst_i2c <= '0';
                end if;
                if wait_count = I2C_RST_WAIT then
                end if;
                if wait_count = I2C_WR_WAIT then
                end if;
            end if;
        end if;
    end process;

    sync_rst_to_clk_free : entity work.synchroniser
        port map(
            clk => clk_free,
            d   => rst_global,
            q   => rst_global_free);

    reset_mgt : process(clk_free)
        variable wait_count : natural range 0 to 10000;
    begin
        if clk_free'event and clk_free = '1' then
            if rst_global_free = '1' then
                wait_count := 0;
--                rst_pll    <= '1';
--                rst_tx     <= '1';
--                rst_rx     <= '1';
            else
                wait_count := wait_count + 1;
                if wait_count = PLL_RST_WAIT then
--                    rst_pll <= '0';
                end if;
                if wait_count = TX_RST_WAIT then
--                    rst_tx <= '0';
                end if;
                if wait_count = RX_RST_WAIT then
--                    rst_rx <= '0';
                end if;
            end if;
        end if;
    end process;
 -- clk_algo is the recovered clock
    sync_rst_to_clk_algo : entity work.synchroniser
        port map(
            clk => clk_algo,
            d   => rst_global,
            q   => rst_global_algo);

    reset_algos : process(clk_algo)
        variable wait_count : natural range 0 to 10000;
    begin
        if clk_algo'event and clk_algo = '1' then
            if rst_global_algo = '1' then
                wait_count   := 0;
                rst_algo     <= '1';
            else
                wait_count := wait_count + 1;
                if wait_count = ALGO_RST_WAIT then
                    rst_algo <= '0';
                end if;
            end if;
        end if;
    end process;

    sync_rst_to_clk_axi : entity work.synchroniser
        port map(
            clk => clk_axi,
            d   => rst_global,
            q   => rst_global_axi);

    reset_axi : process(clk_axi)
        variable wait_count : natural range 0 to 10000;
    begin
        if clk_axi'event and clk_axi = '1' then
            if rst_global_axi = '1' then
                wait_count   := 0;
                rst_packager <= '1';
            else
                wait_count := wait_count + 1;
                if wait_count = PACKAGER_RST_WAIT then
                    rst_packager <= '0';
                end if;
            end if;
        end if;
    end process;



end Behavioral;
