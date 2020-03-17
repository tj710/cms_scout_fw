----------------------------------------------------------------------------------
-- Company: CERN 
-- Engineer: Hannes Sakulin, Dinyar Rabady, Thomas James
-- 
-- Create Date: 19.02.2020 21:06:42
-- Design Name: 
-- Module Name: scout_top - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;

use IEEE.NUMERIC_STD.all;

library unisim;
use unisim.vcomponents.all;

--use work.top_decl.all;
use work.datatypes.all;

entity scout_top is
    port (
    
    --Picostreams
    
    clk : in std_logic; -- 250 MHz clock from Micron infra
    rst : in std_logic;
    
    -- pico stream in 1
    s1i_valid : in std_logic;
    s1i_rdy : out std_logic;
    s1i_data : in std_logic_vector(127 downto 0);
    
    -- pico stream out 1
    s1o_valid :  out std_logic;
    s1o_rdy : in std_logic;
    s1o_data : out std_logic_vector(127 downto 0);  
    
    --pico stream out 2
    s2o_valid :  out std_logic;
    s2o_rdy : in std_logic;
    s2o_data : out std_logic_vector(127 downto 0);
    
    -- I2C 
    scl : in std_logic; -- serial clk
    sda : in std_logic -- serial data
    
        );
end scout_top;


architecture Behavioral of scout_top is

    signal mgtrefclk0_x0y2_p : std_logic;
    signal mgtrefclk0_x0y2_n : std_logic;
    signal mgtrefclk0_x0y4_n : std_logic;
    signal mgtrefclk0_x0y4_p : std_logic;
    
    signal ch0_gtyrxn_in  : std_logic;
    signal ch0_gtyrxp_in  : std_logic;
    signal ch0_gtytxn_out : std_logic;
    signal ch0_gtytxp_out : std_logic;
    
    signal ch1_gtyrxn_in  : std_logic;
    signal ch1_gtyrxp_in  : std_logic;
    signal ch1_gtytxn_out : std_logic;
    signal ch1_gtytxp_out : std_logic;
    
    signal ch2_gtyrxn_in : std_logic;
    signal ch2_gtyrxp_in : std_logic;
    signal ch2_gtytxn_out : std_logic;
    signal ch2_gtytxp_out : std_logic;
    
    signal ch3_gtyrxn_in : std_logic;
    signal ch3_gtyrxp_in : std_logic;
    signal ch3_gtytxn_out : std_logic;
    signal ch3_gtytxp_out : std_logic;
    
    signal ch4_gtyrxn_in : std_logic;
    signal ch4_gtyrxp_in : std_logic;
    signal ch4_gtytxn_out : std_logic;
    signal ch4_gtytxp_out : std_logic;
    
    signal ch5_gtyrxn_in  : std_logic;
    signal ch5_gtyrxp_in  : std_logic;
    signal ch5_gtytxn_out : std_logic;
    signal ch5_gtytxp_out : std_logic;
    
    signal ch6_gtyrxn_in  : std_logic;
    signal ch6_gtyrxp_in  : std_logic;
    signal ch6_gtytxn_out : std_logic;
    signal ch6_gtytxp_out : std_logic;
    
    signal ch7_gtyrxn_in  : std_logic;
    signal ch7_gtyrxp_in  : std_logic;
    signal ch7_gtytxn_out : std_logic;
    signal ch7_gtytxp_out : std_logic;
    
    signal hb_gtwiz_reset_clk_freerun_in : std_logic;
    signal hb_gtwiz_reset_all_in : std_logic;
    
    signal link_down_latched_reset_in : std_logic;
    signal link_status_out : std_logic;
    signal link_down_latched_out : std_logic;
    
    signal clk_freerun : std_logic;
    
    -- data paths between blocks
    signal d_gap_cleaner, d_align : ldata(7 downto 0);
    signal d_zs, q_zs, d_package : adata(7 downto 0);
    
    
    signal clk_i2c : std_logic;

    -- various reset signals
    signal rst_aligner, rst_packager : std_logic;
    
    -- control words between blocks
    signal d_ctrl_zs, q_ctrl_zs, d_ctrl_package : acontrol;
    
    
    signal stream_enable_mask     : std_logic_vector(7 downto 0);


    signal autorealign_counter : unsigned (63 downto 0);

    signal m_axis_c2h_tvalid_0, m_axis_c2h_tready_0, m_axis_c2h_tlast_0 : std_logic;
    signal m_axis_c2h_tdata_0: std_logic_vector(255 downto 0);  

    signal m_axis_c2h_tkeep_0 : std_logic_vector(31 downto 0);
    
    signal freq_input : std_logic_vector(31 downto 0);

    signal enable_autorealign  : std_logic;

    signal orbit_exceeds_size  : std_logic;

    signal hb_gtwiz_reset_rx_datapath_vio_int         : std_logic_vector(0 downto 0);


    
    component fifo_generator_0 is
        port (
            s_aresetn     : in  std_logic                        := '0';
            m_axis_tvalid : out std_logic                        := '0';
            m_axis_tready : in  std_logic                        := '0';
            m_axis_tdata  : out std_logic_vector(256-1 downto 0) := (others => '0');
            m_axis_tkeep  : out std_logic_vector(32-1 downto 0)  := (others => '0');
            m_axis_tlast  : out std_logic                        := '0';
            s_axis_tvalid : in  std_logic                        := '0';
            s_axis_tready : out std_logic                        := '0';
            s_axis_tdata  : in  std_logic_vector(256-1 downto 0) := (others => '0');
            s_axis_tkeep  : in  std_logic_vector(32-1 downto 0)  := (others => '0');
            s_axis_tlast  : in  std_logic                        := '0';
            axi_prog_full : out std_logic                        := '0';
            m_aclk        : in  std_logic                        := '0';
            s_aclk        : in  std_logic                        := '0');
    end component;

    
        signal enable_i2c_gen, rst_i2c_gen, wr_i2c_gen, rst_i2c : std_logic;


    begin
    
    global_reset : entity work.reset
        port map (
            clk_free     => hb_gtwiz_reset_clk_freerun_in,
            clk_i2c      => clk_i2c,
            clk_axi      => clk,
            clk_algo     => clk,
            rst_global   => rst,
            rst_i2c      => rst_i2c_gen,
           -- write_i2c    => wr_i2c_gen,
          --  rst_pll      => hb0_gtwiz_reset_tx_pll_and_datapath_int(0),
           -- rst_tx       => hb0_gtwiz_reset_tx_datapath_int(0),
            rst_rx       => hb_gtwiz_reset_rx_datapath_vio_int(0),
            rst_packager => rst_packager
            );
            
