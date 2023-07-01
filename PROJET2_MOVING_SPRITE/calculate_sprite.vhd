----------------------------------------------------------------------------------
-- Engineer: Eric GASNIER
-- 
-- Create Date: 29.06.2023
-- Module Name: calculate_sprite
-- Project Name: Moving sprite
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Calculate sprite's coordinates
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


entity calculate_sprite is
    generic(
        X_MIN           : std_logic_vector(9 downto 0) := "0000000000"; -- 0
        X_MAX           : std_logic_vector(9 downto 0) := "1001111111"; -- 639
        Y_MIN           : std_logic_vector(9 downto 0) := "0000000000"; -- 0
        Y_MAX           : std_logic_vector(9 downto 0) := "0111011111"; -- 479
        X_INIT          : std_logic_vector(9 downto 0) := "0101000000"; -- 320 
        Y_INIT          : std_logic_vector(9 downto 0) := "0011110000"; -- 240
        HALF_SPRITE_SIZE : std_logic_vector(9 downto 0) := "0000010100"  -- 20
    );
    port ( 
        clk             : in std_logic;
        reset           : in std_logic;
        new_xy          : in std_logic;
        x_sprite        : out std_logic_vector(9 downto 0);
        y_sprite        : out std_logic_vector(9 downto 0)
     );
end calculate_sprite;

architecture behavioral of calculate_sprite is
	
    ----------------------------------------------
    -- SIGNAUX INTERNES
    ----------------------------------------------
    -- Gestion de la direction
    signal x_out, dir_x : std_logic := '0';
    signal y_out, dir_y : std_logic := '0';
    
    -- Gestion des coordonnees
    signal x_spr, y_spr            : std_logic_vector(9 downto 0);
	
	
	begin

        ----------------------
        -- PARTIE SEQUENTIELLE	
        ----------------------
        process(clk, reset)
        begin
            if reset = '1' then
                x_spr <= X_INIT;
                y_spr <= Y_INIT;
 
            elsif rising_edge(clk) then
			    
                -- Gestion de la direction
                if new_xy = '1' then
                    if x_out = '1' then
                        if dir_x = '1' then
                            x_spr <= x_spr - 1;
                        else
                            x_spr <= x_spr + 1;
                        end if;

                        dir_x <= NOT(dir_x);
                    else
                        if dir_x = '1' then
                            x_spr <= x_spr + 1;
                        else
                            x_spr <= x_spr - 1;
                        end if;
                    end if;

                    if y_out = '1' then
                        if dir_y = '1' then
                            y_spr <= y_spr - 1;
                        else
                            y_spr <= y_spr + 1;
                        end if;

                        dir_y <= NOT(dir_y);
                    else
                        if dir_y = '1' then
                            y_spr <= y_spr + 1;
                        else
                            y_spr <= y_spr - 1;
                        end if;
                    end if;
                end if;
                
            end if;
        end process;


        ----------------------
        -- PARTIE COMBINATOIRE
        ----------------------
        -- Gestion de la direction
        x_out <= '1' when (x_spr <= X_MIN + HALF_SPRITE_SIZE) OR (x_spr >= X_MAX - HALF_SPRITE_SIZE)
            else '0';
		  
        y_out <= '1' when (y_spr <= Y_MIN + HALF_SPRITE_SIZE) OR (y_spr >= Y_MAX - HALF_SPRITE_SIZE)
            else '0';


        -- Gestion des coordonnees
        x_sprite <= x_spr;
        y_sprite <= y_spr;
        
end behavioral;