library ieee;
use ieee.std_logic_1164.all;
entity Car_Parking_System is
    port(
        clk : in std_logic;
        reset_n : in std_logic;
        front_sensor : in std_logic;
        back_sensor : in std_logic;
        password_1 : in std_logic_vector(1 downto 0);
        password_2 : in std_logic_vector(1 downto 0);
        GREEN_LED : out std_logic;
        RED_LED : out std_logic;
        HEX_1 : out std_logic_vector(6 downto 0);
        HEX_2 : out std_logic_vector(6 downto 0)
    );
end Car_Parking_System;
