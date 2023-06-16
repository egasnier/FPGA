----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: VGA_sync
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Component generating synchronization signals for VGA and coordinates (x, y)
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


entity VGA_sync is
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
        clk_25         : in std_logic;                       -- Horloge
        reset          : in std_logic;                       -- Entr�e pour RESET des registres
        hsync          : out std_logic;                      -- Synchronization horizontale
        vsync          : out std_logic;                      -- Synchronization verticale
        x              : out std_logic_vector(9 downto 0);   -- Abscisse du pixel dans l'image
        y              : out std_logic_vector(9 downto 0);   -- Ordonn�e du pixel dans l'image
        in_display     : out std_logic                       -- A 1 si le pixel est dans l'image
    );
end VGA_sync;

architecture behavioral of VGA_sync is

    	
    ----------------------------------------------
    -- SIGNAUX INTERNES DES COMPTEURS
    ----------------------------------------------
    signal x1          : std_logic_vector(9 downto 0);	
    signal end_count_x : std_logic;
    signal y1          : std_logic_vector(9 downto 0);	
    signal end_count_y : std_logic;
	
	
	
		
    ------------------------------------------
    -- DECLARATION DES COMPOSANTS
    ------------------------------------------	
    --Declaration de l'entite count_x
    component count_x
        generic(
            H_PIX           : integer;                      -- Taille de l'image horizontale
            H_FPORCH        : integer;                      -- Front porch horizontal
            HSYNC_SIZE      : integer;                      -- Horizontal sync pulse
            H_BPORCH        : integer                       -- Back porch horizontal
        );
        port ( 
            clk_25          : in std_logic;
            reset           : in std_logic; 
            x        	    : out std_logic_vector(9 downto 0);
            end_count_x	    : out std_logic
        );
    end component;


    --Declaration de l'entite count_y
    component count_y
        generic(
            V_PIX           : integer;                       -- Taille de l'image verticale
            V_FPORCH        : integer;                       -- Front porch vertical
            VSYNC_SIZE      : integer;                       -- Vertical sync pulse
            V_BPORCH        : integer                        -- Back porch vertical
        );
        port ( 
            clk_25          : in std_logic;
            reset           : in std_logic; 
            end_count_x	    : in std_logic;
            y        	    : out std_logic_vector(9 downto 0);
            end_count_y	    : out std_logic
        );
    end component;	
	

    begin

    --------------------------	
    -- AFFECTATION DES SIGNAUX
    --------------------------	
    --Affectation des signaux du testbench avec ceux de l'entite count_x
    mapping_count_x: count_x
        generic map (
            H_PIX       => H_PIX,
            H_FPORCH    => H_FPORCH, 
            HSYNC_SIZE  => HSYNC_SIZE, 
            H_BPORCH    => H_BPORCH
        ) 
        port map (
            clk_25      => clk_25,
            reset       => reset,
            x           => x1,
            end_count_x => end_count_x
        );


    --Affectation des signaux du testbench avec ceux de l'entite count_y
    mapping_count_y: count_y
        generic map (
            V_PIX       => V_PIX,
            V_FPORCH    => V_FPORCH, 
            VSYNC_SIZE  => VSYNC_SIZE, 
            V_BPORCH    => V_BPORCH
        ) 
        port map (
            clk_25      => clk_25,
            reset       => reset,
            end_count_x => end_count_x,
            y           => y1,
            end_count_y => end_count_y
        );



        ----------------------
        -- PARTIE COMBINATOIRE
        ----------------------
        -- Signal de synchro horizontale
        hsync <= '1' when (x1 >= (H_PIX + H_FPORCH)) NAND (x1 < (H_PIX + H_FPORCH + HSYNC_SIZE))
            else '0';
		
        -- Signal de synchro verticale
        vsync <= '1' when (y1 >= (V_PIX + V_FPORCH)) NAND (y1 < (V_PIX + V_FPORCH + VSYNC_SIZE))
            else '0';

        -- Signal in_display a 1 lorsque le pixel est dans l'image
        in_display  <= '1' when (x1 < H_PIX) AND (y1 < V_PIX)
            else '0';

        -- Coordonn�es du pixel
        x <= x1;
        y <= y1;
		
end behavioral;