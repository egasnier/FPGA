----------------------------------------------------------------------------------
-- Engineer: Eric GASNIER
-- 
-- Create Date: 29.06.2023
-- Module Name: draw
-- Project Name: Moving sprite
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Draw sprite color or background color depending on coordinates
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
use ieee.numeric_std.all;


entity draw is
    generic(
        HALF_SPRITE_SIZE     : std_logic_vector(9 downto 0) := "0000010100"  -- 20
    );
    port ( 
        x              : in std_logic_vector(9 downto 0);
        y              : in std_logic_vector(9 downto 0);
        x_sprite       : in std_logic_vector(9 downto 0);
        y_sprite       : in std_logic_vector(9 downto 0);
        in_display     : std_logic;
        out_pix        : out std_logic_vector(3 downto 0)
     );
end draw;

architecture behavioral of draw is
	
    ----------------------------------------------
    -- SIGNAUX INTERNES
    ----------------------------------------------
    -- Gestion des coordonnees
    signal is_in_x_range, is_in_y_range, in_sprite : std_logic;
	
	
	begin

        ----------------------
        -- PARTIE COMBINATOIRE
        ----------------------
        -- Traitement des x
        is_in_x_range <= '1' when (x <= x_sprite + HALF_SPRITE_SIZE) AND (x >= x_sprite - HALF_SPRITE_SIZE)
            else '0';
		  
        -- Traitement des y
        is_in_y_range <= '1' when (y <= y_sprite + HALF_SPRITE_SIZE) AND (y >= y_sprite - HALF_SPRITE_SIZE)
            else '0';

        -- Test si dans les coordonnées (x,y) sont dans le sprite
        in_sprite <= '1' when (is_in_x_range = '1') AND (is_in_y_range = '1')
            else '0';

        -- Affichage des pixels
        out_pix <= "0100" when (in_display = '1') AND NOT(in_sprite = '1')
            else "1111" when (in_display = '1') AND (in_sprite = '1')
            else "0000";
        
end behavioral;