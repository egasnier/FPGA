----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: tb_VGA_sync
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Testbench for component VGA_sync
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


entity tb_VGA_sync is
end tb_VGA_sync;

architecture behavioral of tb_VGA_sync is

    signal reset       : std_logic := '1';
    signal clk_25      : std_logic := '0';
    signal hsync       : std_logic;
    signal vsync       : std_logic;
    signal x           : std_logic_vector(9 downto 0);
    signal y           : std_logic_vector(9 downto 0);
    signal end_count_x : std_logic;
    signal in_display  : std_logic;

    ------------------------------------------
    -- DECLARATION DES CONSTANTES
    ------------------------------------------
    constant H_PIX       : integer := 640;
    constant H_FPORCH    : integer := 16;
    constant HSYNC_SIZE  : integer := 96;
    constant H_BPORCH    : integer := 48;
    constant count_max_x : integer := H_PIX + H_FPORCH + HSYNC_SIZE + H_BPORCH;    -- nombre de pixels sur une ligne (image + zone blanche)
    
    constant V_PIX       : integer := 480;
    constant V_FPORCH    : integer := 10;
    constant VSYNC_SIZE  : integer := 2;
    constant V_BPORCH    : integer := 33;
    constant count_max_y : integer := V_PIX + V_FPORCH + VSYNC_SIZE + V_BPORCH;    -- nombre de pixels sur une colonne (image + zone blanche)
    	
    -- Les constantes suivantes permettent de definir la frequence de l'horloge 
    constant hp     : time := 20 ns;             -- demi periode de 20ns
    constant period : time := 2*hp;              -- periode de 40ns, soit une frequence de 25MHz


    ------------------------------------------
    -- DECLARATION DU COMPOSANT VGA_sync
    ------------------------------------------
    component VGA_sync
        generic (
            H_PIX       : integer;
            H_FPORCH    : integer;
            HSYNC_SIZE  : integer;
            H_BPORCH    : integer;
            V_PIX       : integer;
            V_FPORCH    : integer;
            VSYNC_SIZE  : integer;
            V_BPORCH    : integer
        );
        port ( 
            clk_25      : in std_logic;
            reset       : in std_logic; 
            hsync   	: out std_logic;
            vsync   	: out std_logic;
            x           : out std_logic_vector(9 downto 0);
            y           : out std_logic_vector(9 downto 0);
            end_count_x : out std_logic;
            in_display	: out std_logic
        );
	end component;


	begin
	
    --------------------------	
    -- AFFECTATION DES SIGNAUX
    --------------------------	
    --Affectation des signaux du testbench avec ceux de l'entite count_x
    mapping_VGA_sync: VGA_sync
	generic map (
            H_PIX      => H_PIX,
            H_FPORCH   => H_FPORCH, 
            HSYNC_SIZE => HSYNC_SIZE,
            H_BPORCH   => H_BPORCH,
            V_PIX      => V_PIX,
            V_FPORCH   => V_FPORCH,
            VSYNC_SIZE => VSYNC_SIZE,
            V_BPORCH   => V_BPORCH
        )
        port map (
            clk_25     => clk_25,
            reset      => reset,
            hsync      => hsync,
            vsync      => vsync,
            x          => x,
            y          => y,
            end_count_x => end_count_x,
            in_display => in_display
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
        --------------------------------------------------------------------------
        -- TEST DE 4 IMAGES
        --------------------------------------------------------------------------
        --------------------------------------------------------------------------
        for image in 0 to 4 loop
        
            --------------------------------------------------------------------------
            -- PREMIER TEST : TEST POUR LES VALEURS DE Y DANS L'IMAGE (y < V_PIX)
            -- BALAYAGE DE y DE 0 A 479
            --     BALAYAGE DE x DE 0 A 639
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 1 (dans l'image)
            --     BALAYAGE DE x DE 640 A 655
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     BALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 0 (actif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     ALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --------------------------------------------------------------------------
            
            -- BALAYAGE DE y DE 0 A 479
            for j in 0 to (V_PIX - 1) loop
            
                -- BALAYAGE DE x DE 0 A 639
                for x in 0 to (H_PIX - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 1 (dans l'image)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '1'
                        report "ERROR: in_display not equals to 1" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 640 A 655
                for x in 0 to (H_FPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 656 A 751
                for x in 0 to (HSYNC_SIZE - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 0 (actif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '0'
                        report "ERROR: hsync not equals to 0" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 752 A 799
                for x in 0 to (H_BPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
            end loop;
    
    
    
            --------------------------------------------------------------------------
            -- DEUXIEME TEST : TEST POUR LES VALEURS DE Y DANS LA ZONE BLANCHE "V_FPORCH" (V_PIX <= y < V_PIX + V_FPORCH)
            -- BALAYAGE DE y DE 480 A 489
            --     BALAYAGE DE x DE 0 A 639
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     BALAYAGE DE x DE 640 A 655
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     BALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 0 (actif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     ALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --------------------------------------------------------------------------
            
            -- BALAYAGE DE y DE 480 A 489
            for j in 0 to (V_FPORCH - 1) loop
            
                -- BALAYAGE DE x DE 0 A 639
                for x in 0 to (H_PIX - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 640 A 655
                for x in 0 to (H_FPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 656 A 751
                for x in 0 to (HSYNC_SIZE - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 0 (actif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '0'
                        report "ERROR: hsync not equals to 0" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 752 A 799
                for x in 0 to (H_BPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
            end loop;
    
    
            --------------------------------------------------------------------------
            -- TROISIEME TEST : TEST POUR LES VALEURS DE Y DANS LA ZONE BLANCHE "VSYNC_SIZE" (V_PIX + V_FPORCH <= y < V_PIX + V_FPORCH + VSYNC_SIZE)
            -- BALAYAGE DE y DE 490 A 491
            --     BALAYAGE DE x DE 0 A 639
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 0 (actif)
            --          in_display = 0 (dans la zone blanche)
            --     BALAYAGE DE x DE 640 A 655
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 0 (actif)
            --          in_display = 0 (dans la zone blanche)
            --     BALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 0 (actif)
            --          vsync = 0 (actif)
            --          in_display = 0 (dans la zone blanche)
            --     ALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 0 (actif)
            --          in_display = 0 (dans la zone blanche)
            --------------------------------------------------------------------------
            
            -- BALAYAGE DE y DE 490 A 491
            for j in 0 to (VSYNC_SIZE - 1) loop
            
                -- BALAYAGE DE x DE 0 A 639
                for x in 0 to (H_PIX - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 0 (actif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '0'
                        report "ERROR: vsync not equals to 0" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 640 A 655
                for x in 0 to (H_FPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 0 (actif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '0'
                        report "ERROR: vsync not equals to 0" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 656 A 751
                for x in 0 to (HSYNC_SIZE - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 0 (actif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '0'
                        report "ERROR: hsync not equals to 0" severity failure;            
                    assert vsync = '0'
                        report "ERROR: vsync not equals to 0" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 752 A 799
                for x in 0 to (H_BPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 0 (actif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '0'
                        report "ERROR: vsync not equals to 0" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
            end loop;
    
    
            --------------------------------------------------------------------------
            -- QUATRIEME TEST : TEST POUR LES VALEURS DE Y DANS LA ZONE BLANCHE "V_BPORCH" (V_PIX + V_FPORCH + VSYNC_SIZE <= y < V_PIX + V_FPORCH + VSYNC_SIZE + V_BPORCH)
            -- BALAYAGE DE y DE 480 A 489
            --     BALAYAGE DE x DE 0 A 639
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     BALAYAGE DE x DE 640 A 655
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     BALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 0 (actif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     ALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --------------------------------------------------------------------------
            
            -- BALAYAGE DE y DE 492 A 525
            for j in 0 to (V_BPORCH - 1) loop
            
                -- BALAYAGE DE x DE 0 A 639
                for x in 0 to (H_PIX - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 640 A 655
                for x in 0 to (H_FPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 656 A 751
                for x in 0 to (HSYNC_SIZE - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 0 (actif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '0'
                        report "ERROR: hsync not equals to 0" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 752 A 799
                for x in 0 to (H_BPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
            end loop;
            
        end loop;    





        --------------------------------------------------------------------------
        --------------------------------------------------------------------------
        -- TEST DE 4 IMAGES SUITE AU RESET
        --------------------------------------------------------------------------
        --------------------------------------------------------------------------
        -- counting for 2 periods - Waiting before reset
        wait for (145789 * period);
        -- signal reset a 1
        reset <= '1';
        -- counting for 1 period
        wait for period;
        -- signal reset a 0
        reset <= '0';

        for image in 0 to 4 loop
        
            --------------------------------------------------------------------------
            -- PREMIER TEST : TEST POUR LES VALEURS DE Y DANS L'IMAGE (y < V_PIX)
            -- BALAYAGE DE y DE 0 A 479
            --     BALAYAGE DE x DE 0 A 639
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 1 (dans l'image)
            --     BALAYAGE DE x DE 640 A 655
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     BALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 0 (actif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     ALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --------------------------------------------------------------------------
            
            -- BALAYAGE DE y DE 0 A 479
            for j in 0 to (V_PIX - 1) loop
            
                -- BALAYAGE DE x DE 0 A 639
                for x in 0 to (H_PIX - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 1 (dans l'image)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '1'
                        report "ERROR: in_display not equals to 1" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 640 A 655
                for x in 0 to (H_FPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 656 A 751
                for x in 0 to (HSYNC_SIZE - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 0 (actif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '0'
                        report "ERROR: hsync not equals to 0" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 752 A 799
                for x in 0 to (H_BPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
            end loop;
    
    
    
            --------------------------------------------------------------------------
            -- DEUXIEME TEST : TEST POUR LES VALEURS DE Y DANS LA ZONE BLANCHE "V_FPORCH" (V_PIX <= y < V_PIX + V_FPORCH)
            -- BALAYAGE DE y DE 480 A 489
            --     BALAYAGE DE x DE 0 A 639
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     BALAYAGE DE x DE 640 A 655
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     BALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 0 (actif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     ALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --------------------------------------------------------------------------
            
            -- BALAYAGE DE y DE 480 A 489
            for j in 0 to (V_FPORCH - 1) loop
            
                -- BALAYAGE DE x DE 0 A 639
                for x in 0 to (H_PIX - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 640 A 655
                for x in 0 to (H_FPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 656 A 751
                for x in 0 to (HSYNC_SIZE - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 0 (actif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '0'
                        report "ERROR: hsync not equals to 0" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 752 A 799
                for x in 0 to (H_BPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
            end loop;
    
    
            --------------------------------------------------------------------------
            -- TROISIEME TEST : TEST POUR LES VALEURS DE Y DANS LA ZONE BLANCHE "VSYNC_SIZE" (V_PIX + V_FPORCH <= y < V_PIX + V_FPORCH + VSYNC_SIZE)
            -- BALAYAGE DE y DE 490 A 491
            --     BALAYAGE DE x DE 0 A 639
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 0 (actif)
            --          in_display = 0 (dans la zone blanche)
            --     BALAYAGE DE x DE 640 A 655
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 0 (actif)
            --          in_display = 0 (dans la zone blanche)
            --     BALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 0 (actif)
            --          vsync = 0 (actif)
            --          in_display = 0 (dans la zone blanche)
            --     ALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 0 (actif)
            --          in_display = 0 (dans la zone blanche)
            --------------------------------------------------------------------------
            
            -- BALAYAGE DE y DE 490 A 491
            for j in 0 to (VSYNC_SIZE - 1) loop
            
                -- BALAYAGE DE x DE 0 A 639
                for x in 0 to (H_PIX - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 0 (actif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '0'
                        report "ERROR: vsync not equals to 0" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 640 A 655
                for x in 0 to (H_FPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 0 (actif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '0'
                        report "ERROR: vsync not equals to 0" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 656 A 751
                for x in 0 to (HSYNC_SIZE - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 0 (actif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '0'
                        report "ERROR: hsync not equals to 0" severity failure;            
                    assert vsync = '0'
                        report "ERROR: vsync not equals to 0" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 752 A 799
                for x in 0 to (H_BPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 0 (actif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '0'
                        report "ERROR: vsync not equals to 0" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
            end loop;
    
    
            --------------------------------------------------------------------------
            -- QUATRIEME TEST : TEST POUR LES VALEURS DE Y DANS LA ZONE BLANCHE "V_BPORCH" (V_PIX + V_FPORCH + VSYNC_SIZE <= y < V_PIX + V_FPORCH + VSYNC_SIZE + V_BPORCH)
            -- BALAYAGE DE y DE 480 A 489
            --     BALAYAGE DE x DE 0 A 639
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     BALAYAGE DE x DE 640 A 655
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     BALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 0 (actif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --     ALAYAGE DE x DE 752 A 799
            --          Valeurs des sorties attendues
            --          hsync = 1 (inactif)
            --          vsync = 1 (inactif)
            --          in_display = 0 (dans la zone blanche)
            --------------------------------------------------------------------------
            
            -- BALAYAGE DE y DE 492 A 525
            for j in 0 to (V_BPORCH - 1) loop
            
                -- BALAYAGE DE x DE 0 A 639
                for x in 0 to (H_PIX - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 640 A 655
                for x in 0 to (H_FPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 656 A 751
                for x in 0 to (HSYNC_SIZE - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 0 (actif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '0'
                        report "ERROR: hsync not equals to 0" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
    
                -- BALAYAGE DE x DE 752 A 799
                for x in 0 to (H_BPORCH - 1) loop
                    -- Valeurs des sorties attendues
                    -- hsync = 1 (inactif)
                    -- vsync = 1 (inactif)
                    -- in_display = 0 (dans la zone blanche)
                    assert hsync = '1'
                        report "ERROR: hsync not equals to 1" severity failure;            
                    assert vsync = '1'
                        report "ERROR: vsync not equals to 1" severity failure;            
                    assert in_display = '0'
                        report "ERROR: in_display not equals to 0" severity failure;            
                    
                    -- Attente d'une periode
                    wait for period;
                end loop;
    
            end loop;
            
        end loop;    




        wait;
	   
    end process;
	
end behavioral;