----------------------------------------------------------------------------------
-- Company: CERN
-- Engineer: D. Rabady, port to micron T. James
-- 
-- Create Date:  May 2018
-- Design Name: 
-- Module Name: scout_inputs - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Optical serial inputs to 40 MHz scouting boards
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

library UNISIM;
use UNISIM.VComponents.all;

use work.datatypes.all;

entity scout_inputs is

  generic(
  BYPASS_LINKS : boolean := false;
  QUADS        : natural := 2
  );

  port (
  
  clk : in std_logic;
  rst : in std_logic;
  
  mgtrefclk0_x0y2_p : in std_logic;
  mgtrefclk0_x0y2_n : in std_logic;  
  mgtrefclk0_x0y4_p : in std_logic;
  mgtrefclk0_x0y4_n : in std_logic;
  
  ch0_gtyrxn_in : in std_logic;
  ch0_gtyrxp_in : in std_logic; 
  ch0_gtytxn_out : out std_logic;
  ch0_gtytxp_out : out std_logic; 
  
  ch1_gtyrxn_in : in std_logic;
  ch1_gtyrxp_in : in std_logic; 
  ch1_gtytxn_out : out std_logic;
  ch1_gtytxp_out : out std_logic; 
  
  ch2_gtyrxn_in : in std_logic;
  ch2_gtyrxp_in : in std_logic; 
  ch2_gtytxn_out : out std_logic;
  ch2_gtytxp_out : out std_logic;
  
  ch3_gtyrxn_in : in std_logic;
  ch3_gtyrxp_in : in std_logic; 
  ch3_gtytxn_out : out std_logic;
  ch3_gtytxp_out : out std_logic; 
  
  ch4_gtyrxn_in : in std_logic;
  ch4_gtyrxp_in : in std_logic; 
  ch4_gtytxn_out : out std_logic;
  ch4_gtytxp_out : out std_logic;
  
  ch5_gtyrxn_in : in std_logic;
  ch5_gtyrxp_in : in std_logic; 
  ch5_gtytxn_out : out std_logic;
  ch5_gtytxp_out : out std_logic; 
  
  ch6_gtyrxn_in : in std_logic;
  ch6_gtyrxp_in : in std_logic; 
  ch6_gtytxn_out : out std_logic;
  ch6_gtytxp_out : out std_logic;
 
  ch7_gtyrxn_in : in std_logic;
  ch7_gtyrxp_in : in std_logic; 
  ch7_gtytxn_out : out std_logic;
  ch7_gtytxp_out : out std_logic;
  
  clk_freerun : in std_logic;

  link_status_out : out std_logic;
  link_down_latched_out : out std_logic;
  
  q : out ldata(4*QUADS - 1 downto 0);

  oCommaDet : out std_logic_vector(4*QUADS - 1 downto 0)



   );
   
end scout_inputs;

architecture Behavioral of scout_inputs is
constant ORBIT : natural := 3564;

-- for data assignment
signal rx_data : std_logic_vector(4*QUADS * 32 - 1 downto 0);
signal q_int     : ldata(7 downto 0);

-- TODO add comment for these
signal rxctrl0_int : std_logic_vector(QUADS * 64 - 1 downto 0);
signal rxctrl1_int : std_logic_vector(QUADS * 64 - 1 downto 0);
signal rxctrl2_int : std_logic_vector(QUADS * 32 - 1 downto 0);
signal rxctrl3_int : std_logic_vector(QUADS * 32 - 1 downto 0);

signal sCommaDet : std_logic_vector(4*QUADS - 1 downto 0);

signal usr_clk : std_logic; -- link clocks

type TBCounterVec is array(natural range <>) of natural range 0 to 3564;
type TOCounterVec is array(natural range <>) of natural;
type TEvtWordsVec is array(natural range <>) of natural range 0 to 5;

signal ocounter : TOCounterVec(7 downto 0) := (others => 1);
signal bcounter : TBCounterVec(7 downto 0) := (0, 1, 2, 3, 4, 5, 6, 7);
signal evt_word : TEvtWordsVec(7 downto 0) := (others => 0);
signal sCharisk  : std_logic_vector(63 downto 0);



begin

