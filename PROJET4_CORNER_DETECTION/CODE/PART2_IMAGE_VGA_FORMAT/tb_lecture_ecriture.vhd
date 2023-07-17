----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Eric GASNIER & Sefofo SOKPOR
-- 
-- Create Date: 06.07.2023
-- Design Name: 
-- Module Name: tb_lecture_ecriture_tb
-- Description: Read & Write an image in a text file
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_textio.all;
use ieee.numeric_std.all;
library STD;
use STD.textio.all;

entity lecture_ecriture_tb is
end lecture_ecriture_tb;

architecture arch_lecture_ecriture_tb of lecture_ecriture_tb is


    signal clk   : std_ulogic                   := '1';


    ------------------------------------------
    -- DECLARATION DES CONSTANTES
    ------------------------------------------
    -- Les constantes suivantes permettent de definir la frequence de l'horloge 
    constant hp     : time := 20 ns;             -- demi periode de 20ns
    constant period : time := 2*hp;              -- periode de 40ns, soit une frequence de 25MHz



	begin
	
    ------------------------------------------
    -- SIMULATION DE L'HORLOGE
    ------------------------------------------
    process
        begin
            wait for hp;
            clk <= not clk;
        end process;


    process

        constant image_WIDTH : natural := 639;
        
        variable rd_line     : line;
        variable wr_line     : line;

        variable nb          : integer;

        file in_file         : text open read_mode is "Image_in_8b.txt";
        file out_file        : text open write_mode is "result.txt";

        -- variable v_SPACE     : character;
        variable v_TAB       : character := HT;   -- Tabulation

        begin
        ---------------------------------------------
        -- LECTURE - ECRITURE
        ---------------------------------------------
        while not endfile(in_file) loop
            readline(in_file, rd_line);
            for i in 0 to image_WIDTH loop
                read(rd_line, nb);
                read(rd_line, v_TAB);

                wait for period;

                write(wr_line, nb, right, 5);
            end loop;
            writeline(out_file, wr_line);
            

        end loop;

        file_close(in_file);
        file_close(out_file);
    
        wait;

    end process;
	
	

end arch_lecture_ecriture_tb;
