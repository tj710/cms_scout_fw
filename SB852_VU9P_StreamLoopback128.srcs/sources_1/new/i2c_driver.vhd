----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:09:18 12/06/2017 
-- Design Name: 
-- Module Name:    i2c_driver - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity i2c_driver is
    generic(
        input_clk : integer := 50_000_000;  --input clock speed from user logic in Hz
        bus_clk   : integer := 400_000);  --speed the i2c bus (scl) will run at in Hz
    port(
        clk     : in    std_logic;      --system clock
        reset   : in    std_logic;      --active high reset
        str_wr  : in    std_logic;
        str_rd  : in    std_logic;
        data_rd : out   std_logic_vector(7 downto 0);
        sda     : inout std_logic;      --serial data output of i2c bus
        scl     : inout std_logic);     --serial clock output of i2c bus
end i2c_driver;

architecture Behavioral of i2c_driver is

    signal rst_n : std_logic;

    signal ena       : std_logic                    := '0';
    signal addr      : std_logic_vector(6 downto 0) := (others => '0');
    signal rw        : std_logic                    := '0';
    signal data_wr   : std_logic_vector(7 downto 0) := (others => '0');
    signal busy      : std_logic;
--   signal data_rd : std_logic_vector(7 downto 0);
    signal ack_error : std_logic;

    type state_s is (ready, address, busy_wait, data);
    signal state                                               : state_s                      := ready;
    signal data_addr_i, data_i, data_addr_l, data_l            : std_logic_vector(7 downto 0) := (others => '0');
    signal addr_i, addr_l                                      : std_logic_vector(6 downto 0) := (others => '0');
    signal start, rw_i, rw_l, one_byte_only_i, one_byte_only_l : std_logic                    := '0';
    signal fsm_busy, driver_busy                               : std_logic                    := '0';
    type machine_s is (idle, wait_st, wait_long, switch, dco_f, reg_7, reg_8, reg_9, reg_10, reg_11,
                       reg_12, dco_u, new_freq, sw_read);
    signal machine, next_state : machine_s := idle;