--   i2c_i : entity work.i2c_driver
--        port map (
--            clk     => clk_i2c,         -- 50 MHz from PLL below.
--            reset   => rst_i2c,
--            str_wr  => str_wr,
--            str_rd  => str_rd,
--            data_rd => data_rd,
--            sda     => sda,
--            scl     => scl
--            );

    
    inputs : entity work.scout_inputs
    port map(
    
    clk => clk,
    rst => rst,
    
    mgtrefclk0_x0y2_p => mgtrefclk0_x0y2_p,
    mgtrefclk0_x0y2_n => mgtrefclk0_x0y2_n,
    mgtrefclk0_x0y4_p => mgtrefclk0_x0y4_p,
    mgtrefclk0_x0y4_n => mgtrefclk0_x0y4_n,
    
    ch0_gtyrxn_in  => ch0_gtyrxn_in,
    ch0_gtyrxp_in  => ch0_gtyrxp_in,
    ch0_gtytxn_out => ch0_gtytxn_out,
    ch0_gtytxp_out => ch0_gtytxp_out,
    
    ch1_gtyrxn_in  => ch1_gtyrxn_in,
    ch1_gtyrxp_in  => ch1_gtyrxp_in,
    ch1_gtytxn_out => ch1_gtytxn_out,
    ch1_gtytxp_out => ch1_gtytxp_out,
    
    ch2_gtyrxn_in  => ch2_gtyrxn_in,
    ch2_gtyrxp_in  => ch2_gtyrxp_in,
    ch2_gtytxn_out => ch2_gtytxn_out,
    ch2_gtytxp_out => ch2_gtytxp_out,
    
    ch3_gtyrxn_in  => ch3_gtyrxn_in,
    ch3_gtyrxp_in  => ch3_gtyrxp_in,
    ch3_gtytxn_out => ch3_gtytxn_out,
    ch3_gtytxp_out => ch3_gtytxp_out,
    
    ch4_gtyrxn_in  => ch4_gtyrxn_in,
    ch4_gtyrxp_in  => ch4_gtyrxp_in,
    ch4_gtytxn_out => ch4_gtytxn_out,
    ch4_gtytxp_out => ch4_gtytxp_out,
    
    ch5_gtyrxn_in  => ch5_gtyrxn_in,
    ch5_gtyrxp_in  => ch5_gtyrxp_in,
    ch5_gtytxn_out => ch5_gtytxn_out,
    ch5_gtytxp_out => ch5_gtytxp_out,
    
    ch6_gtyrxn_in  => ch6_gtyrxn_in,
    ch6_gtyrxp_in  => ch6_gtyrxp_in,
    ch6_gtytxn_out => ch6_gtytxn_out,
    ch6_gtytxp_out => ch6_gtytxp_out,
    
    ch7_gtyrxn_in  => ch7_gtyrxn_in,
    ch7_gtyrxp_in  => ch7_gtyrxp_in,
    ch7_gtytxn_out => ch7_gtytxn_out,
    ch7_gtytxp_out => ch7_gtytxp_out,
    
    clk_freerun => clk_freerun,
    
    q => d_gap_cleaner
    
--    hb_gtwiz_reset_rx_datapath_vio_int         => hb_gtwiz_reset_rx_datapath_vio_int

       
    );
    
    
