library ieee;
use ieee.std_logic_1164.all;

entity tb_counter is
end tb_counter;

architecture behavioral of tb_counter is

	signal btn_restart : std_logic := '0';
	signal resetn      : std_logic := '0';
	signal clk         : std_logic := '0';
	signal end_counter : std_logic;
	
	-- Les constantes suivantes permettent de definir la frequence de l'horloge 
	constant hp : time := 5 ns;                   -- demi periode de 5ns
	constant period : time := 2*hp;               -- periode de 10ns, soit une frequence de 100MHz
	constant count_max_tb : natural := 200000000; -- nombre de periodes correspondant au compteur

	
	--Declaration de l'entite a tester
	component counter_unit 
		port ( 
			clk             : in std_logic;
			btn_restart     : in std_logic;
			resetn          : in std_logic; 
			end_counter     : out std_logic;
			out_LED         : out std_logic
		 );
	end component;
	
	

	begin
	
    --Affectation des signaux du testbench avec ceux de l'entite a tester
    uut: counter_unit
    port map (
        clk         => clk,
        resetn      => resetn,
        btn_restart => btn_restart,
        end_counter => end_counter
    );
		
    --Simulation du signal d'horloge en continue
    process
    begin
        wait for hp;
        clk <= not clk;
    end process;


    process
    begin
    --------------------------------------------------------------------------
    -- FIRST TEST TO CHECK THE LED BLINKED                                  --
    -- btn_restart SET TO '0' (inactive) && resetn SET TO '1' (inactive)    --
    --------------------------------------------------------------------------
    -- INITIALISATION
    -- counting for 2 periods - Waiting before reset
    wait for (2 * period);
    -- signal reset a 1, ie resetn a 0
    resetn <= '1';
    btn_restart <= '0';
    -- counting for 1 period
    wait for period;
    -- signal reset a 0, ie resetn a 1
    resetn <= '0';	   -- counting for (count_max_tb-2) periods
    wait for ((count_max_tb-2) * period);
    -- Valeurs des sorties attendues
    -- end_counter = 0
    assert end_counter = '0'
        report "ERROR: end_counter not equals to 0" severity failure;


    -- counting for 1 additionnal period (Total: (count_max_tb-1) periods)
    wait for period;
    -- Valeurs des sorties attendues
    -- end_counter = 1
    assert end_counter = '1'
        report "ERROR: end_counter not equals to 1" severity failure;

	   
    -- counting for 1 additionnal period (Total: (count_max_tb) periods)
    wait for period;
    -- Valeurs des sorties attendues
    -- end_counter = 0
    assert end_counter = '0'
        report "ERROR: end_counter not equals to 0" severity failure;


    --------------------------------------------------------------------------
    -- GIVING SOME TIME BEFORE SECOND TEST                                  --
    --------------------------------------------------------------------------
    -- counting for 0 periods - Waiting before reset
    wait for (count_max_tb * 7 * period);


    --------------------------------------------------------------------------
    -- SECOND TEST TO CHECK THE LED STOP BLINKING DURING RESET              --
    -- btn_restart SET TO '0' (inactive)                                    --
    -- && resetn SET TO '0'  for 500 periods (active)                       --
    --------------------------------------------------------------------------
    -- counting for 80 periods - Waiting before reset
    wait for (80 * period);
    -- signal reset a 1, ie resetn a 0
    resetn <= '1';
    -- counting for 500 period
    wait for 500 * period;
    -- signal reset a 0, ie resetn a 1
    resetn <= '0';
    wait for ((count_max_tb-2) * period);
    -- Valeurs des sorties attendues
    -- end_counter = 0
    assert end_counter = '0'
        report "ERROR: end_counter not equals to 0" severity failure;


    -- counting for 1 additionnal period (Total: (count_max_tb-1) periods)
        wait for period;
    -- Valeurs des sorties attendues
    -- end_counter = 1
    assert end_counter = '1'
        report "ERROR: end_counter not equals to 1" severity failure;

	   
    -- counting for 1 additionnal period (Total: (count_max_tb) periods)
    wait for period;
    -- Valeurs des sorties attendues
    -- end_counter = 0
    assert end_counter = '0'
        report "ERROR: end_counter not equals to 0" severity failure;

    --------------------------------------------------------------------------
    -- GIVING SOME TIME BEFORE THIRD TEST                                  --
    --------------------------------------------------------------------------
    -- counting for 0 periods - Waiting before reset
    wait for (count_max_tb * 7 * period);


    --------------------------------------------------------------------------
    -- THIRD TEST TO CHECK THE LED STOP BLINKING DURING RESET               --
    -- btn_restart SET TO '1' (active) && resetn SET TO '1' (inactive)      --
    --------------------------------------------------------------------------
    -- INITIALISATION
    -- counting for 2 periods - Waiting before reset
    wait for (2 * period);
    -- signal reset a 1, ie resetn a 0
    resetn <= '1';
    btn_restart <= '0';
    -- counting for 1 period
    wait for period;
    -- signal reset a 0, ie resetn a 1
    resetn <= '0';
    -- counting for 80 periods - Waiting before pressing restart button
    wait for (80 * period);	   
    -- signal btn_restart a 1
    btn_restart <= '1';

    assert end_counter = '0'
        report "ERROR: end_counter not equals to 0" severity failure;

    -- STOP PRESSING button restart
    -- counting for 500 period
    wait for 500 * period;
    -- signal btn_restart a 0
    btn_restart <= '0';
    wait;
	   
end process;
	
	
end behavioral;