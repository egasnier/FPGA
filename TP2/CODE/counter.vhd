library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity counter_unit is
    port ( 
        clk            : in std_logic;    -- Horloge
        btn_restart    : in std_logic;    -- Entrée pour remise à zéro du compteur
        resetn         : in std_logic;    -- Entrée pour RESET des registres
        end_counter    : out std_logic;   -- Sortie indiquant la fin du comptage
        out_LED        : out std_logic    -- Sortie LED allumée ou éteinte
    );
end counter_unit;

architecture behavioral of counter_unit is
	
    --Declaration des signaux internes
    constant count_max : natural := 200000000; -- Nombre de periodes correspondant a 2 secondes *** A REMPLACER PAR 2E8 ***
    signal Q_out_cnt   : natural range 0 to count_max; -- Signal en sortie du registre du compteur
    signal cmd_cnt     : std_logic := '0';    -- Recopie du signal end_counter pour utilisation dans partie sequentielle
    signal cmd_LED     : std_logic := '0';    -- Recopie du signal end_counter pour utilisation dans partie sequentielle
    signal Q_out_LED   : std_logic := '0';    -- Signal en sortie du registre de la LED (sortie LED)
	
	
	begin

		--Partie sequentielle
		process(clk,resetn)
		begin
			if(resetn = '1') then 
			    Q_out_cnt <= 0;
			    Q_out_led <= '0';
			elsif(rising_edge(clk)) then
			    if (cmd_cnt = '1') then
			         Q_out_cnt <= 0;
			    else
			         Q_out_cnt <= Q_out_cnt + 1;
			    end if;
			    if (cmd_LED = '1') then
			         Q_out_LED <= NOT(Q_out_LED);
			    end if;
			end if;
		end process;
		
		--Partie combinatoire
		cmd_LED <= '1' when (Q_out_cnt = (count_max-1))
				else '0';
		cmd_cnt <= '1' when ((Q_out_cnt = (count_max-1)) OR (btn_restart = '1'))
				else '0';
		end_counter <= cmd_LED;             -- Copie du signal end_counter
		out_LED <= Q_out_led;
		
end behavioral;