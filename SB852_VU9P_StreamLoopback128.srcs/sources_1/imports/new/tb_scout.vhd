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


entity tb_scout is
--  Port ( );
end tb_scout;

architecture Behavioral of tb_scout is
  constant t_period : time := 4 ns;
  constant t_halfperiod : time := t_period / 2;
  constant t_hold : time := t_period / 5;

  
  constant BUFFER_SIZE : integer := 64;
  constant NSTREAMS    : integer := 8;
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
   
       
    signal clk_freerun : std_logic;
    
    -- data paths between blocks
    signal d_gap_cleaner, d_align : ldata(7 downto 0);
    signal d_zs, q_zs, d_package : adata(7 downto 0);
    
    
    signal clk_i2c : std_logic;

    -- various reset signals
    signal rst_packager : std_logic;
    
    -- control words between blocks
    signal d_ctrl_zs, q_ctrl_zs, d_ctrl_package : acontrol;
    
    
    signal stream_enable_mask     : std_logic_vector(7 downto 0);

    signal m_axis_c2h_tvalid_0, m_axis_c2h_tready_0, m_axis_c2h_tlast_0 : std_logic;
    signal m_axis_c2h_tdata_0: std_logic_vector(255 downto 0);  

    signal m_axis_c2h_tkeep_0 : std_logic_vector(31 downto 0);
    
        signal freq_input : std_logic_vector(31 downto 0);

begin

  frequ_meas : entity work.freq_meas
port map (
    clk => clk,
    rst => rst_packager,
    clk_meas => clk,
    freq => freq_input
    );
  
  rst_aligner <= '0';
  
align : entity work.aligner
    generic map (
        NSTREAMS => 8)
    port map (
        clk_wr => clk,
        rst    => rst_aligner,
        d      => d,
        enable => stream_enable_mask,
        clk_rd => clk,
        q      => d_zs,
        q_ctrl => d_ctrl_zs
     );

 zero_suppression : entity work.zero_suppression
        generic map (
        NSTREAMS => 8)
    port map (
        clk    => clk,
        rst    => rst_packager,
        d      => d_zs,
        d_ctrl => d_ctrl_zs,
        q      => q_zs,
        q_ctrl => q_ctrl_zs
    );
    
     m_axis_h2c_tready_0 <= '1' after 200 us; 


fifo_filler : entity work.fifo_filler
    generic map (
        NSTREAMS => 8)
    port map (
        d_clk                  => clk,
        rst                    => rst_packager,
--        orbits_per_packet      => unsigned(orbits_per_packet),
        d                      => q_zs,
        d_ctrl                 => q_ctrl_zs,
        m_aclk                 => clk,                -- memory, axi clk?
        m_axis_tvalid          => m_axis_c2h_tvalid_0,
        m_axis_tready          => m_axis_c2h_tready_0,
        m_axis_tdata           => m_axis_c2h_tdata_0, -- memory, axi stream, what is t?, data
        m_axis_tkeep           => m_axis_c2h_tkeep_0,
        m_axis_tlast           => m_axis_c2h_tlast_0,
--        dropped_orbit_counter  => filler_dropped_orbit_counter,
--        orbit_counter          => filler_orbit_counter,
--        axi_backpressure_seen  => axi_backpressure_seen,
       -- orbit_length           => orbit_length,   
--        orbit_exceeds_size     => orbit_exceeds_size,
        in_autorealign_counter => autorealign_counter
        );

     runtb : process
    variable i : integer := 0;
    variable j : integer := 0;
    variable frame : ldata( NSTREAMS - 1 downto 0);

    file F  : text open read_mode is "/afs/cern.ch/user/t/tjames/testfile_5new2.ptrn";

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
