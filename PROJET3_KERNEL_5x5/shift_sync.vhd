----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 03.07.2023
-- Module Name: shift_sync
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Component shifting the synchronization signals of 1603 periods
-- (2 raws and 3 pixels)
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


entity shift_sync is
    generic (
        H_PIX          : integer := 640;          -- Taille de l'image horizontale
        H_FPORCH       : integer := 16;           -- Front porch horizontal
        HSYNC_SIZE     : integer := 96;           -- Horizontal sync pulse
        H_BPORCH       : integer := 48;           -- Back porch horizontal
        V_PIX          : integer := 480;          -- Taille de l'image verticale
        V_FPORCH       : integer := 10;           -- Front porch vertical
        VSYNC_SIZE     : integer := 2;            -- Vertical sync pulse
        V_BPORCH       : integer := 33            -- Back porch vertical
    );
    port ( 
        clk            : in std_logic;            -- Horloge
        reset          : in std_logic;            -- Entrée pour RESET des registres
        x              : in std_logic_vector(9 downto 0); -- Coordonnée X du pixel
        y              : in std_logic_vector(9 downto 0); -- Coordonnée y du pixel
        end_count_x    : in std_logic;            -- Fin de lecture d'une ligne
        cmd_conv       : out std_logic;           -- Signal de commande du module convolution
        hsync_shifted  : out std_logic;           -- Synchronization horizontale retardée de 802 pixels
        vsync_shifted  : out std_logic            -- Synchronization verticale retardée de 802 pixels
    );
end shift_sync;

architecture behavioral of shift_sync is

    	
    ----------------------------------------------
    -- SIGNAUX INTERNES PARTIE COMBINATOIRE
    ----------------------------------------------
    signal vsync_1     : std_logic;	
    signal vsync_reg0  : std_logic;	
    signal vsync_reg1  : std_logic;	
    signal vsync_reg2  : std_logic;	
    signal hsync_2     : std_logic;

	
    ----------------------------------------------
    -- SIGNAUX INTERNES FSM
    ----------------------------------------------
    type state_FSM is (idle_state, inter_state, sync_state);   -- Définition des états du FSM
    signal current_state : state_FSM;                          -- etat dans lequel on se trouve actuellement
    signal next_state    : state_FSM;	                       -- etat dans lequel on passera au prochain 
    signal cmd_sync, cmd_reg0, cmd_reg1, cmd_reg2 : std_logic;	
	
		

    begin

        ----------------------
        -- PARTIE SEQUENTIELLE	
        ----------------------
        process(clk, reset)
        begin
            if reset = '1' then
                current_state <= idle_state;
            
                -- Réinitialisation des compteurs
                vsync_reg0 <= '1';
                vsync_reg1 <= '1';
                vsync_reg2 <= '1';

                cmd_reg0   <= '0';
                cmd_reg1   <= '0';
                cmd_reg2   <= '0';
 
            elsif rising_edge(clk) then
                current_state <= next_state;     -- Passage à l'état suivant

                -- Synchro verticale: decalage de 3 pixels
                vsync_reg2 <= vsync_reg1;
                vsync_reg1 <= vsync_reg0;
                vsync_reg0 <= vsync_1;

                -- Decalage de 3 pixels
                cmd_reg2 <= cmd_reg1;
                cmd_reg1 <= cmd_reg0;
                cmd_reg0 <= end_count_x;
                			    
            end if;
        end process;


        ----------------------
        -- PARTIE COMBINATOIRE
        ----------------------
		-- Signal de synchro horizontale (décalage de 2 pixels)
		hsync_2 <= '0' when (x >= (H_PIX + H_FPORCH + 3)) AND (x < (H_PIX + H_FPORCH + HSYNC_SIZE + 3))
				else '1';
		
        -- Signal de synchro horizontale (suppression de la premiere ligne)
        hsync_shifted <= hsync_2 when cmd_sync = '1'
            else '1';
		
		-- Signal de synchro verticale (décalage d'une ligne)
		vsync_1 <= '0' when (y >= (V_PIX + V_FPORCH + 2)) AND (y < (V_PIX + V_FPORCH + VSYNC_SIZE + 2))
				else '1';
        vsync_shifted <= vsync_reg2;


        -- Signal de commande du module de convolution
        cmd_conv <= cmd_sync;


        ----------------------
        -- FSM
        ----------------------
        process(current_state, cmd_reg1)
        begin
            --signaux pilotes par la fsm
            case current_state is
                when idle_state =>
                    cmd_sync <= '0';
                    if cmd_reg2 = '1' then
                        next_state <= inter_state;
                    else
                        next_state <= current_state;
                    end if;
              

                when inter_state =>
                    cmd_sync <= '0';
                    if cmd_reg2 = '1' then
                        next_state <= sync_state;
                    else
                        next_state <= current_state;
                    end if;


                when sync_state =>
                    cmd_sync <= '1';
                    next_state <= sync_state;
       
            end case;
              
          
        end process;

		
end behavioral;