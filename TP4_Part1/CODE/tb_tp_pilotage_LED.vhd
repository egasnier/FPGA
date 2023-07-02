library ieee;
use ieee.std_logic_1164.all;

entity tb_tp_pilotage is
end tb_tp_pilotage;

architecture behavioral of tb_tp_pilotage is

	signal clk         : std_logic := '0';
	signal resetn      : std_logic := '0';
	signal bouton_0	   : std_logic := '0';     -- bouton autorisant la mise a jour de la couleur
	signal bouton_1	   : std_logic := '0';     -- bouton pilotant la couleur (verte si 1, bleue si 0)
	signal out_LED_G   : std_logic;
    signal out_LED_B   : std_logic;
	
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp        : time    := 5 ns;     -- demi periode de 5ns
	constant period    : time    := 2*hp;     -- periode de 10ns, soit une frequence de 100Hz
	constant count_max : natural := 1000;     -- nombre de periodes max correspondant au compteur de période
	
	component tp_pilotage_LED
		port ( 
			clk               : in std_logic; 
			resetn            : in std_logic;
            bouton_0          : in std_logic;
            bouton_1          : in std_logic;
            out_LED_G         : out std_logic;
            out_LED_B         : out std_logic
        );
    end component;
	

	begin
	dut: tp_pilotage_LED
        port map (
            clk       => clk, 
            resetn    => resetn,
            bouton_0  => bouton_0,
            bouton_1  => bouton_1,
            out_LED_G => out_LED_G,
            out_LED_B => out_LED_B
        );
		
	--Simulation du signal d'horloge en continue
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
	   -- Les deux boutons sont relaches
	    bouton_0 <= '0';
	    bouton_1 <= '0';
	    wait for period*10;
	    -- On realise un reset.
		resetn <= '0';
		wait for period*10;    
		resetn <= '1';


	   --------------------------------------------------------------------------
	   -- PREMIER TEST: CLIGNOTEMENT DE LA LED BLEUE                           --
	   --------------------------------------------------------------------------
	   -- Appui sur le bouton_0 => un signal update est genere
	   -- Comme on n'appuie pas sur le bouton_1, la LED doit clignoter en bleu
	   bouton_0 <= '1';
	   wait for period*10;
	   bouton_0 <= '0';

	   -- Valeurs des sorties attendues
	   -- G eteinte, B eteinte
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- G eteinte, B allumee
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '1'
	      report "ERROR: out_LED_B not equals to 1" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- G eteinte, B eteinte
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	      
	   wait for 2 * count_max * period;


	   --------------------------------------------------------------------------
	   -- DEUXIEME TEST: CLIGNOTEMENT DE LA LED VERTE                          --
	   --------------------------------------------------------------------------
	   -- Appui sur le bouton_0 => un signal update est genere
	   -- Comme on appuie sur le bouton_1, la LED doit clignoter en vert
	   bouton_1 <= '1';
	   bouton_0 <= '1';
	   wait for period*10;
	   bouton_0 <= '0';

	   -- Valeurs des sorties attendues
	   -- G eteinte, B eteinte
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- G eteinte, B allumee
	   assert out_LED_G = '1'
	      report "ERROR: out_LED_G not equals to 1" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- G eteinte, B eteinte
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	      
	   wait for 2 * count_max * period;
	   

	   --------------------------------------------------------------------------
	   -- TROISIEME TEST: MAINTIEN DU CLIGNOTEMENT EN VERT                     --
	   --------------------------------------------------------------------------
	   -- On relache le bouton_1 sans appuyer sur le bouton_0
	   -- La LED doit continuer a clignoter en vert
	   bouton_1 <= '0';

	   -- Valeurs des sorties attendues
	   -- G eteinte, B eteinte
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- G eteinte, B allumee
	   assert out_LED_G = '1'
	      report "ERROR: out_LED_G not equals to 1" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- G eteinte, B eteinte
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	      
	   wait for 2 * count_max * period;


	   --------------------------------------------------------------------------
	   -- QUATRIEME TEST: CLIGNOTEMENT DE LA LED BLEU                          --
	   --------------------------------------------------------------------------
	   -- Appui sur le bouton_1 => un signal update est genere
	   -- Le bouton_1 n'étant pas appuye, la LED doit clignoter en bleu
	   bouton_0 <= '1';
	   wait for period*10;
	   bouton_0 <= '0';

	   -- Valeurs des sorties attendues
	   -- G eteinte, B eteinte
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- G eteinte, B allumee
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '1'
	      report "ERROR: out_LED_B not equals to 1" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- G eteinte, B eteinte
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	      
	   wait for 2 * count_max * period;


	   --------------------------------------------------------------------------
	    -- FIN DE TEST AVEC un RESET                                           --
	   --------------------------------------------------------------------------
	   -- Appui sur le bouton_0 => un signal update est genere
	   -- Comme on appuie sur le bouton_1, la LED doit clignoter en vert
	   bouton_1 <= '1';
	   bouton_0 <= '1';
	   wait for period*10;
	   bouton_0 <= '0';
	   --bouton_1 <= '0';
	   wait for 2 * count_max * period;

       -- Simulation d'un reset
	   resetn <= '0';
	   wait for period*10;    
	   resetn <= '1';
	   
	   -- LED R eteinte, G eteinte, B eteinte
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;

	   wait for 7 * count_max * period;
	   bouton_0 <= '1';
	   wait;
	    
	end process;
	
	
end behavioral;