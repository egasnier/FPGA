----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: count_unit
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Testbench for component topVGA
-- 
-- Dependencies: Pmod VGA (digilent)
-- 
-- Revision:
-- Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity tb_top_VGA is

end tb_top_VGA;

architecture Behavioral of tb_top_VGA is
      
      
    ------------------------------------------------------------
    --  SIGNAUX 
    ------------------------------------------------------------
    signal reset       : std_logic := '1';
    signal clk_125     : std_logic := '0';
    signal clk_25     : std_logic  := '0';
	 
    signal hsync       : std_logic;
    signal vsync       : std_logic;
	   
    signal Out_pix_R   :  std_logic_vector(3 downto 0);                       -- Composante rouge du pixel
    signal Out_pix_B   :  std_logic_vector(3 downto 0);                       -- Composante bleue du pixel
    signal Out_pix_G   :  std_logic_vector(3 downto 0);                       -- Composante verte du pixel
	   
    signal  in_display :  std_logic :='0';                                     -- Signal indiquant si l'images sont dans la zone d'affichage
                                   
                                        
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


    constant hp_125      : time    := 4 ns;           -- demi periode de 4ns
    constant period_125  : time    := 2*hp_125;           -- periode de 8ns, soit une frequence de 125MHz
    
    constant hp_25       : time := 19.86097319 ns;             -- demi periode de 20ns
    constant period_25   : time := 2*hp_25;              -- periode de 40ns, soit une frequence de 25.175MHz

         


    ------------------------------------------
    -- DECLARATION DU COMPOSANT top_VGA
    ------------------------------------------
    component  top_VGA
        generic (
            H_PIX          : integer := 640;                     -- Taille de l'image horizontale
            H_FPORCH       : integer := 16;                      -- Front porch horizontal
            HSYNC_SIZE     : integer := 96;                      -- Horizontal sync pulse
            H_BPORCH       : integer := 48;                      -- Back porch horizontal
            V_PIX          : integer := 480;                     -- Taille de l'image verticale
            V_FPORCH       : integer := 10;                      -- Front porch vertical
            VSYNC_SIZE     : integer := 2;                       -- Vertical sync pulse
            V_BPORCH       : integer := 33                       -- Back porch vertical
        );
        port ( 
            clk            : in std_logic;
            reset          : in std_logic;
            hsync          : out std_logic;
            vsync          : out std_logic;
            Out_pix_R      : out std_logic_vector(3 downto 0);                       -- Composante rouge du pixel
            Out_pix_B      : out std_logic_vector(3 downto 0);                       -- Composante bleue du pixel
            Out_pix_G      : out std_logic_vector(3 downto 0)                        -- Composante verte du pixel
        );
    end component;

 
    begin
 
    --------------------------	
    -- AFFECTATION DES SIGNAUX
    --------------------------	
    --Affectation des signaux du testbench avec ceux de top_VGA
    mapping_top_VGA: top_VGA
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
            clk        => clk_125,
            reset      => reset,
            hsync      => hsync,
            vsync      => vsync,
            Out_pix_R  => Out_pix_R,
            Out_pix_B  => Out_pix_B,                       
            Out_pix_G  => Out_pix_G
    );



    ------------------------------------------
    -- SIMULATION DES HORLOGES
    ------------------------------------------
    process
    begin
        wait for hp_125;
        clk_125 <= not clk_125;
    end process;

    process
    begin
        wait for hp_25;
        clk_25 <= not clk_25;
    end process;





    process
	
    begin	
	
        ---------------------------------------------
        -- INITIALISATION
        ---------------------------------------------
        -- counting for 2 periods - Waiting before reset
        wait for (2 * period_25);
        -- signal reset a 1
        reset <= '1';
        -- counting for 1 period
        wait for period_25;
        -- signal reset a 0
        reset <= '0';


--        --------------------------------------------------------------------------
--        --------------------------------------------------------------------------
--        -- TEST DE 4 IMAGES
--        --------------------------------------------------------------------------
--        --------------------------------------------------------------------------
--        for image in 0 to 4 loop
        
