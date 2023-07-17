----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 12.07.2023
-- Module Name: tb_topVGA_filtre_V5
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Corner detection
-- Input: VGA image in format 800x525
-- Output: : VGA image in format 640x480
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
use ieee.std_logic_textio.all;
library std;
use std.textio.all;


entity tb_topVGA_filtre_V5 is

end tb_topVGA_filtre_V5;

architecture Behavioral of tb_topVGA_filtre_V5 is

     ------------------------------------------------------------
    --  SIGNAUX 
    ---------------------------------------------------------------------------
    signal reset         : std_logic := '1';
    signal clk           : std_logic := '0';
    signal clk_20        : std_logic := '0';
    signal locked        : std_logic := '0';
    signal hsync_shifted : std_logic;
    signal vsync_shifted : std_logic;
    
    signal out_filt_Ra : std_logic_vector(3 downto 0);      -- Red filter signal 
    signal out_filt_Ba : std_logic_vector(3 downto 0);      -- Blue filter signal 
    signal out_filt_Ga : std_logic_vector(3 downto 0);      -- Green filter signal 



    signal cmd_conv   : std_logic                     := '0';
    signal data_input : std_logic_vector(3 downto 0)  := "0000";

    signal end_img    : std_logic                     := '0';
        


   
   --------------------------------------
    -- DECLARATION DES CONSTANTES
    ------------------------------------------
    constant hp           : time := 4 ns;     -- demi periode de 4ns
    constant period       : time := 2*hp;     -- periode de 8ns, soit une frequence de 125MHz

    constant hp_20        : time := 25 ns;    -- demi periode de 25ns
    constant period_20    : time := 2*hp_20;  -- periode de 50ns, soit une frequence de 20MHz

    constant image_WIDTH_VGA : natural := 800;
    constant image_WIDTH  : natural := 640;
    constant image_HEIGHT : natural := 480;


    
    --Declaration de l'entite topVGA_filtre
    component topVGA_filtre_V4
    port ( 
        clk             : in std_logic;
        reset           : in std_logic;
        data_input      : in std_logic_vector(3 downto 0);
        locked          : out std_logic;
        hsync_shifted   : out std_logic;
        vsync_shifted   : out std_logic;
        cmd_conv        : out std_logic;
        out_filt_Ra     : out std_logic_vector(3 downto 0);
        out_filt_Ba     : out std_logic_vector(3 downto 0);
        out_filt_Ga     : out std_logic_vector(3 downto 0)
    );
    end component; 

    begin
	
    --------------------------	
    -- AFFECTATION DES SIGNAUX
    --------------------------	
    --Affectation des signaux du testbench avec ceux de top_VGA
    mapping_topVGA_filtre_V4: topVGA_filtre_V4
    port map (
        clk            => clk, 
        reset          => reset,
        data_input     => data_input,
        locked         => locked,
        hsync_shifted  => hsync_shifted, 
        vsync_shifted  => vsync_shifted,
        cmd_conv       => cmd_conv,
        out_filt_Ra    => out_filt_Ra,
        out_filt_Ba    => out_filt_Ba,
        out_filt_Ga    => out_filt_Ga 
    );
       
    ------------------------------------------
    -- SIMULATION DE L'HORLOGE A 125 MHz
    ------------------------------------------
    process
        begin
            wait for hp;
            clk <= not clk;
    end process;
        
    ------------------------------------------
    -- SIMULATION DE L'HORLOGE A 20 MHz
    ------------------------------------------
    process
        begin
            wait for hp_20;
            clk_20 <= not clk_20;
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




    ---------------------------------------------
    -- LECTURE
    ---------------------------------------------
    process

        variable rd_line     : line;

        variable nb          : integer;

        file in_file         : text open read_mode is "damier_4b_VGA.txt";

        variable v_TAB       : character := HT;   -- Tabulation

        begin
        while not endfile(in_file) loop
            if locked='1' then
                readline(in_file, rd_line);
                for i in 0 to image_WIDTH_VGA - 1 loop
                    read(rd_line, nb);
                    read(rd_line, v_TAB);
                    data_input <= std_logic_vector(to_unsigned(nb,4));

                    wait for period_20;
                end loop;
            else
                wait for period_20;
            end if;
            
        end loop;
        
        file_close(in_file);
        wait;

    end process;
	
	
    ---------------------------------------------
    -- ECRITURE
    ---------------------------------------------
    process

        variable wr_line_R   : line;
        variable wr_line_B   : line;
        variable wr_line_G   : line;


        file out_file_R      : text open write_mode is "result_R.txt";
        file out_file_B      : text open write_mode is "result_B.txt";
        file out_file_G      : text open write_mode is "result_G.txt";


        begin
        end_img <= '0';
        while end_img = '0' loop
            if cmd_conv = '1' then
                for j in 0 to image_HEIGHT - 1 loop
                    for i in 0 to image_WIDTH_VGA - 1 loop
                        wait for period_20;

                        if i < image_WIDTH then
                            write(wr_line_R, to_integer(unsigned(out_filt_Ra)), right, 5);
                            write(wr_line_B, to_integer(unsigned(out_filt_Ba)), right, 5);
                            write(wr_line_G, to_integer(unsigned(out_filt_Ga)), right, 5);
                        end if;
                    end loop;

                    -- Ecriture des lignes dans les fichiers
                    writeline(out_file_R, wr_line_R);
                    writeline(out_file_B, wr_line_B);
                    writeline(out_file_G, wr_line_G);

                end loop;
                
                end_img <= '1';
                wait for period_20;
            else
                wait for period_20;
            end if;
            
        end loop;
        
        -- Fermeture des fichiers
        file_close(out_file_R);
        file_close(out_file_B);
        file_close(out_file_G);
    
        wait;

    end process;


end Behavioral;