begin

    rst_n <= not reset;

    i2c_master_i : entity work.i2c_master generic map (
        input_clk => input_clk,  --input clock speed from user logic in Hz
        bus_clk   => bus_clk)    --speed the i2c bus (scl) will run at in Hz
        port map (
            clk       => clk,
            reset_n   => rst_n,
            ena       => ena,
            addr      => addr,
            rw        => rw,
            data_wr   => data_wr,
            busy      => busy,
            data_rd   => data_rd,
            ack_error => ack_error,
            sda       => sda,
            scl       => scl
            );



    fsm_proc : process(clk, reset, state, data_addr_i, data_i, rw_i, addr_i, data_addr_l,
                       addr_l, rw_l, busy)
        variable cnt : integer range 0 to 255 := 0;
    begin
        if reset = '1' then
            state    <= ready;
            rw       <= '0';
            ena      <= '0';
            data_wr  <= (others => '0');
            cnt      := 0;
            fsm_busy <= '0';
        elsif clk'event and clk = '1' then
            case state is
                when ready => ena <= '0';
                              if start = '1' then
                                  data_addr_l     <= data_addr_i;
                                  data_l          <= data_i;
                                  rw_l            <= rw_i;
                                  addr_l          <= addr_i;
                                  one_byte_only_l <= one_byte_only_i;
                                  state           <= address;
                                  fsm_busy        <= '1';
                              else
                                  state <= ready;
                              end if;
                when address => data_wr <= data_addr_l;
                                if one_byte_only_l = '1' then
                                    rw <= rw_l;
                                else
                                    rw <= '0';
                                end if;
                                addr <= addr_l;
                                ena  <= '1';
                                if cnt > 124 then
                                    cnt   := 0;
                                    state <= busy_wait;
                                else
                                    cnt   := cnt + 1;
                                    state <= address;
                                end if;
                when busy_wait =>
                    if one_byte_only_l = '0' then
                        data_wr <= data_l;
                        rw      <= rw_l;
                        ena     <= '1';
                        if busy = '1' then
                            state <= busy_wait;
                        else
                            state <= data;
                        end if;
                    else
                        fsm_busy <= '0';
                        state    <= ready;
                    end if;
                when data =>
                    if cnt > 124 then
                        cnt      := 0;
                        fsm_busy <= '0';
                        state    <= ready;
                    else
                        cnt   := cnt + 1;
                        state <= data;
                    end if;
                when others => state <= ready;
            end case;
        end if;
    end process;

    driver_busy <= busy or fsm_busy;

    si570_proc : process(clk, reset, driver_busy)
        variable cnt : integer range 0 to 2**20-1 := 0;
    begin
        if reset = '1' then
            machine    <= idle;
            next_state <= idle;
            start      <= '0';
            cnt        := 0;
        elsif clk'event and clk = '1' then
            case machine is
                when idle => start <= '0';
                             if str_wr = '1' then
                                 machine    <= wait_st;
                                 next_state <= switch;
                             elsif str_rd = '1' then
                                 machine    <= wait_st;
                                 next_state <= sw_read;
                             else
                                 machine <= idle;
                             end if;
                when wait_st => machine <= next_state;
                when switch =>
                    if driver_busy = '1' then
                        start   <= '0';
                        machine <= switch;
                    else
                        addr_i          <= "1110100";  -- x"74", I2C switch
                        data_addr_i     <= x"04";      --ch2, MGT ref clock
                        data_i          <= x"00";
                        rw_i            <= '0';
                        one_byte_only_i <= '1';
                        start           <= '1';
                        next_state      <= wait_long;
                        machine         <= wait_st;
                    end if;
                when wait_long => start <= '0';
                                  if cnt = 2**16 then
                                      cnt        := 0;
                                      next_state <= dco_f;
                                      machine    <= wait_st;
                                  else
                                      cnt        := cnt + 1;
                                      next_state <= wait_long;
                                      machine    <= wait_st;
                                  end if;
                when dco_f =>
                    if driver_busy = '1' then
                        start   <= '0';
                        machine <= dco_f;
                    else
                        addr_i          <= "1011101";  -- x"5D", MGT ref clock
                        data_addr_i     <= x"89";      -- 137
                        data_i          <= x"10";      -- freeze the DCO
                        rw_i            <= '0';
                        one_byte_only_i <= '0';
                        start           <= '1';
                        next_state      <= reg_7;
                        machine         <= wait_st;
                    end if;
                when reg_7 =>
                    if driver_busy = '1' then
                        start   <= '0';
                        machine <= reg_7;
                    else
                        addr_i          <= "1011101";  -- x"5D"
                        data_addr_i     <= x"07";      -- 7
                        data_i          <= x"20";
                        rw_i            <= '0';
                        one_byte_only_i <= '0';
                        start           <= '1';
                        next_state      <= reg_8;
                        machine         <= wait_st;
                    end if;
                when reg_8 =>
                    if driver_busy = '1' then
                        start   <= '0';
                        machine <= reg_8;
                    else
                        addr_i          <= "1011101";  -- x"5D"
                        data_addr_i     <= x"08";      -- 8
                        data_i          <= x"C2";
                        rw_i            <= '0';
                        one_byte_only_i <= '0';
                        start           <= '1';
                        next_state      <= reg_9;
                        machine         <= wait_st;
                    end if;
                when reg_9 =>
                    if driver_busy = '1' then
                        start   <= '0';
                        machine <= reg_9;
                    else
                        addr_i          <= "1011101";  -- x"5D"
                        data_addr_i     <= x"09";      -- 9
                        data_i          <= x"BC";
                        rw_i            <= '0';
                        one_byte_only_i <= '0';
                        start           <= '1';
                        next_state      <= reg_10;
                        machine         <= wait_st;
                    end if;
                when reg_10 =>
                    if driver_busy = '1' then
                        start   <= '0';
                        machine <= reg_10;
                    else
                        addr_i          <= "1011101";  -- x"5D"
                        data_addr_i     <= x"0A";      -- 10
                        data_i          <= x"01";
                        rw_i            <= '0';
                        one_byte_only_i <= '0';
                        start           <= '1';
                        next_state      <= reg_11;
                        machine         <= wait_st;
                    end if;
                when reg_11 =>
                    if driver_busy = '1' then
                        start   <= '0';
                        machine <= reg_11;
                    else
                        addr_i          <= "1011101";  -- x"5D"
                        data_addr_i     <= x"0B";      -- 11
                        data_i          <= x"1E";
                        rw_i            <= '0';
                        one_byte_only_i <= '0';
                        start           <= '1';
                        next_state      <= reg_12;
                        machine         <= wait_st;
                    end if;
                when reg_12 =>
                    if driver_busy = '1' then
                        start   <= '0';
                        machine <= reg_12;
                    else
                        addr_i          <= "1011101";  -- x"5D"
                        data_addr_i     <= x"0C";      -- 12
                        data_i          <= x"B8";
                        rw_i            <= '0';
                        one_byte_only_i <= '0';
                        start           <= '1';
                        next_state      <= dco_u;
                        machine         <= wait_st;
                    end if;
                when dco_u =>
                    if driver_busy = '1' then
                        start   <= '0';
                        machine <= dco_u;
                    else
                        addr_i          <= "1011101";  -- x"5D"
                        data_addr_i     <= x"89";      -- 137
                        data_i          <= x"00";      -- unfreeze the DCO
                        rw_i            <= '0';
                        one_byte_only_i <= '0';
                        start           <= '1';
                        next_state      <= new_freq;
                        machine         <= wait_st;
                    end if;
                when new_freq =>
                    if driver_busy = '1' then
                        start   <= '0';
                        machine <= new_freq;
                    else
                        addr_i          <= "1011101";  -- x"5D"
                        data_addr_i     <= x"87";      -- 135
                        data_i          <= x"40";      -- new_freq bit
                        rw_i            <= '0';
                        one_byte_only_i <= '0';
                        start           <= '1';
                        machine         <= idle;
                    end if;
                when sw_read =>
                    if driver_busy = '1' then
                        start   <= '0';
                        machine <= sw_read;
                    else
                        addr_i          <= "1110100";  -- x"74"
                        data_addr_i     <= x"04";      -- ch2
                        data_i          <= x"00";
                        rw_i            <= '1';
                        one_byte_only_i <= '1';
                        start           <= '1';
                        next_state      <= idle;
                        machine         <= wait_st;
                    end if;
                when others => machine <= idle;
            end case;
        end if;
    end process;
end Behavioral;