--            --------------------------------------------------------------------------
--            -- PREMIER TEST : TEST POUR LES VALEURS DE Y DANS L'IMAGE (y < V_PIX)
--            -- BALAYAGE DE y DE 0 A 479
--            --     BALAYAGE DE x DE 0 A 639
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          Out_pix_x prend des valeurs "0000" ou "1111" selon les carrés
--            --     BALAYAGE DE x DE 640 A 655
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          Out_pix_x = "0000" (dans la zone blanche)
--            --     BALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 0 (actif)
--            --          vsync = 1 (inactif)
--            --          Out_pix_x = "0000" (dans la zone blanche)
--            --     ALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          Out_pix_x = "0000" (dans la zone blanche)
--            --------------------------------------------------------------------------
            
--            -- BALAYAGE DE y DE 0 A 479
--            for j in 0 to (V_PIX - 1) loop
            
--                -- BALAYAGE DE x DE 0 A 639
--                for x in 0 to (H_PIX - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 1 (dans l'image)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 640 A 655
--                for x in 0 to (H_FPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 656 A 751
--                for x in 0 to (HSYNC_SIZE - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 0 (actif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '0'
--                        report "ERROR: hsync not equals to 0" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 752 A 799
--                for x in 0 to (H_BPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
--            end loop;
    
    
    
--            --------------------------------------------------------------------------
--            -- DEUXIEME TEST : TEST POUR LES VALEURS DE Y DANS LA ZONE BLANCHE "V_FPORCH" (V_PIX <= y < V_PIX + V_FPORCH)
--            -- BALAYAGE DE y DE 480 A 489
--            --     BALAYAGE DE x DE 0 A 639
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --     BALAYAGE DE x DE 640 A 655
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --     BALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 0 (actif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --     ALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --------------------------------------------------------------------------
            
--            -- BALAYAGE DE y DE 480 A 489
--            for j in 0 to (V_FPORCH - 1) loop
            
--                -- BALAYAGE DE x DE 0 A 639
--                for x in 0 to (H_PIX - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 640 A 655
--                for x in 0 to (H_FPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 656 A 751
--                for x in 0 to (HSYNC_SIZE - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 0 (actif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '0'
--                        report "ERROR: hsync not equals to 0" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 752 A 799
--                for x in 0 to (H_BPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
--            end loop;
    
    
--            --------------------------------------------------------------------------
--            -- TROISIEME TEST : TEST POUR LES VALEURS DE Y DANS LA ZONE BLANCHE "VSYNC_SIZE" (V_PIX + V_FPORCH <= y < V_PIX + V_FPORCH + VSYNC_SIZE)
--            -- BALAYAGE DE y DE 490 A 491
--            --     BALAYAGE DE x DE 0 A 639
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 0 (actif)
--            --          in_display = 0 (dans la zone blanche)
--            --     BALAYAGE DE x DE 640 A 655
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 0 (actif)
--            --          in_display = 0 (dans la zone blanche)
--            --     BALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 0 (actif)
--            --          vsync = 0 (actif)
--            --          in_display = 0 (dans la zone blanche)
--            --     ALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 0 (actif)
--            --          in_display = 0 (dans la zone blanche)
--            --------------------------------------------------------------------------
            
--            -- BALAYAGE DE y DE 490 A 491
--            for j in 0 to (VSYNC_SIZE - 1) loop
            
--                -- BALAYAGE DE x DE 0 A 639
--                for x in 0 to (H_PIX - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 0 (actif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '0'
--                        report "ERROR: vsync not equals to 0" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 640 A 655
--                for x in 0 to (H_FPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 0 (actif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '0'
--                        report "ERROR: vsync not equals to 0" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 656 A 751
--                for x in 0 to (HSYNC_SIZE - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 0 (actif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '0'
--                        report "ERROR: hsync not equals to 0" severity failure;            
--                    assert vsync = '0'
--                        report "ERROR: vsync not equals to 0" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 752 A 799
--                for x in 0 to (H_BPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 0 (actif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '0'
--                        report "ERROR: vsync not equals to 0" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
--            end loop;
    
    
--            --------------------------------------------------------------------------
--            -- QUATRIEME TEST : TEST POUR LES VALEURS DE Y DANS LA ZONE BLANCHE "V_BPORCH" (V_PIX + V_FPORCH + VSYNC_SIZE <= y < V_PIX + V_FPORCH + VSYNC_SIZE + V_BPORCH)
--            -- BALAYAGE DE y DE 480 A 489
--            --     BALAYAGE DE x DE 0 A 639
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --     BALAYAGE DE x DE 640 A 655
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --     BALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 0 (actif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --     ALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --------------------------------------------------------------------------
            
--            -- BALAYAGE DE y DE 492 A 525
--            for j in 0 to (V_BPORCH - 1) loop
            
--                -- BALAYAGE DE x DE 0 A 639
--                for x in 0 to (H_PIX - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 640 A 655
--                for x in 0 to (H_FPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 656 A 751
--                for x in 0 to (HSYNC_SIZE - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 0 (actif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '0'
--                        report "ERROR: hsync not equals to 0" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 752 A 799
--                for x in 0 to (H_BPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
--            end loop;
            
--        end loop;    





--        --------------------------------------------------------------------------
--        --------------------------------------------------------------------------
--        -- TEST DE 4 IMAGES SUITE AU RESET
--        --------------------------------------------------------------------------
--        --------------------------------------------------------------------------
--        -- counting for 2 periods - Waiting before reset
--        wait for (145789 * period_25);
--        -- signal reset a 1
--        reset <= '1';
--        -- counting for 1 period
--        wait for period_25;
--        -- signal reset a 0
--        reset <= '0';

--        for image in 0 to 4 loop
        
--            --------------------------------------------------------------------------
--            -- PREMIER TEST : TEST POUR LES VALEURS DE Y DANS L'IMAGE (y < V_PIX)
--            -- BALAYAGE DE y DE 0 A 479
--            --     BALAYAGE DE x DE 0 A 639
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 1 (dans l'image)
--            --     BALAYAGE DE x DE 640 A 655
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --     BALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 0 (actif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --     ALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --------------------------------------------------------------------------
            
--            -- BALAYAGE DE y DE 0 A 479
--            for j in 0 to (V_PIX - 1) loop
            
--                -- BALAYAGE DE x DE 0 A 639
--                for x in 0 to (H_PIX - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 1 (dans l'image)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 640 A 655
--                for x in 0 to (H_FPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 656 A 751
--                for x in 0 to (HSYNC_SIZE - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 0 (actif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '0'
--                        report "ERROR: hsync not equals to 0" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 752 A 799
--                for x in 0 to (H_BPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
--            end loop;
    
    
    
--            --------------------------------------------------------------------------
--            -- DEUXIEME TEST : TEST POUR LES VALEURS DE Y DANS LA ZONE BLANCHE "V_FPORCH" (V_PIX <= y < V_PIX + V_FPORCH)
--            -- BALAYAGE DE y DE 480 A 489
--            --     BALAYAGE DE x DE 0 A 639
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --     BALAYAGE DE x DE 640 A 655
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --     BALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 0 (actif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --     ALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --------------------------------------------------------------------------
            
--            -- BALAYAGE DE y DE 480 A 489
--            for j in 0 to (V_FPORCH - 1) loop
            
--                -- BALAYAGE DE x DE 0 A 639
--                for x in 0 to (H_PIX - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 640 A 655
--                for x in 0 to (H_FPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 656 A 751
--                for x in 0 to (HSYNC_SIZE - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 0 (actif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '0'
--                        report "ERROR: hsync not equals to 0" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 752 A 799
--                for x in 0 to (H_BPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
--            end loop;
    
    
--            --------------------------------------------------------------------------
--            -- TROISIEME TEST : TEST POUR LES VALEURS DE Y DANS LA ZONE BLANCHE "VSYNC_SIZE" (V_PIX + V_FPORCH <= y < V_PIX + V_FPORCH + VSYNC_SIZE)
--            -- BALAYAGE DE y DE 490 A 491
--            --     BALAYAGE DE x DE 0 A 639
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 0 (actif)
--            --          in_display = 0 (dans la zone blanche)
--            --     BALAYAGE DE x DE 640 A 655
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 0 (actif)
--            --          in_display = 0 (dans la zone blanche)
--            --     BALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 0 (actif)
--            --          vsync = 0 (actif)
--            --          in_display = 0 (dans la zone blanche)
--            --     ALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 0 (actif)
--            --          in_display = 0 (dans la zone blanche)
--            --------------------------------------------------------------------------
            
--            -- BALAYAGE DE y DE 490 A 491
--            for j in 0 to (VSYNC_SIZE - 1) loop
            
--                -- BALAYAGE DE x DE 0 A 639
--                for x in 0 to (H_PIX - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 0 (actif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '0'
--                        report "ERROR: vsync not equals to 0" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 640 A 655
--                for x in 0 to (H_FPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 0 (actif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '0'
--                        report "ERROR: vsync not equals to 0" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 656 A 751
--                for x in 0 to (HSYNC_SIZE - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 0 (actif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '0'
--                        report "ERROR: hsync not equals to 0" severity failure;            
--                    assert vsync = '0'
--                        report "ERROR: vsync not equals to 0" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 752 A 799
--                for x in 0 to (H_BPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 0 (actif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '0'
--                        report "ERROR: vsync not equals to 0" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
--            end loop;
    
    
--            --------------------------------------------------------------------------
--            -- QUATRIEME TEST : TEST POUR LES VALEURS DE Y DANS LA ZONE BLANCHE "V_BPORCH" (V_PIX + V_FPORCH + VSYNC_SIZE <= y < V_PIX + V_FPORCH + VSYNC_SIZE + V_BPORCH)
--            -- BALAYAGE DE y DE 480 A 489
--            --     BALAYAGE DE x DE 0 A 639
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --     BALAYAGE DE x DE 640 A 655
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --     BALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 0 (actif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --     ALAYAGE DE x DE 752 A 799
--            --          Valeurs des sorties attendues
--            --          hsync = 1 (inactif)
--            --          vsync = 1 (inactif)
--            --          in_display = 0 (dans la zone blanche)
--            --------------------------------------------------------------------------
            
--            -- BALAYAGE DE y DE 492 A 525
--            for j in 0 to (V_BPORCH - 1) loop
            
--                -- BALAYAGE DE x DE 0 A 639
--                for x in 0 to (H_PIX - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 640 A 655
--                for x in 0 to (H_FPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 656 A 751
--                for x in 0 to (HSYNC_SIZE - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 0 (actif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '0'
--                        report "ERROR: hsync not equals to 0" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
    
--                -- BALAYAGE DE x DE 752 A 799
--                for x in 0 to (H_BPORCH - 1) loop
--                    -- Valeurs des sorties attendues
--                    -- hsync = 1 (inactif)
--                    -- vsync = 1 (inactif)
--                    -- in_display = 0 (dans la zone blanche)
--                    assert hsync = '1'
--                        report "ERROR: hsync not equals to 1" severity failure;            
--                    assert vsync = '1'
--                        report "ERROR: vsync not equals to 1" severity failure;            
--                    assert out_pix_R = "0000"
--                        report "ERROR: out_pix_R not equals to 0000" severity failure;            
--                    assert out_pix_B = "0000"
--                        report "ERROR: out_pix_B not equals to 0000" severity failure;            
--                    assert out_pix_G = "0000"
--                        report "ERROR: out_pix_G not equals to 0000" severity failure;            
                    
--                    -- Attente d'une periode
--                    wait for period_25;
--                end loop;
    
--            end loop;
            
--        end loop;    
	   
        
        
--       wait for period_25; 
	
        -- Pour finir la simulation 
        wait;
	   
    end process;		 

end Behavioral;
