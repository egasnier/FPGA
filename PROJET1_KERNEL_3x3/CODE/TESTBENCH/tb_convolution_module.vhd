----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: tb_VGA_sync
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Testbench for component shift_sync
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


entity tb_conv_module is
end tb_conv_module;

architecture behavioral of tb_conv_module is

    signal clk           : std_logic := '0';
    signal cmd_conv      : std_logic :='1';

    signal p_1, p_2, p_3, p_4, p_5, p_6, p_7, p_8, p_9 : std_logic_vector(3 downto 0) := "0000";
    signal out_filt_1 : std_logic_vector(3 downto 0);      -- Id matrix
    signal out_filt_2 : std_logic_vector(3 downto 0);      -- Gaussian filter
    signal out_filt_3 : std_logic_vector(3 downto 0);      -- ??? filter
    signal out_filt_4 : std_logic_vector(3 downto 0);      -- ??? filter

    ------------------------------------------
    -- DECLARATION DES CONSTANTES
    ------------------------------------------
    -- Les constantes suivantes permettent de definir la frequence de l'horloge 
    constant hp     : time := 20 ns;             -- demi periode de 20ns
    constant period : time := 2*hp;              -- periode de 40ns, soit une frequence de 25MHz


    ------------------------------------------
    -- DECLARATION DU COMPOSANT convolution_module
    ------------------------------------------
    component convolution_module
        port ( 
            p_1, p_2, p_3, p_4, p_5, p_6, p_7, p_8, p_9 : in std_logic_vector(3 downto 0);
            cmd_conv   : in std_logic;
            out_filt_1 : out std_logic_vector(3 downto 0);      -- Id matrix
            out_filt_2 : out std_logic_vector(3 downto 0);      -- Gaussian filter
            out_filt_3 : out std_logic_vector(3 downto 0);      -- To be defined
            out_filt_4 : out std_logic_vector(3 downto 0)       -- To be defined
        );
	end component;


	begin
	
    --------------------------	
    -- AFFECTATION DES SIGNAUX
    --------------------------	
    --Affectation des signaux du testbench avec ceux de l'entite convolution_module
    mapping_convolution_module: convolution_module
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


    ------------------------------------------
    -- SIMULATION DE L'HORLOGE
    ------------------------------------------
    process
    begin
        wait for hp;
        clk <= not clk;
    end process;


	process
	begin

        ---------------------------------------------
        -- TESTS OF FEW VALUES
        ---------------------------------------------
        wait for period;


        p_1 <= "0000";
        p_2 <= "0000";
        p_3 <= "0000";
        p_4 <= "0000";
        p_5 <= "0000";
        p_6 <= "0000";
        p_7 <= "0000";
        p_8 <= "0000";
        p_9 <= "0000";
        assert out_filt_1 = "0000"
            report "ERROR: out_filt_1 incorrect" severity failure;
        assert out_filt_2 = "0000"
            report "ERROR: out_filt_2 incorrect" severity failure;


        wait for period;


        p_1 <= "0000";
        p_2 <= "0000";
        p_3 <= "0000";
        p_4 <= "0000";
        p_5 <= "1111";
        p_6 <= "0000";
        p_7 <= "0000";
        p_8 <= "0000";
        p_9 <= "0000";


        wait for period;


        assert out_filt_1 = "1111"
            report "ERROR: out_filt_1 incorrect" severity failure;
        assert out_filt_2 = "0011"
            report "ERROR: out_filt_2 incorrect" severity failure;


        wait for period;


        p_1 <= "1111";
        p_2 <= "1111";
        p_3 <= "1111";
        p_4 <= "1111";
        p_5 <= "1111";
        p_6 <= "1111";
        p_7 <= "1111";
        p_8 <= "1111";
        p_9 <= "1111";


        wait for period;


        assert out_filt_1 = "1111"
            report "ERROR: out_filt_1 incorrect" severity failure;
        assert out_filt_2 = "1111"
            report "ERROR: out_filt_2 incorrect" severity failure;


        wait for period;
        
        
        p_1 <= "1011";
        p_2 <= "1001";
        p_3 <= "1110";
        p_4 <= "0111";
        p_5 <= "1110";
        p_6 <= "0011";
        p_7 <= "1101";
        p_8 <= "1011";
        p_9 <= "1110";


        wait for period;


        assert out_filt_1 = "1110"
            report "ERROR: out_filt_1 incorrect" severity failure;
        assert out_filt_2 = "1010"
            report "ERROR: out_filt_2 incorrect" severity failure;


        wait for period;


        p_1 <= "1111";
        p_2 <= "0000";
        p_3 <= "1111";
        p_4 <= "0000";
        p_5 <= "1111";
        p_6 <= "0000";
        p_7 <= "1111";
        p_8 <= "0000";
        p_9 <= "1111";


        wait for period;


        assert out_filt_1 = "1111"
            report "ERROR: out_filt_1 incorrect" severity failure;
        assert out_filt_2 = "0111"
            report "ERROR: out_filt_2 incorrect" severity failure;


        wait for period;


        p_1 <= "0000";
        p_2 <= "1111";
        p_3 <= "0000";
        p_4 <= "1111";
        p_5 <= "0010";
        p_6 <= "1111";
        p_7 <= "0000";
        p_8 <= "1111";
        p_9 <= "0000";


        wait for period;


        assert out_filt_1 = "0010"
            report "ERROR: out_filt_1 incorrect" severity failure;
        assert out_filt_2 = "1000"
            report "ERROR: out_filt_2 incorrect" severity failure;


        wait;
	   
    end process;
	
end behavioral;