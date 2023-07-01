----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: count_unit
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Component used to display a chessboard on a screen in VGA format 
--              Calculation of RGB signals only
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


entity Gen_mir is
    generic (
        square_width    : integer := 40   -- taille du carré en pixels
    );
    port (
        in_display     : in std_logic;                                           -- Signal indiquant si l'images sont dans la zone d'affichage
        x              : in std_logic_vector(9 downto 0);                        -- Coordonnée X du pixel
        y              : in std_logic_vector(9 downto 0);                        -- Coordonnée y du pixel
        Out_pix_R      : out std_logic_vector(3 downto 0);                       -- Composante rouge du pixel
        Out_pix_B      : out std_logic_vector(3 downto 0);                       -- Composante bleue du pixel
        Out_pix_G      : out std_logic_vector(3 downto 0)                        -- Composante verte du pixel
    );
end Gen_mir;

architecture Behavioral of Gen_mir is

    ----------------------------------------------
    -- SIGNAUX INTERNES
    ----------------------------------------------
    signal inSquare  : integer;                       -- Signal indiquant si le pixel est à l'intérieur du carré blanc
    signal inS_White : std_logic_vector(0 downto 0);  -- Signal indiquant si le pixel est à l'intérieur du carré blanc
    signal x_0       : integer;
    signal x_mod     : integer;
    signal y_0       : integer;
    signal y_mod     : integer;
	
	 
    begin
        x_0 <= to_integer(unsigned(x));
        y_0 <= to_integer(unsigned(y));

        -- Calcul de inSquare pour déterminer si le pixel est à l'intérieur d'un carré de l'échiquier
 
        x_mod <= (x_0 / (square_width));
        y_mod <= (y_0 /(square_width));
     
        -- calcul carrée 
        inSquare <= ((x_mod)+ (y_mod)) mod 2;

        inS_White  <= std_logic_vector(to_unsigned(inSquare,1)); 


        -- chessboard patern generation 

        -- Processus de mise à jour des signaux de sortie en fonction de in_display  et inSquare
        process (in_display, inS_white)
        begin
            -- Si les coordonnées sont dans la zone d'affichage
            -- Mise à jour des composantes rouge, verte et bleue du pixel
            if (in_display  = '1') and (inS_White= "1") then
                Out_pix_R <= "1111" ;
                Out_pix_B <= "1111";
                Out_pix_G <= "1111";
            else
                Out_pix_R <= "0000";
                Out_pix_B <= "0000";
                Out_pix_G <= "0000";
            end if;

    end process;
    
end Behavioral;
