----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Hannes Sakulin
-- 
-- Create Date: 09/19/2018 10:15:25 AM
-- Design Name: 
-- Module Name: tb_aligner - Behavioral
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
use IEEE.numeric_std.all;
use std.textio.all;
use WORK.datatypes.ALL;
use work.test_file_io.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_align_fill is
--  Port ( );
end tb_align_fill;

architecture Behavioral of tb_align_fill is
  constant t_period : time := 4 ns;
  constant t_halfperiod : time := t_period / 2;
  constant t_hold : time := t_period / 5;

  
  constant BUFFER_SIZE : integer := 64;
  constant NSTREAMS    : integer := 2;
  signal clk           : STD_LOGIC;
  signal reset         : STD_LOGIC;
  signal enable : std_logic_vector(NSTREAMS-1 downto 0);

  signal d  : ldata(NSTREAMS-1 downto 0);
  signal q : adata(NSTREAMS-1 downto 0);
  signal q_ctrl : acontrol;
  
   signal dropped_orbit_counter : unsigned(64-1 downto 0);
   signal orbit_counter : unsigned(64-1 downto 0);
   signal axi_backpressure_seen : std_logic;
   
   signal m_axis_h2c_tvalid_0 : std_logic;
   signal m_axis_h2c_tready_0 : std_logic := '0';
   signal m_axis_h2c_tdata_0 : std_logic_vector(255 downto 0);
   signal m_axis_h2c_tkeep_0 : std_logic_vector(31 downto 0);
   signal m_axis_h2c_tlast_0 : std_logic;

   signal rst_aligner : std_logic;
   signal orbit_exceeds_size : std_logic;
   signal autorealign_counter : unsigned (63 downto 0);
begin


    auto_realign_controller_1: entity work.auto_realign_controller
  port map (
    axi_clk           => clk,
    clk_aligner       => clk,
    rst_in            => reset,
    enabled           => '1',
    rst_aligner_out   => rst_aligner,
    misalignment_seen => orbit_exceeds_size,
    autoreset_count   => autorealign_counter);

  aligner_1: entity work.bx_aware_aligner
    generic map (
      NSTREAMS    => NSTREAMS)
    port map (
      clk_wr        => clk,
      clk_rd        => clk,
      rst           => rst_aligner,
      enable => enable,
      d  => d,
      q => q,
      q_ctrl => q_ctrl
      );
      
     --m_axis_h2c_tready_0 <= '0'; 
     m_axis_h2c_tready_0 <= '1' after 200 us; 
     

     fifo_filler: entity work.fifo_filler
         generic map (
             NSTREAMS => NSTREAMS)
         port map (
           d_clk                 => clk,
           rst                   => reset,
           orbits_per_packet     => TO_UNSIGNED(1,16),
           d                     => q,
           d_ctrl                => q_ctrl,
           m_aclk                => clk,
           m_axis_tvalid         => m_axis_h2c_tvalid_0,
           m_axis_tready         => m_axis_h2c_tready_0,
           m_axis_tdata          => m_axis_h2c_tdata_0,
           m_axis_tkeep          => m_axis_h2c_tkeep_0,
           m_axis_tlast          => m_axis_h2c_tlast_0,
           dropped_orbit_counter => dropped_orbit_counter,
           orbit_counter         => orbit_counter,
           axi_backpressure_seen => axi_backpressure_seen,
           orbit_exceeds_size    => orbit_exceeds_size,
           in_autorealign_counter  => autorealign_counter);



  runtb : process
    variable i : integer := 0;
    variable j : integer := 0;
    variable frame : ldata( NSTREAMS - 1 downto 0);

    file F                           : text open read_mode is "/home/hsakulin/xilinx_projects/bx_aware_aligner/testfile_5new2.ptrn";

    begin

    reset <= '1';
    for j in 0 to NSTREAMS-1 loop
--      if not(j = 2) then 
--       enable(j) <= '1';
--      else
--        enable(j) <= '0';
--      end if;   
      enable(j) <= '1';
      d(j).data <= (others => '0');
      d(j).valid <= '0';
      d(j).strobe <= '0';
--      d(j).bx_start <= '0';
      d(j).done <= '0';
    end loop;
    
    for i in 0 to 100 loop
      clk <= '0';
      wait for t_halfperiod;
      clk <= '1';
      wait for t_hold;

      -- change signals
      if i>=5 and i <=30 then
        reset <= '1';
      else
        reset <= '0';
      end if;

      wait for (t_halfperiod - t_hold);

    end loop;
    
    while ( not endfile(F) ) loop
      clk <= '0';
      wait for t_halfperiod;
      clk <= '1';
      wait for t_hold;
       
      ReadFrame(f, NSTREAMS, frame);
      d <= frame;

--       for j in 0 to NSTREAMS -1 loop
--        if i > 20+7*j then
--          if (i=29 or i=37) then
--              inputstreams(j).strobe <= '0';
--          else
--              inputstreams(j).strobe <= '1';
--          end if;    
--          inputstreams(j).data <= STD_LOGIC_VECTOR(TO_UNSIGNED(i-(20+7*j),inputstreams(j).data'length)); 
--          inputstreams(j).valid <= '1';
--        end if;
        
--      end loop;  
--   
      
      wait for (t_halfperiod - t_hold);
    end loop;

   for i in 0 to 200 loop
      clk <= '0';
      wait for t_halfperiod;
      clk <= '1';
      wait for t_hold;
      wait for (t_halfperiod - t_hold);

    end loop;


  end process runtb;  
  

end Behavioral;
