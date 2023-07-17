----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 11.07.2023
-- Module Name: corner_detection
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Component for corner detection
-- (Detection de points d'interet)
-- 
-- Dependencies: Pmod VGA (digilent)
-- 
-- Revision:
-- Revision 0.02 - File Created
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity corner_detection is
    generic (
        THRESHOLD         : std_logic_vector(7 downto 0) := "00010000";
        CORNER_R          : std_logic_vector(3 downto 0) := "1111";
        CORNER_B          : std_logic_vector(3 downto 0) := "0000";
        CORNER_G          : std_logic_vector(3 downto 0) := "0000"
    );
	port(
		mat_id_in         : in std_logic_vector(3 downto 0);
		sob_h_in          : in std_logic_vector(6 downto 0);
		sob_v_in          : in std_logic_vector(6 downto 0);
		out_filt_R        : out std_logic_vector(3 downto 0);
		out_filt_B        : out std_logic_vector(3 downto 0);
		out_filt_G        : out std_logic_vector(3 downto 0)
    );
end corner_detection;

architecture arch_corner_detection of corner_detection is

    ----------------------------------------------
    -- SIGNAUX INTERNES PARTIE COMBINATOIRE
    ----------------------------------------------
    signal sob_sum            : std_logic_vector(7 downto 0);


	begin

        -----------------------------------------
        -- PARTIE COMBINATOIRE
        -----------------------------------------
        -- Sum
        sob_sum <= std_logic_vector(
                    unsigned("0" & sob_h_in) + unsigned("0" & sob_v_in)
                     );

        -- Sorties
        -- Solution 1:
        -- Somme des gradients de Sobel et comparaison a un seuil
        out_filt_R <= CORNER_R when sob_sum > THRESHOLD
            else mat_id_in;

        out_filt_B <= CORNER_B when sob_sum > THRESHOLD
            else mat_id_in;

        out_filt_G <= CORNER_G when sob_sum > THRESHOLD
            else mat_id_in;

        -- Solution 2:
        -- Comparaison de chaque gradient de Sobel par rapport a un seuil
--        out_filt_R <= CORNER_R when (("0" & sob_h_in) > THRESHOLD) AND (("0" & sob_v_in) > THRESHOLD) 
--            else mat_id_in;

--        out_filt_B <= CORNER_B when (("0" & sob_h_in) > THRESHOLD) AND (("0" & sob_v_in) > THRESHOLD)
--            else mat_id_in;

--        out_filt_G <= CORNER_G when (("0" & sob_h_in) > THRESHOLD) AND (("0" & sob_v_in) > THRESHOLD)
--            else mat_id_in;

  
end arch_corner_detection;
