----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.06.2023 14:33:48
-- Design Name: 
-- Module Name: tb_pixel - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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

entity pixel_buffer_tb is
end pixel_buffer_tb;

architecture arch_pixel_buffer of pixel_buffer_tb is

	component pixel_buffer
        generic (
            max_buffer : integer
        ); 
		port(
			clk, reset : in std_logic;
			x          : in std_logic_vector(9 downto 0) := (others => '0');
			d_buffer   : in std_logic_vector(3 downto 0);
			q_buffer   : out std_logic_vector(3 downto 0));
	end component;
	
	signal clk: std_ulogic := '1';
	signal reset: std_logic;
	signal x: std_logic_vector(9 downto 0);
	signal d, q: std_logic_vector(3 downto 0);

    ------------------------------------------
    -- DECLARATION DES CONSTANTES
    ------------------------------------------
    -- Les constantes suivantes permettent de definir la frequence de l'horloge 
    constant hp     : time := 20 ns;             -- demi periode de 20ns
    constant period : time := 2*hp;              -- periode de 40ns, soit une frequence de 25MHz



    begin

    --------------------------	
    -- AFFECTATION DES SIGNAUX
    --------------------------	
    unit: pixel_buffer
        generic map (
            max_buffer => 797
        )
        port map(
            clk => clk,
            reset => reset,
            d_buffer => d,
            q_buffer => q,
            x => x
        );

    
    ------------------------------------------
    -- SIMULATION DE L'HORLOGE
    ------------------------------------------
    process
        begin
            wait for hp;
            clk <= not clk;
        end process;


    process

		variable rd_line: line;
		variable tmp: std_logic_vector(3 downto 0);

        file vector_file: text open read_mode is "test.txt";

        begin
        ---------------------------------------------
        -- INITIALISATION
        ---------------------------------------------
        x <= (others => '0');
        
        -- signal reset a 1
        reset <= '1';
        -- counting for 1 period
        wait for period;
        -- signal reset a 0
        reset <= '0';

            while not endfile(vector_file) loop
                readline(vector_file, rd_line);
                read(rd_line, tmp);
                d <= tmp;
                wait for period;
                x <= std_logic_vector(unsigned(x) + 1);
            end loop;

            wait;
    end process;


end arch_pixel_buffer;