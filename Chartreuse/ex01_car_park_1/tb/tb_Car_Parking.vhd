package Car_Parking_Types is
  type FSM_States is (IDLE, WAIT_PASSWORD, WRONG_PASS, RIGHT_PASS, STOP);
end package Car_Parking_Types;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Car_Parking_Types.all;

-- ENTITY DECLARATION 
entity Car_Parking_System_VHDL is
  port (
    clk, reset_n              : in std_logic;
    front_sensor, back_sensor : in std_logic;
    password_1, password_2    : in std_logic_vector(1 downto 0);
    GREEN_LED, RED_LED        : out std_logic;
    HEX1, HEX2                : out std_logic_vector(6 downto 0)
  );
end entity Car_Parking_System_VHDL;

architecture FSM_Behavioral of Car_Parking_System_VHDL is

  signal current_state, next_state : FSM_States;

  -- LOGIC SIGNALS 
  -- 10 cycles of wait (0 to 9) for fast simulation
  signal counter_wait : unsigned(3 downto 0);
  signal err_counter  : integer range 0 to 3 := 0;
  signal password_ok  : std_logic;

  -- BLINK
  -- Lowered to 5 to see blinking during short simulation
  signal blink_on      : std_logic;
  signal red_tmp, green_tmp : std_logic;

  -- DISPLAY CONSTANTS
  constant HEX_OFF : std_logic_vector(6 downto 0) := "1111111";
  constant HEX_E   : std_logic_vector(6 downto 0) := "0000110";
  constant HEX_n   : std_logic_vector(6 downto 0) := "0101011";
  constant HEX_G   : std_logic_vector(6 downto 0) := "0000010"; -- Shape of '6'
  constant HEX_O   : std_logic_vector(6 downto 0) := "1000000"; -- Shape of '0'
  constant HEX_S   : std_logic_vector(6 downto 0) := "0100100";
  constant HEX_P   : std_logic_vector(6 downto 0) := "0001100";

