----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: count_unit
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Testbench for component count_x
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

entity tb_count_x is
end tb_count_x;

architecture behavioral of tb_count_x is

    ------------------------------------------
    -- DECLARATION DES SIGNAUX INTERNES
    ------------------------------------------
    signal reset       : std_logic := '1';
    signal clk_25      : std_logic := '0';
    signal x           : std_logic_vector(9 downto 0);	
    signal end_count_x : std_logic;
	
	
    ------------------------------------------
    -- DECLARATION DES CONSTANTES
    ------------------------------------------
    -- Les constantes suivantes permettent de definir la frequence de l'horloge 
    constant hp           : time      := 20 ns;             -- demi periode de 20ns
    constant period       : time      := 2*hp;              -- periode de 40ns, soit une frequence de 25MHz
	
    constant H_PIX        : integer   := 640;
    constant H_FPORCH     : integer   := 16;
    constant HSYNC_SIZE   : integer   := 96;
    constant H_BPORCH     : integer   := 48;	
    constant count_max    : integer   := H_PIX + H_FPORCH + HSYNC_SIZE + H_BPORCH;    -- nombre de pixels sur une ligne (image + zone blanche)
	
    constant COUNTER_SIZE : integer := 10;     -- Nombre bits sur lequel est code le compteur x

	
    ------------------------------------------
    -- COMPOSANT A TESTER
    ------------------------------------------
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
	
	

    begin
	
    ------------------------------------------
    -- AFFECTATION DES SIGNAUX
    ------------------------------------------
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
        -- PREMIER TEST : INCREMENTATION DU COMPTEUR JUSQU'A 798                --
        --------------------------------------------------------------------------
        -- Test des valeurs de x de 0 a 798
        for i in 0 to (count_max - 2) loop
            -- Valeurs des sorties attendues
            -- x doit s'incrementer avec i
            -- end_count_x = 0
            assert i = to_integer(unsigned(x))
                report "ERROR: x incorrect" severity failure;            
            assert end_count_x = '0'
                report "ERROR: end_count_x not equals to 0" severity failure;
                
            -- Attente d'une periode
            wait for period;
        end loop;


        --------------------------------------------------------------------------
        -- DEUXIEME TEST : TEST DE LA FIN DU COMPTAGE                           --
        --------------------------------------------------------------------------
        -- Valeurs des sorties attendues
        -- x doit avoir la valeur 799
        -- end_count_x = 1
        assert x = std_logic_vector(to_unsigned(count_max - 1, COUNTER_SIZE))
            report "ERROR: x incorrect" severity failure;            
        assert end_count_x = '1'
            report "ERROR: end_count_x not equals to 0" severity failure;
                
        -- Attente d'une periode
        wait for period;


        --------------------------------------------------------------------------
        -- TROISIEME TEST : INCREMENTATION DU COMPTEUR JUSQU'A 798              --
        --------------------------------------------------------------------------
        -- Test des valeurs de x de 0 a 798
        for i in 0 to (count_max - 2) loop
            -- Valeurs des sorties attendues
            -- x doit s'incrementer avec i
            -- end_count_x = 0
            assert i = to_integer(unsigned(x))
                report "ERROR: x incorrect" severity failure;            
            assert end_count_x = '0'
                report "ERROR: end_count_x not equals to 0" severity failure;
                
            -- Attente d'une periode
            wait for period;
        end loop;


        --------------------------------------------------------------------------
        -- QUATRIEME TEST : TEST DE LA FIN DU COMPTAGE                          --
        --------------------------------------------------------------------------
        -- Valeurs des sorties attendues
        -- x doit avoir la valeur 799
        -- end_count_x = 1
        assert x = std_logic_vector(to_unsigned(count_max - 1, COUNTER_SIZE))
            report "ERROR: x incorrect" severity failure;            
        assert end_count_x = '1'
            report "ERROR: end_count_x not equals to 0" severity failure;
                
        -- Attente d'une periode
        wait for period;


        --------------------------------------------------------------------------
        -- CINQUIEME TEST : TEST DU RESET                                       --
        -- VERIFICATION QUE LE COMPTEUR EST BIEN REINITIALISE                   --
        --------------------------------------------------------------------------
        -- Incrementation de x jusqu'a 437
        for i in 0 to 437 loop
            -- Valeurs des sorties attendues
            -- x doit s'incrementer avec i
            -- end_count_x = 0
            assert i = to_integer(unsigned(x))
                report "ERROR: x incorrect" severity failure;            
            assert end_count_x = '0'
                report "ERROR: end_count_x not equals to 0" severity failure;
                
            -- Attente d'une periode
            wait for period;
        end loop;

        -- signal reset a 1
        reset <= '1';
        -- counting for 1 period
        wait for period;
        -- signal reset a 0
        reset <= '0';

        -- Test des valeurs de x de 0 a 798
        for i in 0 to (count_max - 2) loop
            -- Valeurs des sorties attendues
            -- x doit s'incrementer avec i
            -- end_count_x = 0
            assert i = to_integer(unsigned(x))
                report "ERROR: x incorrect" severity failure;            
            assert end_count_x = '0'
                report "ERROR: end_count_x not equals to 0" severity failure;
                
            -- Attente d'une periode
            wait for period;
        end loop;


        --------------------------------------------------------------------------
        -- SIXIEME TEST : TEST DE LA FIN DU COMPTAGE                           --
        --------------------------------------------------------------------------
        -- Valeurs des sorties attendues
        -- x doit avoir la valeur 799
        -- end_count_x = 1
        assert x = std_logic_vector(to_unsigned(count_max - 1, COUNTER_SIZE))
            report "ERROR: x incorrect" severity failure;            
        assert end_count_x = '1'
            report "ERROR: end_count_x not equals to 0" severity failure;
                
        -- Attente d'une periode
        wait for period;



        wait;
	   
    end process;
	
end behavioral;