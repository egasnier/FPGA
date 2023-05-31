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
	constant period : time := 2*hp;           -- periode de 10ns, soit une frequence de 100Hz
	constant count_max : natural := 1000;     -- nombre de periodes max correspondant au compteur de période


    ------------
    -- COMPOSANT	
    ------------
	component top
		port ( 
			clk			      : in std_logic; 
			resetn		      : in std_logic;
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
	uut: top
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


    ---------------------------------------------		
	-- SIMULATION DU SIGNAL D'HORLOGE EN CONTINU
    ---------------------------------------------		
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
		wait for period*10;    
		resetn <= '0';

--        wait for 167 * count_max * period;

	   --------------------------------------------------------------------------
	    -- PREMIER TEST - ETAT IDLE                                            --
	   --------------------------------------------------------------------------
	   -- Test des 10 cycles "allume/eteint"
	   -- Attente: LEDs eteintes tout le temps
	   for i in 1 to 10 loop
	       -- Valeurs des sorties attendues
	       -- LED0 R eteinte, B eteinte, G eteinte
	       assert out_LED0_R = '0'
	           report "ERROR: out_LED0_R not equals to 0" severity failure;
	       assert out_LED0_B = '0'
	           report "ERROR: out_LED0_B not equals to 0" severity failure;
	       assert out_LED0_G = '0'
	           report "ERROR: out_LED0_G not equals to 0" severity failure;

	       -- LED1 R eteinte, B eteinte, G eteinte
	       assert out_LED1_R = '0'
	           report "ERROR: out_LED1_R not equals to 0" severity failure;
	       assert out_LED1_B = '0'
	           report "ERROR: out_LED1_B not equals to 0" severity failure;
	       assert out_LED1_G = '0'
	           report "ERROR: out_LED1_G not equals to 0" severity failure;

	       -- Attente d'un demi-cycle 
	       wait for count_max * period;

	       -- Valeurs des sorties attendues
	       -- LED0 R eteinte, B eteinte, G eteinte
	       assert out_LED0_R = '0'
	           report "ERROR: out_LED0_R not equals to 0" severity failure;
	       assert out_LED0_B = '0'
	           report "ERROR: out_LED0_B not equals to 0" severity failure;
	       assert out_LED0_G = '0'
	           report "ERROR: out_LED0_G not equals to 0" severity failure;

	       -- LED1 R eteinte, B eteinte, G eteinte
	       assert out_LED1_R = '0'
	           report "ERROR: out_LED1_R not equals to 0" severity failure;
	       assert out_LED1_B = '0'
	           report "ERROR: out_LED1_B not equals to 0" severity failure;
	       assert out_LED1_G = '0'
	           report "ERROR: out_LED1_G not equals to 0" severity failure;

	       -- Attente d'un demi-cycle 
	       wait for count_max * period;
	   end loop;



	   --------------------------------------------------------------------------
	    -- SECOND TEST - ETAT ROUGE                                            --
	   --------------------------------------------------------------------------
	   -- Test des 10 cycles "allume/eteint"
	   -- Attente: Clignotement des LEDs en rouge
	   for i in 1 to 10 loop
	       -- Valeurs des sorties attendues
	       -- LED0 R eteinte, B eteinte, G eteinte
	       assert out_LED0_R = '0'
	           report "ERROR: out_LED0_R not equals to 0" severity failure;
	       assert out_LED0_B = '0'
	           report "ERROR: out_LED0_B not equals to 0" severity failure;
	       assert out_LED0_G = '0'
	           report "ERROR: out_LED0_G not equals to 0" severity failure;

	       -- LED1 R eteinte, B eteinte, G eteinte
	       assert out_LED1_R = '0'
	           report "ERROR: out_LED1_R not equals to 0" severity failure;
	       assert out_LED1_B = '0'
	           report "ERROR: out_LED1_B not equals to 0" severity failure;
	       assert out_LED1_G = '0'
	           report "ERROR: out_LED1_G not equals to 0" severity failure;

	       -- Attente d'un demi-cycle 
	       wait for count_max * period;

	       -- Valeurs des sorties attendues
	       -- LED0 R allumee, B eteinte, G eteinte
	       assert out_LED0_R = '1'
	           report "ERROR: out_LED0_R not equals to 1" severity failure;
	       assert out_LED0_B = '0'
	           report "ERROR: out_LED0_B not equals to 0" severity failure;
	       assert out_LED0_G = '0'
	           report "ERROR: out_LED0_G not equals to 0" severity failure;

	       -- LED1 R allumee, B eteinte, G eteinte
	       assert out_LED1_R = '1'
	           report "ERROR: out_LED1_R not equals to 1" severity failure;
	       assert out_LED1_B = '0'
	           report "ERROR: out_LED1_B not equals to 0" severity failure;
	       assert out_LED1_G = '0'
	           report "ERROR: out_LED1_G not equals to 0" severity failure;

	       -- Attente d'un demi-cycle 
	       wait for count_max * period;
	   end loop;


	   --------------------------------------------------------------------------
	    -- TROISIEME TEST - ETAT BLEU                                          --
	   --------------------------------------------------------------------------
	   -- Test des 10 cycles "allume/eteint"
	   -- Attente: Clignotement des LEDs en bleu
	   for i in 1 to 10 loop
	       -- Valeurs des sorties attendues
	       -- LED0 R eteinte, B eteinte, G eteinte
	       assert out_LED0_R = '0'
	           report "ERROR: out_LED0_R not equals to 0" severity failure;
	       assert out_LED0_B = '0'
	           report "ERROR: out_LED0_B not equals to 0" severity failure;
	       assert out_LED0_G = '0'
	           report "ERROR: out_LED0_G not equals to 0" severity failure;

	       -- LED1 R eteinte, B eteinte, G eteinte
	       assert out_LED1_R = '0'
	           report "ERROR: out_LED1_R not equals to 0" severity failure;
	       assert out_LED1_B = '0'
	           report "ERROR: out_LED1_B not equals to 0" severity failure;
	       assert out_LED1_G = '0'
	           report "ERROR: out_LED1_G not equals to 0" severity failure;

	       -- Attente d'un demi-cycle 
	       wait for count_max * period;

	       -- Valeurs des sorties attendues
	       -- LED0 R allumee, B eteinte, G eteinte
	       assert out_LED0_R = '0'
	           report "ERROR: out_LED0_R not equals to 0" severity failure;
	       assert out_LED0_B = '1'
	           report "ERROR: out_LED0_B not equals to 1" severity failure;
	       assert out_LED0_G = '0'
	           report "ERROR: out_LED0_G not equals to 0" severity failure;

	       -- LED1 R allumee, B eteinte, G eteinte
	       assert out_LED1_R = '0'
	           report "ERROR: out_LED1_R not equals to 0" severity failure;
	       assert out_LED1_B = '1'
	           report "ERROR: out_LED1_B not equals to 1" severity failure;
	       assert out_LED1_G = '0'
	           report "ERROR: out_LED1_G not equals to 0" severity failure;

	       -- Attente d'un demi-cycle 
	       wait for count_max * period;
	   end loop;


	   --------------------------------------------------------------------------
	    -- QUATRIEME TEST - ETAT VERT                                          --
	   --------------------------------------------------------------------------
	   -- Test des 10 cycles "allume/eteint"
	   -- Attente: Clignotement des LEDs en vert
	   for i in 1 to 10 loop
	       -- Valeurs des sorties attendues
	       -- LED0 R eteinte, B eteinte, G eteinte
	       assert out_LED0_R = '0'
	           report "ERROR: out_LED0_R not equals to 0" severity failure;
	       assert out_LED0_B = '0'
	           report "ERROR: out_LED0_B not equals to 0" severity failure;
	       assert out_LED0_G = '0'
	           report "ERROR: out_LED0_G not equals to 0" severity failure;

	       -- LED1 R eteinte, B eteinte, G eteinte
	       assert out_LED1_R = '0'
	           report "ERROR: out_LED1_R not equals to 0" severity failure;
	       assert out_LED1_B = '0'
	           report "ERROR: out_LED1_B not equals to 0" severity failure;
	       assert out_LED1_G = '0'
	           report "ERROR: out_LED1_G not equals to 0" severity failure;

	       -- Attente d'un demi-cycle 
	       wait for count_max * period;

	       -- Valeurs des sorties attendues
	       -- LED0 R allumee, B eteinte, G eteinte
	       assert out_LED0_R = '0'
	           report "ERROR: out_LED0_R not equals to 0" severity failure;
	       assert out_LED0_B = '0'
	           report "ERROR: out_LED0_B not equals to 0" severity failure;
	       assert out_LED0_G = '1'
	           report "ERROR: out_LED0_G not equals to 1" severity failure;

	       -- LED1 R allumee, B eteinte, G eteinte
	       assert out_LED1_R = '0'
	           report "ERROR: out_LED1_R not equals to 0" severity failure;
	       assert out_LED1_B = '0'
	           report "ERROR: out_LED1_B not equals to 0" severity failure;
	       assert out_LED1_G = '1'
	           report "ERROR: out_LED1_G not equals to 1" severity failure;

	       -- Attente d'un demi-cycle 
	       wait for count_max * period;
	   end loop;



	   --------------------------------------------------------------------------
	    -- FIN DE TEST AVEC un RESET                                           --
	   --------------------------------------------------------------------------
	   -- Attente de plusieurs demi-cycles 
	   wait for 37 * count_max * period;
	   
	   -- Appui sur le bouton resetn
	   resetn <= '1';
	   wait for period*10;    
	   resetn <= '0';
	   
	   -- Test des 10 cycles "allume/eteint"
	   -- Attente: LEDs eteintes tout le temps
	   for i in 1 to 10 loop
	       -- Valeurs des sorties attendues
	       -- LED0 R eteinte, B eteinte, G eteinte
	       assert out_LED0_R = '0'
	           report "ERROR: out_LED0_R not equals to 0" severity failure;
	       assert out_LED0_B = '0'
	           report "ERROR: out_LED0_B not equals to 0" severity failure;
	       assert out_LED0_G = '0'
	           report "ERROR: out_LED0_G not equals to 0" severity failure;

	       -- LED1 R eteinte, B eteinte, G eteinte
	       assert out_LED1_R = '0'
	           report "ERROR: out_LED1_R not equals to 0" severity failure;
	       assert out_LED1_B = '0'
	           report "ERROR: out_LED1_B not equals to 0" severity failure;
	       assert out_LED1_G = '0'
	           report "ERROR: out_LED1_G not equals to 0" severity failure;

	       -- Attente d'un demi-cycle 
	       wait for count_max * period;

	       -- Valeurs des sorties attendues
	       -- LED0 R eteinte, B eteinte, G eteinte
	       assert out_LED0_R = '0'
	           report "ERROR: out_LED0_R not equals to 0" severity failure;
	       assert out_LED0_B = '0'
	           report "ERROR: out_LED0_B not equals to 0" severity failure;
	       assert out_LED0_G = '0'
	           report "ERROR: out_LED0_G not equals to 0" severity failure;

	       -- LED1 R eteinte, B eteinte, G eteinte
	       assert out_LED1_R = '0'
	           report "ERROR: out_LED1_R not equals to 0" severity failure;
	       assert out_LED1_B = '0'
	           report "ERROR: out_LED1_B not equals to 0" severity failure;
	       assert out_LED1_G = '0'
	           report "ERROR: out_LED1_G not equals to 0" severity failure;

	       -- Attente d'un demi-cycle 
	       wait for count_max * period;
	   end loop;


    wait;
	    
	end process;
	
	
end behavioral;