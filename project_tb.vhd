--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   06:36:51 05/02/2019
-- Design Name:   
-- Module Name:   /home/satvik/ISE/project/project_tb.vhd
-- Project Name:  project
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Project
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
 
ENTITY project_tb IS
END project_tb;
 
ARCHITECTURE behavior OF project_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Project
    PORT(
         iData_av : IN  std_logic;
         iRd_Data : OUT  std_logic;
         iData : IN  std_logic_vector(143 downto 0);
--         oData_av : OUT  std_logic;
--         oData_rd : IN  std_logic;
--         oData : OUT  std_logic_vector(143 downto 0);
			  Lkup_data : OUT  std_logic_vector(127 downto 0);
         Lkup_valid : OUT  std_logic;
         Lkup_Flow_miss : IN  std_logic;
         Lkup_Flow_priority : IN  std_logic_vector(2 downto 0);
         Lkup_Flow_id : IN  std_logic_vector(7 downto 0);
         Lkup_Flow_info : IN  std_logic_vector(255 downto 0);
         Lkup_Flow_instruction : IN  std_logic_vector(7 downto 0);
           Lkup_Flow_info_valid : IN  std_logic;
--         Flow_id : IN  std_logic_vector(7 downto 0);
--         Burst_Size : IN  std_logic_vector(15 downto 0);
--         Flow_rate : IN  std_logic_vector(15 downto 0);
--         configure : IN  std_logic;
         I_Offset : IN  std_logic_vector(15 downto 0);
         I_Length : IN  std_logic_vector(2 downto 0);
--         I_Instruction : IN  std_logic_vector(7 downto 0);
--         O_Offset : IN  std_logic_vector(15 downto 0);
--         O_Length : IN  std_logic_vector(2 downto 0);
--         O_Instruction : IN  std_logic_vector(7 downto 0);
--			extracted : OUT std_logic_vector( 127 downto 0);
         clk : IN  std_logic;
         rst : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal iData_av : std_logic := '0';
   signal iData : std_logic_vector(143 downto 0) := (others => '0');
--   signal oData_rd : std_logic := '0';
   signal Lkup_Flow_miss : std_logic := '0';
   signal Lkup_Flow_priority : std_logic_vector(2 downto 0) := (others => '0');
   signal Lkup_Flow_id : std_logic_vector(7 downto 0) := (others => '0');
   signal Lkup_Flow_info : std_logic_vector(255 downto 0) := (others => '0');
   signal Lkup_Flow_instruction : std_logic_vector(7 downto 0) := (others => '0');
   signal Lkup_Flow_info_valid : std_logic;
--   signal Flow_id : std_logic_vector(7 downto 0) := (others => '0');
--   signal Burst_Size : std_logic_vector(15 downto 0) := (others => '0');
--   signal Flow_rate : std_logic_vector(15 downto 0) := (others => '0');
--   signal configure : std_logic := '0';
   signal I_Offset : std_logic_vector(15 downto 0) := (others => '0');
   signal I_Length : std_logic_vector(2 downto 0) := (others => '0');
--   signal I_Instruction : std_logic_vector(7 downto 0) := (others => '0');
--   signal O_Offset : std_logic_vector(15 downto 0) := (others => '0');
--   signal O_Length : std_logic_vector(2 downto 0) := (others => '0');
--   signal O_Instruction : std_logic_vector(7 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';

 	--Outputs
   signal iRd_Data : std_logic;
--   signal oData_av : std_logic;
--   signal oData : std_logic_vector(143 downto 0);
     signal Lkup_data : std_logic_vector(127 downto 0);
--	  signal extracted : std_logic_vector( 127 downto 0);
   signal Lkup_valid : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Project PORT MAP (
          iData_av => iData_av,
          iRd_Data => iRd_Data,
          iData => iData,
--          oData_av => oData_av,
--          oData_rd => oData_rd,
--          oData => oData,
            Lkup_data => Lkup_data,
        Lkup_valid => Lkup_valid,
          Lkup_Flow_miss => Lkup_Flow_miss,
          Lkup_Flow_priority => Lkup_Flow_priority,
          Lkup_Flow_id => Lkup_Flow_id,
          Lkup_Flow_info => Lkup_Flow_info,
          Lkup_Flow_instruction => Lkup_Flow_instruction,
          Lkup_Flow_info_valid => Lkup_Flow_info_valid,
--          Flow_id => Flow_id,
--          Burst_Size => Burst_Size,
--          Flow_rate => Flow_rate,
--          configure => configure,
          I_Offset => I_Offset,
          I_Length => I_Length,
--          I_Instruction => I_Instruction,
--          O_Offset => O_Offset,
--          O_Length => O_Length,
--          O_Instruction => O_Instruction,
--          extracted => extracted,
			 clk => clk,
          rst => rst
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
   iData_av <= '0';
	iData <= "100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000";
	I_Offset <= "0000000000000011";
	I_Length <= "010";
	wait for 50ns;
	
	iData_av <='1';
	iData <= "100000000110000000111000000111100000111110000111111000111111100111111110111111111100000001100000011100000111100001111100011111100111111101111111";
	I_Offset <= "0000000000001101";
	I_Length <= "101";
	wait for 10ns;
	
	iData_av <='1';
	iData <= "100000000110000000111000000111100000111110000111111000111111100111111110111111111100000001100000011100000111100001111100011111100111111101111111";
	I_Offset <= "0000000000001101";
	I_Length <= "101";
	wait for 10ns;

	iData_av <='1';
	iData <= "100000000110000000111000000011100000111110000111111000111111100111111110111111111100000001100000011100000111100001111100011111100111111101111111";
	I_Offset <= "0000000000001101";
	I_Length <= "101";
	wait for 10ns;

--	iData_av <='1';
--	iData <= "100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000";
--	I_Offset <= "0000000000010011";
--	I_Length <= "001";
--	wait for 100ns;
	
      -- insert stimulus here 

      wait;
   end process;

END;
