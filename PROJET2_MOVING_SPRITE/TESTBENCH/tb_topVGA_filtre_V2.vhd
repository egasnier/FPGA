----------------------------------------------------------------------------------
-- Engineer: Eric GASNIER
-- 
-- Create Date: 30.06.2023
-- Module Name: tb_topVGA_filtre
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Testbench for whole system (square sprite moving on the screen)
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


entity tb_topVGA_filtre_V2 is

end tb_topVGA_filtre_V2;

architecture Behavioral of tb_topVGA_filtre_V2 is

    ------------------------------------------
    -- DECLARATION DES CONSTANTES
    ------------------------------------------
                                                                 
    -- Les constantes suivantes permette de definir la frequence de l'horloge 
    constant hp : time := 4 ns;               -- demi periode de 4ns
    constant period: time := 2*hp;           -- periode de 8ns, soit une frequence de 125MHz
    constant count_max_tb : natural := 800; -- nombre de periodes correspondant au compteur
         
                            
    ------------------------------------------------------------
    --  SIGNAUX 
    ---------------------------------------------------------------------------
    signal reset       : std_logic := '1';
    signal clk         : std_logic := '0';
    signal hsync_shifted : std_logic;
    signal vsync_shifted : std_logic;
    signal out_filt_R : std_logic_vector(3 downto 0);      -- Red filter signal 
    signal out_filt_B : std_logic_vector(3 downto 0);      -- Blue filter signal 
    signal out_filt_G : std_logic_vector(3 downto 0);      -- Green filter signal 
	 
    --Declaration de l'entite topVGA_filtre
    component topVGA_filtre_V2
    port ( 
        clk            : in std_logic;
        reset          : in std_logic;
        hsync_shifted  : out std_logic;                        -- Synchronization horizontale
        vsync_shifted  : out std_logic; 
        out_filt_R     : out std_logic_vector(3 downto 0);
        out_filt_B     : out std_logic_vector(3 downto 0);
        out_filt_G     : out std_logic_vector(3 downto 0)
    );
    end component; 

    begin
    --Affectation des signaux du testbench avec ceux de top_VGA
    mapping_topVGA_filtre: topVGA_filtre_V2
    port map  (
        clk     => clk, 
        reset   => reset,
        hsync_shifted =>hsync_shifted, 
        vsync_shifted =>vsync_shifted,
        out_filt_R    => out_filt_R,
        out_filt_B    => out_filt_B,
        out_filt_G    => out_filt_G 
    );
        
    --Simulation du signal d'horloge en continue
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
	
        -- Pour finir la simulation 
        wait;
	   
    end process;
  
end Behavioral;
