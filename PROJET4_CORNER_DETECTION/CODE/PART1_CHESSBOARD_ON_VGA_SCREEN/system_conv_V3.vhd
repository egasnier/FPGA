----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 07.07.2023
-- Module Name: system_conv_V2
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: 2D convolution with kernel 3x3
-- Output 1: Id matrix
-- Output 2: Gaussian filtering
-- Output 3: Sobel horizontal
-- Output 4: Sobel vertical
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


entity system_conv_V3 is
    generic (
        THRESHOLD         : std_logic_vector(7 downto 0) := "00010000";
        CORNER_R          : std_logic_vector(3 downto 0) := "1111";
        CORNER_B          : std_logic_vector(3 downto 0) := "0000";
        CORNER_G          : std_logic_vector(3 downto 0) := "0000"
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
end system_conv_V3;

architecture Behavioral of system_conv_V3 is


    --------------------------	
    -- DECLARATION DES SIGNAUX INTERNES
    --------------------------	
    signal out_filt_1 : std_logic_vector(3 downto 0);
    signal out_filt_2 : std_logic_vector(3 downto 0);
    signal out_filt_3 : std_logic_vector(6 downto 0);
    signal out_filt_4 : std_logic_vector(6 downto 0);
    signal out_filt_5 : std_logic_vector(3 downto 0);
    signal p_1, p_2, p_3, p_4, p_5, p_6, p_7, p_8, p_9 : std_logic_vector(3 downto 0);


    -----------------------------------------
    -- DECLARATION DES COMPOSANTS
    -----------------------------------------
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
            out_filt_3 : out std_logic_vector(6 downto 0);      -- Sobel horizontal
            out_filt_4 : out std_logic_vector(6 downto 0);      -- Sobel vertical
            out_filt_5 : out std_logic_vector(3 downto 0)       -- Edge detection
        );
    end component;


    component corner_detection
        generic (
            THRESHOLD         : std_logic_vector(7 downto 0);
            CORNER_R          : std_logic_vector(3 downto 0);
            CORNER_B          : std_logic_vector(3 downto 0);
            CORNER_G          : std_logic_vector(3 downto 0)
        );
        port(
            mat_id_in         : in std_logic_vector(3 downto 0);
            sob_h_in          : in std_logic_vector(6 downto 0);
            sob_v_in          : in std_logic_vector(6 downto 0);
            out_filt_R        : out std_logic_vector(3 downto 0);
            out_filt_B        : out std_logic_vector(3 downto 0);
            out_filt_G        : out std_logic_vector(3 downto 0)
        );
    end component;


     
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
            out_filt_4     => out_filt_4,
            out_filt_5     => out_filt_5
        );


    --Affectation des signaux du testbench avec ceux de l'entite convolution_module
    corner_detect: corner_detection
        generic map (
            THRESHOLD      => THRESHOLD,
            CORNER_R       => CORNER_R,
            CORNER_B       => CORNER_B,
            CORNER_G       => CORNER_G
        )
        port map (
            mat_id_in      => out_filt_1,
            sob_h_in       => out_filt_3,
            sob_v_in       => out_filt_4,
            out_filt_R     => out_filt_R,
            out_filt_B     => out_filt_B,
            out_filt_G     => out_filt_G
        );

        
                     
end Behavioral;
