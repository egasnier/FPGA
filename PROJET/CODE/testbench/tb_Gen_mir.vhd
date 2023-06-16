----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: count_unit
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Testbench of component Gen_mir
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

entity tb_Gen_mir is

end entity tb_Gen_mir ;

architecture testbench of tb_Gen_mir  is


    ------------------------------------------
    -- DECLARATION DES SIGNAUX INTERNES
    ------------------------------------------
    signal reset       : std_logic := '1';
    signal clk         : std_logic := '0';

    -- Signaux d'entree
    signal in_display  : std_logic;
    signal x           : std_logic_vector(9 downto 0);
    signal y           : std_logic_vector(9 downto 0);

    -- Signaux de sortie
    signal Out_pix_R  : std_logic_vector(3 downto 0);
    signal Out_pix_G  : std_logic_vector(3 downto 0);
    signal Out_pix_B  : std_logic_vector(3 downto 0);
    

    ------------------------------------------
    -- DECLARATION DES CONSTANTES
    ------------------------------------------
      
    -- Constantes de configuration du testbench
    constant screen_width  : natural := 640;
    constant screen_height : natural := 480;
    constant square_width  : natural := 40;

    -- Les constantes suivantes permette de definir la frequence de l'horloge 
    constant hp            : time    := 4 ns;   -- demi periode de 5ns
    constant period        : time    := 2*hp;   -- periode de 8ns, soit une frequence de 125MHz
         
    
    -- Generation des signaux d'entree
    constant total_pixels       : natural := screen_width * screen_height;
    shared variable pixel_count : natural := 0;



    ------------------------------------------
    -- DECLARATION DES COMPOSANTS
    ------------------------------------------
    component Gen_mir    
        generic
        (
            square_width   : integer := 40   -- taille du carré en pixels
        );
        port (
            in_display     : in std_logic;                           -- Signal indiquant si l'images sont dans la zone d'affichage
            x              : in std_logic_vector(9 downto 0);        -- Coordonnée X du pixel
            y              : in std_logic_vector(9 downto 0);        -- Coordonnée y du pixel
            Out_pix_R      : out std_logic_vector(3 downto 0);       -- Composante rouge du pixel
            Out_pix_B      : out std_logic_vector(3 downto 0);       -- Composante bleue du pixel
            Out_pix_G      : out std_logic_vector(3 downto 0)        -- Composante verte du pixel
        );
    end component; 
  
  
    begin
	
    ------------------------------------------
    -- AFFECTATION DES SIGNAUX
    ------------------------------------------
    -- Instanciation du module Gen_mir
    uut :  Gen_mir
        generic map (
            square_width => 40   -- taille du carré en pixels
        )
        port map (
            in_display   => in_display,
            x            => x,
            y            => y,
            Out_pix_R    => Out_pix_R,
            Out_pix_G    => Out_pix_G,
            Out_pix_B    => Out_pix_B
        );


    ------------------------------------------
    -- SIMULATION DE L'HORLOGE
    ------------------------------------------
    --Simulation du signal d'horloge en continue
    process
    begin
        wait for hp;
        clk <= not clk;
    end process;


    -- Processus de generation des signaux d'entree
    process
    begin
        ---------------------------------------------
        -- INITIALISATION
        ---------------------------------------------
        -- Initialisation des signaux d'entree
        in_display <= '0';
        x <= (others => '0');
        y <= (others => '0');
        
        -- Generation des signaux d'entree pour chaque pixel
        while pixel_count < total_pixels loop
            in_display <= '1';
            
         
            -- Calcul des coordonnées x et y en fonction du numéro de pixel
            x <= std_logic_vector( to_unsigned(pixel_count mod 640, x'length));
            y <= std_logic_vector(to_unsigned(pixel_count / 640, y'length));
            

            -- Attente pour observer les sorties
            wait for period;
            
            -- Incrementation du compteur de pixels
            pixel_count := pixel_count + 1;
        end loop;
        
        -- Desactivation du signal in_display
        in_display <= '0';
        
        -- Attente supplementaire pour observer les sorties finales
        wait for period;
        
        -- Arret de la simulation
        wait;
    end process ;
    
end architecture ;