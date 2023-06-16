----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: count_y
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Component calculating y coordinates
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


entity count_y is
    generic(
        V_PIX          : integer := 480;                     -- Taille de l'image verticale
        V_FPORCH       : integer := 10;                      -- Front porch vertical
        VSYNC_SIZE     : integer := 2;                       -- Vertical sync pulse
        V_BPORCH       : integer := 33                       -- Back porch vertical
    );
    port ( 
        clk_25         : in std_logic;                       -- Horloge
        reset          : in std_logic;                       -- Entrée pour RESET des registres
        end_count_x    : in std_logic;                       -- Sortie indiquant que x a atteint la valeur de 799
        y              : out std_logic_vector(9 downto 0);   -- Valeur de y
        end_count_y    : out std_logic                       -- Sortie indiquant que x a atteint la valeur de 525
     );
end count_y;

architecture behavioral of count_y is
	
    ----------------------------------------------
    -- SIGNAUX INTERNES MODULE "Counter y"
    ----------------------------------------------
    constant count_max_y : natural              := V_PIX + V_FPORCH + VSYNC_SIZE + V_BPORCH;  -- Nombre maximal de pixels sur une colonne
    signal cnt_y : std_logic_vector(9 downto 0) := (others => '0');                           -- Valeur de y
    signal cmd : std_logic                      := '0';                                       -- Signal de commande du mux pour remise a zero
	
	
	begin

        ----------------------
        -- PARTIE SEQUENTIELLE	
        ----------------------
        process(clk_25, reset)
        begin
            if reset = '1' then
                cnt_y <= (others => '0');   -- Réinitialisation du compteur
 
            elsif rising_edge(clk_25) then
			    
                -- Gestion du compteur de cycle
                if cmd = '1' then
                    cnt_y <= (others => '0');   -- Réinitialisation du compteur
                elsif end_count_x = '1' then
                    cnt_y <= cnt_y + 1;
                end if;
			    
            end if;
        end process;


        ----------------------
        -- PARTIE COMBINATOIRE
        ----------------------
        -- Signal de fin de comptage du y
        cmd <= '1' when (cnt_y = (count_max_y - 1) AND end_count_x = '1')
            else '0';
		
        end_count_y <= cmd;
        y <= cnt_y;

		
end behavioral;