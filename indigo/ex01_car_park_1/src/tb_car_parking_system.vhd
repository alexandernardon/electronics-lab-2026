-------------------------------------------------------------------------------
-- Self-checking testbench for car parking system
-- Taken from door_fsm_tb.vhd and modified to test the car parking system
-------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity tb_car_parking_system is
end entity;

architecture sim of tb_car_parking_system is

  -- INPUTS
  signal clk          : std_logic                    := '0';  --initial values
  signal reset_n      : std_logic                    := '1';  -- asynchronous, active low
  signal front_sensor : std_logic                    := '0';  --initial values
  signal back_sensor  : std_logic                    := '0';  --initial values
  signal password_1   : std_logic_vector(1 downto 0) := "00"; --initial values
  signal password_2   : std_logic_vector(1 downto 0) := "00"; --initial values

  -- OUTPUTS
  signal GREEN_LED : std_logic;
  signal RED_LED   : std_logic;
  signal HEX_1     : std_logic_vector(6 downto 0); --
  signal HEX_2     : std_logic_vector(6 downto 0); --

  signal done       : boolean := false;
  signal mon_errors : natural := 0;
  signal st         : std_logic_vector(2 downto 0); -- current state of the DUT

  constant C_IDLE           : std_logic_vector(2 downto 0) := "000";
  constant C_WAIT_PASSWORD  : std_logic_vector(2 downto 0) := "001";
  constant C_WRONG_PASSWORD : std_logic_vector(2 downto 0) := "010";
  constant C_RIGHT_PASSWORD : std_logic_vector(2 downto 0) := "011";
  constant C_STOP           : std_logic_vector(2 downto 0) := "111";

  -- we define a function to translate the state encoding to a string for reporting
  function name(s : std_logic_vector(2 downto 0)) return string is --function will be seen further
  begin
    case s is
      when "000" => return "IDLE";
      when "001" => return "WAIT_PASSWORD";
      when "010" => return "WRONG_PASSWORD";
      when "011" => return "RIGHT_PASSWORD";
      when "111" => return "STOP";
      when others => return "??";
    end case;
  end function;

begin

  -- ---------------------------------------------------------------- DUT --
  dut: entity work.Car_Parking_System_VHDL(rtl)
    port map (
      clk          => clk,
      reset_n      => reset_n,
      front_sensor => front_sensor,
      back_sensor  => back_sensor,
      password_1   => password_1,
      password_2   => password_2,
      GREEN_LED    => GREEN_LED,
      RED_LED      => RED_LED,
      HEX_1        => HEX_1,
      HEX_2        => HEX_2
    );
  -- -------------------------------------------------------- stimulus --
  stim: process
    variable errors : natural := 0;
    variable v      : std_logic_vector(6 downto 0); -- input vector to the DUT
    variable exp    : std_logic_vector(4 downto 0); -- expected outputs and next state from the reference model 3 outputs + 2 next state bits

    procedure check(cond : boolean; msg : string) is
    begin
      if not cond then
        report msg severity error;
        errors := errors + 1;
      end if;
    end procedure;

    procedure drive(x : std_logic_vector(6 downto 0)) is -- drive the DUT inputs with a vector of 7 bits
    begin
      clk <= not clk after 500 ps; -- 100 MHz clock
      reset_n <= x(6);
      front_sensor <= x(5);
      back_sensor <= x(4);
      password_1 <= x(3 downto 2);
      password_2 <= x(1 downto 0);
      wait for 1 us; -- some time to let the dut settle beofre next vector
    end procedure;

    procedure do_reset is
    begin
      report "-------------- Resetting the DUT --------------";
      reset_n <= '0';
      wait for 1 us;
      reset_n <= '1';
      wait for 1 us;
    end procedure;

    -- closed loop: wait for a state
    procedure wait_state(target     : std_logic_vector(1 downto 0);
                         max_cycles : natural;
                         usg        : string) is
    begin
      for i in 0 to max_cycles loop
        if st = target then
          return;
        end if;
        wait for 5 us;
      end loop;
      -- if we get here, the state was not reached in time put a test here
    end procedure;

    procedure expect_state(target : std_logic_vector(1 downto 0); msg : string) is
    begin
      check(st = target,
            msg & ": expected " & name(target) & ", got " & name(st));
    end procedure;

  begin

    ---------------------------------------------------------------- summary
    wait for 5 us;
    if errors + mon_errors = 0 then
      report "TEST PASSED (0 errors)";
    else
      report "TEST FAILED: " & integer'image(errors) & " check errors, " & integer'image(mon_errors) & " invariant violations"
        severity failure;
    end if;
    done <= true;
    wait;
  end process;

end architecture;
