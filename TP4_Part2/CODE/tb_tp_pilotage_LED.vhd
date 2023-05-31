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
	constant hp : time := 5 ns;               -- demi periode de 5ns
	constant period : time := 2*hp;           -- periode de 10ns, soit une frequence de 100Hz
	constant count_max : natural := 1000;     -- nombre de periodes max correspondant au compteur de période
	
	component tp_pilotage_LED
		port ( 
			clk			      : in std_logic; 
			resetn		      : in std_logic;
	        bouton_0	      : in std_logic;
	        bouton_1	      : in std_logic;
	        out_LED_G         : out std_logic;
	        out_LED_B         : out std_logic
		 );
	end component;
	

	begin
	dut: tp_pilotage_LED
        port map (
            clk => clk, 
            resetn => resetn,
            bouton_0 => bouton_0,
            bouton_1 => bouton_1,
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
		resetn <= '1';
		wait for period*100;    
		resetn <= '0';
		wait for period*100;
		
	   -- Valeurs des sorties attendues
	   -- G eteinte, B eteinte
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;

	   -- Attente d'un cycle pour l'ecriture d'une valeur dans la FIFO
	   wait for 6 * count_max * period;


	   --------------------------------------------------------------------------
	   -- PREMIER TEST: CLIGNOTEMENT DE LA LED BLEUE     (code "11")           --
	   -- Appui sur le bouton_0 => ecriture dans la FIFO                       --
	   -- Attente du prochain cycle pour la mise a jour (lecture de la FIFO)   --
	   -- => On s'attend a ce que la LED clignote en bleu                      --
	   --------------------------------------------------------------------------
	   -- Appui sur le bouton_0 => un signal update est genere
	   -- Comme on n'appuie pas sur le bouton_1, la FIFO écrit la couleur bleue
	   wait for period*100;
	   bouton_0 <= '1';
	   wait for period*100;
	   bouton_0 <= '0';

	   -- Attente d'un cycle pour l'ecriture d'une valeur dans la FIFO
	   wait for 2 * count_max * period;

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
	      


	   --------------------------------------------------------------------------
	   -- DEUXIEME TEST: CLIGNOTEMENT DE LA LED VERTE    (code "10")           --
	   -- Appui sur le bouton_1 => chgt de couleur (verte)                     --
	   -- Appui sur le bouton_0 => ecriture dans la FIFO                       --
	   -- Relachement des deux boutons                                         --
	   -- Attente de la fin d'un cycle => lecture de la FIFO                   --
	   -- => On s'attend a ce que la LED clignote en vert                      --
	   --------------------------------------------------------------------------
	   -- Appui sur le bouton_1 (couleur verte)
	   bouton_1 <= '1';
	   wait for period*10;
	   bouton_0 <= '1';
	   wait for period*10;

       -- Relachement des 2 boutons	   
	   bouton_1 <= '0';
	   wait for period*10;
	   bouton_0 <= '0';
	   wait for period*10;
	   
	   wait for count_max * period;
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
	      
	   

	   --------------------------------------------------------------------------
	   -- TROISIEME TEST: MEMORISATION/CLIGNOTEMENT D'UNE SEQUENCE             --
	   -- Appui sur le bouton_1 => chgt de couleur (verte)                     --
	   -- Appui sur le bouton_0 => ecriture dans la FIFO (vert)                --
	   -- Relachement du bouton_0                                              --
	   -- Appui sur le bouton_0 => ecriture dans la FIFO (vert)                --
	   -- Relachement du bouton_0                                              --
	   -- Relachement du bouton_1 => chgt de couleur (bleue)                   --
	   -- Appui sur le bouton_0 => ecriture dans la FIFO (bleu)                --
	   -- Relachement du bouton_0                                              --
	   -- Appui sur le bouton_1 => chgt de couleur (verte)                     --
	   -- Appui sur le bouton_0 => ecriture dans la FIFO (vert)                --
	   -- Relachement du bouton_0                                              --
	   -- Relachement du bouton_1 => chgt de couleur (bleue)                   --
	   -- Appui sur le bouton_0 => ecriture dans la FIFO (bleu)                --
	   -- Relachement du bouton_0                                              --
	   -- Attente de 5 cycles => lecture de la FIFO                            --
	   -- => On s'attend a observer la séquence "vert/vert/bleu/vert/bleu"     --
	   --------------------------------------------------------------------------
	   -- Appui sur le bouton_1 (couleur verte)
	   bouton_1 <= '1';
	   wait for period*10;
	   
	   -- Appui sur le bouton_0 => ecriture dans la FIFO (vert)
	   bouton_0 <= '1';
	   wait for period*10;
       -- Relachement du bouton_0
	   bouton_0 <= '0';
	   wait for period*10;
	   
	   -- Appui sur le bouton_0 => ecriture dans la FIFO (vert)
	   bouton_0 <= '1';
	   wait for period*10;
       -- Relachement du bouton_0
	   bouton_0 <= '0';
	   wait for period*10;

       -- Relachement du bouton_1 => chgt de couleur (bleue)
	   bouton_1 <= '0';
	   wait for period*10;
	   
	   -- Appui sur le bouton_0 => ecriture dans la FIFO (bleu)
	   bouton_0 <= '1';
	   wait for period*10;
       -- Relachement du bouton_0
	   bouton_0 <= '0';
	   wait for period*10;

	   -- Appui sur le bouton_1 => chgt de couleur (verte)                     --
	   bouton_1 <= '1';
	   wait for period*10;
	   -- Appui sur le bouton_0 => ecriture dans la FIFO (vert)                --
	   bouton_0 <= '1';
	   wait for period*10;
       -- Relachement du bouton_0
	   bouton_0 <= '0';
	   wait for period*10;

	   -- Relachement du bouton_1 => chgt de couleur (bleue)                   --
	   bouton_1 <= '0';
	   wait for period*10;

	   -- Appui sur le bouton_0 => ecriture dans la FIFO (bleu)                --
	   bouton_0 <= '1';
	   wait for period*10;
       -- Relachement du bouton_0
	   bouton_0 <= '0';
	   wait for period*10;

	   

	   wait for count_max * period;
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
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- G eteinte, B allumee
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '1'
	      report "ERROR: out_LED_B not equals to 1" severity failure;


	   --------------------------------------------------------------------------
	    -- FIN DE TEST AVEC un RESET                                           --
	   --------------------------------------------------------------------------
	   wait for 6 * count_max * period;

       -- Simulation d'un reset
	   resetn <= '1';
	   wait for period*10;    
	   resetn <= '0';
	   
	   -- G eteinte, B eteinte
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;

	   wait;
	    
	end process;
	
	
end behavioral;