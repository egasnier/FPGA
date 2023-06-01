library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity LED_driver_unit is
    generic( count_max_cycle : natural := 1 );  -- Valeur du nombre de cycle à compter
    port ( 
		clk			      : in std_logic;     -- horloge 
        resetn		      : in std_logic;     -- bouton de reset
        update		      : in std_logic;     -- signal autorisant la mise a jour de la couleur
        color_code		  : in std_logic_vector (1 downto 0);     -- couleur de LED
	    out_LED_R         : out std_logic;    -- etat de la LED rouge
	    out_LED_G         : out std_logic;    -- etat de la LED verte
	    out_LED_B         : out std_logic;    -- etat de la LED bleue
	    end_cycle         : out std_logic     -- signal indiquant la fin du comptage des cycles
     );
end LED_driver_unit;


architecture behavioral of LED_driver_unit is

    -----------------------------------------------------
    -- SIGNAUX INTERNES DE LA MACHINE A ETATS "FSM"
    -----------------------------------------------------
    type state_LED is (idle_state_off, state_on);   -- Définition des états du FSM
    
    signal current_state : state_LED;  --etat dans lequel on se trouve actuellement
    signal next_state : state_LED;	   --etat dans lequel on passera au prochain coup d'horloge

    signal cmd_state_LED : std_logic := '0';  -- commande l'état de la LED (allumee ou eteinte)

    -----------------------------------------------------
    -- SIGNAL INTERNE EN SORTIE DU MODULE "Counter unit"
    -----------------------------------------------------
    signal end_counter  : std_logic := '0';   -- etat de la LED (allumee ou eteinte)


    -----------------------------------------------------
    -- SIGNAL INTERNE EN ENTREE DES MULTIPLEXEURS ("Mux")
    -----------------------------------------------------
    signal cmd_color_LED : std_logic_vector (1 downto 0) := "00";   -- commande la couleur de la LED (si '00', aucune selectionnee)
    -- ('01' => Rouge, '10' => verte, '11' => Bleue)



    ------------------------------------------
	-- DECLARATION DU COMPOSANT counter_unit
    ------------------------------------------
	--Declaration de l'entite counter_unit (compteur générant le signal end_counter)
	component counter_unit
	    generic(
	       count_max       : natural
	    );
		port ( 
		   clk			    : in std_logic;
		   resetn           : in std_logic;
		   end_counter	    : out std_logic
		);
	end component;
	


	begin

    --------------------------	
	-- AFFECTATION DES SIGNAUX
    --------------------------	
	--Affectation des signaux du compteur
	uut: counter_unit
	    generic map(
	       count_max => 100000000   -- 1 seconde
	    )
        port map (
           clk => clk,
           resetn => resetn,
           end_counter => end_counter
        );
	

        ----------------------
		-- PARTIE SEQUENTIELLE	
        ----------------------
		process(clk, resetn)
		begin
            if resetn = '1' then
                current_state <= idle_state_off;  -- Retour de la FSM à l'état initial
                
                cmd_color_LED <= "00";             -- LED s eteinte
 
			elsif rising_edge(clk) then
			    current_state <= next_state;     -- Passage à l'état suivant
			    
			    -- Update de la couleur si le signal update est a 1 sinon on conserve l'ancienne couleur
			    if update = '1' then
			         cmd_color_LED <= color_code;
		        end if;
            end if;
		end process;


		----------------------
		-- PARTIE COMBINATOIRE
        ----------------------
		-- Gestion de cycle
		end_cycle <= '1' when (end_counter = '1') AND (cmd_state_LED = '1')
			 else '0';


		-- "Mux": Clignotement des LEDs
		out_LED_R <= cmd_state_LED when cmd_color_LED = "01"
		      else '0';
		out_LED_G <= cmd_state_LED when cmd_color_LED = "10"
		      else '0';
		out_LED_B <= cmd_state_LED when cmd_color_LED = "11"
		      else '0';

		
        -------------
        -- PARTIE FSM
        -------------
		process(current_state, end_counter)
		begin
		   -- signaux pilotes par la fsm
		   -- Si on recoit le signal end_counter, on change d'etat, sinon on reste dans le meme etat.
           case current_state is
              when idle_state_off =>
                cmd_state_LED <= '0';
                if end_counter = '1' then
                    next_state <= state_on; --prochain etat
                else
                    next_state <= current_state;
                end if;
              

              when state_on =>
                cmd_state_LED <= '1';
                if end_counter = '1' then
                    next_state <= idle_state_off; --prochain etat
                else
                    next_state <= current_state;
                end if;
           
       
              end case;
              
          
		end process;
		
		

end behavioral;