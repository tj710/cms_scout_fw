----------------------------------------------------------------------------------
-- Company: CERN 
-- Engineer: Hannes Sakulin
-- 
-- Create Date: 19.02.2020 21:06:42
-- Design Name: 
-- Module Name: fifo_filler - Behavioral
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

use work.datatypes.all;


entity fifo_filler is
    generic (
        NSTREAMS : integer := 8);
    port (
        d_clk : in std_logic;
        rst   : in std_logic;

        d      : in adata(NSTREAMS -1 downto 0);
        d_ctrl : in acontrol;

        m_aclk        : in  std_logic;
        m_axis_tvalid : out std_logic;
        m_axis_tready : in  std_logic;
        m_axis_tdata  : out std_logic_vector(256-1 downto 0);
        m_axis_tkeep  : out std_logic_vector(32-1 downto 0);
        m_axis_tlast  : out std_logic := '0';
        
--        orbits_per_packet : in unsigned (15 downto 0);
--        dropped_orbit_counter  : out unsigned(64-1 downto 0);
--        orbit_counter          : out unsigned(64-1 downto 0);
--        axi_backpressure_seen  : out std_logic;
--        orbit_length           : out unsigned(63 downto 0);
        orbit_exceeds_size     : out std_logic;
        in_autorealign_counter : in  unsigned(63 downto 0)


        -- '1' while orbit larger than 3600*6 = 21600 clocks,   
        -- this may happen when the alignment logic fails 

        );
end fifo_filler;

architecture Behavioral of fifo_filler is

signal orbit_length : unsigned(63 downto 0);
signal orbits_per_packet : unsigned(15 downto 0);
signal dropped_orbit_counter : unsigned(63 downto 0);
signal orbit_counter : unsigned(63 downto 0);
signal axi_backpressure_seen : std_logic;

-- 1 MB data fifo with prog full
    component fifo_generator_0
        port (
            m_aclk         : in  std_logic;
            s_aclk         : in  std_logic;
            s_aresetn      : in  std_logic;
            s_axis_tvalid  : in  std_logic;
            s_axis_tready  : out std_logic;
            s_axis_tdata   : in  std_logic_vector(255 downto 0);
            s_axis_tkeep   : in  std_logic_vector(31 downto 0);
            s_axis_tlast   : in  std_logic;
            m_axis_tvalid  : out std_logic;
            m_axis_tready  : in  std_logic;
            m_axis_tdata   : out std_logic_vector(255 downto 0);
            m_axis_tkeep   : out std_logic_vector(31 downto 0);
            m_axis_tlast   : out std_logic;
            axis_prog_full : out std_logic
            );
    end component;

-- 1 MB packet FIFO same clock  
    component fifo_generator_1
        port (
            s_aclk        : in  std_logic;
            s_aresetn     : in  std_logic;
            s_axis_tvalid : in  std_logic;
            s_axis_tready : out std_logic;
            s_axis_tdata  : in  std_logic_vector(255 downto 0);
            s_axis_tkeep  : in  std_logic_vector(31 downto 0);
            s_axis_tlast  : in  std_logic;
            m_axis_tvalid : out std_logic;
            m_axis_tready : in  std_logic;
            m_axis_tdata  : out std_logic_vector(255 downto 0);
            m_axis_tkeep  : out std_logic_vector(31 downto 0);
            m_axis_tlast  : out std_logic
            );
    end component;

    component fifo_generator_2
        port (
            s_aclk        : in  std_logic;
            s_aresetn     : in  std_logic;
            s_axis_tvalid : in  std_logic;
            s_axis_tready : out std_logic;
            s_axis_tdata  : in  std_logic_vector(255 downto 0);
            s_axis_tkeep  : in  std_logic_vector(31 downto 0);
            s_axis_tlast  : in  std_logic;
            m_axis_tvalid : out std_logic;
            m_axis_tready : in  std_logic;
            m_axis_tdata  : out std_logic_vector(255 downto 0);
            m_axis_tkeep  : out std_logic_vector(31 downto 0);
            m_axis_tlast  : out std_logic
            );
    end component;

    signal s_axis_tvalid     : std_logic;
    signal s_axis_tready     : std_logic;
    signal s_axis_tlast      : std_logic;
    signal s_axis_tdata      : std_logic_vector(256-1 downto 0);
    signal s_axis_tvalid_reg : std_logic;
    signal s_axis_tlast_reg  : std_logic;
    signal s_axis_tdata_reg  : std_logic_vector(256-1 downto 0);
    signal axi_prog_full     : std_logic;

    type t_FillerState is (FILLING, DROPPING);
    signal fillerState : t_FillerState;

    signal d1                   : adata(NSTREAMS -1 downto 0);
    signal d_ctrl_d1, d_ctrl_d2 : acontrol;

    signal s_dropped_orbit_counter : unsigned(64-1 downto 0);
    signal s_orbit_counter         : unsigned(64-1 downto 0);

    signal orbits_in_packet : unsigned (15 downto 0);

    signal s_axi_backpressure_seen : std_logic;
    signal orbit_length_int        : unsigned (63 downto 0);

    signal rst_n : std_logic;

    -- from first big data FIFO to small distr RAM FIFO
    signal f1tofd1_axis_tvalid : std_logic;
    signal f1tofd1_axis_tready : std_logic;
    signal f1tofd1_axis_tlast  : std_logic;
    signal f1tofd1_axis_tdata  : std_logic_vector(255 downto 0);
    signal f1tofd1_axis_tkeep  : std_logic_vector (31 downto 0);
    -- from smal distr RAM FIFO to second big (packet) FIFO
    signal fd1tof2_axis_tvalid : std_logic;
    signal fd1tof2_axis_tready : std_logic;
    signal fd1tof2_axis_tlast  : std_logic;
    signal fd1tof2_axis_tdata  : std_logic_vector(255 downto 0);
    signal fd1tof2_axis_tkeep  : std_logic_vector (31 downto 0);
    -- from second big (packet) FIFO to second small distr FIFO
    signal f2tofd2_axis_tvalid : std_logic;
    signal f2tofd2_axis_tready : std_logic;
    signal f2tofd2_axis_tlast  : std_logic;
    signal f2tofd2_axis_tdata  : std_logic_vector(255 downto 0);
    signal f2tofd2_axis_tkeep  : std_logic_vector (31 downto 0);
