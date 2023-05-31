library ieee;
use ieee.std_logic_1164.all;


entity full_adder is

	Port ( 
		--Exemple d'entrees
		A 	: in std_logic;
		B 	: in std_logic;
		Cin : in std_logic;
		
		--Exemple de sorties
		S 	: out std_logic;
		Cout: out std_logic
	);

end full_adder;

 

architecture behavior of full_adder is
 
begin

        S <= (A xor B) xor Cin;
        Cout <= (A AND B) OR ((A XOR B) and Cin);

end behavior;

