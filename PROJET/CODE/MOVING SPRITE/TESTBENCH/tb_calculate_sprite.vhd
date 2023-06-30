----------------------------------------------------------------------------------
-- Engineer: Eric GASNIER
-- 
-- Create Date: 29.06.2023
-- Module Name: tb_calculate_sprite
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Testbench for component calculate_sprite
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

entity tb_calculate_sprite is
end tb_calculate_sprite;

architecture behavioral of tb_calculate_sprite is

    ------------------------------------------
    -- DECLARATION DES SIGNAUX INTERNES
    ------------------------------------------
    signal reset       : std_logic := '1';
    signal clk         : std_logic := '0';
    signal new_xy      : std_logic := '0';
    signal x_sprite    : std_logic_vector(9 downto 0);
    signal y_sprite    : std_logic_vector(9 downto 0);
	
    ------------------------------------------
    -- DECLARATION DES CONSTANTES
    ------------------------------------------
    constant hp : time := 20 ns;             -- demi periode de 20ns
    constant period : time := 2*hp;          -- periode de 40ns, soit une frequence de 25MHz



    ------------------------------------------
    -- DECLARATION DES COMPOSANTS
    ------------------------------------------
    --Declaration de l'entite frame
    component calculate_sprite
        port ( 
            clk             : in std_logic;
            reset           : in std_logic;
            new_xy          : in std_logic;
            x_sprite	    : out std_logic_vector(9 downto 0);
            y_sprite        : out std_logic_vector(9 downto 0)
        );
    end component;
	
	

    begin
	
    ------------------------------------------
    -- AFFECTATION DES SIGNAUX
    ------------------------------------------
    --Affectation des signaux du testbench avec ceux de l'entite frame
    mapping_frame: calculate_sprite
        port map (
            clk         => clk,
            reset       => reset,
            new_xy      => new_xy,
            x_sprite    => x_sprite,
            y_sprite    => y_sprite
        );
		
    ------------------------------------------
    -- SIMULATION DE L'HORLOGE
    ------------------------------------------
    process
    begin
        wait for hp;
        clk <= not clk;
    end process;


    process
    begin
        ---------------------------------------------
        -- INITIALISATION
        ---------------------------------------------
        -- signal reset a 1
        reset <= '1';
        -- counting for 1 period
        wait for period;
        -- signal reset a 0
        reset <= '0';

        for i in 0 to 1000 loop 
            new_xy <= '0';
            wait for 800 * period;
            new_xy <= '1';
            wait for period;
        end loop;


        wait;
        
    end process;
	
end behavioral;