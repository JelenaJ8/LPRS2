-------------------------------------------------------------------------------
--  Odsek za racunarsku tehniku i medjuracunarske komunikacije
--  Autor: LPRS2  <lprs2@rt-rk.com>                                           
--                                                                             
--  Ime modula: timer_counter                                                          
--                                                                             
--  Opis:                                                               
--                                                                             
--    Modul odogvaran za indikaciju o proteku sekunde
--                                                                             
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY clk_counter IS GENERIC(
                              -- maksimalna vrednost broja do kojeg brojac broji
                              max_cnt : STD_LOGIC_VECTOR(25 DOWNTO 0) := "10111110101111000010000000" -- 50 000 000
                             );
                      PORT   (
                               clk_i     : IN  STD_LOGIC; -- ulazni takt
                               rst_i     : IN  STD_LOGIC; -- reset signal
                               cnt_en_i  : IN  STD_LOGIC; -- signal dozvole brojanja
                               cnt_rst_i : IN  STD_LOGIC; -- signal resetovanja brojaca (clear signal)
                               one_sec_o : OUT STD_LOGIC  -- izlaz koji predstavlja proteklu jednu sekundu vremena
                             );
END clk_counter;

ARCHITECTURE rtl OF clk_counter IS

component reg is
	generic(
		WIDTH    : positive := 1;
		RST_INIT : integer := 0
	);
	port(
		i_clk  : in  std_logic;
		in_rst : in  std_logic;
		i_d    : in  std_logic_vector(WIDTH-1 downto 0);
		o_q    : out std_logic_vector(WIDTH-1 downto 0)
	);
end component reg;

SIGNAL   counter_r : STD_LOGIC_VECTOR(25 DOWNTO 0);
SIGNAL	NEXT_CNT : STD_LOGIC_VECTOR(25 DOWNTO 0);
SIGNAL	MID_CNT : STD_LOGIC_VECTOR(25 DOWNTO 0);
SIGNAL	CNT2 : STD_LOGIC_VECTOR(25 DOWNTO 0);
SIGNAL	ADD_CNT : STD_LOGIC_VECTOR(25 DOWNTO 0);
SIGNAL	ONE_SEC : STD_LOGIC;

BEGIN

-- DODATI:
-- brojac koji kada izbroji dovoljan broj taktova generise SIGNAL one_sec_o koji
-- predstavlja jednu proteklu sekundu, brojac se nulira nakon toga

clk_counter : reg 
GENERIC MAP (
	WIDTH => 26,
	RST_INIT => 0
)
PORT MAP (
	i_clk => clk_i,
	in_rst => not rst_i,
	i_d => NEXT_CNT,
	o_q => counter_r
);
						
-- KOMPARATOR --
ONE_SEC <= '1' when counter_r = 50000000-1 else '0';

-- SABIRAC --
ADD_CNT <= counter_r + 1;

-- MUX1 --
WITH cnt_rst_i SELECT NEXT_CNT <=
	MID_CNT WHEN '0',
	"00000000000000000000000000" WHEN OTHERS;
	
-- MUX2 --
WITH cnt_en_i SELECT MID_CNT <=
	CNT2 WHEN '1',
	counter_r WHEN OTHERS;
	
-- MUX3 --
WITH ONE_SEC SELECT CNT2 <=
	ADD_CNT WHEN '0',
	"00000000000000000000000000" WHEN OTHERS;

one_sec_o <= ONE_SEC;

END rtl;