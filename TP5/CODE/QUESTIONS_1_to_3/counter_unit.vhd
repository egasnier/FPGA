library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity counter_unit is
    generic( count_max : natural := 2000 );  -- Valeur du nombre de périodes à compter
    port ( 
		clk			   : in std_logic;    -- Horloge
		resetn         : in std_logic;    -- Entrée pour RESET des registres
        end_counter	   : out std_logic    -- Sortie indiquant la fin du comptage
     );
end counter_unit;

architecture behavioral of counter_unit is
	
    --------------------
    -- SIGNAUX INTERNES 
    --------------------
	signal Q_out_cnt   : natural range 0 to count_max; -- Signal en sortie du registre du compteur
	signal cmd_cnt     : std_logic := '0';             -- Recopie du signal end_counter pour utilisation dans partie sequentielle
	
	
	begin

        ----------------------
		-- PARTIE SEQUENTIELLE	
        ----------------------
		process(clk,resetn)
		begin
			if(resetn = '1') then
			    Q_out_cnt <= 0;

			elsif rising_edge(clk) then
			    if (cmd_cnt = '1') then
			         Q_out_cnt <= 0;
			    else
			         Q_out_cnt <= Q_out_cnt + 1;
			    end if;
			end if;
		end process;


		----------------------
		-- PARTIE COMBINATOIRE
        ----------------------
		cmd_cnt <= '1' when (Q_out_cnt = (count_max - 1))
				else '0';
		end_counter <= cmd_cnt;             -- Copie du signal end_counter
		
end behavioral;