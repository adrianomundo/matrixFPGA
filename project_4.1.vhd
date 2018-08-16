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
    
    type state_type is (IDLE, START,ADD_ADDR, SET_ADDRESS, UPDATE, WIDTHS, HEIGHTS, MAX_ADDR,MULTIPLY, MAX_ADDR_4, 
                        THRESHOLDS, READ_FROM_MEM, 
                        GOSTOP, CHECK_INDEX_COL, CHECK_THRES, CHECK_INDEX_COL_ASSIGNED, CHECK_INDEX_ROW, 
                        CHECK_INDEX_ROW_ASSIGNED, SET_NEXT, COL_ZERO, COL_ONE,MULTIPLY_SQUARE, SET_BASE, SET_ALTEZZA, SET_SQUARE, 
                        SET_MSB, SET_LSB, SET_LSB_ADDRESS, SET_DONE, UNSET_DONE); 
    signal current_state : state_type := IDLE;
    signal height, threshold : unsigned (7 downto 0);
    signal width, width_max : unsigned (15 downto 0);
    signal c_min, c_max, r_min, r_max : unsigned (7 downto 0) := "00000000"; 
    signal col_index, row_index : unsigned (7 downto 0) := "00000000";
    signal max_address,max_addr_one, addr_counter, max_address_4 : unsigned (15 downto 0);
    --signal square : std_logic_vector(15 downto 0);
    signal square : unsigned(15 downto 0);    
    signal c_min_assigned, r_min_assigned : std_logic := '0'; 
    signal base, altezza : unsigned (7 downto 0):= "00000000"; 
    
    signal multiplier_square, multiplier : unsigned (7 downto 0):= "00000000";

