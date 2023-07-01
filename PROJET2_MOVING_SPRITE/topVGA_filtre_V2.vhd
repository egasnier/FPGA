----------------------------------------------------------------------------------
-- Engineer: Eric GASNIER
-- 
-- Create Date: 29.06.2023
-- Module Name: topVGA_filtre_V2
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Sprite moving on the screen
-- 2D convolution with kernel 3x3 
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


entity topVGA_filtre_V2 is
   
    port ( 
        clk            : in std_logic;
        reset          : in std_logic;
        hsync_shifted  : out std_logic;                        -- Synchronization horizontale
        vsync_shifted  : out std_logic; 
        out_filt_R     : out std_logic_vector(3 downto 0);
        out_filt_B     : out std_logic_vector(3 downto 0);
        out_filt_G     : out std_logic_vector(3 downto 0)
    );
end topVGA_filtre_V2;


architecture Behavioral of topVGA_filtre_V2 is

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
        
        constant FRAME_SIZE      : integer := 1;
        constant X_MIN           : std_logic_vector(9 downto 0) := "0000000000"; -- 0
        constant X_MAX           : std_logic_vector(9 downto 0) := "1001111111"; -- 639
        constant Y_MIN           : std_logic_vector(9 downto 0) := "0000000000"; -- 0
        constant Y_MAX           : std_logic_vector(9 downto 0) := "0111011111"; -- 479
        constant X_INIT          : std_logic_vector(9 downto 0) := "0101000000"; -- 320 
        constant Y_INIT          : std_logic_vector(9 downto 0) := "0011110000"; -- 240
        constant HALF_SPRITE_SIZE : std_logic_vector(9 downto 0) := "0000010100"; -- 20

        constant FILTER_SEL      : std_logic_vector(2 downto 0) := "000";        -- Matrice Id
        

        ------------------------------------------------------------
        -- SIGNAUX INTERNES 
        ---------------------------------------------------------------------------
        signal clk_25   : std_logic := '0';    -- signal de sortie de la PLL pour Vga-sync
        signal s_locked : std_logic := '0';    -- Signal  s_locked le resten de vga_sync
        signal lockedn  : std_logic := '0';    -- Signal  s_locked le resten de vga_sync 
                         

        ------------------------------------------------------------------------------
        -- SIGNAUX INTERNES topVGA_filtre
        ---------------------------------------------------------------------------
                              
        signal hsync          : std_logic;
        signal vsync          : std_logic;
                    
        signal in_display     : std_logic :='0';
        signal end_count_x    : std_logic;
        signal end_count_y    : std_logic;
        signal x              : std_logic_vector(9 downto 0);
        signal y              : std_logic_vector(9 downto 0);
        signal Out_pix        : std_logic_vector(3 downto 0);
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
            clk_25		   : in std_logic;
            reset          : in std_logic;
            hsync   	   : out std_logic;
            vsync   	   : out std_logic;
            end_count_x    : out std_logic;
            end_count_y    : out std_logic;
            x              : out std_logic_vector(9 downto 0);
            y              : out std_logic_vector(9 downto 0);
            in_display 	   : out std_logic
        );
        end component;


 
        ------------------------------------------
        -- DECLARATION DU COMPOSANT gen_IMG
        ------------------------------------------
        component gen_IMG
        generic (
            FRAME_SIZE      : integer;
            X_MIN           : std_logic_vector(9 downto 0);
            X_MAX           : std_logic_vector(9 downto 0);
            Y_MIN           : std_logic_vector(9 downto 0);
            Y_MAX           : std_logic_vector(9 downto 0);
            X_INIT          : std_logic_vector(9 downto 0); 
            Y_INIT          : std_logic_vector(9 downto 0);
            HALF_SPRITE_SIZE : std_logic_vector(9 downto 0)
        );
        port (
            clk             : in std_logic;
            reset           : in std_logic;
            end_count_y     : in std_logic;
            in_display      : in std_logic;
            x               : in std_logic_vector(9 downto 0);
            y               : in std_logic_vector(9 downto 0);
            out_pix         : out std_logic_vector(3 downto 0)
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
            clk    => clk,
            reset  => reset,
            clk_25 => clk_25,          
            locked => s_locked
        );               	

    -- Process du locked et le resetn du VGA_sync
    lockedn <= not(s_locked);
   
    --Affectation des signaux du module Vga_sync
    mapping_VGA_sync : VGA_sync
	generic map (
        H_PIX       => H_PIX,
        H_FPORCH    => H_FPORCH, 
        HSYNC_SIZE  => HSYNC_SIZE,
        H_BPORCH    => H_BPORCH,
        V_PIX       => V_PIX,
        V_FPORCH    => V_FPORCH,
        VSYNC_SIZE  => VSYNC_SIZE,
        V_BPORCH    => V_BPORCH
    )
    port map (
        clk_25	    => clk_25,  
        reset       => lockedn ,   
        hsync       => hsync , 
        vsync       => vsync ,   
        x           => x,
        y           => y, 
        end_count_x => end_count_x,              
        end_count_y => end_count_y,              
        in_display  => in_display   
    );
	

    --Affectation des signaux du module gen_IMG
    mapping_gen_IMG : gen_IMG
    generic map (
        FRAME_SIZE      => FRAME_SIZE,
        X_MIN           => X_MIN,
        X_MAX           => X_MAX,
        Y_MIN           => Y_MIN,
        Y_MAX           => Y_MAX,
        X_INIT          => X_INIT, 
        Y_INIT          => Y_INIT,
        HALF_SPRITE_SIZE => HALF_SPRITE_SIZE
    )
    port map (
        clk             => clk_25,
        reset           => reset,
        end_count_y     => end_count_y,
        in_display      => in_display,
        x               => x,
        y               => y,
        out_pix         => out_pix
    );
   

    -- Affectation des signaux du testbench avec ceux de l'entite System_conv
    Systeme: System_conv
    generic map (
        FILTER_SEL    => FILTER_SEL
    )
    port map (
        clk           => clk_25,
        reset         => lockedn,
        cmd_conv      => cmd_conv,
        data_read     => out_pix,
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
