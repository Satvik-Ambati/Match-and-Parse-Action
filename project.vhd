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
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
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
--           oData_av : out  STD_LOGIC;
--           oData_rd : in  STD_LOGIC;
--           oData : out  STD_LOGIC_VECTOR (143 downto 0);
           Lkup_data : out  STD_LOGIC_VECTOR (127 downto 0);
           Lkup_valid : out  STD_LOGIC;
           Lkup_Flow_miss : in  STD_LOGIC;
           Lkup_Flow_priority : in  STD_LOGIC_VECTOR (2 downto 0);
           Lkup_Flow_id : in  STD_LOGIC_VECTOR (7 downto 0);
           Lkup_Flow_info : in  STD_LOGIC_VECTOR (255 downto 0);
           Lkup_Flow_instruction : in  STD_LOGIC_VECTOR (7 downto 0);
             Lkup_Flow_info_valid : in  STD_LOGIC;
--           Flow_id : in  STD_LOGIC_VECTOR (7 downto 0);
--           Burst_Size : in  STD_LOGIC_VECTOR (15 downto 0);
--           Flow_rate : in  STD_LOGIC_VECTOR (15 downto 0);
--           configure : in  STD_LOGIC;
           I_Offset : in  STD_LOGIC_VECTOR (15 downto 0);
           I_Length : in  STD_LOGIC_VECTOR (2 downto 0);
--           I_Instruction : in  STD_LOGIC_VECTOR (7 downto 0);
--           O_Offset : in  STD_LOGIC_VECTOR (15 downto 0);
--           O_Length : in  STD_LOGIC_VECTOR (2 downto 0);
--           O_Instruction : in  STD_LOGIC_VECTOR (7 downto 0);
--			  extracted : OUT std_logic_vector( 127 downto 0);
           clk : in  STD_LOGIC;
           rst : in  STD_LOGIC);
end Project;

