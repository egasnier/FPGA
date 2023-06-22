----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 16.06.2023
-- Module Name: shift_sync
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Component shifting the synchronization signals of 802 periods
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


entity shift_sync is
    port ( 
        clk            : in std_logic;            -- Horloge
        reset          : in std_logic;            -- Entrée pour RESET des registres
        hsync          : in std_logic;            -- Synchronization horizontale
        vsync          : in std_logic;            -- Synchronization verticale
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
    signal hsync_reg0  : std_logic;	
    signal hsync_reg1  : std_logic;	
    signal vsync_reg0  : std_logic;	
    signal vsync_reg1  : std_logic;	

	
    ----------------------------------------------
    -- SIGNAUX INTERNES FSM
    ----------------------------------------------
    type state_FSM is (idle_state, sync_state);   -- Définition des états du FSM
    signal current_state : state_FSM;             -- etat dans lequel on se trouve actuellement
    signal next_state    : state_FSM;	          -- etat dans lequel on passera au prochain 
    signal cmd_sync, cmd_reg0, cmd_reg1 : std_logic;	
	
		

    begin

        ----------------------
        -- PARTIE SEQUENTIELLE	
        ----------------------
        process(clk, reset)
        begin
            if reset = '1' then
                current_state <= idle_state;
            
                -- Réinitialisation des compteurs
                hsync_reg0 <= '0';
                hsync_reg1 <= '0';
                vsync_reg0 <= '0';
                vsync_reg1 <= '0';
 
            elsif rising_edge(clk) then
                current_state <= next_state;     -- Passage à l'état suivant

                hsync_reg1 <= hsync_reg0;
                hsync_reg0 <= hsync;
                vsync_reg1 <= vsync_reg0;
                vsync_reg0 <= vsync;
                
                cmd_reg1 <= cmd_reg0;
                cmd_reg0 <= cmd_sync;
                			    
            end if;
        end process;


        ----------------------
        -- PARTIE COMBINATOIRE
        ----------------------
        -- Signal de synchro horizontale
        hsync_shifted <= hsync_reg1 when cmd_sync = '1'
            else '1';
		
        -- Signal de synchro verticale
        vsync_shifted <= vsync_reg1 when cmd_sync = '1'
            else '1';

        -- Signal de commande du module de convolution
        cmd_conv <= cmd_reg1;

        ----------------------
        -- FSM
        ----------------------
        process(current_state, end_count_x)
        begin
            --signaux pilotes par la fsm
            case current_state is
                when idle_state =>
                    cmd_sync <= '0';
                    if end_count_x = '1' then
                        next_state <= sync_state; --prochain etat
                    else
                        next_state <= current_state;
                    end if;
              

                when sync_state =>
                    cmd_sync <= '1';
                    next_state <= sync_state;
       
            end case;
              
          
        end process;

		
end behavioral;