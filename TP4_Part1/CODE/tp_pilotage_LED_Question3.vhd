library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity tp_pilotage_LED is
    port ( 
        clk               : in std_logic; 
        resetn            : in std_logic;
        bouton_0          : in std_logic;
        out_LED_R         : out std_logic;
        out_LED_G         : out std_logic       
    );
end tp_pilotage_LED;


architecture behavioral of tp_pilotage_LED is

    type state_LED is (idle_state_off, state_on);   -- Définition des états du FSM
    
    signal current_state : state_LED;         -- etat dans lequel on se trouve actuellement
    signal next_state    : state_LED;	      -- etat dans lequel on passera au prochain coup d'horloge
    
    signal end_counter   : std_logic := '0';  -- etat de la LED (allumee ou eteinte)
    signal cmd_state_LED : std_logic := '0';  -- commande l'état de la LED (allumee ou eteinte)
    
    
    --Declaration de l'entite counter_unit (compteur générant le signal end_counter)
    component counter_unit
        generic(
            count_max       : natural
        );
        port ( 
            clk             : in std_logic;
            resetn          : in std_logic;
            end_counter     : out std_logic
        );
    end component;
	

    begin
	
    --Affectation des signaux du compteur de cycle avec ceux de counter_unit
    uut: counter_unit
        generic map(
            count_max   => 1000
        )
        port map (
            clk         => clk,
            resetn      => resetn,
            end_counter => end_counter
        );
	

        -- PARTIE SEQUENTIELLE	
        process(clk, resetn)
        begin
            if(resetn = '1') then
                current_state <= idle_state_off;  -- Retour de la FSM à l'état initial
 
            elsif(rising_edge(clk)) then
                current_state <= next_state;      -- Passage à l'état suivant
			    		
            end if;
        end process;
		
        -- PARTIE COMBINATOIRE
        -- Clignotement des LEDs
        out_LED_R <= cmd_state_LED when (bouton_0 = '0')
            else '0';

        out_LED_G <= cmd_state_LED when (bouton_0 = '1')
            else '0';

		
        -- FSM
        process(current_state, end_counter)
        begin
            --signaux pilotes par la fsm
            case current_state is
                when idle_state_off =>
                    cmd_state_LED <= '0';
                    if (end_counter = '1') then
                        next_state <= state_on; --prochain etat
                    else
                        next_state <= current_state;
                    end if;
              

                when state_on =>
                    cmd_state_LED <= '1';
                    if (end_counter = '1') then
                        next_state <= idle_state_off; --prochain etat
                    else
                        next_state <= current_state;
                    end if;
           
       
            end case;
              
          
        end process;
		
		

end behavioral;