begin

  -- STATE PROCESS
  State_Register_Proc : process (clk, reset_n)
  begin
    if (reset_n = '0') then
      current_state <= IDLE;
    elsif (rising_edge(clk)) then
      current_state <= next_state;
    end if;
  end process State_Register_Proc;

  -- WAIT PROCESS
  Wait_Counter_Proc : process (clk, reset_n)
  begin
    if (reset_n = '0') then
      counter_wait <= (others => '0');
    elsif (rising_edge(clk)) then
      if (current_state = WAIT_PASSWORD) then
        -- Count up to 9 (total 10 cycles including 0)
        if (counter_wait <= 9) then
          counter_wait <= counter_wait + 1;
        end if;
      else
        counter_wait <= (others => '0');
      end if;
    end if;
  end process Wait_Counter_Proc;

  -- PASSWORD PROCESS
  -- basically makes sure to reset password_ok signal when another car comes
  Password_Reset_Proc : process (clk, reset_n)
  begin
    if reset_n = '0' then
      password_ok <= '0';
    elsif rising_edge(clk) then
      case current_state is

        when IDLE =>
          password_ok <= '0';

        when WAIT_PASSWORD =>
          -- Check at 9 
          if counter_wait = 9 then
            if password_1 = "01" and password_2 = "10" then
              password_ok <= '1';
            else
              password_ok <= '0';
            end if;
          end if;

        when WRONG_PASS =>
          -- Continuous check to allow correction
          if password_1 = "01" and password_2 = "10" then
            password_ok <= '1';
          else
            password_ok <= '0';
          end if;

        when STOP =>
          if back_sensor = '0' and front_sensor = '1' then -- for the STOP -> WAIT_PASSWORD state transition
            password_ok <= '0';
          else
            password_ok <= password_ok;
          end if;

        when others =>
          password_ok <= password_ok;
      end case;
    end if;
  end process Password_Reset_Proc;

  -- ERROR COUNTER PROCESS
  Error_Counter_Proc : process (clk, reset_n)
  begin
    if reset_n = '0' then
      err_counter <= 0;
    elsif rising_edge(clk) then
      case current_state is
        when WAIT_PASSWORD =>
          -- Check at 9 
          if counter_wait = 9 and password_ok = '0' then
            err_counter <= 1; -- first wrong attempt (entry point)
          end if;

        when WRONG_PASS =>
          if password_ok = '0' and front_sensor = '1' and err_counter < 3 then
            err_counter <= err_counter + 1;
          elsif front_sensor = '0' or password_ok = '1' or err_counter >= 3 then
            err_counter <= 0;
          end if;

        when others =>
          err_counter <= err_counter;
      end case;
    end if;
  end process Error_Counter_Proc;

  -- STATE TRANSITIONS
  Next_State_Logic_Proc : process (current_state, front_sensor, back_sensor, password_ok, counter_wait, err_counter)
  begin
    next_state <= current_state;
    
    case(current_state) is

      -- IDLE STATE
      when IDLE =>
        if (front_sensor = '1') then
          next_state <= WAIT_PASSWORD;
        else
          next_state <= IDLE;
        end if;

      -- WAIT PASSWORD STATE
      when WAIT_PASSWORD =>
        -- Wait while less than 9
        if (counter_wait < 9) then
          next_state <= WAIT_PASSWORD; -- basically 'calls recursively' the wait process
        else
          if (password_ok = '1') then
            next_state <= RIGHT_PASS;
          else
            next_state <= WRONG_PASS;
          end if;
        end if;

      -- WRONG PASS STATE
      when WRONG_PASS =>
        if front_sensor = '0' then -- car left before retrying
          next_state <= IDLE;
        elsif (err_counter >= 3) then
          next_state <= IDLE; -- Back at the beginning after 3 attempts
        else
          next_state <= WRONG_PASS;
        end if;

      -- RIGHT PASS STATE
      when RIGHT_PASS =>
        if back_sensor = '1' then -- car exiting
          if front_sensor = '1' then -- another car trying to get in
            next_state <= STOP;
          else
            next_state <= IDLE; -- normal exit
          end if;
        else
          next_state <= RIGHT_PASS; -- still going through
        end if;

      -- STOP STATE
      when STOP =>
        if back_sensor = '0' then -- first car gone
          if front_sensor = '1' then
            next_state <= WAIT_PASSWORD;
          else
            next_state <= IDLE;
          end if;
        else -- if first car still going through
          if front_sensor = '0' then
            next_state <= RIGHT_PASS;
          else
            next_state <= STOP;
          end if;
        end if;

    end case;
  end process Next_State_Logic_Proc;

  -- OUTPUT AND BLINK
  Output_Logic_Proc : process (clk, reset_n)
  begin
    if (reset_n = '0') then
      red_tmp   <= '0';
      green_tmp <= '0';
      HEX1      <= HEX_OFF;
      HEX2      <= HEX_OFF;
      blink_on  <= '0'; -- Reset semplice
    elsif (rising_edge(clk)) then

      -- Blink at clock frequency (toggle every cycle)
      blink_on <= not blink_on;

      case(current_state) is
        when IDLE =>
          green_tmp <= '0';
          red_tmp   <= '0';
          HEX1      <= HEX_OFF;
          HEX2      <= HEX_OFF;

        when WAIT_PASSWORD =>
          green_tmp <= '0';
          red_tmp   <= '1'; -- Fixed
          HEX1      <= HEX_E;
          HEX2      <= HEX_n;

        when WRONG_PASS =>
          green_tmp <= '0';
          red_tmp   <= blink_on; -- Blink
          HEX1      <= HEX_E;
          HEX2      <= HEX_E;

        when RIGHT_PASS =>
          green_tmp <= blink_on; -- Blink
          red_tmp   <= '0';
          HEX1      <= HEX_G;
          HEX2      <= HEX_O;

        when STOP =>
          green_tmp <= '0';
          red_tmp   <= blink_on; -- Blink
          HEX1      <= HEX_S;
          HEX2      <= HEX_P;
      end case;
    end if;
  end process Output_Logic_Proc;

  RED_LED   <= red_tmp;
  GREEN_LED <= green_tmp;

end architecture FSM_Behavioral;