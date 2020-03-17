----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.02.2020 21:49:58
-- Design Name: 
-- Module Name: datatypes - Behavioral
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

package datatypes is
    constant LWORD_WIDTH : integer := 32;
    type lword is
    record
        data   : std_logic_vector(LWORD_WIDTH - 1 downto 0);
        valid  : std_logic;
        done   : std_logic;
        strobe : std_logic;
    end record;
    type ldata is array(natural range <>) of lword;
    constant LWORD_NULL : lword             := ((others => '0'), '0', '0', '0');
    constant LWORD_PAD  : lword             := (x"F7F7F7F7", '1', '0', '1');
    constant LDATA_NULL : ldata(0 downto 0) := (0       => LWORD_NULL);

    subtype aword is std_logic_vector(LWORD_WIDTH - 1 downto 0);
    type adata is array(natural range <>) of aword;
    type acontrol is
    record
        valid    : std_logic;
        strobe   : std_logic;
        bx_start : std_logic;
        last     : std_logic;
    end record;
    constant AWORD_NULL : aword             := (others => '0');
    constant AWORD_PAD  : aword             := x"F7F7F7F7";
    constant ADATA_NULL : adata(0 downto 0) := (0      => AWORD_NULL);

    type TLinkBuffer is array (natural range <>) of ldata(7 downto 0);  -- This needs to stay 8 wide because it is sometimes used as a temporal buffer

    type delay_vector is array (natural range <>) of unsigned(14 downto 0);

    type state_buf is (direct_read, fill_buffer, wait_s1, drain_buffer, wait_s2);

    type TReadPointer is array (natural range <>) of unsigned(3 downto 0);

    -- DEBUG
    type state_vec is array (natural range <>) of state_buf;
    type TWordCnt is array (natural range <>) of unsigned(31 downto 0);
end datatypes;