architecture Behavioral of Project is
COMPONENT fifo
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(143 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(143 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END COMPONENT;
type states is (IDLE, READING, BEFORE_LOOKUP, LOOKUP, WAIT_TO_STORE, FLOW_MISS, RATE_LIMIT_LOGIC);
signal p_state, n_state : states := IDLE;
signal numofbytes : std_logic_vector(15 downto 0) := "0000000000000000";
signal extracted : std_logic_vector( 127 downto 0); 
signal I_Length2 : std_logic_Vector( 15 downto 0) := "0000000000000"&I_Length;
signal two_fragment_check : std_logic := '0';

signal Lkup_Flow_miss2 :   STD_LOGIC;
signal Lkup_Flow_priority2 :  STD_LOGIC_VECTOR (2 downto 0);
signal Lkup_Flow_id2 :  STD_LOGIC_VECTOR (7 downto 0);
signal Lkup_Flow_info2 :  STD_LOGIC_VECTOR (255 downto 0);
signal Lkup_Flow_instruction2 : STD_LOGIC_VECTOR (7 downto 0);

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
signal rst1 : std_logic := '0';
signal din : std_logic_vector(143 downto 0) := (others => '0');
signal wr_en : std_logic := '0';
signal rd_en : std_logic := '0';
signal dout : std_logic_vector(143 downto 0) := (others => '0');
signal full : std_logic := '0'; 
signal empty : std_logic := '0';

begin
your_instance_name : fifo
  PORT MAP (
    clk => clk,
    rst => rst1,
    din => din,
    wr_en => wr_en,
    rd_en => rd_en,
    dout => dout,
    full => full,
    empty => empty
  );
process(clk) is
begin
	--if (rising_edge(clk)) then
		p_state <= n_state;
	--end if;
end process;

process(clk,p_state,iData_av,I_Offset) is 
--signal numofbytes : std_logic_vector(15 downto 0) := "0000000000000000";
begin
	I_Length2 <= "0000000000000"&I_Length;
	if (rising_edge(clk)) then
	case p_state is
		when IDLE => 
			extracted <= (others => '1'); --all 128 bits zeroes
			if (iData_av='0') then
				n_state <= IDLE;
				iRd_Data <='0';
			else
				n_state <= READING;
				iRd_Data <= '1';
				--check if any dv's are 1 -> ditch
			end if;
		when READING =>
			wr_en <= '1';
			din <= iData;
			if (to_integer(unsigned(I_Offset)) > to_integer(unsigned(numofbytes))+16) then
				numofbytes <= numofbytes + "0000000000010000";
				n_state <= READING;
				two_fragment_check <= '0';
				--extracted <= numofbytes&"1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111";
				--Add input data to FIFO
			else
				--numofbytes := numofbytes + "0000000000010000";
				--n_state <= READING;
				--extracted <= "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111";
--				if (I_Offset + I_Length2 <= numofbytes + std_logic_vector(to_unsigned(Length1(iData),16))) then
				if (to_integer(unsigned(I_Offset + I_Length2)) <= to_integer(unsigned(numofbytes + "0000000000010000"))) then
					numofbytes <= numofbytes + "0000000000010000";
					if (two_fragment_check='1') then --second part of fragment in case of two fragments
						extracted(127-to_integer(unsigned(numofbytes-I_Offset))*8 downto 127+1-to_integer(unsigned(I_Length2))*8) <= extract(iData,0,to_integer(unsigned(I_Offset+I_Length2-numofbytes-"0000000000000001")))(127 downto 127+1-to_integer(unsigned(I_Length2+I_Offset-numofbytes))*8)  ;
						if (Length1(iData) = 16) then 
							n_state <= BEFORE_LOOKUP;
						else
							n_state <= LOOKUP;
						end if;
					else -- in case of a single fragment
						extracted <= extract(iData,to_integer(unsigned(I_Offset))-to_integer(unsigned(numofbytes)),(to_integer(unsigned(I_Offset))+to_integer(unsigned(I_Length2))-1-to_integer(unsigned(numofbytes))));
--						Lkup_data <= "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111";
						if (Length1(iData) = 16) then 
							n_state <= BEFORE_LOOKUP;
						else
							n_state <= LOOKUP;
						end if;
					end if;
					-- extracted data exists in this fragment
				else
					--two fragments
--					extracted(127 downto 127+1-to_integer(unsigned(numofbytes+std_logic_vector(to_unsigned(Length1(iData),16))-I_Offset))*8) <= extract(iData, to_integer(unsigned(I_Offset)), 15);
					extracted <= extract(iData, to_integer(unsigned(I_Offset)), 15);
					numofbytes <= numofbytes + "0000000000010000";
					two_fragment_check <= '1';
					n_state <= READING;
				end if;
			end if;
			
				--Add func(iData) bytes to FIFO
				--extract starting from I_offset 
		when BEFORE_LOOKUP =>
			if (Length1(iData)=16) then
				n_state <= BEFORE_LOOKUP;
			else
				n_state <= LOOKUP;
				
			end if;
		when LOOKUP =>
			Lkup_data <= extracted;
			Lkup_valid <= '1';
			n_state <= WAIT_TO_STORE;
		
		when WAIT_TO_STORE =>
			if (Lkup_Flow_info_valid='1') then
				Lkup_Flow_miss2 <= Lkup_Flow_miss;
           Lkup_Flow_priority2 <=  Lkup_Flow_priority;
           Lkup_Flow_id2 <= Lkup_Flow_id;
           Lkup_Flow_info2 <= Lkup_Flow_info;
           Lkup_Flow_instruction2<= Lkup_Flow_instruction;
			  n_state <= FLOW_MISS;
				--store flow related info in  registers
			else
				n_state <= WAIT_TO_STORE;
			end if;
		when FLOW_MISS =>
			if (Lkup_Flow_miss2='1') then
				n_state <= IDLE;
			else
				n_state <= RATE_LIMIT_LOGIC;
			end if;
		when RATE_LIMIT_LOGIC =>
			null;
		end case;
		end if;
	end process;
		
end Behavioral;

