----------------------------------------------------------------------------------
-- Engineer: Eric GASNIER
-- 
-- Create Date: 29.06.2023
-- Module Name: gen_IMG
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Generate image with sprite
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


entity gen_IMG is
    generic (
        FRAME_SIZE      : integer := 60;
        X_MIN           : std_logic_vector(9 downto 0) := "0000000100"; -- 0
        X_MAX           : std_logic_vector(9 downto 0) := "1001111111"; -- 639
        Y_MIN           : std_logic_vector(9 downto 0) := "0000000100"; -- 0
        Y_MAX           : std_logic_vector(9 downto 0) := "0111011111"; -- 479
        X_INIT          : std_logic_vector(9 downto 0) := "0101000000"; -- 320 
        Y_INIT          : std_logic_vector(9 downto 0) := "0011110000"; -- 240
        HALF_SPRITE_SIZE : std_logic_vector(9 downto 0) := "0000010100"  -- 20
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
end gen_IMG;


architecture Behavioral of gen_IMG is

        ------------------------------------------------------------
        -- SIGNAUX INTERNES
        ------------------------------------------------------------
        signal new_xy            : std_logic := '0';
        signal x_sprite          : std_logic_vector(9 downto 0);
        signal y_sprite          : std_logic_vector(9 downto 0);                         

         
 
        ------------------------------------------
        -- DECLARATION DU COMPOSANT frame
        ------------------------------------------
        component frame
        generic(
            FRAME_SIZE     : integer
        );
        port ( 
            clk            : in std_logic;
            reset          : in std_logic;
            end_count_y    : in std_logic;
            new_xy         : out std_logic
        );
        end component;


        ------------------------------------------
        -- DECLARATION DU COMPOSANT calculate_sprite
        ------------------------------------------
        component calculate_sprite
        generic(
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
            new_xy          : in std_logic;
            x_sprite        : out std_logic_vector(9 downto 0);
            y_sprite        : out std_logic_vector(9 downto 0)
        );
        end component;



        ------------------------------------------------
        -- DECLARATION DU COMPOSANT draw
        --------------------------------------------------
        component draw
        generic(
            HALF_SPRITE_SIZE : std_logic_vector(9 downto 0) := "0000010100"
        );
        port ( 
            x              : in std_logic_vector(9 downto 0);
            y              : in std_logic_vector(9 downto 0);
            x_sprite       : in std_logic_vector(9 downto 0);
            y_sprite       : in std_logic_vector(9 downto 0);
            in_display     : in std_logic;
            out_pix        : out std_logic_vector(3 downto 0)
        );
        end component;


    begin

    -----------------------------------------------------------------------------	
    -- AFFECTATION DES SIGNAUX
    ------------------------------------------------------------------------------	
    --Affectation des signaux du module frame
    mapping_frame : frame
    generic map (
        FRAME_SIZE => FRAME_SIZE
    )
    port map (
        clk         => clk,
        reset       => reset,
        end_count_y => end_count_y,
        new_xy      => new_xy
    );               	

    --Affectation des signaux du module Vga_sync
    mapping_calculate_sprite : calculate_sprite
    generic map (
        X_MIN       => X_MIN,
        X_MAX       => X_MAX,
        Y_MIN       => Y_MIN,
        Y_MAX       => Y_MAX,
        X_INIT      => X_INIT,
        Y_INIT      => Y_INIT,
        HALF_SPRITE_SIZE => HALF_SPRITE_SIZE
    )
    port map ( 
        clk         => clk,
        reset       => reset,
        new_xy      => new_xy,
        x_sprite    => x_sprite,
        y_sprite    => y_sprite
    );
	

    --Affectation des signaux du module draw
    mapping_draw : draw
    generic map (
        HALF_SPRITE_SIZE => HALF_SPRITE_SIZE
    )
    port map ( 
        x               => x,
        y               => y,
        x_sprite        => x_sprite,
        y_sprite        => y_sprite,
        in_display      => in_display,
        out_pix         => out_pix
     );
   

   
end Behavioral;
