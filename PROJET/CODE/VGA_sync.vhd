library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity VGA_sync is
    port ( 
        clk_25         : in std_logic;                         -- Horloge
        reset          : in std_logic;                         -- Entrée pour RESET des registres
        hsync          : out std_logic;                        -- Synchronization horizontale
        vsync          : out std_logic;                        -- Synchronization verticale
        x              : out std_logic_vector(9 downto 0);
        y              : out std_logic_vector(9 downto 0);
        in_display     : out std_logic                         -- A 1 si le pixel est dans l'image
     );
end VGA_sync;

architecture behavioral of VGA_sync is


    ------------------------------------------
	-- DECLARATION DES CONSTANTES
    ------------------------------------------
    constant H_PIX        : integer := 640;
    constant V_PIX        : integer := 480;
    constant H_FPORCH     : integer := 16;
    constant H_BPORCH     : integer := 48;
    constant V_FPORCH     : integer := 10;
    constant V_BPORCH     : integer := 33;
    constant HSYNC_SIZE   : integer := 96;
    constant VSYNC_SIZE   : integer := 2;
    
    
    	
    ----------------------------------------------
    -- SIGNAUX INTERNES DES COMPTEURS
    ----------------------------------------------
    signal x1           : std_logic_vector(9 downto 0);	
    signal end_count_x  : std_logic;
    signal y1           : std_logic_vector(9 downto 0);	
    signal end_count_y  : std_logic;
	
		
    ------------------------------------------
	-- DECLARATION DES COMPOSANTS
    ------------------------------------------	
	--Declaration de l'entite count_x
	component count_x
		port ( 
			clk_25          : in std_logic;
			reset           : in std_logic; 
			x               : out std_logic_vector(9 downto 0);
			end_count_x     : out std_logic
		 );
	end component;


	--Declaration de l'entite count_y
	component count_y 
		port ( 
			clk_25          : in std_logic;
			reset           : in std_logic; 
			end_count_x     : in std_logic;
			y               : out std_logic_vector(9 downto 0);
			end_count_y     : out std_logic
		 );
	end component;	
	

	begin
	
	--Affectation des signaux du testbench avec ceux de l'entite count_x
	mapping_count_x: count_x
        port map (
            clk_25      => clk_25,
            reset       => reset,
            x           => x1,
            end_count_x => end_count_x
        );


	--Affectation des signaux du testbench avec ceux de l'entite count_y
	mapping_count_y: count_y
        port map (
            clk_25      => clk_25,
            reset       => reset,
            end_count_x => end_count_x,
            y           => y1,
            end_count_y => end_count_y
        );


        ----------------------
		-- PARTIE COMBINATOIRE
        ----------------------
		-- Signal de synchro horizontale
		hsync <= '0' when (x1 >= (H_PIX + H_FPORCH)) AND (x1 < (H_PIX + H_FPORCH + HSYNC_SIZE))
				else '1';
		
		-- Signal de synchro verticale
		vsync <= '0' when (y1 >= (V_PIX + V_FPORCH)) AND (y1 < (V_PIX + V_FPORCH + VSYNC_SIZE))
				else '1';

		-- Signal in_display a 1 lorsque le pixel est dans l'image
		in_display  <= '1' when (x1 < H_PIX) and (y1 < V_PIX)
				else '0';

        --Affectation de X et Y 
		x <= x1;
		y <= y1;
		
		
end behavioral;