----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 03.07.2023
-- Module Name: shift_register
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Component shift register
-- Buffer with 5 pixels
-- 
-- Dependencies: Pmod VGA (digilent)
-- 
-- Revision:
-- Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity shift_register is
	port(
		clk, reset: in std_logic;
		d: in std_logic_vector(3 downto 0);
		q: out std_logic_vector(3 downto 0);
		pixel_1, pixel_2, pixel_3, pixel_4, pixel_5: out std_logic_vector(3 downto 0));	
end shift_register;

architecture arch_shift_register of shift_register is
	signal r_reg_0: std_logic_vector(4 downto 0);
	signal r_next_0: std_logic_vector(4 downto 0);
	
	signal r_reg_1: std_logic_vector(4 downto 0);
	signal r_next_1: std_logic_vector(4 downto 0);
	
	signal r_reg_2: std_logic_vector(4 downto 0);
	signal r_next_2: std_logic_vector(4 downto 0);

	signal r_reg_3: std_logic_vector(4 downto 0);
	signal r_next_3: std_logic_vector(4 downto 0);


	begin
	--Register
	process(clk, reset)
		begin
		if(reset = '1') then
			r_reg_0 <= (others => '0');
			r_reg_1 <= (others => '0');
			r_reg_2 <= (others => '0');
			r_reg_3 <= (others => '0');

		elsif(rising_edge(clk)) then
			r_reg_0 <= r_next_0;
			r_reg_1 <= r_next_1;
			r_reg_2 <= r_next_2;
			r_reg_3 <= r_next_3;
		end if;
	end process;
	
	--Next state logic
	r_next_0 <= d(0) & r_reg_0(4 downto 1);
	r_next_1 <= d(1) & r_reg_1(4 downto 1);
	r_next_2 <= d(2) & r_reg_2(4 downto 1);
	r_next_3 <= d(3) & r_reg_3(4 downto 1);

	--Output logic
	q(0) <= r_reg_0(0);
	q(1) <= r_reg_1(0);
	q(2) <= r_reg_2(0);
	q(3) <= r_reg_3(0);

	pixel_1 <= r_reg_3(4) & r_reg_2(4) & r_reg_1(4) & r_reg_0(4);
	pixel_2 <= r_reg_3(3) & r_reg_2(3) & r_reg_1(3) & r_reg_0(3);
	pixel_3 <= r_reg_3(2) & r_reg_2(2) & r_reg_1(2) & r_reg_0(2);
	pixel_4 <= r_reg_3(1) & r_reg_2(1) & r_reg_1(1) & r_reg_0(1);
	pixel_5 <= r_reg_3(0) & r_reg_2(0) & r_reg_1(0) & r_reg_0(0);

end arch_shift_register;
