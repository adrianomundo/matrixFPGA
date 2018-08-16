----------------------------------------------------------------------------------
-- Engineer: Mundo-Miceli
-- 
-- Create Date: 28.07.2018 12:13:48
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: project_reti_logiche
-- Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_start : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector(7 downto 0)
        );
end project_reti_logiche;


architecture FSM of project_reti_logiche is
    
    type state_type is (IDLE, START, SET_ADDRESS, WAITBOH, READ_FROM_MEM, CHECK_INDEX_COL, CHECK_INDEX_ROW, SET_NEXT, SET_SQUARE, SET_MSB, SET_LSB,SET_LSB_ADDRESS, SET_DONE, UNSET_DONE); 
    signal current_state : state_type := IDLE;
    signal width, height, threshold : unsigned (7 downto 0);
    signal c_min, c_max, r_min, r_max : unsigned (7 downto 0);
    signal col_index, row_index : unsigned (7 downto 0);
    signal max_address, addr_counter : unsigned (15 downto 0);
    signal square : std_logic_vector(15 downto 0);
    signal c_min_assigned, r_min_assigned : std_logic; 
    signal base, altezza : unsigned (7 downto 0);

begin
   
    lambda_delta : process(i_clk, i_rst)
   
    begin

        if (i_rst = '1') then
            o_en <= '0';
            addr_counter <= "0000000000000010";
            c_min_assigned <= '0';
            r_min_assigned <= '0';
            col_index <= "00000000";
            row_index <= "00000000";
            current_state <= IDLE;  
        elsif rising_edge(i_clk) then
                case current_state is
                    when IDLE =>
                        if (i_start = '1') then
                            current_state <= START;
                        else 
                            current_state <= IDLE;
                        end if;
                    when START =>
                        if (i_start = '1') then
                            current_state <= START;
                        else 
                            o_we <= '0';
                            o_en <= '1';
                            current_state <= SET_ADDRESS; 
                        end if;           
                    when SET_ADDRESS =>
                        o_address <= std_logic_vector(addr_counter);
                        current_state <= WAITBOH;
                    when WAITBOH =>
                        current_state <= READ_FROM_MEM;    
                    when READ_FROM_MEM =>
                        if (addr_counter = "0000000000000010") then
                            width <= unsigned(i_data) - 1;
                            addr_counter <= addr_counter + 1;
                            current_state <= SET_ADDRESS;
                        elsif (addr_counter = "0000000000000011") then
                            height <= unsigned(i_data);
                            addr_counter <= addr_counter + 1;
                            current_state <= SET_ADDRESS;
                        elsif (addr_counter = "0000000000000100") then
                            max_address <= unsigned(((width + 1) * height) + 4); 
                            threshold <= unsigned(i_data);
                            addr_counter <= addr_counter + 1;
                            current_state <= SET_ADDRESS;
                        elsif (addr_counter = (max_address + 1)) then
                            o_en <= '1';
                            o_we <= '1';
                            base <= c_max - c_min +1;
                            altezza <= r_max - r_min + 1;
                            current_state <= SET_SQUARE;
                        else 
                            current_state <= CHECK_INDEX_COL;
                        end if;
                    when CHECK_INDEX_COL =>
                        if (unsigned(i_data) >= threshold) then
                            if (c_min_assigned = '0') then
                                c_min <= col_index;
                                c_max <= col_index;
                                c_min_assigned <= '1';
                                current_state <= CHECK_INDEX_ROW;
                            else
                               if (col_index < c_min) then
                                   c_min <= col_index;
                                   current_state <= CHECK_INDEX_ROW;
                               elsif (col_index > c_max) then
                                   c_max <= col_index;
                                   current_state <= CHECK_INDEX_ROW;
                               else
                                   current_state <= CHECK_INDEX_ROW;              
                               end if;  
                            end if;                                
                        else 
                            current_state <= SET_NEXT;    
                        end if; 
                    when CHECK_INDEX_ROW =>
                        if (r_min_assigned = '0') then
                            r_min <= row_index;
                            r_max <= row_index;
                            r_min_assigned <= '1';
                            current_state <= SET_NEXT;
                        else
                            if (row_index < r_min) then
                                r_min <= row_index;
                                current_state <= SET_NEXT;  
                            elsif (row_index > r_max) then
                                r_max <= row_index;
                                current_state <= SET_NEXT;
                            else
                                current_state <= SET_NEXT;    
                            end if;    
                       end if;
                    when SET_NEXT =>
                        if (col_index = width) then
                            col_index <= "00000000";
                            row_index <= row_index + 1;
                            addr_counter <= addr_counter + 1;
                            current_state <= SET_ADDRESS;
                        else
                            col_index <= col_index + 1;
                            addr_counter <= addr_counter + 1;
                            current_state <= SET_ADDRESS;
                        end if;         
                    when SET_SQUARE =>
                        square <= std_logic_vector(base * altezza);   
                        o_address <= "0000000000000001";
                        current_state <= SET_MSB;
                    when SET_MSB =>
                        o_data <= square(15 downto 8);
                        current_state <= SET_LSB_ADDRESS;
                    when SET_LSB_ADDRESS =>
                        o_address <= "0000000000000000";
                        current_state <= SET_LSB; 
                    when SET_LSB =>
                        o_data <= square(7 downto 0);
                        current_state <= SET_DONE;
                    when SET_DONE =>
                        o_en <= '0';
                        o_we <= '0';
                        o_done <= '1';
                        current_state <= UNSET_DONE;            
                    when UNSET_DONE =>
                        o_done <= '0';
                        --next_state <= START;    
               end case;
         end if;
    end process;
    
end FSM;
