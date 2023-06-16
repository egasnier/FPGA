----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.06.2023 17:44:48
-- Design Name: 
-- Module Name: top_Gen - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;



entity top_VGA is
    port (
        clk            : in std_logic;
        reset          : in std_logic;
        hsync          : out std_logic;
        vsync          : out std_logic;
        Out_pix_R      : out std_logic_vector(3 downto 0);                       -- Composante rouge du pixel
        Out_pix_B      : out std_logic_vector(3 downto 0);                       -- Composante bleue du pixel
        Out_pix_G      : out std_logic_vector(3 downto 0)                        -- Composante verte du pixel
    );
end top_VGA;

architecture Behavioral of top_VGA is

    ------------------------------------------------------------
    -- SIGNAUX INTERNES
    ------------------------------------------------------------
                             
    signal clk_25          : std_logic := '0';        -- signal de sortie de la PLL pour Vga-sync
    signal s_locked        : std_logic := '0';        -- Signal  s_locked le resten de vga_sync
    signal lockedn         : std_logic := '0';        -- Signal  not(s_locked) qui correspond au reset de VGA_sync 
               
                    
    ------------------------------------------------------------
    -- SIGNAUX INTERNES Gen_mir
    ------------------------------------------------------------
                             
    signal  in_display     :  std_logic :='0';                                     -- Signal indiquant si l'images sont dans la zone d'affichage
    signal  x              :  std_logic_vector(9 downto 0);                        -- Coordonn�e X du pixel
    signal  y              :  std_logic_vector(9 downto 0);                        -- Coordonn�e y du pixel
                                   
 
    ------------------------------------------
    -- DECLARATION DU COMPOSANT PLL
    ------------------------------------------
    component PLL
        port ( 
            clk            : in std_logic;     -- horloge � 125MHZ
            reset          : in std_logic;     -- bouton de reset
            clk_25       : out std_logic;    -- horloge � 25.175MHZ
            locked         : out std_logic     -- bouton de reset
        );
    end component;	


    ------------------------------------------
    -- DECLARATION DU COMPOSANT VGA_sync
    ------------------------------------------
    component VGA_sync
        port ( 
            clk_25         : in std_logic;                         -- Horloge
            reset          : in std_logic;                         -- Entr�e pour RESET des registres
            hsync   	   : out std_logic;                        -- Synchronization horizontale
            vsync   	   : out std_logic;                        -- Synchronization verticale
            x              : out std_logic_vector(9 downto 0);
            y              : out std_logic_vector(9 downto 0);
            in_display 	   : out std_logic                         -- A 1 si le pixel est dans l'image
        );
    end component;


 
    ------------------------------------------
    -- DECLARATION DU COMPOSANT Gen_mir
    ------------------------------------------
    component Gen_mir
        generic (
            square_width   : integer := 40   -- taille du carr� en pixels
        );
        port (
            in_display     : in std_logic;                                           -- Signal indiquant si l'images sont dans la zone d'affichage
            x              : in std_logic_vector(9 downto 0);                        -- Coordonn�e X du pixel
            y              : in std_logic_vector(9 downto 0);                        -- Coordonn�e y du pixel
            Out_pix_R      : out std_logic_vector(3 downto 0);                       -- Composante rouge du pixel
            Out_pix_B      : out std_logic_vector(3 downto 0);                       -- Composante bleue du pixel
            Out_pix_G      : out std_logic_vector(3 downto 0)                        -- Composante verte du pixel
        );
    end component;
        
 
    begin

    -----------------------------------------------------------------------------	
    -- AFFECTATION DES SIGNAUX
    ------------------------------------------------------------------------------	
	--Affectation des signaux du module PLL
	mapping_PLL : PLL
    port map (
        clk          => clk,
        reset        => reset,
        clk_25       => clk_25,          
        locked       => s_locked
    );               	

    --Affectation des signaux du module Vga_sync
    mapping_VGA_sync : VGA_sync
    port map (
        clk_25	     =>	clk_25,  
        reset        => lockedn ,   
        hsync        =>	hsync , 
        vsync        =>	vsync ,   
        x            => x,
        y            => y,                  
        in_display   => in_display   
    );
	
    --Affectation des signaux du module Gen_mir
    mapping_Gen_mir : Gen_mir
    generic map (
        square_width => 40   -- taille du carr� en pixels
    )
    port map (
        in_display   => in_display,
        x            => x ,          
        y            => y ,          
        Out_pix_R    => Out_pix_R,
        Out_pix_B    => Out_pix_B, 
        Out_pix_G    => Out_pix_G  
    );
	  
	  
	  
    -- Process du locked et le resetn du VGA_sync
    lockedn <= not(s_locked);
   
   
end Behavioral;
