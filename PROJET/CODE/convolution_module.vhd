----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 22.06.2023
-- Module Name: convolution_module
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

entity convolution_module is
	port(
		p_1, p_2, p_3, p_4, p_5, p_6, p_7, p_8, p_9 : in std_logic_vector(3 downto 0);
		cmd_conv   : in std_logic;
		out_filt_1 : out std_logic_vector(3 downto 0);      -- Id matrix
		out_filt_2 : out std_logic_vector(3 downto 0);      -- Gaussian filter
		out_filt_3 : out std_logic_vector(3 downto 0);      -- To be defined
		out_filt_4 : out std_logic_vector(3 downto 0)       -- To be defined
    );
end convolution_module;

architecture arch_conv_module of convolution_module is

    ----------------------------------------------
    -- SIGNAUX INTERNES PARTIE COMBINATOIRE
    ----------------------------------------------
    signal out_sum            : std_logic_vector(7 downto 0);
	signal p_1_8b, p_2_8b, p_3_8b, p_4_8b, p_5_8b, p_6_8b, p_7_8b, p_8_8b, p_9_8b: std_logic_vector(7 downto 0);


	begin

        -----------------------------------------
        -- PARTIE COMBINATOIRE : Id MATRIX
        -----------------------------------------
    	out_filt_1 <= p_5 when cmd_conv ='1'
                           else "0000";


        -----------------------------------------
        -- PARTIE COMBINATOIRE : FILTRE GAUSSIEN
        -----------------------------------------
        -- Completion to 8 bits
    	p_1_8b <= "0000" & p_1;
    	p_3_8b <= "0000" & p_3;
    	p_7_8b <= "0000" & p_7;
    	p_9_8b <= "0000" & p_9;

        -- Multiplication by 4 and completion to 8 bits
        p_2_8b <= "000" & p_2(3 downto 0) & "0";
        p_4_8b <= "000" & p_4(3 downto 0) & "0";
        p_6_8b <= "000" & p_6(3 downto 0) & "0";
        p_8_8b <= "000" & p_8(3 downto 0) & "0";

        -- Multiplication by 4 and completion to 8 bits
        p_5_8b <= "00" & p_5(3 downto 0) & "00";
        
        -- Sum
        out_sum <= std_logic_vector(
                    unsigned(p_1_8b) + unsigned(p_2_8b) + unsigned(p_3_8b) + unsigned(p_4_8b) + unsigned(p_5_8b)
                     + unsigned(p_6_8b) + unsigned(p_7_8b) + unsigned(p_8_8b) + unsigned(p_9_8b)
                     );

        -- Division by 16
        out_filt_2 <= out_sum(7) & out_sum(6) & out_sum(5) & out_sum(4) when cmd_conv ='1'
                                                                        else "0000";

      

end arch_conv_module;
