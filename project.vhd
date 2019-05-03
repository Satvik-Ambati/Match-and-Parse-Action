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
			  iData : in  STD_LOGIC_VECTOR (143 downto 0);
			  
           iRd_Data : out  STD_LOGIC;
           
           oData_av : out  STD_LOGIC;
             oData_rd : in  STD_LOGIC;
           oData : out  STD_LOGIC_VECTOR (143 downto 0);
           
           Lkup_Flow_miss : in  STD_LOGIC;
           Lkup_Flow_priority : in  STD_LOGIC_VECTOR (2 downto 0);
           Lkup_Flow_id : in  STD_LOGIC_VECTOR (7 downto 0);
           Lkup_Flow_info : in  STD_LOGIC_VECTOR (255 downto 0);
           Lkup_Flow_instruction : in  STD_LOGIC_VECTOR (7 downto 0);
           Lkup_Flow_info_valid : in  STD_LOGIC;
           Flow_id : in  STD_LOGIC_VECTOR (7 downto 0);
           Burst_Size : in  STD_LOGIC_VECTOR (15 downto 0);
           Flow_rate : in  STD_LOGIC_VECTOR (15 downto 0);
           configure : in  STD_LOGIC;
			  
			  Lkup_data : out  STD_LOGIC_VECTOR (127 downto 0);
           Lkup_valid : out  STD_LOGIC;
			  
			  
           I_Offset : in  STD_LOGIC_VECTOR (15 downto 0);
           I_Length : in  STD_LOGIC_VECTOR (2 downto 0);
--           I_Instruction : in  STD_LOGIC_VECTOR (7 downto 0);
           O_Offset : out  STD_LOGIC_VECTOR (15 downto 0);
           O_Length : out  STD_LOGIC_VECTOR (2 downto 0);
           O_Instruction : out  STD_LOGIC_VECTOR (7 downto 0);
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
type states is (IDLE, READING, BEFORE_LOOKUP, LOOKUP, WAIT_TO_STORE, FLOW_MISS, RATE_LIMIT_LOGIC, OUTPUT_P, OUTPUT);
signal p_state, n_state : states := IDLE;
signal numofbytes : std_logic_vector(15 downto 0) := "0000000000000000"; --for extract purposes
signal extracted : std_logic_vector( 127 downto 0); 
signal I_Length2 : std_logic_Vector( 15 downto 0) := "0000000000000"&I_Length;
signal two_fragment_check : std_logic := '0';

signal Lkup_Flow_miss2 :   STD_LOGIC;
signal Lkup_Flow_priority2 :  STD_LOGIC_VECTOR (2 downto 0);
signal Lkup_Flow_id2 :  STD_LOGIC_VECTOR (7 downto 0);
signal Lkup_Flow_info2 :  STD_LOGIC_VECTOR (255 downto 0);
signal Lkup_Flow_instruction2 : STD_LOGIC_VECTOR (7 downto 0);

	--- fifo logic 
	type dataregister is array (255 downto 0) of std_logic_vector(15 downto 0);
	signal FlowRateReg : dataregister := (others => (others => '0'));
	signal BurstSizeReg : dataregister := (others => (others => '0'));
	signal buckets : dataregister := (others => (others => '0'));
   signal configure1 : std_logic := '0';
	signal update : std_logic := '0';
	signal counter : integer range 0 to 10  := 0;

signal numofbytes_add : integer range 0 to 10000 := 0;
signal numofbytes_replace : std_logic_vector(15 downto 0) := "0000000000000000"; --for swap purpose in instructions
signal O_Offset2 : std_logic_vector(15 downto 0) := "0000000000000000"; --to store the value of O_Offset from Lkup_flow_info2
signal tag : std_logic_vector(233 downto 0) := (others => '0');
signal swap_check : std_logic := '0';
signal swap_remaining : integer range 0 to 26 := 26;
signal add_check : std_logic := '0';
signal add_remaining : integer range 0 to 26 := 26;
signal temp1 : std_logic_vector(143 downto 0) := (others => '0');
signal temp2 : std_logic_vector(143 downto 0) := (others => '0');


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


function minimum(a : std_logic_vector(15 downto 0);
					  b : std_logic_vector(15 downto 0))
					  return std_logic_vector is
begin
				if a > b then
					return b;
				else
					return a;
				end if;
end function;


function addtaghelp( a : std_logic_vector(207 downto 0)) return std_logic_vector is
variable b1 : std_logic_vector(233 downto 0) := "100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000100000000";
begin
	for N in 0 to 25 loop
		b1(233-N-1 downto 226-1-N) := a(207-N downto 200-N);
	end loop;
	return b1;
end function;

