library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity codelock is
   port( clk:      in  std_logic;
           K:      in  std_logic_vector(1 to 3);
           R:      in  std_logic_vector(1 to 4);
           q:      out std_logic_vector(4 downto 0);
           UNLOCK: out std_logic );
end codelock;

architecture behavior of codelock is
subtype state_type is integer range 0 to 31;
signal state, nextstate: state_type;
  
begin
nextstate_decoder: -- next state decoding part
process(state, K, R)
 begin
   case state is
      when 0 => if (K = "001" and R ="0010")			then nextstate <= 1;
					 elsif (K = "001" and R ="0001")		then nextstate <= 4;
                else nextstate <= 0;
                end if;
      when 1 => if (K = "001" and R = "0010")    then nextstate <= 1;	-- first digit still pressed
                elsif (K = "010" and R = "1000") then nextstate <= 2;	-- second digit pressed
                else nextstate <= 0;												-- wrong digit pressed
                end if;
		when 2 => if (K = "010" and R = "1000")    then nextstate <= 2;	-- second digit still pressed
                elsif (K = "001" and R = "0001") then nextstate <= 3;	-- third digit pressed
                else nextstate <= 0;												-- wrong digit pressed
                end if;
		when 3 => if (K = "001" and R = "0001")    then nextstate <= 3;	-- third digit still pressed
                elsif (K = "010" and R = "1000") then nextstate <= 4;	-- fourth digit pressed
                else nextstate <= 0;												-- wrong digit pressed
                end if;
      when 4 to 30 => nextstate <= state + 1;
      when 31 => nextstate <= 0;
   end case;
end process;

debug_output:  -- display the state
q <= conv_std_logic_vector(state,5);
	
output_decoder: -- output decoder part
process(state)
begin
  case state is
     when 0 to 3  => UNLOCK <= '0';
     when 4 to 31 => UNLOCK <= '1';
  end case;	
end process;

state_register: -- the state register part (the flipflops)
process(clk)
begin
  if rising_edge(clk) then
     state <= nextstate;
  end if;
end process;
end behavior;