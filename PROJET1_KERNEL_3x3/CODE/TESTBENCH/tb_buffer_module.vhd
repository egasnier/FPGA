----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.06.2023 14:30:25
-- Design Name: 
-- Module Name: tb_buffer_module - Behavioral
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

entity buffer_module_tb is
end buffer_module_tb;

architecture arch_buffer_module_tb of buffer_module_tb is


	component buffer_module
		port(
			clk, reset: in std_logic;
			data_in: in std_logic_vector(3 downto 0);
			x: in std_logic_vector(9 downto 0);
			pixel_1 :out std_logic_vector(3 downto 0);
			pixel_2: out std_logic_vector(3 downto 0);
			pixel_3, pixel_4, pixel_5:out std_logic_vector(3 downto 0);
			pixel_6, pixel_7, pixel_8, pixel_9: out std_logic_vector(3 downto 0));
	end component;

	
    signal clk   : std_ulogic                   := '1';
    signal reset : std_logic                    :='1';
    signal x     : std_logic_vector(9 downto 0) := "0000000000";
    signal d     : std_logic_vector(3 downto 0) := "0000";
    signal pixel_1, pixel_2, pixel_3, pixel_4, pixel_5,
	       pixel_6, pixel_7, pixel_8, pixel_9: std_logic_vector(3 downto 0);


    ------------------------------------------
    -- DECLARATION DES CONSTANTES
    ------------------------------------------
    -- Les constantes suivantes permettent de definir la frequence de l'horloge 
    constant hp     : time := 20 ns;             -- demi periode de 20ns
    constant period : time := 2*hp;              -- periode de 40ns, soit une frequence de 25MHz



	begin
		unit: buffer_module
		port map(
			clk => clk, 
			reset => reset, 
			data_in => d, 
			x => x, 
			pixel_1 => pixel_1, 
			pixel_2 => pixel_2,
			pixel_3 => pixel_3, 
			pixel_4 => pixel_4, 
			pixel_5 => pixel_5, 
			pixel_6 => pixel_6, 
			pixel_7 => pixel_7,
			pixel_8 => pixel_8, 
			pixel_9 => pixel_9
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
	
	

end arch_buffer_module_tb;
