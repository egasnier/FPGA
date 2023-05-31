library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity top is
    port ( 
		clk			      : in std_logic;     -- horloge 
        resetn		      : in std_logic;     -- bouton de reset
	    out_LED0_R         : out std_logic;    -- etat de la LED0 rouge
	    out_LED0_G         : out std_logic;    -- etat de la LED0 verte
	    out_LED0_B         : out std_logic;     -- etat de la LED0 bleue
	    out_LED1_R         : out std_logic;    -- etat de la LED1 rouge
	    out_LED1_G         : out std_logic;    -- etat de la LED1 verte
	    out_LED1_B         : out std_logic     -- etat de la LED1 bleue
     );
end top;


architecture behavioral of top is

    ----------------------------------------
    -- SIGNAUX INTERNES MODULES "LED_DRIVER"
    ----------------------------------------
    -- Signaux internes pour les fins de cycle "allume/eteint"
    signal end_cycle_LED0 : std_logic := '0';    -- Sortie end_cycle du LED_driver 0    
    signal end_cycle_LED1 : std_logic := '0';    -- Sortie end_cycle du LED_driver 1 (sortie non utilisée)    

    -- Signaux internes pour la gestion de la couleur
    signal color_code :     std_logic_vector (1 downto 0) := "00";  -- Couleur de la LED
    -- "00" si eteinte
    -- "01" si rouge
    -- "10" si vert
    -- "11" si bleu

    signal update :         std_logic := '0';            -- signal autorisant la mise a jour de la couleur

    
    ----------------------------------------------
    -- SIGNAUX INTERNES MODULE "Counter 10 cycles"
    ----------------------------------------------
    constant count_max_cycle : natural := 10;          -- Nombre de cycles "allume/eteint" a compter
    signal count_cycle : std_logic_vector (4 downto 0) := (others => '0');             -- Compteur de cycle
    signal end_cnt_cycle : std_logic := '0';           -- Signal indiquant la fin de 10 cycles
    

    -----------------------------------------------------
    -- SIGNAUX INTERNES DE LA MACHINE A ETATS "FSM_color"
    -----------------------------------------------------
    type state_LED is (idle, state_R, state_B, state_G);   -- Définition des états du FSM
    
    signal current_state : state_LED;  --etat dans lequel on se trouve actuellement
    signal next_state : state_LED;	   --etat dans lequel on passera au prochain coup d'horloge



    ------------------------------------------
	-- DECLARATION DU COMPOSANT LED_driver_unit
    ------------------------------------------
	component LED_driver_unit
		port ( 
		   clk			    : in std_logic;
		   resetn           : in std_logic := '0';
           update		    : in std_logic := '0';     -- signal autorisant la mise a jour de la couleur
           color_code		: in std_logic_vector (1 downto 0) := "00";     -- couleur de LED
	       out_LED_R        : out std_logic;    -- etat de la LED rouge
	       out_LED_G        : out std_logic;    -- etat de la LED verte
	       out_LED_B        : out std_logic;    -- etat de la LED bleue
	       end_cycle        : out std_logic     -- fin de cycle
		);
	end component;	

	begin
	

    --------------------------	
	-- AFFECTATION DES SIGNAUX
    --------------------------	
	--Affectation des signaux du module LED_driver de la LED0
	mapping_LED0_driver: LED_driver_unit
        port map (
           clk => clk,
           resetn => resetn,
           update => update,
           color_code => color_code,
           out_LED_R => out_LED0_R,
           out_LED_G => out_LED0_G,
           out_LED_B => out_LED0_B,
           end_cycle => end_cycle_LED0
        );
  	
	--Affectation des signaux du module LED_driver de la LED1
	mapping_LED1_driver: LED_driver_unit
        port map (
           clk => clk,
           resetn => resetn,
           update => update,
           color_code => color_code,
           out_LED_R => out_LED1_R,
           out_LED_G => out_LED1_G,
           out_LED_B => out_LED1_B,
           end_cycle => end_cycle_LED1
        );



        ----------------------
		-- PARTIE SEQUENTIELLE	
        ----------------------
		process(clk, resetn)
		begin
            if resetn = '1' then
                current_state <= idle;            -- Retour de la FSM à l'état initial
                
                count_cycle <= (others => '0');   -- Réinitialisation du compteur
 
			elsif rising_edge(clk) then
			    current_state <= next_state;      -- Passage à l'état suivant
			    
			    -- Gestion du compteur de cycle
			    if end_cnt_cycle = '1' then
                    count_cycle <= (others => '0');   -- Réinitialisation du compteur
			    elsif end_cycle_LED0 = '1' then
			         count_cycle <= count_cycle + 1;
			    end if;
			    
			    -- Ajout d'un registre pour synchroniser le chgt de couleur et le signal update
			    update <= end_cnt_cycle;
			    
            end if;
		end process;



        ----------------------
		-- PARTIE COMBINATOIRE
        ----------------------
		-- Signal de fin des 10 cycles (on compte de 0 a 9)
		end_cnt_cycle <= '1' when (count_cycle = (count_max_cycle - 1) AND end_cycle_LED0 = '1')
				else '0';


        -------------
        -- PARTIE FSM
        -------------
		-- Machine a etats "FSM_color" pour la gestion des couleurs
		-- Si on a compté 10 cycles, on change de d'état (ie de couleur) sinon on reste dans le meme etat.
		process(current_state, end_cnt_cycle)
		begin
		   --signaux pilotes par la fsm
           case current_state is
              when idle =>
                color_code <= "00";
                if end_cnt_cycle = '1' then
                    next_state <= state_R; --prochain etat
                else
                    next_state <= current_state;
                end if;
              

              when state_R =>
                color_code <= "01";
                if end_cnt_cycle = '1' then
                    next_state <= state_B; --prochain etat
                else
                    next_state <= current_state;
                end if;


              when state_B =>
                color_code <= "11";
                if end_cnt_cycle = '1' then
                    next_state <= state_G; --prochain etat
                else
                    next_state <= current_state;
                end if;


              when state_G =>
                color_code <= "10";
                if end_cnt_cycle = '1' then
                    next_state <= state_R; --prochain etat
                else
                    next_state <= current_state;
                end if;
           
       
           end case;
              
        end process;		

end behavioral;