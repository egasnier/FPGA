----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: tb_VGA_sync
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Testbench for component shift_sync
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


entity tb_shift_sync is
end tb_shift_sync;

architecture behavioral of tb_shift_sync is

    signal reset         : std_logic := '1';
    signal clk           : std_logic := '0';
    signal hsync         : std_logic := '0';
    signal vsync         : std_logic := '0';
    signal end_count_x   : std_logic := '0';
    signal hsync_shifted : std_logic;
    signal vsync_shifted : std_logic;

    ------------------------------------------
    -- DECLARATION DES CONSTANTES
    ------------------------------------------
    -- Les constantes suivantes permettent de definir la frequence de l'horloge 
    constant hp     : time := 20 ns;             -- demi periode de 20ns
    constant period : time := 2*hp;              -- periode de 40ns, soit une frequence de 25MHz


    ------------------------------------------
    -- DECLARATION DU COMPOSANT VGA_sync
    ------------------------------------------
    component shift_sync
        port ( 
            clk            : in std_logic;            -- Horloge
            reset          : in std_logic;            -- Entrée pour RESET des registres
            hsync          : in std_logic;            -- Synchronization horizontale
            vsync          : in std_logic;            -- Synchronization verticale
            end_count_x    : in std_logic;            -- Fin de lecture d'une ligne
            hsync_shifted  : out std_logic;           -- Synchronization horizontale retardée de 802 pixels
            vsync_shifted  : out std_logic            -- Synchronization verticale retardée de 802 pixels
        );
	end component;


	begin
	
    --------------------------	
    -- AFFECTATION DES SIGNAUX
    --------------------------	
    --Affectation des signaux du testbench avec ceux de l'entite count_x
    mapping_shift_sync: shift_sync
        port map (
            clk            => clk,
            reset          => reset,
            hsync          => hsync,
            vsync          => vsync,
            end_count_x    => end_count_x,
            hsync_shifted  => hsync_shifted,
            vsync_shifted  => vsync_shifted
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
        -- counting for 2 periods - Waiting before reset
        wait for (2 * period);
        -- signal reset a 1
        reset <= '1';
        -- counting for 1 period
        wait for period;
        -- signal reset a 0
        reset <= '0';


        ---------------------------------------------
        -- FIRST TEST BEFORE end_count_x = 1
        -- Expected results : hsync_shifted and vsync_shifted equal to 1
        ---------------------------------------------
        hsync <= '1';
        vsync <= '1';
        -- counting for 656 periods
        for i in 0 to 655 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;

        hsync <= '0';
        vsync <= '0';
        -- counting for 96 periods
        for i in 0 to 95 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;

        hsync <= '1';
        vsync <= '1';
        -- counting for 48 periods
        for i in 0 to 47 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;
        
        
        ---------------------------------------------
        -- SECOND TEST AFTER end_count_x = 1
        -- Expected results :
        -- hsync_shifted and vsync_shifted equal to equal to hsync and vsync shifted of two periods
        ---------------------------------------------
        end_count_x <= '1';
        -- counting for 1 period
        wait for period;
        end_count_x <= '0';


        hsync <= '1';
        vsync <= '1';
        -- counting for 656 periods
        for i in 0 to 655 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;

        hsync <= '0';
        vsync <= '0';
        -- counting for 2 periods
        for i in 0 to 1 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;

        -- counting for 94 periods
        for i in 0 to 93 loop
            assert hsync_shifted = '0'
                        report "ERROR: hsync_shifted not equals to 0" severity failure;
            assert vsync_shifted = '0'
                        report "ERROR: vsync_shifted not equals to 0" severity failure;
            wait for period;
        end loop;



        hsync <= '1';
        vsync <= '1';
        -- counting for 2 periods
        for i in 0 to 1 loop
            assert hsync_shifted = '0'
                        report "ERROR: hsync_shifted not equals to 0" severity failure;
            assert vsync_shifted = '0'
                        report "ERROR: vsync_shifted not equals to 0" severity failure;
            wait for period;
        end loop;

        -- counting for 48 periods
        for i in 0 to 47 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;



        ---------------------------------------------
        -- THIRD TEST AFTER A NEW end_count_x = 1
        -- Expected results :
        -- hsync_shifted and vsync_shifted equal to equal to hsync and vsync shifted of two periods
        ---------------------------------------------
        end_count_x <= '1';
        -- counting for 1 period
        wait for period;
        end_count_x <= '0';


        hsync <= '1';
        vsync <= '1';
        -- counting for 656 periods
        for i in 0 to 655 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;

        hsync <= '0';
        vsync <= '0';
        -- counting for 2 periods
        for i in 0 to 1 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;

        -- counting for 94 periods
        for i in 0 to 93 loop
            assert hsync_shifted = '0'
                        report "ERROR: hsync_shifted not equals to 0" severity failure;
            assert vsync_shifted = '0'
                        report "ERROR: vsync_shifted not equals to 0" severity failure;
            wait for period;
        end loop;



        hsync <= '1';
        vsync <= '1';
        -- counting for 2 periods
        for i in 0 to 1 loop
            assert hsync_shifted = '0'
                        report "ERROR: hsync_shifted not equals to 0" severity failure;
            assert vsync_shifted = '0'
                        report "ERROR: vsync_shifted not equals to 0" severity failure;
            wait for period;
        end loop;

        -- counting for 48 periods
        for i in 0 to 47 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;


        ---------------------------------------------
        -- FOURTH TEST AFTER A RESET
        -- Expected results : hsync_shifted and vsync_shifted equal to 1
        ---------------------------------------------
                -- signal reset a 1
        reset <= '1';
        -- counting for 1 period
        wait for period;
        -- signal reset a 0
        reset <= '0';



        hsync <= '1';
        vsync <= '1';
        -- counting for 656 periods
        for i in 0 to 655 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;

        hsync <= '0';
        vsync <= '0';
        -- counting for 96 periods
        for i in 0 to 95 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;

        hsync <= '1';
        vsync <= '1';
        -- counting for 48 periods
        for i in 0 to 47 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;


        ---------------------------------------------
        -- FITH TEST AFTER end_count_x = 1
        -- Expected results :
        -- hsync_shifted and vsync_shifted equal to equal to hsync and vsync shifted of two periods
        ---------------------------------------------
        end_count_x <= '1';
        -- counting for 1 period
        wait for period;
        end_count_x <= '0';


        hsync <= '1';
        vsync <= '1';
        -- counting for 656 periods
        for i in 0 to 655 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;

        hsync <= '0';
        vsync <= '0';
        -- counting for 2 periods
        for i in 0 to 1 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;

        -- counting for 94 periods
        for i in 0 to 93 loop
            assert hsync_shifted = '0'
                        report "ERROR: hsync_shifted not equals to 0" severity failure;
            assert vsync_shifted = '0'
                        report "ERROR: vsync_shifted not equals to 0" severity failure;
            wait for period;
        end loop;



        hsync <= '1';
        vsync <= '1';
        -- counting for 2 periods
        for i in 0 to 1 loop
            assert hsync_shifted = '0'
                        report "ERROR: hsync_shifted not equals to 0" severity failure;
            assert vsync_shifted = '0'
                        report "ERROR: vsync_shifted not equals to 0" severity failure;
            wait for period;
        end loop;

        -- counting for 48 periods
        for i in 0 to 47 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;




        wait;
	   
    end process;
	
end behavioral;