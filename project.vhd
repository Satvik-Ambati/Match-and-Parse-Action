----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:52:45 05/01/2019 
-- Design Name: 
-- Module Name:    Project - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Project is
    Port ( iData_av : in  STD_LOGIC;
           iRd_Data : out  STD_LOGIC;
           iData : in  STD_LOGIC_VECTOR (143 downto 0);
           oData_av : out  STD_LOGIC;
           oData_rd : in  STD_LOGIC;
           oData : out  STD_LOGIC_VECTOR (143 downto 0);
           Lkup_data : out  STD_LOGIC_VECTOR (127 downto 0);
           Lkup_valid : out  STD_LOGIC;
           Lkup_Flow_miss : in  STD_LOGIC;
           Lkup_Flow_priority : in  STD_LOGIC_VECTOR (2 downto 0);
           Lkup_Flow_id : in  STD_LOGIC_VECTOR (7 downto 0);
           Lkup_Flow_info : in  STD_LOGIC_VECTOR (255 downto 0);
           Lkup_Flow_instruction : in  STD_LOGIC_VECTOR (7 downto 0);
           Lkup_Flow_info_valid : in  STD_LOGIC_VECTOR (7 downto 0);
           Flow_id : in  STD_LOGIC_VECTOR (7 downto 0);
           Burst_Size : in  STD_LOGIC_VECTOR (15 downto 0);
           Flow_rate : in  STD_LOGIC_VECTOR (15 downto 0);
           configure : in  STD_LOGIC;
           I_Offset : in  STD_LOGIC_VECTOR (15 downto 0);
           I_Length : in  STD_LOGIC_VECTOR (2 downto 0);
           I_Instruction : in  STD_LOGIC_VECTOR (7 downto 0);
           O_Offset : in  STD_LOGIC_VECTOR (15 downto 0);
           O_Length : in  STD_LOGIC_VECTOR (2 downto 0);
           O_Instruction : in  STD_LOGIC_VECTOR (7 downto 0);
           clk : in  STD_LOGIC;
           rst : in  STD_LOGIC);
end Project;

architecture Behavioral of Project is

type states is (IDLE, READING, EXTRACING, BEFORE_LOOKUP, LOOKUP);
signal p_state, n_state : states := IDLE;
signal numofbytes : std_logic_vector(15 downto 0) := "0000000000000000";
signal extracted : std_logic_vector( 127 downto 0); 
signal I_Length2 : std_logic_Vector( 16 downto 0) := "0000000000000"&I_Length;


function Length1(fragment : std_logic_vector(143 downto 0)) return integer is
		variable length1 : integer range 0 to 144 := 0;
	begin
		for N in 0 to 15 loop
			if fragment(143-N*9)='1' then
				length1:=length1+1;
			else exit;
			end if;
		end loop;
		return length1;
	end function;


function extract(X : std_logic_vector(143 downto 0);
					  i : integer;
					  j : integer)
              return std_logic_vector is
				  variable output : std_logic_vector(127 downto 0);
begin 	
	for N in 0 to j-i loop
		output(127-8*N downto 120-8*N) := X(143-i*9-9*N-1 downto 135-i*9-9*N);
	end loop;
	for N in j-i+1 to 15 loop
		output(127-8*N downto 120-8*N) := "11111111";
	end loop;
	return output;

end function;


begin

process(clk)
begin
	if (rising_edge(clk)) then
		p_state <= n_state;
	end if;
end process;

process(p_state,iData_av ) 
begin
	case p_state is
		when IDLE => 
			extracted <= (others => '0'); --all 128 bits zeroes
			if (iData_av='0') then
				n_state <= IDLE;
			else
				n_state <= READING;
				iRd_Data <= '1';
				--check if any dv's are 1 -> ditch
			end if;
		when READING =>
			if (I_Offset>numofbytes+std_logic_vector(to_unsigned(Length1(iData),16))) then
				numofbytes <= numofbytes + 16;
				n_state <= READING;
				--Add input data to FIFO
			else
				if (I_Offset + I_Length2 <= numofbytes + std_logic_vector(to_unsigned(Length1(iData),16))) then
					extracted <= extract(iData,to_integer(unsigned(numofbytes+16-I_Offset)),to_integer(unsigned(numofbytes+16-I_Offset + I_Length2)));
					numofbytes<=numofbytes+16;
					n_state <= BEFORE_LOOKUP;
					
					-- extracted data exists in this fragment
				else
					--two fragments
					extracted(127 downto 127-to_integer(to_integer(unsigned(numofbytes+std_logic_vector(to_unsigned(func(iData),16))-I_Offset))*8); 
				--Add func(iData) bytes to FIFO
				-- if func(iData) not =16, then append 1's.
				--extract starting from I_offset 
	
				




end Behavioral;
