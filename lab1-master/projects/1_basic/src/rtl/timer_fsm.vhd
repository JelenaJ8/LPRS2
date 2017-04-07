-------------------------------------------------------------------------------
--  Odsek za racunarsku tehniku i medjuracunarske komunikacije
--  Autor: LPRS2  <lprs2@rt-rk.com>                                           
--                                                                             
--  Ime modula: timer_fsm                                                           
--                                                                             
--  Opis:                                                               
--                                                                             
--    Automat za upravljanje radom stoperice                                              
--                                                                             
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY timer_fsm IS PORT (
                          clk_i             : IN  STD_LOGIC; -- ulazni takt signal
                          rst_i             : IN  STD_LOGIC; -- reset signal
                          reset_switch_i    : IN  STD_LOGIC; -- prekidac za resetovanje brojaca
                          start_switch_i    : IN  STD_LOGIC; -- prekidac za startovanje brojaca
                          stop_switch_i     : IN  STD_LOGIC; -- prekidac za zaustavljanje brojaca
                          continue_switch_i : IN  STD_LOGIC; -- prekidac za nastavak brojanja brojaca
                          cnt_en_o          : OUT STD_LOGIC; -- izlazni signal koji sluzi kao signal dozvole brojanja
                          cnt_rst_o         : OUT STD_LOGIC  -- izlazni signal koji sluzi kao signal resetovanja brojaca (clear signal)
                         );
END timer_fsm;



ARCHITECTURE rtl OF timer_fsm IS

TYPE   STATE_TYPE IS (IDLE, COUNT, STOP); -- stanja automata

SIGNAL current_state, next_state : STATE_TYPE; -- trenutno i naredno stanje automata
SIGNAL en,rst : STD_LOGIC;

BEGIN

-- DODATI :
-- automat sa konacnim brojem stanja koji upravlja brojanjem sekundi na osnovu stanja prekidaca

PROCESS (current_state) BEGIN 
	CASE (current_state) IS
		WHEN IDLE =>
			IF(start_switch_i = '1') THEN
				next_state <= COUNT;
			ELSE
				next_state <= IDLE;
			END IF;
		WHEN COUNT =>
			IF(stop_switch_i = '1') THEN
				next_state <= STOP;
			ELSIF(reset_switch_i = '1') THEN
				next_state <= IDLE;
			ELSE
				next_state <= COUNT;
			END IF;
		WHEN OTHERS =>
			IF(continue_switch_i = '1') THEN
				next_state <= COUNT;
			ELSIF(reset_switch_i = '1') THEN
				next_state <= IDLE;
			ELSE
				next_state <= STOP;
			END IF;
	END CASE;
END PROCESS;

process(clk_i, rst_i)
	begin
		if rst_i = '1' then
			current_state <= IDLE;
		elsif rising_edge(clk_i) then
			current_state <= next_state;
		end if;
end process;

PROCESS (current_state) BEGIN
	CASE (current_state) IS
		WHEN IDLE =>
			en <= '0';
			rst <= '1';
		WHEN COUNT =>
			en <= '1';
			rst <= '0';
		WHEN OTHERS =>
			en <= '0';
			rst <= '0';
	END CASE;
END PROCESS;

cnt_en_o <= en;
cnt_rst_o <= rst;

END rtl;