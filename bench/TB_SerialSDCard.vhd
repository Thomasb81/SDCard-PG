--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:41:44 08/05/2013
-- Design Name:   
-- Module Name:   /home/tom/prog/git/SDCard-PG/bench/TB_SerialSDCard.vhd
-- Project Name:  SDCard-PG
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SerialSDCard_top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TB_SerialSDCard IS
END TB_SerialSDCard;
 
ARCHITECTURE behavior OF TB_SerialSDCard IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SerialSDCard_top
    PORT(
         osc_in : IN  std_logic;
         nreset : IN  std_logic;
         usb_rx : OUT  std_logic;
         usb_tx : IN  std_logic;
         audio_r : OUT  std_logic;
         audio_l : OUT  std_logic;
         led1 : OUT  std_logic;
         led2 : OUT  std_logic;
         led3 : OUT  std_logic;
         led4 : OUT  std_logic;
         sd_clk : OUT  std_logic;
         sd_cmd : INOUT  std_logic;
         sd_data : INOUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    
	 component card
    generic (
      card_type_g  : string := "none";
      is_sd_card_g : integer := 1
    );
    port (
      spi_clk_i  : in  std_logic;
      spi_cs_n_i : in  std_logic;
      spi_data_i : in  std_logic;
      spi_data_o : out std_logic
    );
  end component;

   --Inputs
   signal osc_in : std_logic := '0';
   signal nreset : std_logic := '0';
   signal usb_tx : std_logic := '0';

	--BiDirs
   signal sd_cmd : std_logic;
   signal sd_data : std_logic_vector(3 downto 0);

 	--Outputs
   signal usb_rx : std_logic;
   signal audio_r : std_logic;
   signal audio_l : std_logic;
   signal led1 : std_logic;
   signal led2 : std_logic;
   signal led3 : std_logic;
   signal led4 : std_logic;
   signal sd_clk : std_logic;

   -- Clock period definitions
   constant sd_clk_period : time := 31.25 ns;
 
BEGIN
   -- weak pull-ups
   sd_clk <= 'H';
   sd_data(3) <= 'H';
   sd_cmd<= 'H';
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SerialSDCard_top PORT MAP (
          osc_in => osc_in,
          nreset => nreset,
          usb_rx => usb_rx,
          usb_tx => usb_tx,
          audio_r => audio_r,
          audio_l => audio_l,
          led1 => led1,
          led2 => led2,
          led3 => led3,
          led4 => led4,
          sd_clk => sd_clk,
          sd_cmd => sd_cmd,
          sd_data => sd_data
        );

  card_b : card
    generic map (
      card_type_g  => "MMC Chip",
      is_sd_card_g => 0
    )
    port map (
      spi_clk_i  => sd_clk,
      spi_cs_n_i => sd_data(3),
      spi_data_i => sd_cmd,
      spi_data_o => sd_data(0)
    );



   -- Clock process definitions
   sd_clk_process :process
   begin
		osc_in <= '0';
		wait for sd_clk_period/2;
		osc_in <= '1';
		wait for sd_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for sd_clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