begin

    filler : process (d_clk) is

    begin
        if (d_clk'event and d_clk = '1') then
            if (rst = '1') then
                fillerState             <= FILLING;
                s_orbit_counter         <= to_unsigned(0, 64);
                s_dropped_orbit_counter <= to_unsigned(0, 64);
                orbits_in_packet        <= to_unsigned(0, 16);
                s_axi_backpressure_seen <= '0';
                orbit_exceeds_size      <= '0';
                orbit_length_int        <= to_unsigned(0, 64);
                s_axis_tdata            <= (others => '0');
                s_axis_tlast            <= '0';
                s_axis_tvalid           <= '0';
                
            else

                d1        <= d;
                d_ctrl_d1 <= d_ctrl;
                d_ctrl_d2 <= d_ctrl_d1;

                -- register FIFO inputs so that timing is easier to meet 
                s_axis_tvalid_reg <= s_axis_tvalid;
                s_axis_tlast_reg  <= s_axis_tlast;
                s_axis_tdata_reg  <= s_axis_tdata;

                if d_ctrl_d1.valid = '1' and d_ctrl_d2.valid = '0' then  -- start of orbit
                    orbit_length_int <= to_unsigned(1, 64);
                end if;

                if d_ctrl_d1.valid = '1' and d_ctrl_d2.valid = '1' and d_ctrl_d1.strobe = '1' then
                    orbit_length_int <= orbit_length_int +1;
                    if orbit_length_int > 21600 then
                        orbit_exceeds_size <= '1';
                    else
                        orbit_exceeds_size <= '0';
                    end if;
                end if;

                if d_ctrl_d1.valid = '0' and d_ctrl_d2.valid = '1' then  -- end of orbit
                    orbit_length <= orbit_length_int;
                    orbit_length_int       <= to_unsigned(0, 64);
                    orbit_exceeds_size <= '0';
                end if;

                case fillerState is
                    when FILLING =>
                        if s_axis_tvalid_reg = '1' and s_axis_tready = '0' then
                            s_axi_backpressure_seen <= '1';
                        end if;
                        s_axis_tvalid <= d_ctrl_d1.valid and d_ctrl_d1.strobe;
                        s_axis_tlast  <= '0';  -- d_ctrl.last; --- mhmmm
                        s_axis_tdata  <= (others => '0');
                        for i in d'range loop
                            s_axis_tdata(i*32 + 31 downto i*32) <= d1(i);
                        end loop;



                        if d_ctrl_d1.valid = '0' and d_ctrl_d2.valid = '1' then  -- end of orbit
                            s_orbit_counter <= s_orbit_counter + 1;
                            if (orbits_in_packet < orbits_per_packet-1) then
                                orbits_in_packet <= orbits_in_packet + 1;
                            else
                                s_axis_tvalid    <= '1';
                                s_axis_tlast     <= '1';
                                s_axis_tdata     <= std_logic_vector(s_orbit_counter + 1) & std_logic_vector(s_dropped_orbit_counter) & std_logic_vector(in_autorealign_counter) & x"deadbeefdeadbeef";  -- end of packet marker
--                                s_axis_tdata     <= x"deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef";  -- end of packet marker
                                orbits_in_packet <= to_unsigned(0, 16);
                            end if;
                            if axi_prog_full = '1' then
                                fillerState <= DROPPING;
                            end if;
                        end if;
                    when DROPPING =>
                        s_axis_tvalid <= '0';
                        s_axis_tlast  <= '0';
                        s_axis_tdata  <= (others => '0');
                        if d_ctrl_d1.valid = '0' and d_ctrl_d2.valid = '1' then  -- end of orbit
                            s_orbit_counter         <= s_orbit_counter + 1;
                            s_dropped_orbit_counter <= s_dropped_orbit_counter + 1;
                            if axi_prog_full = '1' then
                                fillerState <= DROPPING;
                            end if;
                        end if;
                        if d_ctrl.valid = '1' and d_ctrl_d1.valid = '0' then  -- start of orbit
                            if axi_prog_full = '0' then
                                fillerState <= FILLING;
                            end if;
                        end if;

                end case fillerState;
            end if;
        end if;

    end process filler;

    orbit_counter         <= s_orbit_counter;
    dropped_orbit_counter <= s_dropped_orbit_counter;
    axi_backpressure_seen <= s_axi_backpressure_seen;

    rst_n <= not rst;

    fifo : fifo_generator_0
        port map(
            s_aclk         => d_clk,
            m_aclk         => m_aclk,
            s_aresetn      => rst_n,
            s_axis_tvalid  => s_axis_tvalid_reg,
            s_axis_tready  => s_axis_tready,
            s_axis_tdata   => s_axis_tdata_reg,
            s_axis_tkeep   => (others => '1'),
            s_axis_tlast   => s_axis_tlast_reg,
            axis_prog_full => axi_prog_full,

            m_axis_tvalid => f1tofd1_axis_tvalid,
            m_axis_tready => f1tofd1_axis_tready,
            m_axis_tdata  => f1tofd1_axis_tdata,
            m_axis_tkeep  => f1tofd1_axis_tkeep,
            m_axis_tlast  => f1tofd1_axis_tlast
            );

    distrRAM_fifo12 : fifo_generator_2  -- small FIFO to achcive timing between two big FIFOs
        port map (
            s_aclk        => m_aclk,
            s_aresetn     => rst_n,
            s_axis_tvalid => f1tofd1_axis_tvalid,
            s_axis_tready => f1tofd1_axis_tready,
            s_axis_tdata  => f1tofd1_axis_tdata,
            s_axis_tkeep  => f1tofd1_axis_tkeep,
            s_axis_tlast  => f1tofd1_axis_tlast,
            m_axis_tvalid => fd1tof2_axis_tvalid,
            m_axis_tready => fd1tof2_axis_tready,
            m_axis_tdata  => fd1tof2_axis_tdata,
            m_axis_tkeep  => fd1tof2_axis_tkeep,
            m_axis_tlast  => fd1tof2_axis_tlast
            );



    fifo2 : fifo_generator_1
        port map (
            s_aclk        => m_aclk,
            s_aresetn     => rst_n,
            s_axis_tvalid => fd1tof2_axis_tvalid,
            s_axis_tready => fd1tof2_axis_tready,
            s_axis_tdata  => fd1tof2_axis_tdata,
            s_axis_tkeep  => fd1tof2_axis_tkeep,
            s_axis_tlast  => fd1tof2_axis_tlast,

            m_axis_tvalid => f2tofd2_axis_tvalid,
            m_axis_tready => f2tofd2_axis_tready,
            m_axis_tdata  => f2tofd2_axis_tdata,
            m_axis_tkeep  => f2tofd2_axis_tkeep,
            m_axis_tlast  => f2tofd2_axis_tlast

            );

    distrRAM_fifo2dma : fifo_generator_2  -- small FIFO to achcive timing between two big FIFOs
        port map (
            s_aclk        => m_aclk,
            s_aresetn     => rst_n,
            s_axis_tvalid => f2tofd2_axis_tvalid,
            s_axis_tready => f2tofd2_axis_tready,
            s_axis_tdata  => f2tofd2_axis_tdata,
            s_axis_tkeep  => f2tofd2_axis_tkeep,
            s_axis_tlast  => f2tofd2_axis_tlast,
            
            m_axis_tvalid => m_axis_tvalid,
            m_axis_tready => m_axis_tready,
            m_axis_tdata  => m_axis_tdata,
            m_axis_tkeep  => m_axis_tkeep,
            m_axis_tlast  => m_axis_tlast
            );


end Behavioral;

