------------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/18/2018 10:01:02 AM
-- Design Name: 
-- Module Name: auto_realign_controller - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity auto_realign_controller is
    port (
        axi_clk : in std_logic;
        rst_in  : in std_logic;

        enabled           : in  std_logic;
        clk_aligner       : in  std_logic;
        rst_aligner_out   : out std_logic;
        misalignment_seen : in  std_logic;

        autoreset_count : out unsigned(63 downto 0)
        );
end auto_realign_controller;

architecture Behavioral of auto_realign_controller is

--
-- If the alignemtn logic gets misaligned because orbit length is not the same in all input channels it 
-- can get into a state where teh valid will stay always high. In this case the packager will see axi backpressure.
--
-- To recover, we trigger a package reset 
--

    type t_ar_state is (ALIGNED, R1, R2, R3, A1, A2, A3, A4, A5);
    signal ar_state            : t_ar_state;
    signal s_autoreset_count   : unsigned (63 downto 0);
    signal misalignment_seen_d : std_logic;
    signal rst_aligner_int     : std_logic;
begin

    auto_realign : process (rst_in, axi_clk) is

    begin
        if rst_in = '1' then
            rst_aligner_int     <= '1';
            s_autoreset_count   <= TO_UNSIGNED(0, 64);
            ar_state            <= ALIGNED;
            misalignment_seen_d <= '0';
        else
            rst_aligner_int <= '0';
            if axi_clk'event and axi_clk = '1' then

                misalignment_seen_d <= misalignment_seen;

                case ar_state is
                    when ALIGNED =>
                        if enabled = '1' and misalignment_seen = '1' and misalignment_seen_d = '0' then
                            rst_aligner_int   <= '1';
                            ar_state          <= R1;
                            s_autoreset_count <= s_autoreset_count + 1;
                        end if;
                    when R1 => ar_state <= R2; rst_aligner_int <= '1';
                    when R2 => ar_state <= R3; rst_aligner_int <= '1';
                    when R3 => ar_state <= A1; rst_aligner_int <= '0';
                    when A1 => ar_state <= A2;
                    when A2 => ar_state <= A3;
                    when A3 => ar_state <= A4;
                    when A4 => ar_state <= A5;
                    when A5 => ar_state <= ALIGNED;
                end case ar_state;
                
            end if;
        end if;
    end process auto_realign;

    autoreset_count <= s_autoreset_count;

    sync_aligner_rst_to_clk : entity work.synchroniser
        port map(
            clk => clk_aligner,
            d   => rst_aligner_int,
            q   => rst_aligner_out);


end Behavioral;
