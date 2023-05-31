library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
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

    type state_LED is (idle_state_off, state_on);   -- Définition des états du FSM
    
    signal current_state : state_LED;  --etat dans lequel on se trouve actuellement
    signal next_state : state_LED;	   --etat dans lequel on passera au prochain coup d'horloge
  
    signal Qout_cycle      : std_logic_vector (2 downto 0) := (others => '0');         -- Signal en sortie du registre du compteur de cycle
    signal Qout_cycle_dec  : std_logic_vector (2 downto 0) := (others => '0');         -- Signal en sortie du registre du compteur de cycle + 1
    signal count_cycle : std_logic_vector (1 downto 0) := (others => '0');             -- Compteur de cycle
    signal cmd_restart : std_logic := '0';           -- Commande du multiplexeur de restart
      
    signal end_counter  : std_logic := '0';   -- etat de la LED (allumee ou eteinte)
    signal cmd_state_LED : std_logic := '0';  -- commande l'état de la LED (allumee ou eteinte)
    signal cmd_color_LED : std_logic_vector (1 downto 0) := "00";   -- commande la couleur de la LED (si '00', aucune selectionnee)
    -- ('01' => Rouge, '10' => verte, '11' => Bleue)
    
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
	
	--Affectation des signaux du compteur de cycle avec ceux de counter_unit
	uut: counter_unit
	    generic map(
	       count_max => 100000000   -- 1 seconde
	    )
        port map (
           clk => clk,
           resetn => resetn,
           end_counter => end_counter
        );
	

		-- PARTIE SEQUENTIELLE	
		process(clk, resetn)
		begin
            if resetn = '1' then
                current_state <= idle_state_off;  -- Retour de la FSM à l'état initial
                
                Qout_cycle <= (others => '0');   -- Réinitialisation du compteur
                cmd_color_LED <= "00";             -- LED s eteinte
 
			elsif rising_edge(clk) then
			    current_state <= next_state;     -- Passage à l'état suivant
			    
			    -- Gestion du compteur de cycle
			    if cmd_restart = '1' then
                    Qout_cycle <= (others => '0');   -- Réinitialisation du compteur
			    elsif end_counter = '1' then
			         Qout_cycle <= Qout_cycle + 1;
			    end if;
			    
			    -- Update de la couleur si le signal update est a 1 sinon on conserve l'ancienne couleur
			    if update = '1' then
			         cmd_color_LED <= color_code;
		        end if;
            end if;
		end process;
		
		-- PARTIE COMBINATOIRE
		-- Comptage de cycles
		Qout_cycle_dec <= Qout_cycle + 1;
		-- Suppression du LSB
		count_cycle <= Qout_cycle_dec(2 downto 1);
		cmd_restart <= '1' when (count_cycle = count_max_cycle AND end_counter = '1')
				else '0';
		end_cycle <= cmd_restart;


		-- Clignotement des LEDs
		out_LED_R <= cmd_state_LED when cmd_color_LED = "01"
		      else '0';
		out_LED_G <= cmd_state_LED when cmd_color_LED = "10"
		      else '0';
		out_LED_B <= cmd_state_LED when cmd_color_LED = "11"
		      else '0';

		
		-- FSM
		process(current_state, end_counter)
		begin
		   --signaux pilotes par la fsm
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