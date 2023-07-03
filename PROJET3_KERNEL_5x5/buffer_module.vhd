----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 03.07.2023
-- Module Name: buffer_module
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Component buffer module
-- To extract the 25 pixels from the kernel 5x5
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

entity buffer_module is
	port(
		clk, reset        : in std_logic;
		data_in           : in std_logic_vector(3 downto 0);
		x                 : in std_logic_vector(9 downto 0);
		pixel_1, pixel_2, pixel_3, pixel_4, pixel_5,
		pixel_6, pixel_7, pixel_8, pixel_9, pixel_10,
		pixel_11, pixel_12, pixel_13, pixel_14, pixel_15,
		pixel_16, pixel_17, pixel_18, pixel_19, pixel_20,
		pixel_21, pixel_22, pixel_23, pixel_24, pixel_25: out std_logic_vector(3 downto 0)
		);
end buffer_module;

architecture arch_buffer_module of buffer_module is

    ------------------------------------------
    -- DECLARATION DES COMPOSANTS shift_register ET pixel_buffer
    ------------------------------------------
	component shift_register
        port(
            clk, reset                : in std_logic;
            d                         : in std_logic_vector(3 downto 0);
            q                         : out std_logic_vector(3 downto 0);
            pixel_1, pixel_2, pixel_3, pixel_4, pixel_5 : out std_logic_vector(3 downto 0));
    end component;

    component pixel_buffer
        port(
            clk, reset : in std_logic;
            x          : in std_logic_vector(9 downto 0);
            d_buffer   : in std_logic_vector(3 downto 0);
            q_buffer   : out std_logic_vector(3 downto 0));
    end component;

    ----------------------------------------------
    -- SIGNAUX INTERNES FIFO
    ----------------------------------------------
    signal first_pix_in, sec_pix_in, third_pix_in, fourth_pix_in, final_pix: std_logic_vector(3 downto 0);
    signal first_pix_out, sec_pix_out, third_pix_out, fourth_pix_out       : std_logic_vector(3 downto 0);
    signal image_width_add: std_logic_vector(12 downto 0);
		
    begin

    -----------------------------------------------------------------------------	
    -- AFFECTATION DES SIGNAUX
    ------------------------------------------------------------------------------	
        bottom_shift: shift_register
        port map(
            clk      => clk,
            reset    => reset,
            d        => data_in,
            q        => first_pix_in,
            pixel_1  => pixel_25,
            pixel_2  => pixel_24,
            pixel_3  => pixel_23,
            pixel_4  => pixel_22,
            pixel_5  => pixel_21
        );
		
        first_buffer: pixel_buffer
        port map(
            clk      => clk,
            reset    => reset,
            x        => x,
            d_buffer => first_pix_in,
            q_buffer => first_pix_out
        );

        middle1_shift: shift_register
        port map(
            clk      => clk,
            reset    => reset,
            d        => first_pix_out,
            q        => sec_pix_in,
            pixel_1  => pixel_20,
            pixel_2  => pixel_19,
            pixel_3  => pixel_18,
            pixel_4  => pixel_17,
            pixel_5  => pixel_16
        );
	
        second_buffer: pixel_buffer
        port map(
            clk      => clk,
            reset    => reset,
            x        => x,
            d_buffer => sec_pix_in,
            q_buffer => sec_pix_out
        );
	
        middle2_shift: shift_register
        port map(
            clk      => clk,
            reset    => reset,
            d        => sec_pix_out,
            q        => third_pix_in,
            pixel_1  => pixel_15,
            pixel_2  => pixel_14,
            pixel_3  => pixel_13,
            pixel_4  => pixel_12,
            pixel_5  => pixel_11
        );
	
        third_buffer: pixel_buffer
        port map(
            clk      => clk,
            reset    => reset,
            x        => x,
            d_buffer => third_pix_in,
            q_buffer => third_pix_out
        );

        middle3_shift: shift_register
        port map(
            clk      => clk,
            reset    => reset,
            d        => third_pix_out,
            q        => fourth_pix_in,
            pixel_1  => pixel_10,
            pixel_2  => pixel_9,
            pixel_3  => pixel_8,
            pixel_4  => pixel_7,
            pixel_5  => pixel_6
        );
	
        fourth_buffer: pixel_buffer
        port map(
            clk      => clk,
            reset    => reset,
            x        => x,
            d_buffer => fourth_pix_in,
            q_buffer => fourth_pix_out
        );

        top_shift: shift_register
        port map(
            clk      => clk,
            reset    => reset,
            d        => fourth_pix_out,
            q        => final_pix,
            pixel_1  => pixel_5,
            pixel_2  => pixel_4,
            pixel_3  => pixel_3,
            pixel_4  => pixel_2,
            pixel_5  => pixel_1
        );

  
end arch_buffer_module;
