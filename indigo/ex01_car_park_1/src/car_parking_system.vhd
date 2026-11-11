-------------------------------------------------------------------------------
-- Logic Networks 2026 - Exercise:
-- Car Parking System
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

entity Car_Parking_System_VHDL is
  port (
    clk          : in  std_logic;
    reset_n      : in  std_logic;                    -- active low, asynchronous
    front_sensor : in  std_logic;
    back_sensor  : in  std_logic;
    password_1   : in  std_logic_vector(1 downto 0);
    password_2   : in  std_logic_vector(1 downto 0);
    GREEN_LED    : out std_logic;
    RED_LED      : out std_logic;
    HEX_1        : out std_logic_vector(6 downto 0); -- segments gfedcba
    HEX_2        : out std_logic_vector(6 downto 0)
  );
end entity;

architecture rtl of Car_Parking_System_VHDL is
  type state_type is (IDLE, WAIT_PASSWORD, WRONG_PASSWORD, RIGHT_PASSWORD, STOP);
  signal current_state : state_type;
  signal next_state    : state_type;
begin

  -- state register
  reg: process (clk, reset_n)
  begin
    if reset_n = '0' then
      current_state <= IDLE;
    elsif rising_edge(clk) then
      current_state <= next_state;
    end if;
  end process;

  FSM: process (clk)
  begin
    next_state <= current_state;

    case current_state is
      when IDLE =>
        if (front_sensor = '1') then
          next_state <= WAIT_PASSWORD;
        else
          next_state <= IDLE;
        end if;

      when WAIT_PASSWORD =>

      when WRONG_PASSWORD =>

      when RIGHT_PASSWORD =>

      when STOP =>

    end case;
  end process;
end architecture;