gen_links : if BYPASS_LINKS = false generate 
gty_wrapper : entity work.gt_ultrascale_custom_top
port map
(

mgtrefclk0_x0y2_p => mgtrefclk0_x0y2_p,
mgtrefclk0_x0y2_n => mgtrefclk0_x0y2_n,
mgtrefclk0_x0y4_n => mgtrefclk0_x0y4_n,
mgtrefclk0_x0y4_p => mgtrefclk0_x0y4_p,

ch0_gtyrxn_in  => ch0_gtyrxn_in,
ch0_gtyrxp_in  => ch0_gtyrxn_in,
ch0_gtytxn_out => ch0_gtytxn_out,
ch0_gtytxp_out => ch0_gtytxp_out,

ch1_gtyrxn_in  => ch1_gtyrxn_in,
ch1_gtyrxp_in  => ch1_gtyrxn_in,
ch1_gtytxn_out => ch1_gtytxn_out,
ch1_gtytxp_out => ch1_gtytxp_out,

ch2_gtyrxn_in  => ch2_gtyrxn_in,
ch2_gtyrxp_in  => ch2_gtyrxn_in,
ch2_gtytxn_out => ch2_gtytxn_out,
ch2_gtytxp_out => ch2_gtytxp_out,

ch3_gtyrxn_in  => ch3_gtyrxn_in,
ch3_gtyrxp_in  => ch3_gtyrxn_in,
ch3_gtytxn_out => ch3_gtytxn_out,
ch3_gtytxp_out => ch3_gtytxp_out,

ch4_gtyrxn_in  => ch4_gtyrxn_in,
ch4_gtyrxp_in  => ch4_gtyrxn_in,
ch4_gtytxn_out => ch4_gtytxn_out,
ch4_gtytxp_out => ch4_gtytxp_out,

ch5_gtyrxn_in  => ch5_gtyrxn_in,
ch5_gtyrxp_in  => ch5_gtyrxn_in,
ch5_gtytxn_out => ch5_gtytxn_out,
ch5_gtytxp_out => ch5_gtytxp_out,

ch6_gtyrxn_in  => ch6_gtyrxn_in,
ch6_gtyrxp_in  => ch6_gtyrxn_in,
ch6_gtytxn_out => ch6_gtytxn_out,
ch6_gtytxp_out => ch6_gtytxp_out,

ch7_gtyrxn_in  => ch7_gtyrxn_in,
ch7_gtyrxp_in  => ch7_gtyrxn_in,
ch7_gtytxn_out => ch7_gtytxn_out,
ch7_gtytxp_out => ch7_gtytxp_out,

hb_gtwiz_reset_clk_freerun_in => clk_freerun,
hb_gtwiz_reset_all_in => rst,

link_down_latched_reset_in => rst,
link_status_out => link_status_out,
link_down_latched_out => link_down_latched_out,

gtwiz_userdata_rx_out         => rx_data(255 downto 0),

gtwiz_userclk_rx_usrclk_out   => usr_clk,


-- signals from MGT that encode information on rx words
rxctrl0_out                   => rxctrl0_int,  -- If RXCTRL3 is low: Corresponding rxdata byte is a KWORD
rxctrl1_out                   => rxctrl1_int,
rxctrl2_out                   => rxctrl2_int,  -- Corresponding byte is a comma.
rxctrl3_out                   => rxctrl3_int  -- Can't decode the word.

);

end generate;

--bypass_mgt : if BYPASS_LINKS = true generate
--    usr_clk <= clk;
--end generate;
----clk <=  usr_clk;

oCommaDet <= sCommaDet; -- add comment, what is s vs o?



data_assignment : process(rx_data, q_int, rxctrl0_int, rxctrl2_int, rxctrl3_int)
begin
    for i in 0 to 4*QUADS-1 loop 
        if BYPASS_LINKS = true then
            q(i) <= q_int(i);
        end if;
        if BYPASS_LINKS = false then
            q(i).data <= rx_data(i*32 + 31 downto i*32);
            q(i).done <= '0';
            if rxctrl3_int(i*8) = '0' and rxctrl0_int(i*16) = '1' and rxctrl2_int(i*8) = '1' then  -- Comma
                sCommaDet(i) <= '1';
                q(i).valid   <= '0';
                q(i).strobe  <= '1';
            elsif rxctrl3_int(i*8 + 3 downto i*8) = "0000" and rxctrl0_int(i*16 + 3 downto i*16) = "1111" then  -- Padding
                -- TODO: Check if word is actually 0xF7F7F7F7?
                sCommaDet(i) <= '0';
                q(i).valid   <= '1';
                q(i).strobe  <= '0';
            else
                sCommaDet(i) <= '0';
                q(i).valid   <= '1';
                q(i).strobe  <= '1';
            end if;
        end if;
    end loop;
