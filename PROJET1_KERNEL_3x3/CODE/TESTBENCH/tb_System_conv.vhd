----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 22.06.2023
-- Module Name: tb_system_conv
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
use ieee.std_logic_textio.all;
library std;
use std.textio.all;


entity tb_System_conv is
 
end tb_System_conv;

architecture Behavioral of tb_System_conv is


    signal clk        : std_logic := '0';
    signal reset      : std_logic := '1';
    signal cmd_conv   : std_logic := '0';
    signal data_read  : std_logic_vector(3 downto 0) := "0000";
    signal x          : std_logic_vector(9 downto 0) := "0000000000";
    signal count      : integer                      := 0;
    signal out_filt_R : std_logic_vector(3 downto 0);      -- Id matrix
    signal out_filt_B : std_logic_vector(3 downto 0);      -- Gaussian filter
    signal out_filt_G : std_logic_vector(3 downto 0);      -- ??? filter
    
   ------------------------------------------
    -- DECLARATION DES CONSTANTES
    ------------------------------------------
    -- Les constantes suivantes permettent de definir la frequence de l'horloge 
    constant hp     : time := 20 ns;             -- demi periode de 20ns
    constant period : time := 2*hp;              -- periode de 40ns, soit une frequence de 25MHz
    
    
     ------------------------------------------
    -- DECLARATION DU COMPOSANT convolution_module
    ------------------------------------------
    component System_conv
         generic(
              filter_sel : std_logic_vector(2 downto 0)
               );
         port ( 
             clk, reset        : in std_logic;
             cmd_conv          : in std_logic;
	         data_read         : in std_logic_vector(3 downto 0);
	         x                 : in std_logic_vector(9 downto 0);
             out_filt_R        : out std_logic_vector(3 downto 0);
             out_filt_B        : out std_logic_vector(3 downto 0);
             out_filt_G        : out std_logic_vector(3 downto 0)
    );
	 end component;

    begin
	
    --------------------------	
    -- AFFECTATION DES SIGNAUX
    --------------------------	
    -- Affectation des signaux du testbench avec ceux de l'entite System_conv
    Systeme: System_conv
        generic map (
             filter_sel   => "001"
        )
        port map (
            clk           => clk,
            reset         => reset,
            cmd_conv      => cmd_conv,
            data_read     => data_read,
            x             => x,
            out_filt_R    => out_filt_R,
            out_filt_B    => out_filt_B,
            out_filt_G    => out_filt_G          
        );


    ------------------------------------------
    -- SIMULATION DE L'HORLOGE
    ------------------------------------------
    process
    begin
        wait for hp;
        clk <= not clk;
    end process;
     
     
    process(clk)
        variable wr_line: line;
        file out_file: text open write_mode is "result.txt";

    begin
        if( rising_edge(clk)) then
            write(wr_line, out_filt_R);
            writeline(out_file, wr_line);
        end if;
    end process;


    process
        variable rd_line: line;
        variable tmp: std_logic_vector(3 downto 0);
        file vector_file: text open read_mode is "test.txt";

    begin
        ---------------------------------------------
        -- TESTS OF 
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
            data_read <= tmp;
            wait for period;
            
            x <= std_logic_vector(unsigned(x) + 1);

            -- Initialization de cmd_conv (positionnement a 1 au bout d'une ligne
            count <= count + 1;
            if count > 800 then
                cmd_conv <= '1';
            else
                cmd_conv <= '0';
            end if;
        end loop;
           
        -- Fin de la simulation
        wait;
    end process;

end Behavioral;