frequ_meas : entity work.freq_meas
port map (
    clk => clk,
    rst => rst_packager,
    clk_meas => clk,
    freq => freq_input
    );

    
gap_cleaner : entity work.gap_cleaner
   port map(
        clk=> clk,
        rst => rst,
        d => d_gap_cleaner,
        q => d_align
    );
    
       auto_realign_controller_1 : entity work.auto_realign_controller
        port map (
            axi_clk           => clk,
            rst_in            => rst,
            enabled           => enable_autorealign,
            clk_aligner       => clk,
            rst_aligner_out   => rst_aligner,
            misalignment_seen => orbit_exceeds_size,
            autoreset_count   => autorealign_counter);

    
    
 align : entity work.aligner
    generic map (
        NSTREAMS => 8)
    port map (
        clk_wr => clk,
        rst    => rst_aligner,
        d      => d_align,
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
    
-- m = master, axis = axi stream, c2h = client to host, (t = convention for axi signal?)
fifo_filler : entity work.fifo_filler
    generic map (
        NSTREAMS => 8)
    port map (
        d_clk                  => clk,
        rst                    => rst_packager,
--        orbits_per_packet      => unsigned(orbits_per_packet),
        d                      => q_zs,
        d_ctrl                 => q_ctrl_zs,
        m_aclk                 => clk,                -- master, axi clk?
        m_axis_tvalid          => m_axis_c2h_tvalid_0,
        m_axis_tready          => m_axis_c2h_tready_0,
        m_axis_tdata           => m_axis_c2h_tdata_0, -- master, axi stream
        m_axis_tkeep           => m_axis_c2h_tkeep_0, -- is weird
        m_axis_tlast           => m_axis_c2h_tlast_0, -- last valid word in xi stream packet
--        dropped_orbit_counter  => filler_dropped_orbit_counter,
--        orbit_counter          => filler_orbit_counter,
--        axi_backpressure_seen  => axi_backpressure_seen,
       -- orbit_length           => orbit_length,   
        orbit_exceeds_size     => orbit_exceeds_size,
        in_autorealign_counter => autorealign_counter
        );


    stream_out : process (clk)
    begin 
    
    if (m_axis_c2h_tvalid_0 = '1' and s1o_rdy = '1' and s2o_rdy = '1') then
    
    s1o_data(127 downto 0) <= m_axis_c2h_tdata_0(127 downto 0);
    s2o_data(127 downto 0) <= m_axis_c2h_tdata_0(255 downto 128);
    
    s1o_valid <= '1';
    s2o_valid <= '1';
    
    else
    
    s1o_valid <= '0';
    s2o_valid <= '0';
    
    end if;
    
    end process;

end Behavioral;
