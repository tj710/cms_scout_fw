----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2018 09:17:41 AM
-- Design Name: 
-- Module Name: test_file_io - Behavioral
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
use IEEE.NUMERIC_STD.all;
--use WORK.top_decl.all;
use WORK.datatypes.all;
library STD;
use STD.TEXTIO.all;
use ieee.std_logic_textio.all;


package test_file_io is


procedure ReadFrame (
  file F : text; 
  constant NSTREAMS : in integer;
  variable frame : out ldata
  );
  
end package test_file_io;

package body test_file_io is

  function reverse_bits(a: in std_logic_vector)
    return std_logic_vector
  is
    variable a_rev: std_logic_vector(a'REVERSE_RANGE);
  begin
    for i in a'RANGE loop
      a_rev(i) := a(i);
    end loop;
    return a_rev;
  end;


  procedure ReadFrame (
    file F : text; 
    constant NSTREAMS : in integer;
    variable frame : out ldata
    ) is 
    
    variable L : line;
    variable L1 : line;
    variable vsb : std_logic_vector (3 downto 0);

    variable dummy : string (1 to 1);
    variable bDone : boolean := false;
  begin
    bDone := False;
    -- read event
    while ( not endfile(F) and not bDone) loop
      readline (F, L);
      write (L1,string'("read line:"));
      write (L1, L.all);
      writeline(OUTPUT,L1 );
      if (L.all(1 to 2) = "--" ) then
        next;
      end if;
      for i in 0 to NSTREAMS - 1 loop
         hread(L, frame(i).data); 
         read(L, dummy);   
         bread(L, vsb);
         if not (i = NSTREAMS-1) then
           read(L, dummy);   
         end if;
         frame(i).valid := vsb(3);
         frame(i).strobe := vsb(2);
 --        frame(i).bx_start := vsb(1); 
         frame(i).done := vsb(0);
         bDone := true;
      end loop;
      
    end loop;  

  end ReadFrame;


end package body test_file_io;

