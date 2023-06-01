library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity top_PLL is
    port ( 
		clk 			   : in std_logic;     -- horloge
        resetn		       : in std_logic;     -- bouton de reset
	    out_LED0_R         : out std_logic;    -- etat de la LED0 rouge
	    out_LED0_G         : out std_logic;    -- etat de la LED0 verte
	    out_LED0_B         : out std_logic;    -- etat de la LED0 bleue
	    out_LED1_R         : out std_logic;    -- etat de la LED1 rouge
	    out_LED1_G         : out std_logic;    -- etat de la LED1 verte
	    out_LED1_B         : out std_logic     -- etat de la LED1 bleue
     );
end top_PLL;


architecture behavioral of top_PLL is

    ----------------------------------------
    -- SIGNAUX INTERNES COMPOSANT PLL
    ----------------------------------------
    signal clkA :         std_logic := '0';
    signal clkB :         std_logic := '0';
    signal locked :       std_logic := '0';
    signal lockedn :      std_logic := '0';    -- NOT(locked)


    ------------------------------------------
	-- DECLARATION DU COMPOSANT LED_driver_unit
    ------------------------------------------
	component LEDs_2clocks
		port ( 
		   clkA			    : in std_logic;
		   clkB			    : in std_logic;
		   resetn           : in std_logic;
	       out_LED0_R        : out std_logic;    -- etat de la LED0 rouge
	       out_LED0_G        : out std_logic;    -- etat de la LED0 verte
	       out_LED0_B        : out std_logic;    -- etat de la LED0 bleue
	       out_LED1_R        : out std_logic;    -- etat de la LED1 rouge
	       out_LED1_G        : out std_logic;    -- etat de la LED1 verte
	       out_LED1_B        : out std_logic     -- etat de la LED1 bleue
		);
	end component;	


    ------------------------------------------
	-- DECLARATION DU COMPOSANT PLL
    ------------------------------------------
	component PLL
		port ( 
		   clk_in1			: in std_logic;
		   reset            : in std_logic;
		   clk_out1			: out std_logic; 
		   clk_out2			: out std_logic;
		   locked           : out std_logic
		);
    end component;


	begin
	

    --------------------------	
	-- AFFECTATION DES SIGNAUX
    --------------------------	
	--Affectation des signaux du composant LEDs_2clocks
	mapping_LEDs_2clocks: LEDs_2clocks
        port map (
           clkA => clkA,
           clkB => clkB,
           resetn => lockedn,
           out_LED0_R => out_LED0_R,
           out_LED0_G => out_LED0_G,
           out_LED0_B => out_LED0_B,
           out_LED1_R => out_LED1_R,
           out_LED1_G => out_LED1_G,
           out_LED1_B => out_LED1_B
        );
  	

	--Affectation des signaux du module PLL
	mapping_PLL: PLL
        port map (
		   clk_in1 => clk,
		   reset => resetn,
		   clk_out1 => clkB, 
		   clk_out2 => clkA,
		   locked => locked
        );


    ------------------------------------------
	-- PARTIE COMBINATOIRE
    ------------------------------------------
    lockedn <= NOT(locked);

end behavioral;