begin
   
    lambda_delta : process(i_clk, i_rst)
   
    begin

        if (i_rst = '1') then
            o_en <= '0';
            addr_counter <= "0000000000000010";
            square <= "0000000000000000";
            width <= "0000000000000000";
            --base <= "00000000";
            --altezza <= "00000000";
            --c_max <= "00000000";
            --c_min <= "00000000";
            --r_max <= "00000000";
            --r_min <= "00000000";
            --c_min_assigned <= '0';
            --r_min_assigned <= '0';
            --col_index <= "00000000";
            --row_index <= "00000000";
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
                    when ADD_ADDR =>
                         addr_counter <= addr_counter + 1;
                         current_state <= SET_ADDRESS;               
                    when SET_ADDRESS =>
                        o_address <= std_logic_vector(addr_counter);
                        current_state <= UPDATE;
                    when UPDATE =>
                         current_state <= READ_FROM_MEM;  
                    when WIDTHS =>
                         width <= unsigned("00000000" & i_data);
                         --width_max <= unsigned(i_data);
                         --addr_counter <= addr_counter + 1;
                         --current_state <= SET_ADDRESS;
                         current_state <= ADD_ADDR;
                    when HEIGHTS =>
                         height <= unsigned(i_data);
                         width_max <= width;
                         width <= width -  1;
                         --addr_counter <= addr_counter + 1;
                         --current_state <= SET_ADDRESS;
                         current_state <= ADD_ADDR;
                    when THRESHOLDS =>  
                         threshold <= unsigned(i_data);
                         max_addr_one <= max_address_4 + 1;
                         current_state <= ADD_ADDR;
                         --addr_counter <= addr_counter + 1;
                         --current_state <= SET_ADDRESS;
                    when MAX_ADDR => 
                         --max_address <= width_max * height;
                         multiplier <= "00000001";
                         max_address <= width_max;
                         --current_state <= MAX_ADDR_4;
                         current_state <= MULTIPLY;
                    when MULTIPLY =>
                         if (multiplier = height) then
                             current_state <= MAX_ADDR_4;
                         else 
                            multiplier <= multiplier + 1;
                            max_address <= max_address + width_max;
                            current_state <= MULTIPLY;
                         end if;        
                    when MAX_ADDR_4 =>
                         max_address_4 <= max_address + 4;
                         current_state <= THRESHOLDS;             
                    when READ_FROM_MEM =>
                        if (addr_counter = "0000000000000010") then
                            current_state <= WIDTHS;
                        elsif (addr_counter = "0000000000000011") then
                            current_state <= HEIGHTS;
                        elsif (addr_counter = "0000000000000100") then
                            current_state <= MAX_ADDR;
                        else 
                            current_state <= GOSTOP;
                        end if;
                    when GOSTOP =>
                         if (addr_counter = max_addr_one) then
                             o_en <= '1';
                             o_we <= '1';
                             current_state <= SET_BASE;
                         else 
                             current_state <= CHECK_INDEX_COL;
                         end if;   
                    when CHECK_INDEX_COL =>
                        if (unsigned(i_data) >= threshold) then
                            current_state <= CHECK_THRES;                         
                        else 
                            current_state <= SET_NEXT;    
                        end if;
                    when CHECK_THRES =>
                         if (c_min_assigned = '0') then
                             c_min <= col_index;
                             c_max <= col_index;
                             c_min_assigned <= '1';
                             current_state <= CHECK_INDEX_ROW;
                         else 
                            current_state <= CHECK_INDEX_COL_ASSIGNED;
                         end if;                                                    
                    when CHECK_INDEX_COL_ASSIGNED =>
                         if (col_index < c_min) then
                             c_min <= col_index;
                             current_state <= CHECK_INDEX_ROW;
                         elsif (col_index > c_max) then
                             c_max <= col_index;
                             current_state <= CHECK_INDEX_ROW;
                         else
                             current_state <= CHECK_INDEX_ROW;              
                         end if;          
                    when CHECK_INDEX_ROW =>
                        if (r_min_assigned = '0') then
                            r_min <= row_index;
                            r_max <= row_index;
                            r_min_assigned <= '1';
                            current_state <= SET_NEXT;
                        else
                            current_state <= CHECK_INDEX_ROW_ASSIGNED;   
                       end if;
                    when CHECK_INDEX_ROW_ASSIGNED =>
                        if (row_index < r_min) then
                            r_min <= row_index;
                            current_state <= SET_NEXT;  
                        elsif (row_index > r_max) then
                            r_max <= row_index;
                            current_state <= SET_NEXT;
                        else
                            current_state <= SET_NEXT;    
                        end if;                    
                    when SET_NEXT =>
                        if (col_index = width) then
                            current_state <= COL_ZERO;
                        else
                            current_state <= COL_ONE;
                        end if;
                    when COL_ZERO =>
                         col_index <= "00000000";
                         row_index <= row_index + 1;
                         current_state <= ADD_ADDR;
                         --addr_counter <= addr_counter + 1;
                         --current_state <= SET_ADDRESS;
                    when COL_ONE =>
                         col_index <= col_index + 1;
                         current_state <= ADD_ADDR;                         
                         --addr_counter <= addr_counter + 1;
                         --current_state <= SET_ADDRESS;                        
                    when SET_BASE =>
                         o_en <= '1';
                         o_we <= '1';                   
                         base <= c_max - c_min + 1;  
                         current_state <= SET_ALTEZZA;
                    when SET_ALTEZZA =>
                         o_en <= '1';
                         o_we <= '1';
                         altezza <= r_max - r_min + 1;
                         current_state <= SET_SQUARE;                                            
                    when SET_SQUARE =>
                        o_address <= "0000000000000001";
                        if (base = "00000001" and altezza = "00000001") then
                            square <= "0000000000000000";
                            current_state <= SET_MSB; 
                        else
                            square <= "00000000" & base;
                            multiplier_square <= "00000001"; 
                            --square <= std_logic_vector(base * altezza);
                            current_state <= MULTIPLY_SQUARE;
                        end if;   
                        --current_state <= SET_MSB;
                    when MULTIPLY_SQUARE =>
                         if (multiplier_square = altezza) then
                             o_address <= "0000000000000001";
                             current_state <= SET_MSB;   
                         else
                             multiplier_square <= multiplier_square + 1;
                             square <= square + base;
                             current_state <= MULTIPLY_SQUARE;
                         end if;
                    when SET_MSB =>
                        o_data <= std_logic_vector(square(15 downto 8));
                        current_state <= SET_LSB_ADDRESS;
                    when SET_LSB_ADDRESS =>
                        o_address <= "0000000000000000";
                        current_state <= SET_LSB; 
                    when SET_LSB =>
                        o_data <= std_logic_vector(square(7 downto 0));
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