signal rst1 : std_logic := '0';
signal din : std_logic_vector(143 downto 0) := (others => '0');
signal wr_en : std_logic := '0';
signal rd_en : std_logic := '0';
signal dout : std_logic_vector(143 downto 0) := (others => '0');
signal full : std_logic := '0'; 
signal empty : std_logic := '0';
signal decrement_token : std_logic := '0'; 
--signal my_lkup_flow_id : integer range 0 to 255 := 0;

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
	if (rising_edge(clk)) then
		if (counter= 5) then
			update <= '1';
			counter <= 0;
		else 
			update <= '0';
			counter <= counter + 1;
		end if;
	end if;
end process;

process(clk) is
begin
	if(rising_edge(clk)) then
		if(update='1') then
			for flow_index in 0 to 255 loop
					buckets(flow_index) <= minimum(buckets(flow_index)+FlowRateReg(flow_index), BurstSizeReg(flow_index));
			end loop;
		else
				if decrement_token = '1' then
					buckets(to_integer(unsigned(Lkup_Flow_id2))) <= buckets(to_integer(unsigned(Lkup_Flow_id2)))-1;
					decrement_token <= '0';
				end if;
		end if;
	end if;
end process;	
  
  
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
			numofbytes <= "0000000000000000";
			rst1 <= '1'; --resetting the FIFO queue
			extracted <= (others => '1'); --all 128 bits ones
			if (iData_av='0') then
				n_state <= IDLE;
				iRd_Data <='0';
			else
				n_state <= READING;
				iRd_Data <= '1';
			end if;
			
		when READING =>
			wr_en <= '1'; --write data to fifo
			din <= iData; --144 bit data being entered into fifo
			if (to_integer(unsigned(I_Offset)) > to_integer(unsigned(numofbytes))+16) then
				numofbytes <= numofbytes + "0000000000010000";
				n_state <= READING;
				two_fragment_check <= '0';
				--extracted <= numofbytes&"1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111";
			else
				numofbytes <= numofbytes + "0000000000010000";

				if (to_integer(unsigned(I_Offset)) + to_integer(unsigned(I_Length2)) <= to_integer(unsigned(numofbytes)) + 16) then
					
					if (two_fragment_check='1') then --second part of fragment in case of two fragments
						extracted(127-(to_integer(unsigned(numofbytes))-to_integer(unsigned(I_Offset)))*8 downto 127+1-to_integer(unsigned(I_Length2))*8) <= extract(iData,0,to_integer(unsigned(I_Offset))+to_integer(unsigned(I_Length2))-to_integer(unsigned(numofbytes))-1)(127 downto 127+1-(to_integer(unsigned(I_Length2))+to_integer(unsigned(I_Offset))-to_integer(unsigned(numofbytes)))*8)  ;
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
					--numofbytes <= numofbytes + "0000000000010000";
					two_fragment_check <= '1';
					n_state <= READING;
				end if;
			end if;
			wr_en <= '0';
				 
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
			if buckets(to_integer(unsigned(Lkup_Flow_id2))) > 0 then 
				n_state <= OUTPUT_P;
				decrement_token <= '1';
			else 
				n_state <= IDLE;
			end if;
		when OUTPUT_P =>
			if (oData_rd='1') then
				n_state <= OUTPUT;
				O_Offset2 <= Lkup_Flow_info2(23 downto 8);
				tag <= addtaghelp(Lkup_Flow_info2(239 downto 32));
				swap_remaining <= 26;
				swap_check <='0';
				numofbytes_add <= 0;
				numofbytes_replace <= "0000000000000000";
			else
				n_state <= OUTPUT_P;
			end if;
		when OUTPUT =>
			if (Lkup_Flow_instruction2="00000000") then
				if empty = '1' then
					n_state <= IDLE;
					oData_av <= '0';
					rd_en <='0';
				else
					rd_en <= '1';
					oData <= dout;
					oData_av <= '1';
					n_state <= OUTPUT;
				end if;
			elsif (Lkup_Flow_instruction2="00000001") then
				oData_av <= '1';
				O_Length <= Lkup_Flow_info2(31 downto 24);
				O_Offset <= Lkup_Flow_info2(23 downto 8);
				O_Instruction <= Lkup_Flow_info2(7 downto 0);
				--bypass here also
				if empty = '1' then
					n_state <= IDLE;
					oData_av <= '0';
					rd_en <= '0';
				else
					rd_en <= '1';
					oData <= dout;
					oData_av <= '1';
					n_state <= OUTPUT;
				end if;

			elsif( Lkup_Flow_instruction2="00000010") then 
				--Add tag and value
				
				if (empty='1') then
					oData_av <= '0';
					rd_en <= '0';
					n_state <= IDLE;
				else					
					oData_av <= '1';
					if (to_integer(unsigned(O_Offset2)) >= numofbytes_add + 16) then
						n_state <= OUTPUT;
						numofbytes_add <= numofbytes_add + 16;
						rd_en <='1';
						oData <= dout;
					
					--this elsif to be done
					elsif (to_integer(unsigned(O_Offset2)) + 26 <= numofbytes_add) then
						--rd_en <='1';
						n_state <= OUTPUT;
						numofbytes_add <= numofbytes_add + 16;
						oData <= dout;
						--bypass here
						
					else
						numofbytes_add <= numofbytes_add + 16;
						--rd_en <= '1';
						if (add_check = '0') then
							oData(143 downto 143+1-(to_integer(unsigned(O_Offset2))-numofbytes_add)*9) <= dout(143 downto 143+1-(to_integer(unsigned(O_Offset2))-numofbytes_add)*9);
							oData(143-(to_integer(unsigned(O_Offset2))-numofbytes_add)*9 downto 0) <= tag(233 downto 233+1-(16-to_integer(unsigned(O_Offset2))+numofbytes_add)*9);
							temp1(143-(to_integer(unsigned(O_Offset2))-numofbytes_add)*9 downto 0) <= dout(143-(to_integer(unsigned(O_Offset2))-numofbytes_add)*9 downto 0); 
							add_check <='1';
							n_state <= OUTPUT;
							add_remaining <= add_remaining - numofbytes_add-16 + to_integer(unsigned(O_offset2));
						else
							if (add_remaining <= 15) then
								oData(143 downto 143+1-add_remaining*8) <= tag((add_remaining)*9-1 downto 0);
								oData(143-swap_remaining*8 downto 0) <= dout(143-swap_remaining*8 downto 0);
								swap_remaining <= 0;
								swap_check <='0';
								n_state <= OUTPUT;
							else
								oData(143 downto 0)  <= tag(swap_remaining*9-1 downto (swap_remaining-16)*9);
								swap_remaining <= swap_remaining - 16;
								swap_check <= '1';
								n_state <= OUTPUT;
							end if;
						end if;
					end if;
				end if;
				
				

			elsif( Lkup_Flow_instruction2="00000011") then
				if (empty='1') then
					oData_av <= '0';
					rd_en <= '0';
					n_state <= IDLE;
				else					
					oData_av <= '1';
					rd_en <='1';
					if (to_integer(unsigned(O_Offset2)) >= to_integer(unsigned(numofbytes_replace)) + 16) then
						n_state <= OUTPUT;
						numofbytes_replace <= numofbytes_replace + "0000000000010000";
						--rd_en <='1';
						oData <= dout;
				
					elsif (to_integer(unsigned(O_Offset2)) + 26 <= to_integer(unsigned(numofbytes_replace))) then
						--rd_en <='1';
						n_state <= OUTPUT;
						numofbytes_replace <= numofbytes_replace + "0000000000010000";
						oData <= dout;			
					else
						numofbytes_replace <= numofbytes_replace + "0000000000010000";
						--rd_en <= '1';
						if (swap_check = '0') then
							oData(143 downto 143+1-(to_integer(unsigned(O_Offset2))-to_integer(unsigned(numofbytes_replace)))*9) <= dout(143 downto 143+1-(to_integer(unsigned(O_Offset2))-to_integer(unsigned(numofbytes_replace)))*9);
							oData(143-(to_integer(unsigned(O_Offset2))-to_integer(unsigned(numofbytes_replace)))*9 downto 0) <= tag(233 downto 233+1-(16-to_integer(unsigned(O_Offset2))+to_integer(unsigned(numofbytes_replace)))*9);
							swap_check <='1';
							n_state <= OUTPUT;
							swap_remaining <= swap_remaining - to_integer(unsigned(numofbytes_replace))-16 + to_integer(unsigned(O_offset2));
						else
							if (swap_remaining <= 15) then
								oData(143 downto 143+1-swap_remaining*8) <= tag((swap_remaining)*9-1 downto 0);
								oData(143-swap_remaining*8 downto 0) <= dout(143-swap_remaining*8 downto 0);
								swap_remaining <= 0;
								swap_check <='0';
								n_state <= OUTPUT;
							else
								oData(143 downto 0)  <= tag(swap_remaining*9-1 downto (swap_remaining-16)*9);
								swap_remaining <= swap_remaining - 16;
								swap_check <= '1';
								n_state <= OUTPUT;
							end if;
						end if;
					end if;
				end if;
								
						
			elsif ( Lkup_Flow_instruction2="00000100" ) then
				n_state <= IDLE;
			end if;
				
				
			
		
		when others =>
			null;
		end case;
		end if;
	end process;
Config_process : process(clk, configure, Flow_id, Flow_rate, Burst_size) is
	begin
		if rising_edge(clk) then
			if configure = '1' then
				FlowRateReg(to_integer(unsigned(Flow_id))) <= Flow_rate;
				BurstSizeReg(to_integer(unsigned(Flow_id))) <= Burst_size;
				buckets(to_integer(unsigned(Flow_id))) <= Burst_size;
			end if;
		end if;
	end process;
end Behavioral;