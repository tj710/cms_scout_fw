----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.02.2020 18:22:51
-- Design Name: 
-- Module Name: aligner - Behavioral
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
use WORK.datatypes.all;
--use work.top_decl.all;



entity aligner is
generic (
        NSTREAMS : integer
        );
    port (clk_wr : in  std_logic;
          clk_rd : in  std_logic;
          rst    : in  std_logic;       -- active high pulse
          enable : in  std_logic_vector(NSTREAMS - 1 downto 0);  -- 1 for an enabled channel
          d      : in  ldata(NSTREAMS-1 downto 0);
          q      : out adata(NSTREAMS-1 downto 0);
          q_ctrl : out acontrol
          );

end aligner;

architecture Behavioral of aligner is

    subtype aword_with_last is std_logic_vector(32 downto 0);
    type adata_with_last is array (natural range <>) of aword_with_last;

    signal q_fifo            : adata_with_last(NSTREAMS-1 downto 0);
    signal fifo_prog_empty   : std_logic_vector(NSTREAMS-1 downto 0);
    signal fifo_empty        : std_logic_vector(NSTREAMS-1 downto 0);
    signal fifo_almost_empty : std_logic_vector(NSTREAMS-1 downto 0);
    signal fifo_full         : std_logic_vector(NSTREAMS-1 downto 0);
    signal fifo_rd_en        : std_logic;

    signal write_inhibit : std_logic;
    signal reset_all_fifos      : std_logic;

    type t_state is (GAP, IDLE, D6, D5, D4, D3, D2, D1, START_GAP_OR_IDLE);
    signal State     : t_state;
    signal LastState : t_state;

    type t_ResetState is (DONE, WAIT_ORBIT_END, R1, R2, R3, A1, A2, A3, A4, A5, A6, A7, A8, WAIT_ORBIT2_END);
    signal ResetState              : t_ResetState;
--    signal rst_d : std_logic;
    signal all_streams_not_valid_d : std_logic;
    signal reset_read_sm, reset_read_sm_rd           : std_logic;

    signal all_fifos_contain_bx : std_logic;
    signal ctrl_i : acontrol;


 component aligner_fifo is
        port (
            wr_clk       : in  std_logic                       := '0';
            rd_clk       : in  std_logic                       := '0';
            rst          : in  std_logic                       := '0';
            prog_empty   : out std_logic                       := '1';
            wr_en        : in  std_logic                       := '0';
            rd_en        : in  std_logic                       := '0';
            din          : in  std_logic_vector(32 downto 0) := (others => '0');
            dout         : out std_logic_vector(32 downto 0) := (others => '0');
            full         : out std_logic                       := '0';
            empty        : out std_logic                       := '1';
            almost_empty : out std_logic                       := '1');

    end component;


