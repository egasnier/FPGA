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
		p_1, p_2, p_3, p_4, p_5, p_6, p_7, p_8, p_9 : in std_logic_vector(3 downto 0);
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
    constant SIXTY            : integer := 60;
    
    signal out_sum            : std_logic_vector(7 downto 0);
	signal p_1_8b, p_2_8b, p_3_8b, p_4_8b, p_5_8b, p_6_8b, p_7_8b, p_8_8b, p_9_8b: std_logic_vector(7 downto 0);

    signal out_sob_h          : std_logic_vector(6 downto 0);
	signal p_1_sh, p_3_sh, p_4_sh, p_6_sh, p_7_sh, p_9_sh: std_logic_vector(6 downto 0);

    signal out_sob_v          : std_logic_vector(6 downto 0);
	signal p_1_sv, p_2_sv, p_3_sv, p_7_sv, p_8_sv, p_9_sv: std_logic_vector(6 downto 0);

    signal out_edge           : std_logic_vector(7 downto 0);
	signal p_1_ed, p_2_ed, p_3_ed, p_4_ed, p_5_ed, p_6_ed, p_7_ed, p_8_ed, p_9_ed: std_logic_vector(7 downto 0);


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

        -- Multiplication by 2 and completion to 8 bits
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


        -----------------------------------------
        -- PARTIE COMBINATOIRE : FILTRE SOBEL HORIZONTAL
        -----------------------------------------
        -- Completion to 8 bits
    	p_1_sh <= "000" & p_1;
    	p_3_sh <= "000" & p_3;
    	p_7_sh <= "000" & p_7;
    	p_9_sh <= "000" & p_9;

        -- Multiplication by 2 and completion to 7 bits
        p_4_sh <= "00" & p_4(3 downto 0) & "0";
        p_6_sh <= "00" & p_6(3 downto 0) & "0";

        -- Sum
        out_sob_h <= std_logic_vector(
                    unsigned(p_1_sh) + unsigned(p_4_sh) + unsigned(p_7_sh)
                    - unsigned(p_3_sh) - unsigned(p_6_sh) - unsigned(p_9_sh)
                    + SIXTY
                     );

        -- Division by 8
        out_filt_3 <= out_sob_h(6) & out_sob_h(5) & out_sob_h(4) & out_sob_h(3) when cmd_conv ='1'
                                                                        else "0000";
      
        -----------------------------------------
        -- PARTIE COMBINATOIRE : FILTRE SOBEL VERTICAL
        -----------------------------------------
        -- Completion to 8 bits
    	p_1_sv <= "000" & p_1;
    	p_3_sv <= "000" & p_3;
    	p_7_sv <= "000" & p_7;
    	p_9_sv <= "000" & p_9;

        -- Multiplication by 2 and completion to 7 bits
        p_2_sv <= "00" & p_2(3 downto 0) & "0";
        p_8_sv <= "00" & p_8(3 downto 0) & "0";

        -- Sum
        out_sob_v <= std_logic_vector(
                    unsigned(p_1_sv) + unsigned(p_2_sv) + unsigned(p_3_sv)
                    - unsigned(p_7_sv) - unsigned(p_8_sv) - unsigned(p_9_sv)
                    + SIXTY
                     );

        -- Division by 8
        out_filt_4 <= out_sob_v(6) & out_sob_v(5) & out_sob_v(4) & out_sob_v(3) when cmd_conv ='1'
                                                                        else "0000";


        -----------------------------------------
        -- PARTIE COMBINATOIRE : EDGE DETECTION
        -----------------------------------------
        -- Completion to 8 bits
    	p_1_ed <= "0000" & p_1;
    	p_2_ed <= "0000" & p_2;
    	p_3_ed <= "0000" & p_3;
    	p_4_ed <= "0000" & p_4;
    	p_6_ed <= "0000" & p_6;
    	p_7_ed <= "0000" & p_7;
    	p_8_ed <= "0000" & p_8;
    	p_9_ed <= "0000" & p_9;

        -- Multiplication by 8 and completion to 8 bits
        p_5_ed <= "0" & p_5(3 downto 0) & "000";

        -- Sum
        out_edge <= std_logic_vector(
                    unsigned(p_5_ed) + (SIXTY * 2)
                    - (unsigned(p_1_ed) + unsigned(p_2_ed) + unsigned(p_3_ed)
                       + unsigned(p_4_ed) + unsigned(p_6_ed)
                       + unsigned(p_7_ed) + unsigned(p_8_ed) + unsigned(p_9_ed)
                      )
                    );

        -- Division by 16
        out_filt_5 <= out_edge(7) & out_edge(6) & out_edge(5) & out_edge(4) when cmd_conv ='1'
                                                                        else "0000";


end arch_conv_module;
