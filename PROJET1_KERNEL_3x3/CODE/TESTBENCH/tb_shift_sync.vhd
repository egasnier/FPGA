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
    signal x             : std_logic_vector(9 downto 0) := (others => '0');
    signal y             : std_logic_vector(9 downto 0) := (others => '0');
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
    generic (
        H_PIX          : integer;                 -- Taille de l'image horizontale
        H_FPORCH       : integer;                 -- Front porch horizontal
        HSYNC_SIZE     : integer;                 -- Horizontal sync pulse
        H_BPORCH       : integer;                 -- Back porch horizontal
        V_PIX          : integer;                 -- Taille de l'image verticale
        V_FPORCH       : integer;                 -- Front porch vertical
        VSYNC_SIZE     : integer;                 -- Vertical sync pulse
        V_BPORCH       : integer                  -- Back porch vertical
    );
    port ( 
        clk            : in std_logic;            -- Horloge
        reset          : in std_logic;            -- Entrée pour RESET des registres
        x              : in std_logic_vector(9 downto 0); -- Coordonnée X du pixel
        y              : in std_logic_vector(9 downto 0); -- Coordonnée y du pixel
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
        generic map (
            H_PIX          => 640,
            H_FPORCH       => 16,
            HSYNC_SIZE     => 96,
            H_BPORCH       => 48,
            V_PIX          => 480,
            V_FPORCH       => 10,
            VSYNC_SIZE     => 2,
            V_BPORCH       => 33
        )
        port map (
            clk            => clk,
            reset          => reset,
            x              => x,
            y              => y,
            end_count_x    => end_count_x,
            hsync_shifted  => hsync_shifted,
            vsync_shifted  => vsync_shifted
        );


    ------------------------------------------
    -- SIMULATION DE L'HORLOGE
    ------------------------------------------
    process
    begin
        clk <= not clk;
        wait for hp;
    end process;


    ------------------------------------------
    -- SIMULATION DE X
    ------------------------------------------
    process
    begin
        if reset = '1' then
            x <= (others => '0');
        else if x = "1100011111" then
                x <= (others => '0');
                end_count_x <= '1';
            else
                x <= std_logic_vector(unsigned(x) + 1);
                end_count_x <= '0';
            end if;
        end if;
        wait for period;
    end process;


    ------------------------------------------
    -- SIMULATION DE Y
    ------------------------------------------
    process
    begin
        if reset = '1' then
            y <= (others => '0');
        else if y = "1000001101" then
                y <= (others => '0');
            else
                y <= std_logic_vector(unsigned(y) + 1); 
            end if;
        end if;

        -- counting for 800 periods
        for i in 0 to 799 loop
            wait for period;
        end loop;

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


        ---------------------------------------------
        -- FIRST TEST BEFORE end_count_x = 1
        -- Expected results : hsync_shifted and vsync_shifted equal to 1
        ---------------------------------------------
        -- counting for 799 periods
        for i in 0 to 798 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;

        
        
        ---------------------------------------------
        -- SECOND TEST AFTER end_count_x = 1
        -- Expected results :
        -- hsync_shifted equal to hsync shifted of two periods
        -- vsync_shifted equals to 1
        ---------------------------------------------
    
        -- counting for 658 periods
        for i in 0 to 657 loop
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;

        -- counting for 2 periods
        for i in 0 to 1 loop
            --x <= std_logic_vector(unsigned(x) + 1);
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;

        -- counting for 96 periods
        for i in 0 to 95 loop
            --x <= std_logic_vector(unsigned(x) + 1);
            assert hsync_shifted = '0'
                        report "ERROR: hsync_shifted not equals to 0" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;


        -- counting for 48 periods
        for i in 0 to 47 loop
            --x <= std_logic_vector(unsigned(x) + 1);
            assert hsync_shifted = '1'
                        report "ERROR: hsync_shifted not equals to 1" severity failure;
            assert vsync_shifted = '1'
                        report "ERROR: vsync_shifted not equals to 1" severity failure;
            wait for period;
        end loop;



        ---------------------------------------------
        -- THIRD TEST AFTER 490 raws 
        -- Expected results :
        -- vsync_shifted shifted of two periods
        ---------------------------------------------
        -- counting for 489 raws
        for j in 0 to 488 loop
            for i in 0 to 799 loop
                wait for period;
            end loop;
        end loop;
        
        for i in 0 to 799 loop
            wait for period;
            assert vsync_shifted = '0'
                report "ERROR: vsync_shifted not equals to 0" severity failure;
        end loop;        
        

        wait;
	   
    end process;
	
end behavioral;