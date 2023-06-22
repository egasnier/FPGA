----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 22.06.2023
-- Module Name: system_conv
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: 2D convolution with kernel 3x3
-- Output 1: Id matrix
-- Output 2: Gaussian filtering
-- Output 3: ?
-- Output 4: ?
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


entity System_conv is
    generic (
          filter_sel : std_logic_vector(2 downto 0) := "000"
    );
    port ( 
        clk, reset        : in std_logic;
        data_read         : in std_logic_vector(3 downto 0);
        cmd_conv          : in std_logic;
        x                 : in std_logic_vector(9 downto 0);
        out_filt_R        : out std_logic_vector(3 downto 0);
        out_filt_B        : out std_logic_vector(3 downto 0);
        out_filt_G        : out std_logic_vector(3 downto 0)
    );
end System_conv;

architecture Behavioral of System_conv is

    component buffer_module
		port(
            clk, reset        : in std_logic;
            data_in           : in std_logic_vector(3 downto 0);
            x                 : in std_logic_vector(9 downto 0);
            pixel_1, pixel_2, pixel_3, pixel_4, pixel_5,
            pixel_6, pixel_7, pixel_8, pixel_9: out std_logic_vector(3 downto 0));
	end component;

    component convolution_module
        port(
            p_1, p_2, p_3, p_4, p_5, p_6, p_7, p_8, p_9 : in std_logic_vector(3 downto 0);
            cmd_conv   : in std_logic;
            out_filt_1 : out std_logic_vector(3 downto 0);      -- Id matrix
            out_filt_2 : out std_logic_vector(3 downto 0);      -- Gaussian filter
            out_filt_3 : out std_logic_vector(3 downto 0);      -- To be defined
            out_filt_4 : out std_logic_vector(3 downto 0)       -- To be defined
        );

    end component;
         
    --Signaux internes-- 
    signal out_filt_1 : std_logic_vector(3 downto 0);
    signal out_filt_2 : std_logic_vector(3 downto 0);
    signal out_filt_3 : std_logic_vector(3 downto 0);
    signal out_filt_4 : std_logic_vector(3 downto 0);
    signal out_mux    : std_logic_vector(3 downto 0);
    signal p_1, p_2, p_3, p_4, p_5, p_6, p_7, p_8, p_9 : std_logic_vector(3 downto 0);

     
begin

    --------------------------	
    -- AFFECTATION DES SIGNAUX
    --------------------------	
    --Affectation des signaux du testbench avec ceux de l'entite buffer_module

    buffer_m : buffer_module
        port map(
            clk     => clk, 
            reset   => reset, 
			data_in => data_read, 
			x       => x,
			pixel_1 => p_1, 
			pixel_2 => p_2,
			pixel_3 => p_3, 
			pixel_4 => p_4, 
			pixel_5 => p_5, 
			pixel_6 => p_6, 
			pixel_7 => p_7,
			pixel_8 => p_8, 
			pixel_9 => p_9
        );  
			 
    --Affectation des signaux du testbench avec ceux de l'entite convolution_module
    convolution: convolution_module
        port map (
            p_1            => p_1,
            p_2            => p_2,
            p_3            => p_3,
            p_4            => p_4,
            p_5            => p_5,
            p_6            => p_6,
            p_7            => p_7,
            p_8            => p_8,
            p_9            => p_9,
            cmd_conv       => cmd_conv,
            out_filt_1     => out_filt_1,
            out_filt_2     => out_filt_2,
            out_filt_3     => out_filt_3,
            out_filt_4     => out_filt_4
        );
        
    -----------------------------------------
    -- PARTIE COMBINATOIRE : Sortie Filtre
    -----------------------------------------
        
    out_mux <=  out_filt_1 when filter_sel = "000" else
                out_filt_2 when filter_sel = "001" else
                out_filt_3 when filter_sel = "010" else
                out_filt_4;
           
    --Sortie de l'mage filtrée
    out_filt_R <= out_mux; 
    out_filt_B <= out_mux; 
    out_filt_G <= out_mux;           

                     
end Behavioral;
