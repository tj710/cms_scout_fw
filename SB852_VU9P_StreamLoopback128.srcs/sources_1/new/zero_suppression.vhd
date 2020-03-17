----------------------------------------------------------------------------------
-- Company: CERN
-- Engineer: Hannes Sakulin
-- 
-- Create Date: 19.02.2020 20:33:27
-- Design Name: 
-- Module Name: zero_suppression - Behavioral
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
use work.datatypes.all;

entity zero_suppression is
    generic (
        NSTREAMS : integer 
        );
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        d      : in  adata(NSTREAMS-1 downto 0);
        d_ctrl : in  acontrol;
        q      : out adata(NSTREAMS-1 downto 0);
        q_ctrl : out acontrol
        );
end zero_suppression;

architecture Behavioral of zero_suppression is

    signal d1, d2, d3, d4, d5, d6 : adata(NSTREAMS-1 downto 0);
    signal d_ctrl1, d_ctrl2, d_ctrl3, d_ctrl4, d_ctrl5, d_ctrl6 : acontrol;

begin

    zs: process(clk, rst) is
      variable suppress : boolean;
    begin
        if rst = '1' then
            d1 <= (others => AWORD_NULL); d_ctrl1 <=('0', '0', '0', '0');
            d2 <= (others => AWORD_NULL); d_ctrl2 <=('0', '0', '0', '0');
            d3 <= (others => AWORD_NULL); d_ctrl3 <=('0', '0', '0', '0');
            d4 <= (others => AWORD_NULL); d_ctrl4 <=('0', '0', '0', '0');
            d5 <= (others => AWORD_NULL); d_ctrl5 <=('0', '0', '0', '0');
        else
           if clk'event and clk = '1' then
                q <= d5; q_ctrl <= d_ctrl5;
                d5 <= d4; d_ctrl5 <= d_ctrl4;
                d4 <= d3; d_ctrl4 <= d_ctrl3;
                d3 <= d2; d_ctrl3 <= d_ctrl2;
                d2 <= d1; d_ctrl2 <= d_ctrl1;
                d1 <= d;  d_ctrl1 <= d_ctrl;
                
                
                if d_ctrl5.valid ='1' and d_ctrl5.strobe='1' and d_ctrl5.bx_start = '1' then
                    suppress := true;
                    for i in d'range loop
                      if d3(i)(18 downto 10) /= "000000000" or   -- pt is in bits 18 downto 10
                         d1(i)(18 downto 10) /= "000000000" then -- d3 has 1st word of 1st muon, d1 has 1st word of 2nd muon
                           suppress := false;
                      end if;   
                    end loop;
                    if suppress then
                        q_ctrl.strobe <= '0';
                        d_ctrl5.strobe <= '0';
                        d_ctrl4.strobe <= '0';
                        d_ctrl3.strobe <= '0';
                        d_ctrl2.strobe <= '0';
                        d_ctrl1.strobe <= '0';
                    end if;
               end if;
            end if;
        end if;
    end process zs;



end Behavioral;

