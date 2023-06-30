----------------------------------------------------------------------------------
-- Engineer: Eric GASNIER
-- 
-- Create Date: 29.06.2023
-- Module Name: tb_frame
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Testbench for component frame
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

entity tb_frame is
end tb_frame;

architecture behavioral of tb_frame is

    ------------------------------------------
    -- DECLARATION DES SIGNAUX INTERNES
    ------------------------------------------
    signal reset       : std_logic := '1';
    signal clk         : std_logic := '0';
    signal end_count_y : std_logic;
    signal new_xy      : std_logic;
	
    ------------------------------------------
    -- DECLARATION DES CONSTANTES
    ------------------------------------------
    constant hp : time := 20 ns;             -- demi periode de 20ns
    constant period : time := 2*hp;          -- periode de 40ns, soit une frequence de 25MHz

    constant FRAME_SIZE : integer  := 60;


    ------------------------------------------
    -- DECLARATION DES COMPOSANTS
    ------------------------------------------
    --Declaration de l'entite frame
    component frame
        generic(
            FRAME_SIZE      : integer
        );
        port ( 
            clk             : in std_logic;
            reset           : in std_logic; 
            end_count_y	    : in std_logic;
            new_xy          : out std_logic
        );
    end component;
	
	

    begin
	
    ------------------------------------------
    -- AFFECTATION DES SIGNAUX
    ------------------------------------------
    --Affectation des signaux du testbench avec ceux de l'entite frame
    mapping_frame: frame
        generic map(
            FRAME_SIZE  => FRAME_SIZE
        )
        port map (
            clk         => clk,
            reset       => reset,
            end_count_y => end_count_y,
            new_xy      => new_xy
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
        end_count_y <= '1';
        
        -- signal reset a 1
        reset <= '1';
        -- counting for 1 period
        wait for period;
        -- signal reset a 0
        reset <= '0';


        --------------------------------------------------------------------------
        -- PREMIER TEST : end_count_y maintenu a 1
        -- Attendu: new_xy passe a 1 apres la 60eme image
        --------------------------------------------------------------------------
        -- Balayage des images de 0 a 58
        for i in 0 to (FRAME_SIZE - 2) loop
            assert new_xy = '0'
                report "ERROR: new_xy incorrect" severity failure;            
                
            -- Attente d'une periode
            wait for period;
        end loop;

        -- Balayage de la 59eme image
        assert new_xy = '1'
            report "ERROR: new_xy incorrect" severity failure;            

        wait for period;


        --------------------------------------------------------------------------
        -- DEUXIEME TEST : end_count_y maintenu a 0
        -- Attendu: new_xy passe reste a 0
        --------------------------------------------------------------------------
        end_count_y <= '0';

        -- Balayage des images de 0 a 59
        for i in 0 to (FRAME_SIZE - 1) loop
            assert new_xy = '0'
                report "ERROR: new_xy incorrect" severity failure;            
                
            -- Attente d'une periode
            wait for period;
        end loop;

        wait;
        
    end process;
	
end behavioral;