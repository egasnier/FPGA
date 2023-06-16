----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: count_x
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Component calculating x coordinates
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


entity count_x is
    generic(
        H_PIX           : integer := 640;                     -- Taille de l'image horizontale
        H_FPORCH        : integer := 16;                      -- Front porch horizontal
        HSYNC_SIZE      : integer := 96;                      -- Horizontal sync pulse
        H_BPORCH        : integer := 48                       -- Back porch horizontal
    );
    port ( 
        clk_25          : in std_logic;                       -- Horloge
        reset           : in std_logic;                       -- Entrée pour RESET des registres
        x               : out std_logic_vector(9 downto 0);   -- Valeur de x
        end_count_x     : out std_logic                       -- Sortie indiquant que x a atteint la valeur de 799
     );
end count_x;

architecture behavioral of count_x is
	


    ------------------------------------------
	-- DECLARATION DU COMPOSANT counter_unit
    ------------------------------------------
	--Declaration de l'entite counter_unit (compteur générant le signal end_counter)
	component counter_unit
	    generic(
            count_max       : natural;
            nb_bit          : integer
	    );
        port ( 
            clk             : in std_logic;
            reset           : in std_logic;
            counter         : out std_logic_vector((nb_bit-1) downto 0);
            end_counter     : out std_logic
		);
	end component;



	begin

    --------------------------	
	-- AFFECTATION DES SIGNAUX
    --------------------------	
	--Affectation des signaux du compteur
	uut: counter_unit
        generic map(
            count_max   => (H_PIX + H_FPORCH + HSYNC_SIZE + H_BPORCH),   -- Nb de pixels par ligne
            nb_bit      => 10
        )
        port map (
            clk         => clk_25,
            reset       => reset,
            counter     => x,
            end_counter => end_count_x
        );
	
		
end behavioral;