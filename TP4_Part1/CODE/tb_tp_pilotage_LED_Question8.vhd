library ieee;
use ieee.std_logic_1164.all;

entity tb_tp_pilotage is
end tb_tp_pilotage;

architecture behavioral of tb_tp_pilotage is

    signal clk         : std_logic := '0';
    signal resetn      : std_logic := '0';
    signal update      : std_logic := '0';     -- signal autorisant la mise a jour de la couleur
    signal color_LED   : std_logic_vector (1 downto 0) := "00";     -- couleur de LED
    signal out_LED_R   : std_logic;
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
            update            : std_logic;
            color_LED         : std_logic_vector (1 downto 0);
            out_LED_R         : out std_logic;
            out_LED_G         : out std_logic;
            out_LED_B         : out std_logic
        );
    end component;
	

    begin
    dut: tp_pilotage_LED
        port map (
            clk       => clk, 
            resetn    => resetn,
            update    => update,
            color_LED => color_LED,
            out_LED_R => out_LED_R,
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
	    update <= '0';
	    wait for period*10;    
	    resetn <= '1';
	    wait for period*10;    
	    resetn <= '0';


	   --------------------------------------------------------------------------
	    -- PREMIER TEST AVEC update NON APPUYE                                 --
	   --------------------------------------------------------------------------
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, G eteinte, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, G eteinte, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	      
	   wait for 2 * count_max * period;


	   --------------------------------------------------------------------------
	   -- DEUXIEME TEST AVEC LA COULEUR ROUGE                                  --
	   --------------------------------------------------------------------------
	   color_LED <= "01";
	   wait for 10 * period; 
	   -- Simulation de l'appui sur update
	   update <= '1';
	   wait for period;
	   update <= '0';

	   -- Valeurs des sorties attendues
	   -- LED R eteinte, G eteinte, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;

	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- LED R allumee, G eteinte, B eteinte
	   assert out_LED_R = '1'
	      report "ERROR: out_LED_R not equals to 1" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, G eteinte, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;

	   wait for 2 * count_max * period;
	   

	   --------------------------------------------------------------------------
	   -- TROISIEME TEST AVEC LA COULEUR VERTE                                 --
	   --------------------------------------------------------------------------
	   color_LED <= "10";
	   wait for 10 * period; 
	   -- Simulation de l'appui sur update
	   update <= '1';
	   wait for period;
	   update <= '0';

	   wait for period;
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, G eteinte, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;

	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, G allumee, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '1'
	      report "ERROR: out_LED_G not equals to 1" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, G eteinte, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;

	   wait for 2 * count_max * period;


	   --------------------------------------------------------------------------
	   -- QUATRIEME TEST AVEC LA COULEUR BLEUE                                 --
	   --------------------------------------------------------------------------
	   color_LED <= "11";
	   wait for 10 * period; 
	   -- Simulation de l'appui sur update
	   update <= '1';
	   wait for period;
	   update <= '0';

	   wait for period;
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, G eteinte, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;

	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, G eteinte, B allumee
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '1'
	      report "ERROR: out_LED_B not equals to 1" severity failure;
	      
	   wait for count_max * period;
	   -- Valeurs des sorties attendues
	   -- LED R eteinte, G eteinte, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;

	   wait for 2 * count_max * period;


	   --------------------------------------------------------------------------
	    -- FIN DE TEST AVEC un RESET                                           --
	   --------------------------------------------------------------------------
	   -- Simulation de l'appui sur update
	   update <= '0';
 	   wait for period*10;    
	   resetn <= '1';
	   wait for period*10;    
	   resetn <= '0';
	   
	   -- LED R eteinte, G eteinte, B eteinte
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   wait;
	    
	end process;
	
	
end behavioral;