----------------------------------------------------------------------------------
-- Engineer: Eric GASNIER
-- 
-- Create Date: 29.06.2023
-- Module Name: frame
-- Project Name: Moving sprite
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Generate one pulse every FRAME_SIZE images
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


entity frame is
    generic(
        FRAME_SIZE     : integer := 60          -- Déplacement chaque seconde
    );
    port ( 
        clk            : in std_logic;          -- Horloge
        reset          : in std_logic;          -- Entrée pour RESET des registres
        end_count_y    : in std_logic;          -- Signal indiquant que x a atteint la valeur de 525
        new_xy         : out std_logic          -- Pulse indiquant le comptage de FRAME_SIZE images
     );
end frame;

architecture behavioral of frame is
	
    ----------------------------------------------
    -- SIGNAUX INTERNES MODULE "frame"
    ----------------------------------------------
    signal cnt_img : std_logic_vector(9 downto 0) := (others => '0');
    signal cmd     : std_logic                    := '0';
	
	
	begin

        ----------------------
        -- PARTIE SEQUENTIELLE	
        ----------------------
        process(clk, reset)
        begin
            if reset = '1' then
                cnt_img <= (others => '0');   -- Réinitialisation du compteur
 
            elsif rising_edge(clk) then
			    
                -- Gestion du compteur de cycle
                if cmd = '1' then
                    cnt_img <= (others => '0');   -- Réinitialisation du compteur
                elsif end_count_y = '1' then
                    cnt_img <= cnt_img + 1;
                end if;
			    
            end if;
        end process;


        ----------------------
        -- PARTIE COMBINATOIRE
        ----------------------
        -- Signal de fin de comptage du y
        cmd <= '1' when (cnt_img = (FRAME_SIZE - 1) AND end_count_y = '1')
            else '0';
		
        new_xy <= cmd;
		
end behavioral;