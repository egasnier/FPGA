----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 23.06.2023
-- Module Name: topVGA_filtre
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: 2D convolution with kernel 3x3
-- Output 1: Id matrix
-- Output 2: Gaussian filtering
-- Output 3: Sobel horizontal
-- Output 4: Sobel vertical
-- Output 5: Edge detection
-- 
-- Dependencies: Pmod VGA (digilent)
-- 
-- Revision:
-- Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity topVGA_filtre is
   
    port ( 
        clk            : in std_logic;
        reset          : in std_logic;
        hsync_shifted  : out std_logic;                        -- Synchronization horizontale
        vsync_shifted  : out std_logic; 
        out_filt_R     : out std_logic_vector(3 downto 0);
        out_filt_B     : out std_logic_vector(3 downto 0);
        out_filt_G     : out std_logic_vector(3 downto 0)
    );
end topVGA_filtre;


architecture Behavioral of topVGA_filtre is

        ------------------------------------------
        -- DECLARATION DES CONSTANTES
        ------------------------------------------
        constant H_PIX       : integer := 640;
        constant H_FPORCH    : integer := 16;
        constant HSYNC_SIZE  : integer := 96;
        constant H_BPORCH    : integer := 48;
    
        constant V_PIX       : integer := 480;
        constant V_FPORCH    : integer := 10;
        constant VSYNC_SIZE  : integer := 2;
        constant V_BPORCH    : integer := 33;

        ------------------------------------------------------------
        -- SIGNAUX INTERNES 
        ---------------------------------------------------------------------------
        signal clk_25   : std_logic := '0';    -- signal de sortie de la PLL pour Vga-sync
        signal s_locked : std_logic := '0';    -- Signal  s_locked le resten de vga_sync
        signal lockedn  : std_logic := '0';    -- Signal  s_locked le resten de vga_sync 
                         

        ------------------------------------------------------------------------------
        -- SIGNAUX INTERNES topVGA_filtre
        ---------------------------------------------------------------------------
                              
        signal hsync          : std_logic;                                -- Synchronization horizontale
        signal vsync          : std_logic;                                -- Synchronization verticale
                    
        signal in_display     : std_logic :='0';
        signal end_count_X    : std_logic;                                -- Signal indiquant si l'images sont dans la zone d'affichage
        signal x              : std_logic_vector(9 downto 0);             -- Coordonnée X du pixel
        signal y              : std_logic_vector(9 downto 0);             -- Coordonnée y du pixel
        signal Out_pix_R      : std_logic_vector(3 downto 0);             -- Composante rouge du pixel
        signal Out_pix_B      : std_logic_vector(3 downto 0);             -- Composante bleue du pixel
        signal Out_pix_G      : std_logic_vector(3 downto 0); 
        signal data_read      : std_logic_vector(3 downto 0):= "0000";
        signal cmd_conv       : std_logic := '0';

         
 
        ------------------------------------------
        -- DECLARATION DU COMPOSANT PLL
        ------------------------------------------
        component PLL
        port ( 
            clk			       : in std_logic;     -- horloge à 125MHZ
            reset		       : in std_logic;     -- bouton de reset
            clk_25             : out std_logic;    -- horloge à 25.175MHZ
            locked  	       : out std_logic     -- bouton de reset
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
            clk_25		   : in std_logic;                      -- Horloge
            reset          : in std_logic;                      -- Entrée pour RESET des registres
            hsync   	   : out std_logic;                     -- Synchronization horizontale
            vsync   	   : out std_logic;    
            end_count_x   : out std_logic;                      -- Synchronization verticale
            x              : out std_logic_vector(9 downto 0);
            y               : out std_logic_vector(9 downto 0);
            in_display 	   : out std_logic                      -- A 1 si le pixel est dans l'image
        );
        end component;


 
        ------------------------------------------
        -- DECLARATION DU COMPOSANT Gen_mir
        ------------------------------------------
        component Gen_mir
        generic (
            square_width    : integer            -- taille du carré en pixels
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



        ------------------------------------------------
        -- DECLARATION DU COMPOSANT system_conv
        --------------------------------------------------
        component System_conv
        generic(
              filter_sel : std_logic_vector(2 downto 0)
               );
        port ( 
            clk, reset        : in std_logic;
            cmd_conv          : in std_logic;
            data_read         : in std_logic_vector(3 downto 0);
            x                 : in std_logic_vector(9 downto 0);
            out_filt_R        : out std_logic_vector(3 downto 0);
            out_filt_B        : out std_logic_vector(3 downto 0);
            out_filt_G        : out std_logic_vector(3 downto 0)
        );
        end component;


        ------------------------------------------------
        -- DECLARATION DU COMPOSANT shift_sync
        --------------------------------------------------   
        component shift_sync        
        port ( 
            clk            : in std_logic;            -- Horloge
            reset          : in std_logic;            -- Entrée pour RESET des registres
            x              : in std_logic_vector(9 downto 0);  -- Coordonnée X du pixel
            y              : in std_logic_vector(9 downto 0);  -- Coordonnée y du pixel
            end_count_x    : in std_logic;            -- Fin de lecture d'une ligne
            cmd_conv       : out std_logic;           -- Signal de commande du module convolution
            hsync_shifted  : out std_logic;           -- Synchronization horizontale retardée de 802 pixels
            vsync_shifted  : out std_logic            -- Synchronization verticale retardée de 802 pixels
        );
        end component;



    begin

    -----------------------------------------------------------------------------	
    -- AFFECTATION DES SIGNAUX
    ------------------------------------------------------------------------------	
    --Affectation des signaux du module PLL
    mapping_PLL : PLL
        port map (
            clk=> clk,
            reset => reset,
            clk_25 => clk_25,          
            locked => s_locked
        );               	

    -- Process du locked et le resetn du VGA_sync
    lockedn <= not(s_locked);
   
    --Affectation des signaux du module Vga_sync
    mapping_VGA_sync : VGA_sync
	generic map (
        H_PIX      => H_PIX,
        H_FPORCH   => H_FPORCH, 
        HSYNC_SIZE => HSYNC_SIZE,
        H_BPORCH   => H_BPORCH,
        V_PIX      => V_PIX,
        V_FPORCH   => V_FPORCH,
        VSYNC_SIZE => VSYNC_SIZE,
        V_BPORCH   => V_BPORCH
    )
    port map (
        clk_25	=> clk_25,  
        reset   => lockedn ,   
        hsync   => hsync , 
        vsync   => vsync ,   
        x       => x,
        y       => y, 
        end_count_x => end_count_x,              
        in_display  => in_display   
    );
	

    --Affectation des signaux du module Gen_mir
    mapping_Gen_mir : Gen_mir
    generic map (
        square_width => 40     -- taille du carré en pixels
    )
    port map (
        in_display => in_display,
        x => x,          
        y => y,          
        Out_pix_R  => Out_pix_R,
        Out_pix_B =>  Out_pix_B, 
        Out_pix_G =>  Out_pix_G  
    );
   

    -- Affectation des signaux du testbench avec ceux de l'entite System_conv
    Systeme: System_conv
    generic map (
        filter_sel   => "001"
    )
    port map (
        clk           => clk_25,
        reset         => lockedn,
        cmd_conv      => cmd_conv,
        data_read     => Out_pix_R,
        x             => x,
        out_filt_R    => out_filt_R,
        out_filt_B    => out_filt_B,
        out_filt_G    => out_filt_G          
    );
 
			 
 
    --Affectation des signaux du testbench avec ceux de l'entite shift_sync
    Shift: shift_sync
    port map (
        clk           => clk_25, 
        reset         => lockedn,
        x             => x, 
        y             => y,  
        end_count_x   => end_count_x,
        cmd_conv      => cmd_conv,
        hsync_shifted => hsync_shifted, 
        vsync_shifted => vsync_shifted
    );
      
   
end Behavioral;
