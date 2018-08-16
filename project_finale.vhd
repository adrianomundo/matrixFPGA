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
    
    type state_type is (IDLE, START, ADD_ADDRESS, SET_ADDRESS, UPDATE, READ_MEM,  WIDTHS, HEIGHTS, 
                        MAX_ADDRESS , MULTIPLY_ADDRESS, MAX_ADDR_4, THRESHOLDS, GOSTOP, 
                        INDEX_COL, CHECK_THRES, INDEX_COL_ASSIGNED, INDEX_ROW, INDEX_ROW_ASSIGNED, 
                        SET_NEXT, MULTIPLY_SQUARE, 
                        BASE_ALTEZZA, SET_SQUARE, MSB, LSB, LSB_ADDRESS, SET_DONE, UNSET_DONE);
                         
    signal current_state : state_type := IDLE;
    
    signal c_min_assigned, r_min_assigned : std_logic := '0'; 

    signal height, threshold : unsigned (7 downto 0);
    signal multiplier_square, multiplier_address : unsigned (7 downto 0):= "00000000";
    signal c_min, c_max, r_min, r_max, col_index, row_index, base, altezza : unsigned (7 downto 0) := "00000000";
    
    signal width, width_max : unsigned (15 downto 0);
    signal square_address, max_addr, max_addr_out_range, addr_counter, square  : unsigned (15 downto 0);
    

