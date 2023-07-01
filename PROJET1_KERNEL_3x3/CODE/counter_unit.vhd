----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: count_unit
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Counter unit
-- 
-- Dependencies: Pmod VGA (digilent)
-- 
-- Revision:
-- Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity counter_unit is
    generic(
        count_max      : natural := 800;      -- Valeur du nombre de périodes à compter
        nb_bit         : integer := 10        -- Nombre de bits sur lequel est code le compteur
    );
    port ( 
        clk            : in std_logic;        -- Horloge
        reset          : in std_logic;        -- Entrée pour RESET des registres
        counter        : out std_logic_vector((nb_bit-1) downto 0);  -- Signal en sortie du registre du compteur
        end_counter    : out std_logic        -- Sortie indiquant la fin du comptage
    );
end counter_unit;

architecture behavioral of counter_unit is
	
    --------------------
    -- SIGNAUX INTERNES 
    --------------------
	signal Qout_cnt    : std_logic_vector((nb_bit-1) downto 0); -- Signal en sortie du registre du compteur
	signal cmd         : std_logic := '0';                      -- Recopie du signal end_counter pour utilisation dans partie sequentielle
	
	
	begin

        ----------------------
        -- PARTIE SEQUENTIELLE	
        ----------------------
        process(clk,reset)
        begin
            if(reset = '1') then
                Qout_cnt <= (others => '0');

            elsif rising_edge(clk) then
                if (cmd = '1') then
                    Qout_cnt <= (others => '0');
                else
                    Qout_cnt <= Qout_cnt + 1;
                end if;
            end if;
        end process;


        ----------------------
        -- PARTIE COMBINATOIRE
        ----------------------
        cmd <= '1' when (Qout_cnt = (count_max - 1))
            else '0';
        end_counter <= cmd;             -- Copie du signal end_counter
		
        counter <= Qout_cnt;
		
end behavioral;