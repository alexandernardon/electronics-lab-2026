-------------------------------------------------------------------------------
-- Car Parking System FSM
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Car_Parking_System_VHDL is
    port(
        clk             : in std_logic;
        reset_n         : in std_logic;     --active low (0 is active), asynchronus 
        front_sensor    : in std_logic;     --1 = car at the gate
        back_sensor     : in std_logic;     --1 = car passed the gate
        password_1      : in std_logic_vector(1 downto 0);
        password_2      : in std_logic_vector(1 downto 0);
        GREEN_LED       : out std_logic;
        RED_LED         : out std_logic;
        HEX_1           : out std_logic_vector(6 downto 0); -- segments gfedcba
        HEX_2           : out std_logic_vector(6 downto 0)
    );
end Car_Parking_System_VHDL;

architecture rtl of Car_Parking_System_VHDL is    --architecture structure inspired by sliding door exercise. 
  type state_t is (IDLE, WAIT_PASSWORD, WRONG_PASS, RIGHT_PASS, STOP);

  signal current_state, next_state : state_t; 

  signal counter : unsigned(3 downto 0); --clock cycles counter

  signal blink : std_logic;

  constant CORRECT_PASS_1 : std_logic_vector (1 downto 0) := "01";  --correct password: 0110
  constant CORRECT_PASS_2 : std_logic_vector (1 downto 0) := "10";

begin

  reg : process (clk, reset_n) --behavior with clock cycles, "memory" of current state, counter, blink
  begin
    if reset_n = '0' then     --if reset is active sets state to IDLE, and resets counter and blink. 
      current_state <= IDLE;
      counter       <= (others => '0');
      blink         <= '0';

    elsif rising_edge(clk) then
      current_state <= next_state;    --at rising clock edge changes to the next state (from FSM)

      if next_state = WAIT_PASSWORD then    -- check next state, becuause so the first cycle is 1, second cycle is 2, ...
        if counter < 10 then                -- otherwise it would be 0 at the first cycle and so on so WAIT_PASSWORD would last 11 cycles
          counter <= counter + 1;
        end if;

      else
        counter <= (others => '0');
      end if;

      blink <= not blink;  --opposite of last value of blink so it alternates.
    end if;
  end process reg;






  FSM : process (current_state, front_sensor, back_sensor, password_1, password_2, counter, blink)
    --to be done (Elvira)
  begin

    case current_state is

      when IDLE =>

      when WAIT_PASSWORD =>  
    
      when WRONG_PASS =>

      when RIGHT_PASS => 
      
      when STOP =>

    end case;
  end process FSM;


end architecture rtl;



