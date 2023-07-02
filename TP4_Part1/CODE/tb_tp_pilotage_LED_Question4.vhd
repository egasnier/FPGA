library ieee;
use ieee.std_logic_1164.all;

entity tb_tp_pilotage is
end tb_tp_pilotage;

architecture behavioral of tb_tp_pilotage is

    signal clk               : std_logic := '0';
    signal resetn            : std_logic := '0';
    signal bouton_0          : std_logic := '0';
    signal out_LED_R         : std_logic;
    signal out_LED_G         : std_logic;
	
    -- Les constantes suivantes permette de definir la frequence de l'horloge 
    constant hp        : time    := 5 ns;     -- demi periode de 5ns
    constant period    : time    := 2*hp;     -- periode de 10ns, soit une frequence de 100Hz
    constant count_max : natural := 1000;     -- nombre de periodes max correspondant au compteur de période
	
    component tp_pilotage_LED
        port ( 
            clk               : in std_logic; 
            resetn            : in std_logic;
            bouton_0          : in std_logic;
            out_LED_R         : out std_logic;
            out_LED_G         : out std_logic
        );
    end component;
	

    begin
    dut: tp_pilotage_LED
        port map (
            clk       => clk, 
            resetn    => resetn,
            bouton_0  => bouton_0,
            out_LED_R => out_LED_R,
            out_LED_G => out_LED_G
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
	    bouton_0 <= '0';
	    wait for period*10;    
		resetn <= '1';
		wait for period*10;    
		resetn <= '0';


	   --------------------------------------------------------------------------
	    -- PREMIER TEST AVEC bouton_0 NON APPUYE                               --
	   --------------------------------------------------------------------------
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- LED R allumee, B eteinte
	   assert out_LED_R = '1'
	      report "ERROR: out_LED_R not equals to 1" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	      

	   --------------------------------------------------------------------------
	    -- DEUXIEME TEST AVEC bouton_0 APPUYE                                  --
	   --------------------------------------------------------------------------
	   -- Simulation de l'appui sur bouton_0
	   bouton_0 <= '1';
	   wait for count_max * period;
	   
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, B allumee
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '1'
	      report "ERROR: out_LED_G not equals to 1" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   --------------------------------------------------------------------------
	    -- TROISEME TEST AVEC bouton_0 RELACHE                                 --
	   --------------------------------------------------------------------------
	   wait for count_max * hp;
	   -- Simulation du relachement du bouton_0
	   bouton_0 <= '0';
	   wait for count_max * hp;

	   -- Valeurs des sorties attendues
	   -- LED R allumee, B eteinte
	   assert out_LED_R = '1'
	      report "ERROR: out_LED_R not equals to 1" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;

	   
	   --------------------------------------------------------------------------
	    -- QUATRIEME TEST AVEC bouton_0 APPUYE                                  --
	   --------------------------------------------------------------------------
	   wait for count_max * hp * 3;
	   -- Simulation de l'appui sur bouton_0
	   bouton_0 <= '1';
	   wait for count_max * hp;
	   
	   -- Valeurs des sorties attendues
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	      
	   wait for count_max * period;
	   -- LED R eteinte, B allumee
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '1'
	      report "ERROR: out_LED_G not equals to 1" severity failure;


	   --------------------------------------------------------------------------
	    -- CINQUIEME TEST AVEC APPUI SUR BOUTON resetn                         --
	   --------------------------------------------------------------------------
	   -- Simulation du relachement du bouton_0
	   bouton_0 <= '0';
	   wait for period*10;    
	   resetn <= '1';
	   wait for period*10;    
	   resetn <= '0';
		
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- LED R allumee, B eteinte
	   assert out_LED_R = '1'
	      report "ERROR: out_LED_R not equals to 1" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	      

	   --------------------------------------------------------------------------
	   -- FIN DE TEST AVEC bouton_0 APPUYE                                    --
	   --------------------------------------------------------------------------
	   -- Simulation de l'appui sur bouton_0
	   bouton_0 <= '1';
   
	   wait;
	    
	end process;
	
	
end behavioral;