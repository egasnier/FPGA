library ieee;
use ieee.std_logic_1164.all;

entity tb_domaineHorloge is
end tb_domaineHorloge;

architecture behavioral of tb_domaineHorloge is

    -------------------
    -- SIGNAUX INTERNES
    -------------------
	signal clk         : std_logic := '0';
	signal resetn      : std_logic := '0';

	signal out_LED0_R   : std_logic;
	signal out_LED0_G   : std_logic;
    signal out_LED0_B   : std_logic;

	signal out_LED1_R   : std_logic;
	signal out_LED1_G   : std_logic;
    signal out_LED1_B   : std_logic;

	
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;               -- demi periode de 5ns
	constant period : time := 2 * hp;         -- periode de 10ns, soit une frequence de 100MHz
	constant period_clkA : time := 4 ns;      -- periode de 10ns, soit une frequence de 250MHz

	constant count_max : natural := 10;       -- nombre de periodes max correspondant au compteur de période


    ------------
    -- COMPOSANT	
    ------------
	component top_PLL
		port ( 
			clk			       : in std_logic; 
			resetn		       : in std_logic;
		    out_LED0_R         : out std_logic;
	        out_LED0_G         : out std_logic;
	        out_LED0_B         : out std_logic;
		    out_LED1_R         : out std_logic;
	        out_LED1_G         : out std_logic;
	        out_LED1_B         : out std_logic
		 );
	end component;
	

    ----------
    -- MAPPING
    ----------
	begin
	uut: top_PLL
        port map (
            clk => clk, 
            resetn => resetn,
		    out_LED0_R => out_LED0_R,
	        out_LED0_G => out_LED0_G,
	        out_LED0_B => out_LED0_B,
		    out_LED1_R => out_LED1_R,
	        out_LED1_G => out_LED1_G,
	        out_LED1_B => out_LED1_B
        );


    ----------------------------------------------		
	-- SIMULATION DES SIGNAUX D'HORLOGE EN CONTINU
    ----------------------------------------------		
	process
    begin
		wait for hp;
		clk <= not clk;
	end process;


	process
	begin        
	   --------------------------------------------------------------------------
	    -- INITIALISATION                                                      --
	   --------------------------------------------------------------------------
	    wait for period*10;    
		resetn <= '1';
		wait for period;    
		resetn <= '0';


        wait for 317 * count_max * period_clkA;

		resetn <= '1';
		wait for period;    
		resetn <= '0';


        wait;
	    
	end process;
	
	
end behavioral;