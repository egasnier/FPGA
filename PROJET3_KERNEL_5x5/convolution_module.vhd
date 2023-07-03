----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 27.06.2023
-- Module Name: convolution_module
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: 2D convolution with kernel 3x3
-- Output 1: Id matrix
-- Output 2: Gaussian filtering
-- Output 3: Sobel horizontal
-- Output 4: Sobel vertical
-- Output 5: Edge detection
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
		p_1, p_2, p_3, p_4, p_5     : in std_logic_vector(3 downto 0);
		p_6, p_7, p_8, p_9, p_10    : in std_logic_vector(3 downto 0);
		p_11, p_12, p_13, p_14, p_15: in std_logic_vector(3 downto 0);
		p_16, p_17, p_18, p_19, p_20: in std_logic_vector(3 downto 0);
		p_21, p_22, p_23, p_24, p_25: in std_logic_vector(3 downto 0);
		cmd_conv   : in std_logic;
		out_filt_1 : out std_logic_vector(3 downto 0);      -- Id matrix
		out_filt_2 : out std_logic_vector(3 downto 0);      -- Gaussian filter
		out_filt_3 : out std_logic_vector(3 downto 0);      -- Sobel horizontal
		out_filt_4 : out std_logic_vector(3 downto 0);      -- Sobel vertical
		out_filt_5 : out std_logic_vector(3 downto 0)       -- Edge detection

    );
end convolution_module;

architecture arch_conv_module of convolution_module is

    ----------------------------------------------
    -- SIGNAUX INTERNES PARTIE COMBINATOIRE
    ----------------------------------------------
	signal p_1_12b, p_2_12b, p_3_12b, p_4_12b, p_5_12b     : std_logic_vector(11 downto 0);
	signal p_6_12b, p_7_12b, p_8_12b, p_9_12b, p_10_12b    : std_logic_vector(11 downto 0);
	signal p_11_12b, p_12_12b, p_13_12b, p_14_12b, p_15_12b: std_logic_vector(11 downto 0);
	signal p_16_12b, p_17_12b, p_18_12b, p_19_12b, p_20_12b: std_logic_vector(11 downto 0);
	signal p_21_12b, p_22_12b, p_23_12b, p_24_12b, p_25_12b: std_logic_vector(11 downto 0);
	
	signal out_coeff1, out_coeff4, out_coeff6, out_coeff16, out_coeff24, out_coeff36: std_logic_vector(11 downto 0);
    signal out_sum                                         : std_logic_vector(11 downto 0);


	begin

        -----------------------------------------
        -- PARTIE COMBINATOIRE : Id MATRIX
        -----------------------------------------
    	out_filt_1 <= p_13 when cmd_conv ='1'
                           else "0000";


        -----------------------------------------
        -- PARTIE COMBINATOIRE : FILTRE GAUSSIEN
        -----------------------------------------
        -- Coeff1
    	p_1_12b  <= "00000000" & p_1;
    	p_5_12b  <= "00000000" & p_5;
    	p_21_12b <= "00000000" & p_21;
    	p_25_12b <= "00000000" & p_25;
    	out_coeff1 <= std_logic_vector(
                    unsigned(p_1_12b) + unsigned(p_5_12b) + unsigned(p_21_12b) + unsigned(p_25_12b)
                     );

        -- Coeff4
        p_2_12b  <= "000000" & p_2(3 downto 0) & "00";
        p_4_12b  <= "000000" & p_4(3 downto 0) & "00";
        p_6_12b  <= "000000" & p_6(3 downto 0) & "00";
        p_10_12b <= "000000" & p_10(3 downto 0) & "00";
        p_16_12b <= "000000" & p_16(3 downto 0) & "00";
        p_20_12b <= "000000" & p_20(3 downto 0) & "00";
        p_22_12b <= "000000" & p_22(3 downto 0) & "00";
        p_24_12b <= "000000" & p_24(3 downto 0) & "00";
    	out_coeff4 <= std_logic_vector(
                    unsigned(p_2_12b) + unsigned(p_4_12b) + unsigned(p_6_12b) + unsigned(p_10_12b)
                    + unsigned(p_16_12b) + unsigned(p_20_12b) + unsigned(p_22_12b) + unsigned(p_24_12b)
                     );

        -- Coeff6
    	p_3_12b  <= std_logic_vector(
                    unsigned("000000" & p_3(3 downto 0) & "00") + unsigned("0000000" & p_3(3 downto 0) & "0")
                     );
    	p_11_12b <= std_logic_vector(
                    unsigned("000000" & p_11(3 downto 0) & "00") + unsigned("0000000" & p_11(3 downto 0) & "0")
                     );
    	p_15_12b <= std_logic_vector(
                    unsigned("000000" & p_15(3 downto 0) & "00") + unsigned("0000000" & p_15(3 downto 0) & "0")
                     );
    	p_23_12b <= std_logic_vector(
                    unsigned("000000" & p_23(3 downto 0) & "00") + unsigned("0000000" & p_23(3 downto 0) & "0")
                     );
    	out_coeff6 <= std_logic_vector(
                    unsigned(p_3_12b) + unsigned(p_11_12b) + unsigned(p_15_12b) + unsigned(p_23_12b)
                     );

        -- Coeff16
    	p_7_12b  <= "0000" & p_7(3 downto 0) & "0000";
    	p_9_12b  <= "0000" & p_9(3 downto 0) & "0000";
    	p_17_12b <= "0000" & p_17(3 downto 0) & "0000";
    	p_19_12b <= "0000" & p_19(3 downto 0) & "0000";
    	out_coeff16 <= std_logic_vector(
                    unsigned(p_7_12b) + unsigned(p_9_12b) + unsigned(p_17_12b) + unsigned(p_19_12b)
                     );

        -- Coeff24
    	p_8_12b  <= std_logic_vector(
                    unsigned("0000" & p_8(3 downto 0) & "0000") + unsigned("00000" & p_8(3 downto 0) & "000")
                     );
    	p_12_12b <= std_logic_vector(
                    unsigned("0000" & p_12(3 downto 0) & "0000") + unsigned("00000" & p_12(3 downto 0) & "000")
                     );
    	p_14_12b <= std_logic_vector(
                    unsigned("0000" & p_14(3 downto 0) & "0000") + unsigned("00000" & p_14(3 downto 0) & "000")
                     );
    	p_18_12b <= std_logic_vector(
                    unsigned("0000" & p_18(3 downto 0) & "0000") + unsigned("00000" & p_18(3 downto 0) & "000")
                     );
    	out_coeff24 <= std_logic_vector(
                    unsigned(p_8_12b) + unsigned(p_12_12b) + unsigned(p_14_12b) + unsigned(p_18_12b)
                     );


        -- Coeff36
        out_coeff36 <= std_logic_vector(
                    unsigned("000" & p_13(3 downto 0) & "00000") + unsigned("000000" & p_13(3 downto 0) & "00")
                     );
        
        -- Sum
        out_sum <= std_logic_vector(
                    unsigned(out_coeff1) + unsigned(out_coeff4) + unsigned(out_coeff6)
                     + unsigned(out_coeff16) + unsigned(out_coeff24) + unsigned(out_coeff36)
                     );

        -- Division by 256
        out_filt_2 <= out_sum(11) & out_sum(10) & out_sum(9) & out_sum(8) when cmd_conv ='1'
                                                                        else "0000";




end arch_conv_module;
