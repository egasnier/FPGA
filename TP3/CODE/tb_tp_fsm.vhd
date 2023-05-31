library ieee;
use ieee.std_logic_1164.all;

entity tb_tp_fsm is
end tb_tp_fsm;

architecture behavioral of tb_tp_fsm is

	signal clk         : std_logic := '0';
	signal resetn      : std_logic := '0';
	signal btn_restart : std_logic := '0';
	signal end_counter_cycle : std_logic;
	signal out_LED_R         : std_logic;
	signal out_LED_B         : std_logic;
	signal out_LED_G         : std_logic;
	
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;               -- demi periode de 5ns
	constant period : time := 2*hp;           -- periode de 10ns, soit une frequence de 100Hz
	constant count_max : natural := 1000;     -- nombre de periodes max correspondant au compteur de période
	constant count_max_cycle : natural := 3;  -- nombre de cycle max correspondant au compteur de cycle
	
	
	component tp_fsm
	    generic(
	       count_max_cycle    : natural
	    );
		port ( 
			clk			      : in std_logic; 
			resetn		      : in std_logic;
			btn_restart       : in std_logic;
		    end_counter_cycle : out std_logic;
		    out_LED_R         : out std_logic;
	        out_LED_B         : out std_logic;
	        out_LED_G         : out std_logic
		 );
	end component;
	
	

	begin
	dut: tp_fsm
	    generic map(
	       count_max_cycle => 3
	    )
        port map (
            clk => clk, 
            resetn => resetn,
            btn_restart => btn_restart,
			end_counter_cycle => end_counter_cycle,
		    out_LED_R => out_LED_R,
	        out_LED_B => out_LED_B,
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
	    btn_restart <= '0';
	    wait for period*10;    
		resetn <= '1';
		wait for period*10;    
		resetn <= '0';

	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;
	   
	   --------------------------------------------------------------------------
	   -- PREMIER TEST: ETAT IDLE                                              --
	   -- Les 3 LED doivent clignoter 3 fois en meme temps                     --
	   --------------------------------------------------------------------------
	   -- counting for count_max_cycle cycles
       wait for ((count_max - 1) * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '1'
	      report "ERROR: out_LED_R not equals to 1" severity failure;
	   assert out_LED_B = '1'
	      report "ERROR: out_LED_B not equals to 1" severity failure;
	   assert out_LED_G = '1'
	      report "ERROR: out_LED_G not equals to 1" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '1'
	      report "ERROR: out_LED_R not equals to 1" severity failure;
	   assert out_LED_B = '1'
	      report "ERROR: out_LED_B not equals to 1" severity failure;
	   assert out_LED_G = '1'
	      report "ERROR: out_LED_G not equals to 1" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 1
	   assert end_counter_cycle = '1'
	      report "ERROR: end_counter_cycle not equals to 1" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '1'
	      report "ERROR: out_LED_R not equals to 1" severity failure;
	   assert out_LED_B = '1'
	      report "ERROR: out_LED_B not equals to 1" severity failure;
	   assert out_LED_G = '1'
	      report "ERROR: out_LED_G not equals to 1" severity failure;


	   --------------------------------------------------------------------------
	   -- DEUXIEME TEST: TEST DU CLIGNOTEMENT DE LA LED ROUGE                  --
	   -- La LED Rouge doit clignoter 3 fois.                                  --
	   --------------------------------------------------------------------------
	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '1'
	      report "ERROR: out_LED_R not equals to 1" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '1'
	      report "ERROR: out_LED_R not equals to 1" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 1
	   assert end_counter_cycle = '1'
	      report "ERROR: end_counter_cycle not equals to 1" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '1'
	      report "ERROR: out_LED_R not equals to 1" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   --------------------------------------------------------------------------
	   -- TROISIEME TEST: TEST DU CLIGNOTEMENT DE LA LED BLEUE                 --
	   -- La LED Bleue doit clignoter 3 fois.                                  --
	   --------------------------------------------------------------------------
	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '1'
	      report "ERROR: out_LED_B not equals to 1" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '1'
	      report "ERROR: out_LED_B not equals to 1" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 1
	   assert end_counter_cycle = '1'
	      report "ERROR: end_counter_cycle not equals to 1" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '1'
	      report "ERROR: out_LED_B not equals to 1" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   --------------------------------------------------------------------------
	   -- QUATRIEME TEST: TEST DU CLIGNOTEMENT DE LA LED VERTE                 --
	   -- La LED Verte doit clignoter 3 fois.                                  --
	   --------------------------------------------------------------------------
	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '1'
	      report "ERROR: out_LED_G not equals to 1" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '1'
	      report "ERROR: out_LED_G not equals to 1" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 1
	   assert end_counter_cycle = '1'
	      report "ERROR: end_counter_cycle not equals to 1" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '1'
	      report "ERROR: out_LED_G not equals to 1" severity failure;



       --------------------------------------------------------------------------
	   -- CINQUIEME TEST: TEST DU CLIGNOTEMENT DE LA LED ROUGE                 --
	   -- La LED Rouge doit clignoter 3 fois.                                  --
	   --------------------------------------------------------------------------
	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '1'
	      report "ERROR: out_LED_R not equals to 1" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   --------------------------------------------------------------------------
	   -- SIXIEME TEST: TEST DU BOUTON btn_restart                             --
	   -- Suite a l'appui sur le bouton btn_restart, on doit revenir dans      --
	   -- idle. Les 3 LEDs doivent clignoter 3 fois.                           --
	   --------------------------------------------------------------------------
       -- Appui sur le bouton btn_restart
	   btn_restart <= '1';
	   wait for 10 * period;
	   btn_restart <= '0';
	   
	   
	   -- counting for count_max_cycle cycles
       wait for ((count_max - 10) * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '1'
	      report "ERROR: out_LED_R not equals to 1" severity failure;
	   assert out_LED_B = '1'
	      report "ERROR: out_LED_B not equals to 1" severity failure;
	   assert out_LED_G = '1'
	      report "ERROR: out_LED_G not equals to 1" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '1'
	      report "ERROR: out_LED_R not equals to 1" severity failure;
	   assert out_LED_B = '1'
	      report "ERROR: out_LED_B not equals to 1" severity failure;
	   assert out_LED_G = '1'
	      report "ERROR: out_LED_G not equals to 1" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '0'
	      report "ERROR: end_counter_cycle not equals to 0" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '0'
	      report "ERROR: out_LED_R not equals to 0" severity failure;
	   assert out_LED_B = '0'
	      report "ERROR: out_LED_B not equals to 0" severity failure;
	   assert out_LED_G = '0'
	      report "ERROR: out_LED_G not equals to 0" severity failure;


	   -- counting for count_max_cycle cycles
       wait for (count_max * period);
	   -- Valeurs des sorties attendues
	   -- end_counter_cycle = 0
	   assert end_counter_cycle = '1'
	      report "ERROR: end_counter_cycle not equals to 1" severity failure;
	   -- LED R, B, et G allummées
	   assert out_LED_R = '1'
	      report "ERROR: out_LED_R not equals to 1" severity failure;
	   assert out_LED_B = '1'
	      report "ERROR: out_LED_B not equals to 1" severity failure;
	   assert out_LED_G = '1'
	      report "ERROR: out_LED_G not equals to 1" severity failure;


   
		wait;
	    
	end process;
	
	
end behavioral;