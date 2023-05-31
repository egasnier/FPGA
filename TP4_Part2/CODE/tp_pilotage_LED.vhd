library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity tp_pilotage_LED is
    port ( 
		clk			      : in std_logic;     -- horloge 
        resetn		      : in std_logic;     -- bouton de reset
        bouton_0		  : in std_logic;     -- bouton autorisant la mise a jour de la couleur
        bouton_1		  : in std_logic;     -- bouton pilotant la couleur (verte si 1, bleue si 0) 
	    out_LED_G         : out std_logic;    -- etat de la LED verte
	    out_LED_B         : out std_logic     -- etat de la LED bleue
     );
end tp_pilotage_LED;


architecture behavioral of tp_pilotage_LED is

    signal end_cycle : std_logic;    

    -- Signaux internes pour la gestion de la couleur
    signal color_btn1 :     std_logic_vector (1 downto 0) := "11";  -- Couleur de la LED en entree de FIFO
    signal color_code :     std_logic_vector (1 downto 0) := "11";  -- Couleur de la LED en sortie de FIFO
    signal bouton_0_reg1 :  std_logic := '0';                       -- Signal bouton_0 apr�s le premier registre
    signal bouton_0_reg2 :  std_logic := '0';                       -- Signal bouton_0 apr�s le second registre
    signal update :         std_logic := '0';                       -- signal autorisant la mise a jour de la couleur
    
    
	--Declaration de l'entite LED_driver_unit
	component LED_driver_unit
		port ( 
		   clk			    : in std_logic;
		   resetn           : in std_logic := '0';
           update		    : in std_logic := '1';     -- signal autorisant la mise a jour de la couleur, maintenu a 1 dans le LED_driver
           color_code		: in std_logic_vector (1 downto 0) := "11";     -- couleur de LED
	       out_LED_R        : out std_logic;    -- etat de la LED rouge
	       out_LED_G        : out std_logic;    -- etat de la LED verte
	       out_LED_B        : out std_logic;    -- etat de la LED bleue
	       end_cycle        : out std_logic     -- fin de cycle
		);
	end component;	

	component FIFO_color
		port ( 
		   clk			    : in std_logic;
		   srst             : in std_logic := '0';
           wr_en            : in std_logic := '0';    -- signal autorisant la mise a jour de la couleur
           din              : in std_logic_vector(1 downto 0) := "11";
           rd_en            : in std_logic := '0';    -- signal autorisant la lecture de la couleur
	       dout             : out std_logic_vector(1 downto 0)
		);
	end component;

	begin
	
	--Affectation des signaux du compteur de cycle avec ceux de counter_unit
	mapping_LED_driver: LED_driver_unit
        port map (
           clk => clk,
           resetn => resetn,
           update => '1',
           color_code => color_code,
           out_LED_G => out_LED_G,
           out_LED_B => out_LED_B,
           end_cycle => end_cycle
        );
	
	--Affectation des signaux avec ceux de la FIFO
	mapping_FIFO: FIFO_color
        port map (
           clk => clk,
           srst => resetn,
           wr_en => update,
           din => color_btn1,
           rd_en => end_cycle,
           dout => color_code
        );


		-- PARTIE SEQUENTIELLE	
		process(clk, resetn)
		begin
            if resetn = '1' then
                bouton_0_reg1 <= '0';
                bouton_0_reg2 <= '0';
 
			elsif rising_edge(clk) then
			    -- Gestion du bouton_0: registres
			    bouton_0_reg2 <= bouton_0_reg1;
			    bouton_0_reg1 <= bouton_0;
			    
            end if;
		end process;

		-- PARTIE COMBINATOIRE
		-- Gestion du bouton_1: s'il est appuy�, couleur verte, sinon bleue.
		color_btn1 <= "10" when bouton_1 = '1'
		else "11";
		
		-- Gestion du bouton_0: s'il est appuy�, le signal update prend la valeur '1' le temps d'un cop d'horloge.
		update <= '1' when (bouton_0_reg1 = '1') AND NOT(bouton_0_reg2 = '1')
		else '0';
		

end behavioral;