begin
   
    lambda_delta : process(i_clk, i_rst)
   
    begin
        if (i_rst = '1') then
            --o_en <= '0';
            o_en <= '1';
            addr_counter <= "0000000000000010";
            square <= "0000000000000000";
            width <= "0000000000000000";
            c_max <= "00000000";
            c_min <= "00000000";
            r_max <= "00000000";
            r_min <= "00000000";
            c_min_assigned <= '0';
            r_min_assigned <= '0';
            col_index <= "00000000";
            row_index <= "00000000";
            current_state <= IDLE;  
        elsif rising_edge(i_clk) then
                case current_state is
                
                    --stato che resta in attesa che il segnale di i_start venga portato
                    --ad uno per poter passare allo stato di start
                    when IDLE =>
                        if (i_start = '1') then
                            current_state <= START;
                        else 
                            current_state <= IDLE;
                        end if;
                        
                    --stato che resta in attesa che il segnale i_start venga riportato a 
                    --zero per poter iniziare la lettura della matrice, dopo aver settato 
                    --i segnali correttamente per poter comunicare con la memoria in lettura    
                    when START =>
                        if (i_start = '1') then
                            current_state <= START;
                        else 
                            o_we <= '0';
                            o_en <= '1';
                            current_state <= SET_ADDRESS; 
                        end if;
                        
                    --stato che aumenta il valore del segnale addr_counter che tiene traccia
                    --dell' indirizzo corrente sul quale si dovrà effettura l'operazione di lettura o scrittura    
                    when ADD_ADDRESS =>
                         addr_counter <= addr_counter + 1;
                         current_state <= SET_ADDRESS;
                         
                    --stato che setta in o_address nella memoria, il valore attuale dell'addr_counter, così che
                    --l'indirizzo al quale si vuole leggere/scrivere nella memoria sia quello dell'addr_counter                    
                    when SET_ADDRESS =>
                        o_address <= std_logic_vector(addr_counter);
                        current_state <= UPDATE;
                        
                    --stato di attesa dell'aggiornamento del valore del valore in memoria, in attesa di un nuovo
                    --ciclo di clock    
                    when UPDATE =>
                         current_state <= READ_MEM;
                         
                    --stato che in seguito al settaggio dell'o_address col valore dell'addr_counter decide come 
                    --proseguire nell'elaborazione in base al valore di addr_counter
                    when READ_MEM =>
                         if (addr_counter = "0000000000000010") then
                             current_state <= WIDTHS;
                         elsif (addr_counter = "0000000000000011") then
                             current_state <= HEIGHTS;
                         elsif (addr_counter = "0000000000000100") then
                             current_state <= MAX_ADDRESS;
                         else 
                             current_state <= GOSTOP;
                         end if;
                         
                    --stato che memorizza nel segnale width il valore attuale ricevuto in ingresso su i_data
                    --concatenando 8 bit a 0 poichè width è un segnale a 16 bit ed i_data ad 8 bit, memorizza
                    --quindi il valore del numero di colonne dell'immagine considerata           
                    when WIDTHS =>
                         width <= unsigned("00000000" & i_data);
                         current_state <= ADD_ADDRESS;
                         
                    -- stato che memorizza nel segnale height il valore attuale ricevuto in ingresso su i_data
                    -- che corrisponde all'altezza della matrice dell'immagine, inoltre memorizza in una variabile
                    -- width_max che sarà usata sucessivamente per calcolare il valore del massimo indirizzo fino 
                    -- al quale leggere la matrice il valore di width, ed infine aggiorna width diminuendo
                    -- di uno il valore per poter gestire gli indici di colonna a partire da 0 e non da 1     
                    when HEIGHTS =>
                         height <= unsigned(i_data);
                         if (width = "0000000000000000") then
                             current_state <= BASE_ALTEZZA;
                         else
                             width_max <= width;
                             width <= width - 1;
                             current_state <= ADD_ADDRESS;   
                         end if;

                         
                    --stato attivato dopo la lettura dei valori di altezza e larghezza, nel quale viene settato ad 1 il
                    --valore di un segnale multiplier_address, il quale funge da moltiplicatore e tiene traccia di quante
                    --moltiplicazioni (effettuate come somme ripetute) sono state effettuate fino a quel momento, il suo valore
                    --iniziale è 1 poichè subito dopo, il segnale square_address viene inizializzato al valore width_max che
                    --contiene il valore della larghezza imposto dalla memoria 
                    when MAX_ADDRESS =>
                         if (height = "00000000") then
                             current_state <= BASE_ALTEZZA;
                         else
                             multiplier_address <= "00000001";
                             square_address <= width_max;
                             current_state <= MULTIPLY_ADDRESS; 
                         end if; 

                    
                    --stato che nel momento in cui il valore di multiplier_address è uguale ad height, vuol dire che ha
                    --raggiunto il valore massimo di somme ripetute e quindi passa ad uno stato diverso, altrimenti aggiornare
                    --il valore del multiplier_address e di square_address, dopodichè rientra nello stato     
                    when MULTIPLY_ADDRESS =>
                         if (multiplier_address = height) then
                             current_state <= MAX_ADDR_4;
                         else 
                             multiplier_address <= multiplier_address + 1;
                             square_address <= square_address + width_max;
                             current_state <= MULTIPLY_ADDRESS;
                         end if;
                         
                    --stato che memorizza il vero valore fino al quale si deve effettuare la lettura della memoria, il cui valore
                    --è dato dal valore calcolato di square_address precedentemente, che altro non è che l'area massima del rettangolo
                    --con i valori di numero righe e colonne letto dalla memoria più uno shift di 4 indirizzi per sopperire agli indirizzi
                    --iniziali usati per memorizzare il risultato della computazione e gli altri valori di base             
                    when MAX_ADDR_4 =>
                         max_addr <= square_address + 4;
                         current_state <= THRESHOLDS;
                    
                    --stato che memorizza nel segnale threshold il valore di soglia letto dalla memoria e giunto in ingresso sul
                    --segnale i_data, e memorizza nel segnale max_addr_out_range il primo valore fuori dal range di indirizzo, il
                    --quale non deve essere considerato nella lettura della memoria                              
                    when THRESHOLDS =>  
                         threshold <= unsigned(i_data);
                         max_addr_out_range <= max_addr + 1;
                         current_state <= ADD_ADDRESS;
             
                    --stato in cui la fsm giunge ogni qual volta vien letto un indirizzo che non sia uno dei primi 3 che settano i 
                    --valori base per l'elaborazione, in primis lo stato controllo se addr_counter che viene aggiornato anche dopo
                    --la lettura dell'ultimo indirizzo dell'area massima, sia uguale al valore max_addr_out_range, ed in tal caso
                    --alza il segnale di o_en e di o_we per poter scrivere in memoria e passa allo stato SET_BASE, altrimenti entra
                    --nello stato di controllo indice colonna
                    when GOSTOP =>
                         if (addr_counter = max_addr_out_range) then
                             o_en <= '1';
                             o_we <= '1';
                             current_state <= BASE_ALTEZZA;
                         else 
                             current_state <= CHECK_THRES;
                         end if;
                    
                    --stato che controlla se il valore letto dalla memoria è >= soglia, quindi se appartiene all'immagine, passa
                    --nello stato di controllo, altrimenti entra in uno stato che controlla gli indici e aggiorna l'indirizzo        
                    when CHECK_THRES =>
                        if (unsigned(i_data) >= threshold) then
                            current_state <= INDEX_COL;                         
                        else 
                            current_state <= SET_NEXT;    
                        end if;
                    
                    --stato che setta i valor dei segnali c_min e c_max al valore attuale di col_index se i valori non sono mai stati
                    --assegnati, e tale controllo viene fatto tramite il segnale ad un bit c_min_assigned, dopodichè passa al check delle righe
                    --oppure fa direttamente un controllo nel caso i valori  c_min e c_max siano già stati assegnati almeno una volta 
                    when INDEX_COL =>
                         if (c_min_assigned = '0') then
                             c_min <= col_index;
                             c_max <= col_index;
                             c_min_assigned <= '1';
                             current_state <= INDEX_ROW;
                         else 
                            current_state <= INDEX_COL_ASSIGNED;
                         end if;
                     
                    --stato che controlla l'aggiornamento dei valori di c_min e c_max in base al col_index corrente,dopo passa a fare
                    --controllo degli indici di riga                                                         
                    when INDEX_COL_ASSIGNED =>
                         if (col_index < c_min) then
                             c_min <= col_index;
                             current_state <= INDEX_ROW;
                         elsif (col_index > c_max) then
                             c_max <= col_index;
                             current_state <= INDEX_ROW;
                         else
                             current_state <= INDEX_ROW;              
                         end if;
                         
                    --stato che setta i valor dei segnali r_min e r_max al valore attuale di row_index se i valori non sono mai stati
                    --assegnati, e tale controllo viene fatto tramite il segnale ad un bit r_min_assigned, dopodichè passa al check delle righe
                    --oppure fa direttamente un controllo nel caso i valori  r_min e r_max siano già stati assegnati almeno una volta                                    
                    when INDEX_ROW =>
                        if (r_min_assigned = '0') then
                            r_min <= row_index;
                            r_max <= row_index;
                            r_min_assigned <= '1';
                            current_state <= SET_NEXT;
                        else
                            current_state <= INDEX_ROW_ASSIGNED;   
                       end if;
                    
                    --stato che controlla i valori r_min ed r_max in base al valore di row_index corrente, dopodichè passa
                    --all'aggiornamento degli indici   
                    when INDEX_ROW_ASSIGNED =>
                        if (row_index < r_min) then
                            r_min <= row_index;
                            current_state <= SET_NEXT;  
                        elsif (row_index > r_max) then
                            r_max <= row_index;
                            current_state <= SET_NEXT;
                        else
                            current_state <= SET_NEXT;    
                        end if;
                     
                    --stato che aggiorna i valori di col_inde e row_index in base a dove ci troviamo nella matrice ed al
                    --valore width che rappresenta la larghezza-1, cosi che gli indici partano da 0, dopodichè si passa 
                    --allo stato che aumenta l'addr_counter                        
                    when SET_NEXT =>
                        if (col_index = width) then
                            col_index <= "00000000";
                            row_index <= row_index + 1;
                            current_state <= ADD_ADDRESS;
                        else
                            col_index <= col_index + 1;
                            current_state <= ADD_ADDRESS;
                        end if;
                    
                    --stato che setta i segnali corretti per poter scrivere in memoria e calcola il valore della base e
                    --dell'altezza del rettangolo minimo che circoscrive la figura
                    when BASE_ALTEZZA =>
                         o_en <= '1';
                         o_we <= '1';                   
                         base <= c_max - c_min + 1;
                         altezza <= r_max - r_min + 1;  
                         current_state <= SET_SQUARE;
                    
                    
                    --stato che setta il valore dell'indirizzo del msb (most significant byte) in memoria e controlla il caso
                    --in cui base ed altezza abbiano valore 1 che significa che entrambi sono in realtà zero, e quindi siamo 
                    --nel caso base di area 0, altrimenti setta il segnale multiplier_square ad uno, per poi passare allo stato
                    --delle somme ripetute (la logica è la stessa precedente, usata nel moltiplicare per calcolare l'indirizzo max)                                                 
                    when SET_SQUARE =>
                        o_address <= "0000000000000001";
                        if (base = "00000001" and altezza = "00000001" and c_min_assigned = '0') then
                            square <= "0000000000000000";
                            current_state <= MSB; 
                        else
                            square <= "00000000" & base;
                            multiplier_square <= "00000001"; 
                            current_state <= MULTIPLY_SQUARE;
                        end if;
                    
                    --stato che nel momento in cui il valore di multiplier_square è uguale ad altezza, vuol dire che ha
                    --raggiunto il valore massimo di somme ripetute e quindi passa ad uno stato diverso, altrimenti aggiornare
                    --il valore del multiplier_square e di square, dopodichè rientra nello stato     
                    when MULTIPLY_SQUARE =>
                         if (multiplier_square = altezza) then
                             o_address <= "0000000000000001";
                             current_state <= MSB;   
                         else
                             multiplier_square <= multiplier_square + 1;
                             square <= square + base;
                             current_state <= MULTIPLY_SQUARE;
                         end if;
                    
                    --stato che scrive in output su o_data gli 8 più significativi del risultato dell'area calcolato precedentemente     
                    when MSB =>
                        o_data <= std_logic_vector(square(15 downto 8));
                        current_state <= LSB_ADDRESS;
                    
                    --stato che setta indirizzo in o_address dell'lsb (less significant byte) in memoria, tale indirizzo è 0    
                    when LSB_ADDRESS =>
                        o_address <= "0000000000000000";
                        current_state <= LSB;
                    
                    --stato che scrive in output su o_data gli 8 bit meno significativi del risultato dell'area calcolato precedentemente     
                    when LSB =>
                        o_data <= std_logic_vector(square(7 downto 0));
                        current_state <= SET_DONE;
                    
                    --stato che alza il segnale di o_done per comunicare la conclusione dell'elaborazione effettuata dal componente    
                    when SET_DONE =>
                        o_en <= '0';
                        o_we <= '0';
                        o_done <= '1';
                        current_state <= UNSET_DONE;
                    
                    -- stato che riporta il segnale di o_done a zero dopo un ciclo di clock                
                    when UNSET_DONE =>
                        o_done <= '0';
                        current_state <= UNSET_DONE;    
               end case;
         end if;
    end process;
    
end FSM;
