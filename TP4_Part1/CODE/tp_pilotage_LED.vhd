library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity tp_pilotage_LED is
    port (
        clk               : in std_logic;     -- horloge 
        resetn            : in std_logic;     -- bouton de reset
        bouton_0          : in std_logic;     -- bouton autorisant la mise a jour de la couleur
        bouton_1          : in std_logic;     -- bouton pilotant la couleur (verte si 1, bleue si 0) 
        out_LED_G         : out std_logic;    -- etat de la LED verte
        out_LED_B         : out std_logic     -- etat de la LED bleue
    );
end tp_pilotage_LED;


architecture behavioral of tp_pilotage_LED is

    signal update        : std_logic                     := '0';   -- signal autorisant la mise a jour de la couleur
    signal color_code    : std_logic_vector (1 downto 0) := "11";  -- Couleur de la LED
    signal bouton_0_reg1 : std_logic                     := '0';   -- Signal bouton_0 après le premier registre
    signal bouton_0_reg2 : std_logic                     := '0';   -- Signal bouton_0 après le second registre
    
    
    --Declaration de l'entite LED_driver_unit
    component LED_driver_unit
        port ( 
            clk        : in std_logic;
            resetn     : in std_logic := '1';
            update     : in std_logic := '0';     -- signal autorisant la mise a jour de la couleur
            color_code : in std_logic_vector (1 downto 0) := "11";     -- couleur de LED
            out_LED_R  : out std_logic;    -- etat de la LED rouge
            out_LED_G  : out std_logic;    -- etat de la LED verte
            out_LED_B  : out std_logic     -- etat de la LED bleue
        );
    end component;	

    begin
	
    --Affectation des signaux du compteur de cycle avec ceux de counter_unit
    uut: LED_driver_unit
        port map (
            clk        => clk,
            resetn     => resetn,
            update     => update,
            color_code => color_code,
            out_LED_G  => out_LED_G,
            out_LED_B  => out_LED_B
        );
	

    -- PARTIE SEQUENTIELLE	
    process(clk, resetn)
    begin
        if resetn = '0' then
            bouton_0_reg1 <= '0';
            bouton_0_reg2 <= '0';
 
        elsif rising_edge(clk) then
--			    -- Gestion du bouton_1: s'il est appuyé, couleur verte, sinon bleue. 
--			    if bouton_1 = '1' then
--			         color_code <= "10";
--			    else
--			         color_code <= "11";
--			    end if;

            -- Gestion du bouton_0: registres
            bouton_0_reg2 <= bouton_0_reg1;
            bouton_0_reg1 <= bouton_0;
			    
        end if;
    end process;

    -- PARTIE COMBINATOIRE
    -- Gestion du bouton_1: s'il est appuyé, couleur verte, sinon bleue.
    color_code <= "10" when bouton_1 = '1'
        else "11";
		
    -- Gestion du bouton_0: s'il est appuyé, le signal update prend la valeur '1' le temps d'un cop d'horloge.
    update <= '1' when (bouton_0_reg1 = '1') AND NOT(bouton_0_reg2 = '1')
        else '0';
		

end behavioral;