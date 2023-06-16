----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: count_unit
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Component used to display a chessboard on a screen in VGA format
--              Calculation of RGB signals only + Synchronization signals
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



entity top_VGA is
    generic (
        H_PIX          : integer := 640;                     -- Taille de l'image horizontale
        H_FPORCH       : integer := 16;                      -- Front porch horizontal
        HSYNC_SIZE     : integer := 96;                      -- Horizontal sync pulse
        H_BPORCH       : integer := 48;                      -- Back porch horizontal
        V_PIX          : integer := 480;                     -- Taille de l'image verticale
        V_FPORCH       : integer := 10;                      -- Front porch vertical
        VSYNC_SIZE     : integer := 2;                       -- Vertical sync pulse
        V_BPORCH       : integer := 33                       -- Back porch vertical
    );
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
    signal  x              :  std_logic_vector(9 downto 0);                        -- Coordonnée X du pixel
    signal  y              :  std_logic_vector(9 downto 0);                        -- Coordonnée y du pixel
                                   
 
    ------------------------------------------
    -- DECLARATION DU COMPOSANT PLL
    ------------------------------------------
    component PLL
        port ( 
            clk            : in std_logic;     -- horloge à 125MHZ
            reset          : in std_logic;     -- bouton de reset
            clk_25         : out std_logic;    -- horloge à 25.175MHZ
            locked         : out std_logic     -- bouton de reset
        );
    end component;	


    ------------------------------------------
    -- DECLARATION DU COMPOSANT VGA_sync
    ------------------------------------------
    component VGA_sync
        generic (
            H_PIX       : integer;
            H_FPORCH    : integer;
            HSYNC_SIZE  : integer;
            H_BPORCH    : integer;
            V_PIX       : integer;
            V_FPORCH    : integer;
            VSYNC_SIZE  : integer;
            V_BPORCH    : integer
        );
        port ( 
            clk_25         : in std_logic;                         -- Horloge
            reset          : in std_logic;                         -- Entrée pour RESET des registres
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
            square_width   : integer := 40   -- taille du carré en pixels
        );
        port (
            in_display     : in std_logic;                                           -- Signal indiquant si l'images sont dans la zone d'affichage
            x              : in std_logic_vector(9 downto 0);                        -- Coordonnée X du pixel
            y              : in std_logic_vector(9 downto 0);                        -- Coordonnée y du pixel
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
    generic map (
        H_PIX        => H_PIX,
        H_FPORCH     => H_FPORCH, 
        HSYNC_SIZE   => HSYNC_SIZE,
        H_BPORCH     => H_BPORCH,
        V_PIX        => V_PIX,
        V_FPORCH     => V_FPORCH,
        VSYNC_SIZE   => VSYNC_SIZE,
        V_BPORCH     => V_BPORCH
    )
    port map (
        clk_25       =>	clk_25,  
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
        square_width => 40   -- taille du carré en pixels
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