end process;

-- create_testdata : process(usr_clk)
--        variable send_padding  : std_logic_vector(QUADS*4-1 downto 0);
--    begin
--        if usr_clk'event and usr_clk = '1' then
--            -- Create test data now
--            for i in QUADS*4-1 downto 0 loop  -- Number of channels            
--                if ((bcounter(i)+2*i) mod 4 = 0) and (evt_word(i) = 0) and (send_padding(i) = '0') then
--                    send_padding(i) := '1';
--                elsif evt_word(i) < 5 then
--                    send_padding(i) := '0';
--                    evt_word(i)     <= evt_word(i)+1;
--                elsif evt_word(i) = 5 then
--                    send_padding(i) := '0';
--                    evt_word(i)     <= 0;
--                    if bcounter(i) < ORBIT then
--                        bcounter(i) <= bcounter(i)+1;
--                    elsif bcounter(i) = ORBIT then
--                        bcounter(i) <= 1;
--                        ocounter(i) <= ocounter(i)+1;
--                    else
--                        bcounter(i) <= 1;
--                    end if;
--                else
--                    send_padding(i) := '0';
--                    evt_word(i)     <= 0;
--                end if;

--                if send_padding(i) = '1' then
--                    q_int(i).data                  <= x"F7F7F7F7";  -- Padding
--                    q_int(i).valid                 <= '1';
--                    q_int(i).strobe                <= '0';
--                    q_int(i).done                  <= '0';
--                    tx_data(i*32 + 31 downto i*32) <= x"F7F7F7F7";  -- Padding
--                    sCharisk(i*8 + 7 downto i*8)   <= "00001111";
--                elsif bcounter(i) > 0 and bcounter(i) < ORBIT-5 then  -- Arbitrary obit gap
--                    if evt_word(i) = 0 then
--                        tx_data(i*32 + 31 downto i*32) <= std_logic_vector(to_unsigned(bcounter(i), 32));
--                        q_int(i).data                  <= std_logic_vector(to_unsigned(bcounter(i), 32));
--                    elsif evt_word(i) = 1 then
--                        tx_data(i*32 + 31 downto i*32) <= std_logic_vector(to_unsigned(ocounter(i), 32));
--                        q_int(i).data                  <= std_logic_vector(to_unsigned(ocounter(i), 32));
--                    elsif (evt_word(i) = 2) or (evt_word(i) = 4) then
--                        tx_data(i*32 + 31 downto i*32) <= "000000001" & "1100" & "100000000" & "0000000000";
--                        q_int(i).data                  <= "000000001" & "1100" & "100000000" & "0000000000";
--                    elsif (evt_word(i) = 3) or (evt_word(i) = 5) then
--                        tx_data(i*32 + 31 downto i*32) <= (others => '1');
----                        tx_data(i*32 + 31 downto i*32)  <= "00000000000" & "0000000001" & "0111111" & "10" & "00";
--                        q_int(i).data                  <= (others => '1');
----                        q_int(i).data  <= "00000000000" & "0000000001" & "0111111" & "10" & "00";
--                    else
--                        tx_data(i*32 + 31 downto i*32) <= (others => '1');
--                        q_int(i).data                  <= (others => '1');
--                    end if;

--                    q_int(i).done                <= '0';
--                    q_int(i).valid               <= '1';
--                    q_int(i).strobe              <= '1';
--                    sCharisk(i*8 + 7 downto i*8) <= "00000000";
--                elsif bcounter(i) = ORBIT-5 and (evt_word(i) = 1 or evt_word(i) = 2) then
--                    q_int(i).done                  <= '0';
--                    q_int(i).strobe                <= '1';
--                    q_int(i).valid                 <= '1';
--                    q_int(i).data                  <= "10101010101010101010101010101010";  -- If I see this pattern I'm transmitting "CRCs".
--                    tx_data(i*32 + 31 downto i*32) <= "10101010101010101010101010101010";
--                    sCharisk(i*8 + 7 downto i*8)   <= "00000000";
--                else
--                    q_int(i).done                  <= '0';
--                    q_int(i).strobe                <= '1';
--                    q_int(i).valid                 <= '0';
--                    q_int(i).data                  <= x"505050BC";  -- COMMA
--                    tx_data(i*32 + 31 downto i*32) <= x"505050BC";  -- COMMA
--                    sCharisk(i*8 + 7 downto i*8)   <= "00000001";
--                end if;
--            end loop;

--        end if;
--    end process;

end Behavioral;
