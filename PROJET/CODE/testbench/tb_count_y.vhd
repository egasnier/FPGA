----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: count_unit
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Testbench for component count_y
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

entity tb_count_y is
end tb_count_y;

architecture behavioral of tb_count_y is

    ------------------------------------------
    -- DECLARATION DES SIGNAUX INTERNES
    ------------------------------------------
    signal reset       : std_logic := '1';
    signal clk_25      : std_logic := '0';
    signal x           : std_logic_vector(9 downto 0);	
    signal end_count_x : std_logic;
    signal y           : std_logic_vector(9 downto 0);	
    signal end_count_y : std_logic;
	
    ------------------------------------------
    -- DECLARATION DES CONSTANTES
    ------------------------------------------
    constant hp : time := 20 ns;             -- demi periode de 20ns
    constant period : time := 2*hp;          -- periode de 40ns, soit une frequence de 25MHz

    constant H_PIX       : integer   := 640;
    constant H_FPORCH    : integer   := 16;
    constant HSYNC_SIZE  : integer   := 96;
    constant H_BPORCH    : integer   := 48;	
    constant count_max_x : integer   := H_PIX + H_FPORCH + HSYNC_SIZE + H_BPORCH;    -- nombre de pixels sur une ligne (image + zone blanche)

    constant V_PIX       : integer   := 480;
    constant V_FPORCH    : integer   := 10;
    constant VSYNC_SIZE  : integer   := 2;
    constant V_BPORCH    : integer   := 33;	
    constant count_max_y : integer   := V_PIX + V_FPORCH + VSYNC_SIZE + V_BPORCH;    -- nombre de pixels sur une colonne (image + zone blanche)
	
    constant COUNTER_SIZE : integer  := 10;     -- Nombre bits sur lequel est code le compteur x


    ------------------------------------------
    -- DECLARATION DES COMPOSANTS
    ------------------------------------------
    --Declaration de l'entite count_x
    component count_x
        generic(
            H_PIX           : integer;
            H_FPORCH        : integer;
            HSYNC_SIZE      : integer;
            H_BPORCH        : integer
        );
        port ( 
            clk_25          : in std_logic;
            reset           : in std_logic; 
            x        	    : out std_logic_vector(9 downto 0);
            end_count_x	    : out std_logic
        );
    end component;

	
    --Declaration de l'entite count_y
    component count_y 
        generic(
            V_PIX           : integer;
            V_FPORCH        : integer;
            VSYNC_SIZE      : integer;
            V_BPORCH        : integer
        );
        port ( 
            clk_25          : in std_logic;
            reset           : in std_logic; 
            end_count_x	    : in std_logic;
            y        	    : out std_logic_vector(9 downto 0);
            end_count_y	    : out std_logic
        );
    end component;
	
	

    begin
	
    ------------------------------------------
    -- AFFECTATION DES SIGNAUX
    ------------------------------------------
    --Affectation des signaux du testbench avec ceux de l'entite count_x
    mapping_count_x: count_x
        generic map(
            H_PIX       => H_PIX,
            H_FPORCH    => H_FPORCH,
            HSYNC_SIZE  => HSYNC_SIZE,
            H_BPORCH    => H_BPORCH
        )
        port map (
            clk_25      => clk_25,
            reset       => reset,
            x           => x,
            end_count_x => end_count_x
        );

    --Affectation des signaux du testbench avec ceux de l'entite count_y
    mapping_count_y: count_y
        generic map(
            V_PIX       => V_PIX,
            V_FPORCH    => V_FPORCH,
            VSYNC_SIZE  => VSYNC_SIZE,
            V_BPORCH    => V_BPORCH
        )
        port map (
            clk_25      => clk_25,
            reset       => reset,
            end_count_x => end_count_x,
            y           => y,
            end_count_y => end_count_y
        );
		
    ------------------------------------------
    -- SIMULATION DE L'HORLOGE
    ------------------------------------------
    process
    begin
        wait for hp;
        clk_25 <= not clk_25;
    end process;


    process
    begin
        ---------------------------------------------
        -- INITIALISATION
        ---------------------------------------------
        -- counting for 2 periods - Waiting before reset
        wait for (2 * period);
        -- signal reset a 1
        reset <= '1';
        -- counting for 1 period
        wait for period;
        -- signal reset a 0
        reset <= '0';


        --------------------------------------------------------------------------
        -- PREMIER TEST : INCREMENTATION DU COMPTEUR y JUSQU'A 523              --
        -- LA VALEUR DE y S'INCREMENTE                                          --
        -- end_count_y RESTE A 0                                                --
        --------------------------------------------------------------------------
        -- Balayage de y de 0 a 523
        for j in 0 to (count_max_y - 2) loop
            -- Balayage de x de 0 a 799
            for i in 0 to (count_max_x - 1) loop
                -- Valeurs des sorties attendues
                -- y s'incremente
                -- end_count_y = 0
                assert j = to_integer(unsigned(y))
                    report "ERROR: y incorrect" severity failure;            
                assert end_count_y = '0'
                    report "ERROR: end_count_y not equals to 0" severity failure;
                
                -- Attente d'une periode
                wait for period;
            end loop;
        end loop;


        --------------------------------------------------------------------------
        -- DEUXIEME TEST : CHANGEMENT D'IMAGE                                   --
        -- Y VAUT 524 SUR LA DERNIERE LIGNE                                     --
        -- end_count_y PASSE A 1 A LA FIN DE LA DERNIERE LIGNE                  --
        --------------------------------------------------------------------------
        -- Balayage de x de 0 a 798
        for i in 0 to (count_max_x - 2) loop
            -- Valeurs des sorties attendues
            -- y = 524
            -- end_count_y = 0
            assert y = std_logic_vector(to_unsigned(count_max_y - 1, COUNTER_SIZE))
                report "ERROR: y incorrect" severity failure;            
            assert end_count_y = '0'
                report "ERROR: end_count_y not equals to 0" severity failure;
                
            -- Attente d'une periode
            wait for period;
        end loop;


        -- Valeurs des sorties attendues
        -- y = 524
        -- end_count_y = 1
        assert y = std_logic_vector(to_unsigned(count_max_y - 1, COUNTER_SIZE))
            report "ERROR: y incorrect" severity failure;            
        assert end_count_y = '1'
            report "ERROR: end_count_y not equals to 1" severity failure;
                
        -- Attente d'une periode
        wait for period;
            

            
        --------------------------------------------------------------------------
        -- TROISIEME TEST : INCREMENTATION DU COMPTEUR y JUSQU'A 523            --
        -- LA VALEUR DE y S'INCREMENTE                                          --
        -- end_count_y RESTE A 0                                                --
        --------------------------------------------------------------------------
        -- Balayage de y de 0 a 523
        for j in 0 to (count_max_y - 2) loop
            -- Balayage de x de 0 a 799
            for i in 0 to (count_max_x - 1) loop
                -- Valeurs des sorties attendues
                -- y s'incremente
                -- end_count_y = 0
                assert j = to_integer(unsigned(y))
                    report "ERROR: y incorrect" severity failure;            
                assert end_count_y = '0'
                    report "ERROR: end_count_y not equals to 0" severity failure;
                
                -- Attente d'une periode
                wait for period;
            end loop;
        end loop;


        --------------------------------------------------------------------------
        -- QUATRIEME TEST : CHANGEMENT D'IMAGE                                  --
        -- Y VAUT 524 SUR LA DERNIERE LIGNE                                     --
        -- end_count_y PASSE A 1 A LA FIN DE LA DERNIERE LIGNE                  --
        --------------------------------------------------------------------------
        -- Balayage de x de 0 a 798
        for i in 0 to (count_max_x - 2) loop
            -- Valeurs des sorties attendues
            -- y = 524
            -- end_count_y = 0
            assert y = std_logic_vector(to_unsigned(count_max_y - 1, COUNTER_SIZE))
                report "ERROR: y incorrect" severity failure;            
            assert end_count_y = '0'
                report "ERROR: end_count_y not equals to 0" severity failure;
                
            -- Attente d'une periode
            wait for period;
        end loop;


        -- Valeurs des sorties attendues
        -- y = 524
        -- end_count_y = 1
        assert y = std_logic_vector(to_unsigned(count_max_y - 1, COUNTER_SIZE))
            report "ERROR: y incorrect" severity failure;            
        assert end_count_y = '1'
            report "ERROR: end_count_y not equals to 1" severity failure;
                
        -- Attente d'une periode
        wait for period;



        --------------------------------------------------------------------------
        -- CINQUIEME TEST : TEST DU RESET                                       --
        -- VERIFICATION QUE LE COMPTEUR EST BIEN REINITIALISE                   --
        --------------------------------------------------------------------------
        -- Balayage de y de 0 a 243
        for j in 0 to 243 loop
            -- Balayage de x de 0 a 799
            for i in 0 to (count_max_x - 1) loop
                -- Valeurs des sorties attendues
                -- y s'incremente
                -- end_count_y = 0
                assert j = to_integer(unsigned(y))
                    report "ERROR: y incorrect" severity failure;            
                assert end_count_y = '0'
                    report "ERROR: end_count_y not equals to 0" severity failure;
                
                -- Attente d'une periode
                wait for period;
            end loop;
        end loop;
        
        -- Balayage de x de 0 a 517
        for i in 0 to 517 loop
            -- Valeurs des sorties attendues
            -- y = 244
            -- end_count_y = 0
            assert y = std_logic_vector(to_unsigned(244, COUNTER_SIZE))
                report "ERROR: y incorrect" severity failure;            
            assert end_count_y = '0'
                report "ERROR: end_count_y not equals to 0" severity failure;
                
            -- Attente d'une periode
            wait for period;
        end loop;        


        -- signal reset a 1
        reset <= '1';
        -- counting for 1 period
        wait for period;
        -- signal reset a 0
        reset <= '0';

        
        -- Balayage de y de 0 a 523
        for j in 0 to (count_max_y - 2) loop
            -- Balayage de x de 0 a 799
            for i in 0 to (count_max_x - 1) loop
                -- Valeurs des sorties attendues
                -- y s'incremente
                -- end_count_y = 0
                assert j = to_integer(unsigned(y))
                    report "ERROR: y incorrect" severity failure;            
                assert end_count_y = '0'
                    report "ERROR: end_count_y not equals to 0" severity failure;
                
                -- Attente d'une periode
                wait for period;
            end loop;
        end loop;


        --------------------------------------------------------------------------
        -- SIXIEME TEST : CHANGEMENT D'IMAGE                                    --
        -- Y VAUT 524 SUR LA DERNIERE LIGNE                                     --
        -- end_count_y PASSE A 1 A LA FIN DE LA DERNIERE LIGNE                  --
        --------------------------------------------------------------------------
        -- Balayage de x de 0 a 798
        for i in 0 to (count_max_x - 2) loop
            -- Valeurs des sorties attendues
            -- y = 524
            -- end_count_y = 0
            assert y = std_logic_vector(to_unsigned(count_max_y - 1, COUNTER_SIZE))
                report "ERROR: y incorrect" severity failure;            
            assert end_count_y = '0'
                report "ERROR: end_count_y not equals to 0" severity failure;
                
            -- Attente d'une periode
            wait for period;
        end loop;


        -- Valeurs des sorties attendues
        -- y = 524
        -- end_count_y = 1
        assert y = std_logic_vector(to_unsigned(count_max_y - 1, COUNTER_SIZE))
            report "ERROR: y incorrect" severity failure;            
        assert end_count_y = '1'
            report "ERROR: end_count_y not equals to 1" severity failure;
                
        -- Attente d'une periode
        wait for period;

        wait;
	   
    end process;
	
end behavioral;