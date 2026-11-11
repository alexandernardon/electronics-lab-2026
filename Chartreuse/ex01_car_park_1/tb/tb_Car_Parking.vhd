library ieee;
use ieee.std_logic_1164.all;

-- Testbench per sistema parcheggio: 10 test
entity tb_Car_Parking_System is
end entity tb_Car_Parking_System;

architecture test of tb_Car_Parking_System is
    -- Componente da testare
    component car_parking_system is
    port (
        clk, reset_n : in std_logic;
        front_sensor, back_sensor : in std_logic;
        pswd_in : in std_logic;  -- nuovo per timeout
        password_1, password_2 : in std_logic_vector(1 downto 0);
        GREEN_LED, RED_LED : out std_logic;
        HEX_1, HEX_2 : out std_logic_vector(6 downto 0)
    );
    end component;
    
    -- Clock period: 10 ns
    constant CLK_PERIOD : time := 10 ns;
    
    -- Segnali input
    signal s_clk : std_logic := '0';
    signal s_reset_n : std_logic;
    signal s_front_sensor : std_logic;
    signal s_back_sensor : std_logic;
    signal s_pswd_in : std_logic;
    signal s_password_1 : std_logic_vector(1 downto 0);
    signal s_password_2 : std_logic_vector(1 downto 0);
    
    -- Segnali output
    signal s_GREEN_LED : std_logic;
    signal s_RED_LED : std_logic;
    signal s_HEX_1 : std_logic_vector(6 downto 0);
    signal s_HEX_2 : std_logic_vector(6 downto 0);
begin
    -- Istanza componente
    UUT: car_parking_system
    port map (
        clk => s_clk,
        reset_n => s_reset_n,
        front_sensor => s_front_sensor,
        back_sensor => s_back_sensor,
        pswd_in => s_pswd_in,
        password_1 => s_password_1,
        password_2 => s_password_2,
        GREEN_LED => s_GREEN_LED,
        RED_LED => s_RED_LED,
        HEX_1 => s_HEX_1,
        HEX_2 => s_HEX_2
    );
    
    -- Generatore clock
    Clk_Process: process
    begin
        s_clk <= '0';
        wait for CLK_PERIOD / 2;
        s_clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Processo di test
    Stimulus_Process: process
    begin
        report "=== Inizio Test ===";
        
        -- Inizializza input
        s_front_sensor <= '0';
        s_back_sensor <= '0';
        s_pswd_in <= '0';
        s_password_1 <= "00";
        s_password_2 <= "00";
        
        -- Test 1: Reset
        report "Test 1: Reset del sistema";
        s_reset_n <= '0';
        wait for CLK_PERIOD * 5;
        s_reset_n <= '1';
        wait for CLK_PERIOD;
        -- Sistema dovrebbe essere in IDLE
        
        -- Test 2: Password sbagliata
        report "Test 2: Provo password errata";
        s_front_sensor <= '1';  -- auto arriva
        wait for CLK_PERIOD;
        s_front_sensor <= '0';
        -- Ora in WAIT_PASSWORD
        
        s_pswd_in <= '1';  -- attivo tastiera
        s_password_1 <= "11";  -- password sbagliata
        s_password_2 <= "00";
        wait for CLK_PERIOD * 15;  -- aspetto validazione (10 cicli + margine)
        -- Dovrebbe essere in WRONG_PASS con "EE" sul display
        -- Test 3: Correggo la password
        report "Test 3: Inserisco password corretta";
        s_password_1 <= "01";  -- password giusta
        s_password_2 <= "10";
        wait for CLK_PERIOD * 2;
        -- Ora in RIGHT_PASS con "GO" verde lampeggiante
        s_pswd_in <= '0';  -- disattivo tastiera
        
        -- Test 4: L'auto passa
        report "Test 4: Auto transita";
        s_back_sensor <= '1';  -- auto sul sensore uscita
        wait for CLK_PERIOD * 2;
        -- Sistema torna a IDLE
        s_back_sensor <= '0';
        wait for CLK_PERIOD * 5;
        
        -- Test 5: Password corretta al primo tentativo
        report "Test 5: Inserisco subito password corretta";
        s_front_sensor <= '1';
        wait for CLK_PERIOD;
        s_front_sensor <= '0';
        
        s_pswd_in <= '1';
        s_password_1 <= "01";
        s_password_2 <= "10";
        wait for CLK_PERIOD * 15;  -- attendo i 10 cicli
        -- Ora dovrebbe essere in RIGHT_PASS
        s_pswd_in <= '0';
        
        -- Test 6: Arriva seconda auto (STOP)
        report "Test 6: Seconda auto mentre prima sta passando";
        s_front_sensor <= '1';  -- seconda auto!
        s_back_sensor <= '1';   -- prima sta ancora passando
        wait for CLK_PERIOD * 2;
        -- Ora in STOP con "SP" rosso lampeggiante
        -- Test 7: Gestione seconda auto
        report "Test 7: Sblocco seconda auto da STOP";
        s_front_sensor <= '1';  -- seconda auto ferma
        s_back_sensor <= '0';   -- prima è passata
        s_password_1 <= "01";   -- password per seconda auto
        s_password_2 <= "10";
        wait for CLK_PERIOD * 2;
        -- Torna a RIGHT_PASS
        s_pswd_in <= '0';
        s_front_sensor <= '0';  -- auto avanza
        
        -- Test 8: Seconda auto passa
        report "Test 8: Seconda auto completa transito";
        s_back_sensor <= '1';
        wait for CLK_PERIOD * 2;
        s_back_sensor <= '0';
        wait for CLK_PERIOD * 5;
        -- Sistema tornato a IDLE
        
        -- Test 9: Reset durante operazione
        report "Test 9: Reset asincrono mentre sto inserendo password";
        s_front_sensor <= '1';
        wait for CLK_PERIOD;
        s_front_sensor <= '0';
        
        s_pswd_in <= '1';
        s_password_1 <= "01";
        s_password_2 <= "10";
        wait for CLK_PERIOD * 5;
        
        -- Reset improvviso!
        report "Applico reset...";
        s_reset_n <= '0';
        wait for CLK_PERIOD * 2;
        s_reset_n <= '1';
        wait for CLK_PERIOD * 3;
        -- Tutto dovrebbe essere resettato
        -- Test 10: Timeout password
        report "Test 10: Timeout durante inserimento password";
        s_reset_n <= '1';
        s_front_sensor <= '1';
        wait for CLK_PERIOD;
        s_front_sensor <= '0';
        
        -- Attivo tastiera
        s_pswd_in <= '1';
        s_password_1 <= "01";
        s_password_2 <= "10";
        wait for CLK_PERIOD * 3;
        
        -- Simulo timeout prima dei 10 cicli
        report "Scatta timeout! pswd_in va a 0";
        s_pswd_in <= '0';
        wait for CLK_PERIOD * 2;
        -- Sistema dovrebbe tornare a IDLE senza validare password
        wait for CLK_PERIOD * 3;
        
        report "=== Test completati ===";
        wait;
    end process;
end architecture test;