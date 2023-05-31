library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity tp_fsm is
    generic( count_max_cycle : natural := 3 );  -- Valeur du nombre de cycle à compter
    port ( 
		clk			      : in std_logic; 
        resetn		      : in std_logic;
        btn_restart       : in std_logic;
		end_counter_cycle : out std_logic;
	    out_LED_R         : out std_logic;
	    out_LED_B         : out std_logic;
	    out_LED_G         : out std_logic       
     );
end tp_fsm;


architecture behavioral of tp_fsm is

    type state is (idle, state_R, state_B, state_G);   -- Définition des états du FSM
    
    signal current_state : state;  --etat dans lequel on se trouve actuellement
    signal next_state : state;	   --etat dans lequel on passera au prochain coup d'horloge
    
    signal Qout_LED  : std_logic := '0'; -- etat de la LED (allumee ou eteinte)

    signal Qout_cycle      : std_logic_vector (2 downto 0) := (others => '0');         -- Signal en sortie du registre du compteur de cycle
    signal Qout_cycle_dec  : std_logic_vector (2 downto 0) := (others => '0');         -- Signal en sortie du registre du compteur de cycle + 1
    signal count_cycle : std_logic_vector (1 downto 0) := (others => '0');             -- Compteur de cycle
    signal cmd_cnt     : std_logic := '0';           -- Commande du multiplexeur de comptage
    signal cmd_restart : std_logic := '0';           -- Commande du multiplexeur de restart
    signal cmd_state_R : std_logic := '0';           -- Commande de pilotage de la LED Rouge
    signal cmd_state_B : std_logic := '0';           -- Commande de pilotage de la LED Bleue
    signal cmd_state_G : std_logic := '0';           -- Commande de pilotage de la LED Verte
    
    
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
	       count_max => 100000000
	    )
        port map (
           clk => clk,
           resetn => resetn,
           end_counter => cmd_cnt
        );
	

		-- PARTIE SEQUENTIELLE	
		process(clk, resetn)
		begin
            if(resetn = '1') then
                current_state <= idle;           -- Retour de la FSM à l'état initial
                
                Qout_cycle <= (others => '0');   -- Réinitialisation du compteur
                Qout_LED <= '0';                 -- Initialisation de l'ete de la LED
 
			elsif(rising_edge(clk)) then
			    current_state <= next_state;     -- Passage à l'état suivant
			    
			    if ((btn_restart = '1') OR (cmd_restart = '1')) then
                    Qout_cycle <= (others => '0');   -- Réinitialisation du compteur
                    Qout_LED <= '0';                 -- Initialisation de l'ete de la LED
			    elsif (cmd_cnt = '1') then
			         Qout_cycle <= Qout_cycle + 1;
			         Qout_LED <= NOT(Qout_LED);
			    end if;
			    
				
            end if;
		end process;
		
		-- PARTIE COMBINATOIRE
		-- Comptage de cycles
		Qout_cycle_dec <= Qout_cycle + 1;
		-- 
		count_cycle <= Qout_cycle_dec(2 downto 1);
		cmd_restart <= '1' when (count_cycle = count_max_cycle AND cmd_cnt = '1')
				else '0';
		end_counter_cycle <= cmd_restart;
		
		-- Clignotement des LEDs
		out_LED_R <= Qout_LED when cmd_state_R = '1'
		      else '0';

		out_LED_B <= Qout_LED when cmd_state_B = '1'
		      else '0';

		out_LED_G <= Qout_LED when cmd_state_G = '1'
		      else '0';
		
		-- FSM
		-- Fonctionnement:
		-- Si on appuie sur le bouton_restart, on revient à l'etat initial
		-- sinon si le signal cmd_restart est a 1 (fin de compatge de cycle), alors on passe a l'etat suivant
		-- sinon on ne change pas d'etat
		process(current_state, cmd_restart, btn_restart)
		begin
		   -- Etat initial
           case current_state is
              when idle =>
                -- Signaux de commandes des 3 LEDs
                cmd_state_R <= '1';
                cmd_state_B <= '1';
                cmd_state_G <= '1';
                if (btn_restart = '1') then
                    next_state <= idle;
                elsif (cmd_restart = '1') then
                    next_state <= state_R; --prochain etat
                else
                    next_state <= current_state;
                end if;
              
             -- LED rouge
              when state_R =>
                -- Signaux de commandes des 3 LEDs
                cmd_state_R <= '1';
                cmd_state_B <= '0';
                cmd_state_G <= '0';
                if (btn_restart = '1') then
                    next_state <= idle;
                elsif (cmd_restart = '1') then
				    next_state <= state_B;
                else
                    next_state <= current_state;
                end if;
				
             -- LED bleue              
              when state_B =>
                -- Signaux de commandes des 3 LEDs
                cmd_state_R <= '0';
                cmd_state_B <= '1';
                cmd_state_G <= '0';
                if (btn_restart = '1') then
                    next_state <= idle;
                elsif (cmd_restart = '1') then
				    next_state <= state_G;
                else
                    next_state <= current_state;
                end if;
				
             -- LED verte              
              when state_G =>
                -- Signaux de commandes des 3 LEDs
                cmd_state_R <= '0';
                cmd_state_B <= '0';
                cmd_state_G <= '1';
                if (btn_restart = '1') then
                    next_state <= idle;
                elsif (cmd_restart = '1') then
				    next_state <= state_R;
                else
                    next_state <= current_state;
                end if;
				
              
              end case;
              
          
		end process;
		
		
		

end behavioral;