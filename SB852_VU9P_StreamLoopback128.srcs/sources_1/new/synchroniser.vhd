----------------------------------------------------------------------------------
-- Company:  CERN
-- Engineer: 
-- 
-- Create Date: 16.02.2020 18:04:42
-- Design Name: 
-- Module Name: synchroniser - Behavioral
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
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VComponents.all;


entity synchroniser is
    Port ( clk : in STD_LOGIC;
           d : in STD_LOGIC;
           q : out STD_LOGIC);
end synchroniser;

architecture Behavioral of synchroniser is

signal q_int : std_logic;

begin


    fd1 : FD        -- edge-triggered D flip flop
        port map (
            C => clk,
            D => d,
            Q => q_int);


    fd2 : FD        -- edge-triggered D flip flop
        port map (
            C => clk,
            D => q_int,
            Q => q);


end Behavioral;
