----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.02.2020 19:03:44
-- Design Name: 
-- Module Name: gap_cleaner - Behavioral
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

entity gap_cleaner is
    generic (
        QUADS : natural := 2
        );
    port (clk : in  std_logic;
          rst : in  std_logic;
          d   : in  ldata(4*QUADS - 1 downto 0);
          q   : out ldata(4*QUADS - 1 downto 0));
end gap_cleaner;

architecture Behavioral of gap_cleaner is
    signal q_padding_buf : TLinkBuffer(23 downto 0);
    signal q_buffer      : TLinkBuffer(5 downto 0);
begin

    q_padding_buf(0)(4*QUADS - 1 downto 0) <= d;

    invalidate_padding_in_comma_gap : process(clk)
    begin
        if clk'event and clk = '1' then
            q_padding_buf(q_padding_buf'high downto 1) <= q_padding_buf(q_padding_buf'high-1 downto 0);
            for i in q'range loop
                if (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-2)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-3)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-4)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-5)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-6)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-7)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-8)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-9)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-10)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-11)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-12)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-13)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-14)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-15)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-16)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-17)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-18)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-19)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-20)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-21)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-22)(i).valid = '0') or
                    (q_buffer(0)(i).valid = '0' and q_padding_buf(q_padding_buf'high-23)(i).valid = '0')
                then
                    q_buffer(0)(i).data   <= q_padding_buf(q_padding_buf'high-1)(i).data;
                    q_buffer(0)(i).strobe <= q_padding_buf(q_padding_buf'high-1)(i).strobe;
                    q_buffer(0)(i).done   <= q_padding_buf(q_padding_buf'high-1)(i).done;
                    q_buffer(0)(i).valid  <= '0';
                else
                    q_buffer(0)(i) <= q_padding_buf(q_padding_buf'high-1)(i);
                end if;
            end loop;
        end if;
    end process;

    protect_comma_gap : process(clk)
    begin
        if clk'event and clk = '1' then
            q_buffer(q_buffer'high downto 1) <= q_buffer(q_buffer'high-1 downto 0);
            for i in q'range loop
                if (q_buffer(q_buffer'high-1)(i).valid = '1' and q_buffer(q_buffer'high-2)(i).valid = '0' and q_buffer(q_buffer'high-5)(i).valid = '0') or  -- If we're at the end of a packet (last word was still valid) 
                                   (q_buffer(q_buffer'high)(i).valid = '1' and q_buffer(q_buffer'high-1)(i).valid = '0' and q_buffer(q_buffer'high-4)(i).valid = '0') or  -- Checking for second valid word
                                   (q_buffer(q_buffer'high-1)(i).valid = '1' and q_buffer(q_buffer'high-2)(i).valid = '0' and q_buffer(q_buffer'high-4)(i).valid = '0')  -- Special case if CRC&LID are split by padding word
                then                    -- remove the CRC and LID fields
                    q(i).data   <= q_buffer(q_buffer'high-3)(i).data;
                    q(i).strobe <= q_buffer(q_buffer'high-3)(i).strobe;
                    q(i).done   <= q_buffer(q_buffer'high-3)(i).done;
                    q(i).valid  <= '0';
                else
                    q(i) <= q_buffer(q_buffer'high-3)(i);
                end if;
            end loop;
        end if;
    end process;

end Behavioral;
