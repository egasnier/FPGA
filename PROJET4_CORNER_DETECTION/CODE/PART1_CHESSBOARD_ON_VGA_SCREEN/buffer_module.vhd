----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: shift_sync
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Component buffer module
-- To extract the 9 pixels from the kernel 3x3
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
		pixel_6, pixel_7, pixel_8, pixel_9: out std_logic_vector(3 downto 0));
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
            pixel_1, pixel_2, pixel_3 : out std_logic_vector(3 downto 0));
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
    signal first_pixel_in, second_pixel_in, final_pixel: std_logic_vector(3 downto 0);
    signal first_pixel_out, second_pixel_out: std_logic_vector(3 downto 0);
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
            q        => first_pixel_in,
            pixel_1  => pixel_9,
            pixel_2  => pixel_8,
            pixel_3  => pixel_7
        );
		
        first_buffer: pixel_buffer
        port map(
            clk      => clk,
            reset    => reset,
            x        => x,
            d_buffer => first_pixel_in,
            q_buffer => first_pixel_out
        );

        middle_shift: shift_register
        port map(
            clk      => clk,
            reset    => reset,
            d        => first_pixel_out,
            q        => second_pixel_in,
            pixel_1  => pixel_6,
            pixel_2  => pixel_5,
            pixel_3  => pixel_4
        );
	
        second_buffer: pixel_buffer
        port map(
            clk      => clk,
            reset    => reset,
            x        => x,
            d_buffer => second_pixel_in,
            q_buffer => second_pixel_out
        );
	
        top_shift: shift_register
        port map(
            clk      => clk,
            reset    => reset,
            d        => second_pixel_out,
            q        => final_pixel,
            pixel_1  => pixel_3,
            pixel_2  => pixel_2,
            pixel_3  => pixel_1
        );

  
end arch_buffer_module;