begin  ---beginning of Behavioral architecture of aligner


    per_stream_fifo : for i in NSTREAMS - 1 downto 0 generate

        signal wen : std_logic;
        signal d1 : lword;
        signal last : std_logic;
        signal din : std_logic_vector(32 downto 0); 
        
        
    begin
    
        generate_last: process(clk_wr) is
        begin
          if clk_wr'event and clk_wr='1' then
            d1 <= d(i);
          end if;
        end process generate_last;

        last <= d1.valid and not d(i).valid; 
        din <= last & d1.data; 
        wen <= d1.valid and d1.strobe and enable(i) and (not write_inhibit);

        fifo_inst : aligner_fifo
            port map (
                wr_clk       => clk_wr,
                rd_clk       => clk_rd,
                rst          => reset_all_fifos,
                prog_empty   => fifo_prog_empty(i),
                wr_en        => wen,
                rd_en        => fifo_rd_en,
                din          => din,
                dout         => q_fifo(i),
                full         => fifo_full(i),
                empty        => fifo_empty(i),
                almost_empty => fifo_almost_empty(i));

    end generate per_stream_fifo;


    --
    -- upon a rising edge of the reset signal:
    --   -- wait until an orbit end is detected (all channels becoming not valid)
    --   -- wait 2 clocks
    --   -- reset fifos for 3 clocks
    --   -- wait 16 clocks
    --   -- during the whole reset time reset the read logic.
    --  
    reset_logic : process (clk_wr, rst) is
        variable not_valid : boolean;
    begin
        if rst = '1' then
            ResetState              <= WAIT_ORBIT_END;
            --waiting_orbit_end       <= '1';
            write_inhibit           <= '1';
            reset_read_sm           <= '1';
            all_streams_not_valid_d <= '1';  -- set this to 1 so that we don't detect an orgbit gap start if the reset is released in the orbit gap  
        else
            if (clk_wr'event and clk_wr = '1') then

                not_valid := true;
                for i in NSTREAMS - 1 downto 0 loop
                    if enable(i) = '1' and d(i).valid = '1' then
                        not_valid := false;
                    end if;
                end loop;

                if (not_valid) then
                    all_streams_not_valid_d <= '1';
                else
                    all_streams_not_valid_d <= '0';
                end if;

                case ResetState is
                    when WAIT_ORBIT_END =>  -- wait for a rising edge of all streams not valid
                        reset_read_sm <= '1';
                        if not_valid and all_streams_not_valid_d = '0' then
                            reset_all_fifos <= '1';
                            ResetState      <= R1;
                      --      waiting_orbit_end <= '0';
                        end if;
                    when R1 => ResetState <= R2;
                    when R2 => ResetState <= R3;
                    when R3 => ResetState <= A1; reset_all_fifos <= '0';
                    when A1 => ResetState <= A2;
                    when A2 => ResetState <= A3;
                    when A3 => ResetState <= A4;
                    when A4 => ResetState <= A5;
                    when A5 => ResetState <= A6;
                    when A6 => ResetState <= A7;
                    when A7 => ResetState <= A8;
                    when A8 => ResetState <= WAIT_ORBIT2_END; reset_read_sm <= '0';-- waiting_orbit_end <= '1';
                    when WAIT_ORBIT2_END =>
                        if not_valid and all_streams_not_valid_d = '0' then
                            write_inhibit <= '0';
                            ResetState    <= DONE;
                        --    waiting_orbit_end <= '0';
                        end if;
                    when DONE => reset_all_fifos <= '0'; reset_read_sm <= '0'; write_inhibit <= '0';
                end case;
            end if;
        end if;
    end process reset_logic;

     sync_reset_read_sm_to_clk_axi : entity work.synchroniser
        port map(
            clk => clk_rd,
            d   => reset_read_sm,
            q   => reset_read_sm_rd);
    -- 
    -- READ LOGIC
    --     

    -- check that all prog_empty are 0
    all_fifos_contain_bx <= '1' when (fifo_prog_empty and enable) = (NSTREAMS-1 downto 0 => '0')
                            else '0';


    read_logic : process (clk_rd, reset_read_sm) is
        variable i : integer;
        variable all_last : boolean;
    begin
        if reset_read_sm_rd = '1' then
            State           <= GAP;
            ctrl_i.valid    <= '0';
            ctrl_i.strobe   <= '0';
            ctrl_i.bx_start <= '0';
            ctrl_i.last     <= '0';
            q_ctrl.valid    <= '0';
            q_ctrl.strobe   <= '0';
            q_ctrl.bx_start <= '0';
            q_ctrl.last     <= '0';
            q               <= (others => AWORD_NULL);
        else
            if clk_rd'event and clk_rd = '1' then

                    all_last := true;
                    for i in q_fifo'range loop
                      if q_fifo(i)(32)='0' then
                          all_last := false;
                      end if;   
                    end loop; 

                    LastState <= State;

                    case State is

                        when GAP =>
                            if (all_fifos_contain_bx = '1') then
                                State      <= D6;
                                fifo_rd_en <= '1';
                            else
                                fifo_rd_en <= '0';
                            end if;

                        when IDLE =>
                            if (all_fifos_contain_bx = '1') then
                                State      <= D6;
                                fifo_rd_en <= '1';
                            end if;

                        when D6 =>
                            State           <= D5;

                        when D5 =>
                            State           <= D4;

                        when D4 =>
                            State <= D3;

                        when D3 =>
                            State <= D2;

                        when D2 =>
                            State <= D1;

                        when D1 =>

                            if (all_fifos_contain_bx = '1') then
                                State <= D6;
                            else
                                State <= START_GAP_OR_IDLE;
                                fifo_rd_en  <= '0';
                            end if;
                       when START_GAP_OR_IDLE =>
                            if (all_fifos_contain_bx = '1') then
                                State <= D6;
                                fifo_rd_en <= '1';
                            else
                                if all_last then 
                                    State       <= GAP;
                                else
                                    State         <= IDLE;
                                end if;
                          end if;
                       
                    end case;


                    --
                    -- Multiplexer and last flip flop
                    --
                    case LastState is
                        when D6 =>         q_ctrl.valid     <= '1';                        
                                           q_ctrl.strobe    <= '1';  
                                           q_ctrl.bx_start  <= '1';  
                                           q_ctrl.last      <= '0';
                        when D5 to D2 =>   q_ctrl.valid     <= '1';
                                           q_ctrl.strobe    <= '1';
                                           q_ctrl.bx_start  <= '0';
                                           q_ctrl.last      <= '0';
                        when D1 =>         q_ctrl.valid     <= '1';
                                           q_ctrl.strobe    <= '1';
                                           q_ctrl.bx_start  <= '0';
                                           if (all_last) then
                                              q_ctrl.last      <= '1';
                                           else    
                                              q_ctrl.last      <= '0';
                                           end if;
                        when START_GAP_OR_IDLE =>
                                           if (State = GAP) then
                                             q_ctrl.valid <= '0';
                                           else
                                             q_ctrl.valid <= '1';
                                           end if;
                                           q_ctrl.strobe   <= '0';
                                           q_ctrl.bx_start <= '0';
                                           q_ctrl.last <= '0';
                        when GAP =>        q_ctrl.valid     <= '0';
                                           q_ctrl.strobe    <= '0';
                                           q_ctrl.bx_start  <= '0';
                                           q_ctrl.last      <= '0';
                        when IDLE =>       q_ctrl.valid     <= '1';
                                           q_ctrl.strobe    <= '0';
                                           q_ctrl.bx_start  <= '0';
                                           q_ctrl.last      <= '0';
                     end case;    

                    if LastState = GAP or (LastState = START_GAP_OR_IDLE and State = GAP) then
                        q <= (others => AWORD_NULL);
                    elsif LastState = IDLE or (LastState = START_GAP_OR_IDLE and State /= GAP) then -- assume a GAP takes at least 2 clocks, otherwise it is an IDLE
                        q <= (others => AWORD_PAD);
                    else
                        for i in NSTREAMS - 1 downto 0 loop
                            if enable(i) = '1' then
                                q(i) <= q_fifo(i)(31 downto 0);
                            else
                                q(i) <= AWORD_NULL;
                            end if;
                        end loop;
                    end if;

                end if;
            end if;
    end process read_logic;



end Behavioral;
