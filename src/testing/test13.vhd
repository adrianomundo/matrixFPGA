
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity project_tb is
end project_tb;

architecture projecttb of project_tb is
constant c_CLOCK_PERIOD		: time := 15 ns;
signal   tb_done		: std_logic;
signal   mem_address		: std_logic_vector (15 downto 0) := (others => '0');
signal   tb_rst		    : std_logic := '0';
signal   tb_start		: std_logic := '0';
signal   tb_clk		    : std_logic := '0';
signal   mem_o_data,mem_i_data		: std_logic_vector (7 downto 0);
signal   enable_wire  		: std_logic;
signal   mem_we		: std_logic;

type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);



signal RAM: ram_type := (2 => std_logic_vector(to_unsigned( 24 , 8)),
                         3 => std_logic_vector(to_unsigned( 203 , 8)),
                         4 => std_logic_vector(to_unsigned( 15 , 8)),
                         
  2087  => std_logic_vector(to_unsigned( 25 , 8)), 
-- PosX= 19  PosY= 86  --
  2389  => std_logic_vector(to_unsigned( 64 , 8)), 
 -- PosX= 9  PosY= 99  --
  4187  => std_logic_vector(to_unsigned( 23 , 8)), 
 -- PosX= 7  PosY= 174  --
  2481  => std_logic_vector(to_unsigned( 93 , 8)), 
 -- PosX= 5  PosY= 103  --
  3089  => std_logic_vector(to_unsigned( 29 , 8)), 
 -- PosX= 13  PosY= 128  --
  1319  => std_logic_vector(to_unsigned( 25 , 8)), 
 -- PosX= 19  PosY= 54  --
  2241  => std_logic_vector(to_unsigned( 64 , 8)), 
 -- PosX= 5  PosY= 93  --
 -- MaxX= 19  MinX= 5 --
 -- MaxY= 174  MinY= 54 --
  1406  => std_logic_vector(to_unsigned( 14 , 8)), 
  963  => std_logic_vector(to_unsigned( 2 , 8)), 
  1089  => std_logic_vector(to_unsigned( 14 , 8)), 
  450  => std_logic_vector(to_unsigned( 6 , 8)), 
  412  => std_logic_vector(to_unsigned( 10 , 8)), 
  1471  => std_logic_vector(to_unsigned( 11 , 8)), 
 others => (others =>'0'));

component project_reti_logiche is
port (
      i_clk         : in  std_logic;
      i_start       : in  std_logic;
      i_rst         : in  std_logic;
      i_data       : in  std_logic_vector(7 downto 0); --1 byte
      o_address     : out std_logic_vector(15 downto 0); --16 bit addr: max size is 255*255 + 3 more for max x and y and thresh.
      o_done            : out std_logic;
      o_en         : out std_logic;
      o_we       : out std_logic;
      o_data            : out std_logic_vector (7 downto 0)
      );
end component project_reti_logiche;


begin
UUT: project_reti_logiche
port map (
          i_clk      	=> tb_clk,
          i_start       => tb_start,
          i_rst      	=> tb_rst,
          i_data    	=> mem_o_data,
          o_address  	=> mem_address,
          o_done      	=> tb_done,
          o_en   	=> enable_wire,
          o_we 	=> mem_we,
          o_data    => mem_i_data
          );

p_CLK_GEN : process is
begin
wait for c_CLOCK_PERIOD/2;
tb_clk <= not tb_clk;
end process p_CLK_GEN;


MEM : process(tb_clk)
begin
    if tb_clk'event and tb_clk = '1' then
        if enable_wire = '1' then
            if mem_we = '1' then
                RAM(conv_integer(mem_address))              <= mem_i_data;
                mem_o_data                      <= mem_i_data;
            else
                mem_o_data <= RAM(conv_integer(mem_address));
            end if;
        end if;
    end if;
end process;


test : process is
begin 
    wait for 100 ns;
    wait for c_CLOCK_PERIOD;
    tb_rst <= '1';
    wait for c_CLOCK_PERIOD;
    tb_rst <= '0';
    wait for c_CLOCK_PERIOD;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '1';
    wait until tb_done = '0';
    wait until rising_edge(tb_clk);

    -- area =  1815 
    assert RAM(1) = std_logic_vector(to_unsigned( 7 , 8)) report "FAIL high bits computed"  & integer'image(to_integer(unsigned(RAM(1))))  & " golden " & integer'image(to_integer(to_unsigned( 7 , 8))) severity failure;
    assert RAM(0) = std_logic_vector(to_unsigned( 23 , 8)) report "FAIL low bits computed" & integer'image(to_integer(unsigned(RAM(0))))  & " golden " & integer'image(to_integer(to_unsigned( 23 , 8))) severity failure;


    assert false report "Simulation Ended!, test passed computed RAM(1)" & integer'image(to_integer(unsigned(RAM(1)))) & " RAM(0) " & integer'image(to_integer(unsigned(RAM(0)))) & "golden RAM(1) " & integer'image(to_integer(to_unsigned( 7 , 8))) & " RAM(0) " & integer'image(to_integer(to_unsigned( 23 , 8))) severity failure;
end process test;

end projecttb; 
