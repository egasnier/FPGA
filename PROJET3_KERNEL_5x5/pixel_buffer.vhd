----------------------------------------------------------------------------------
-- Engineer: Adjo Sefofo SOKPOR & Eric GASNIER
-- 
-- Create Date: 03.07.2023
-- Module Name: shift_sync
-- Project Name: Image processing & VGA display
-- Target Devices: coraZ7 (Xilinx)
-- Tool Versions: VIVADO 2020.2
-- Description: Component pixel buffer (sometimes called line bufer)
-- Circular buffer of 795 values
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


entity pixel_buffer is
    generic (
        max_buffer : integer := 795
    ); 
    port ( 
		clk, reset : in std_logic;
		x          : in std_logic_vector(9 downto 0);
		d_buffer   : in std_logic_vector(3 downto 0);
		q_buffer   : out std_logic_vector(3 downto 0)
    );
end pixel_buffer;

architecture behavioral of pixel_buffer is

    ----------------------------------------------
    -- SIGNAUX INTERNES FIFO
    ----------------------------------------------
    signal out_FIFO : std_logic_vector(3 downto 0);


    ----------------------------------------------
    -- SIGNAUX INTERNES FSM
    ----------------------------------------------
    type state_FSM is (idle_state, read_state);   -- Définition des états du FSM
    signal current_state : state_FSM;             -- etat dans lequel on se trouve actuellement
    signal next_state    : state_FSM;	          -- etat dans lequel on passera au prochain 
    signal cmd_reader    : std_logic;	
    signal end_count     : std_logic;	


    ------------------------------------------
    -- DECLARATION DU COMPOSANT pixel_FIFO
    ------------------------------------------
    component pixel_FIFO
        port ( 
            clk          : in std_logic;
            srst         : in std_logic                    := '0';
            wr_en        : in std_logic                    := '0';    -- signal autorisant la mise a jour de la couleur
            din          : in std_logic_vector(3 downto 0) := "0000";
            rd_en        : in std_logic                    := '0';    -- signal autorisant la lecture de la couleur
            dout         : out std_logic_vector(3 downto 0)
        );
    end component;
    	

    begin

    -----------------------------------------------------------------------------	
    -- AFFECTATION DES SIGNAUX
    ------------------------------------------------------------------------------	
    --Affectation des signaux avec ceux de la FIFO
    mapping_FIFO: pixel_FIFO
        port map (
            clk    => clk,
            srst   => reset,
            wr_en  => '1',
            din    => d_buffer,
            rd_en  => cmd_reader,
            dout   => out_FIFO
        );


        ----------------------
        -- PARTIE SEQUENTIELLE	
        ----------------------
        process(clk, reset)
        begin
            if reset = '1' then
                current_state <= idle_state;
            
            elsif rising_edge(clk) then
                current_state <= next_state;     -- Passage à l'état suivant

            end if;
        end process;


        ----------------------
        -- PARTIE COMBINATOIRE
        ----------------------
        -- Signal de synchro horizontale
        end_count <= '1' when x > max_buffer - 3
            else '0';

        -- Signal de sortie
        q_buffer <= out_FIFO  when cmd_reader = '1'
            else "0000";



        ----------------------
        -- FSM
        ----------------------
        process(current_state, end_count)
        begin
            --signaux pilotes par la fsm
            case current_state is
                when idle_state =>
                    cmd_reader <= '0';
                    if end_count = '1' then
                        next_state <= read_state; --prochain etat
                    else
                        next_state <= current_state;
                    end if;
              

                when read_state =>
                    cmd_reader <= '1';
                    next_state <= read_state;
       
            end case;
                      
        end process;

		
end behavioral;