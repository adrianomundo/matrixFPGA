package com.me;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

class script {

    private static final String ZERO = "00000000";

    private int randomInt() {
        Random random = new Random();
        return random.nextInt(256);
    }


    private String bin(int decimal) {
        String bin = Integer.toBinaryString(decimal);
        if (bin.length() == 8) {
            return bin;
        } else if (bin.length() == 7) {
            return "0" + bin;
        } else if (bin.length() == 6) {
            return "00" + bin;
        } else if (bin.length() == 5) {
            return "000" + bin;
        } else if (bin.length() == 4) {
            return "0000" + bin;
        } else if (bin.length() == 3) {
            return "00000" + bin;
        } else if (bin.length() == 2) {
            return "000000" + bin;
        } else {
            return "0000000" + bin;
        }
    }

    String binSquare(String bin) {

        if (bin.length() == 16) {
            return bin;
        } else if (bin.length() == 15) {
            return "0" + bin;
        } else if (bin.length() == 14) {
            return "00" + bin;
        } else if (bin.length() == 13) {
            return "000" + bin;
        } else if (bin.length() == 12) {
            return "0000" + bin;
        } else if (bin.length() == 11) {
            return "00000" + bin;
        } else if (bin.length() == 10) {
            return "000000" + bin;
        } else if (bin.length() == 9) {
            return "0000000" + bin;
        } else if (bin.length() == 8) {
            return "00000000" + bin;
        } else if (bin.length() == 7) {
            return "000000000" + bin;
        } else if (bin.length() == 6) {
            return "0000000000" + bin;
        } else if (bin.length() == 5) {
            return "00000000000" + bin;
        } else if (bin.length() == 4) {
            return "000000000000" + bin;
        } else if (bin.length() == 3) {
            return "0000000000000" + bin;
        } else if (bin.length() == 2) {
            return "00000000000000" + bin;
        } else {
            return "000000000000000" + bin;
        }
    }


    void fillMatrix(String[] matrix) {

        matrix[0] = ZERO;
        matrix[1] = ZERO;

        int squareToFill = Integer.parseInt(matrix[2], 2) * Integer.parseInt(matrix[3], 2);

        for (int i = 5; i < matrix.length; i++) {
            if (i <= squareToFill + 4) {
                matrix[i] = bin(randomInt());
            } else {
                matrix[i] = ZERO;
            }
        }
    }

    void setLength(String[] matrix) {
        matrix[2] = bin(randomInt());
    }

    void setHeight(String[] matrix) {
        matrix[3] = bin(randomInt());
    }

    void setThreshold(String[] matrix) {
        matrix[4] = bin(randomInt());
    }

    List<Integer> values(String[] matrix) {
        List<Integer> values = new ArrayList<>();
        values.add(Integer.parseInt(matrix[2], 2));
        values.add(Integer.parseInt(matrix[3], 2));
        values.add(Integer.parseInt(matrix[4], 2));
        return values;
    }

    List<Integer> minRectCalculator(String[] matrix) {

        int length = Integer.parseInt(matrix[2],2)-1;
        int xMin = 0;
        int xMax = 0;
        int yMin = 0;
        int yMax = 0;
        boolean xFounded = false;
        boolean yFounded = false;
        int threshold = Integer.parseInt(matrix[4], 2);
        int squareToFill = Integer.parseInt(matrix[2],2) * Integer.parseInt(matrix[3], 2);
        int indexRow = 0;
        int indexCol = 0;

        for (int i = 5; i <= squareToFill + 4; i++) {

            if (Integer.parseInt(matrix[i], 2) >= threshold) {
                if (!xFounded) {
                    xMin = indexCol;
                    xMax = indexCol;
                    xFounded = true;
                }
                else {
                    if (indexCol < xMin)
                        xMin = indexCol;
                    if (indexCol > xMax)
                        xMax = indexCol;
                }
                if (!yFounded) {
                    yMin = indexRow;
                    yMax = indexRow;
                    yFounded = true;
                }
                else {
                    if (indexRow < yMin)
                        yMin = indexRow;
                    if (indexRow > yMax)
                        yMax = indexRow;
                }
            }

            if (indexCol == length) {
                indexCol = 0;
                indexRow++;
            }
            else {
                indexCol++;
            }

        }

        int square = (xMax - xMin + 1) * (yMax - yMin + 1);

        List<Integer> valori = new ArrayList<>();
        valori.add(square);
        valori.add(xMin);
        valori.add(xMax);
        valori.add(yMin);
        valori.add(yMax);
        return valori;

    }

    static String fillMatrixTest(String[] matrix, int squareToFill) {

        String str = "";

        for(int i = 2; i < matrix.length; i++) {
            if (i <= squareToFill) {
                str = str + (toStringMatrix(matrix[i], i));
            }
            else {
                break;
            }
        }
        str = str + (toStringOthers());

        return str;
    }

    static String toStringMatrix(String matrixValue, int index) {

        String str = index + " => " + "\"" + matrixValue + "\"" + ",";
        return str;
    }

    static String toStringOthers() {
        return "others => (others =>'0')";
    }


    static void testBench(List<Integer> list, String[] matrix, int square) throws IOException {

        File file = new File("./");
        System.out.println(file.getAbsolutePath());
        String filePath = file.getAbsolutePath().replace(".", "src/com/me/testbench.vhd");
        File test = new File(filePath);
        test.createNewFile();

        System.out.println(filePath);

        try (FileWriter writer = new FileWriter(test)) {
            writer.write(" library ieee;\n" +
                    "use ieee.std_logic_1164.all;\n" +
                    "use ieee.numeric_std.all;\n" +
                    "use ieee.std_logic_unsigned.all;\n" +
                    " \n" +
                    "entity project_tb is\n" +
                    "end project_tb;\n" +
                    "\n" +
                    "\n" +
                    "architecture projecttb of project_tb is\n" +
                    "constant c_CLOCK_PERIOD\t\t: time := 15 ns;\n" +
                    "signal   tb_done\t\t: std_logic;\n" +
                    "signal   mem_address\t\t: std_logic_vector (15 downto 0) := (others => '0');\n" +
                    "signal   tb_rst\t\t    : std_logic := '0';\n" +
                    "signal   tb_start\t\t: std_logic := '0';\n" +
                    "signal   tb_clk\t\t    : std_logic := '0';\n" +
                    "signal   mem_o_data,mem_i_data\t\t: std_logic_vector (7 downto 0);\n" +
                    "signal   enable_wire  \t\t: std_logic;\n" +
                    "signal   mem_we\t\t: std_logic;\n" +
                    "\n" +
                    "type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);\n" +
                    "signal RAM: ram_type := (" + fillMatrixTest(matrix,square) + ");\n" +
                    "\n" +
                    "\n" +
                    "component project_reti_logiche is \n" +
                    "    port (\n" +
                    "            i_clk         : in  std_logic;\n" +
                    "            i_start       : in  std_logic;\n" +
                    "            i_rst         : in  std_logic;\n" +
                    "            i_data       : in  std_logic_vector(7 downto 0); --1 byte\n" +
                    "            o_address     : out std_logic_vector(15 downto 0); --16 bit addr: max size is 255*255 + 3 more for max x and y and thresh.\n" +
                    "            o_done            : out std_logic;\n" +
                    "            o_en         : out std_logic;\n" +
                    "            o_we       : out std_logic;\n" +
                    "            o_data            : out std_logic_vector (7 downto 0)\n" +
                    "          );\n" +
                    "end component project_reti_logiche;\n" +
                    "\n" +
                    "\n" +
                    "begin \n" +
                    "\tUUT: project_reti_logiche\n" +
                    "\tport map (\n" +
                    "\t\t  i_clk      \t=> tb_clk,\t\n" +
                    "          i_start       => tb_start,\n" +
                    "          i_rst      \t=> tb_rst,\n" +
                    "          i_data    \t=> mem_o_data,\n" +
                    "          o_address  \t=> mem_address, \n" +
                    "          o_done      \t=> tb_done,\n" +
                    "          o_en   \t=> enable_wire,\n" +
                    "\t\t  o_we \t=> mem_we,\n" +
                    "          o_data    => mem_i_data\n" +
                    ");\n" +
                    "\n" +
                    "p_CLK_GEN : process is\n" +
                    "  begin\n" +
                    "    wait for c_CLOCK_PERIOD/2;\n" +
                    "    tb_clk <= not tb_clk;\n" +
                    "  end process p_CLK_GEN; \n" +
                    "  \n" +
                    "  \n" +
                    "MEM : process(tb_clk)\n" +
                    "   begin\n" +
                    "    if tb_clk'event and tb_clk = '1' then\n" +
                    "     if enable_wire = '1' then\n" +
                    "      if mem_we = '1' then\n" +
                    "       RAM(conv_integer(mem_address))              <= mem_i_data;\n" +
                    "       mem_o_data                      <= mem_i_data;\n" +
                    "      else\n" +
                    "       mem_o_data <= RAM(conv_integer(mem_address));\n" +
                    "      end if;\n" +
                    "     end if;\n" +
                    "    end if;\n" +
                    "   end process;\n" +
                    " \n" +
                    "  \n" +
                    "  \n" +
                    "test : process is\n" +
                    "begin \n" +
                    "wait for 100 ns;\n" +
                    "wait for c_CLOCK_PERIOD;\n" +
                    "tb_rst <= '1';\n" +
                    "wait for c_CLOCK_PERIOD;\n" +
                    "tb_rst <= '0';\n" +
                    "wait for c_CLOCK_PERIOD;\n" +
                    "tb_start <= '1';\n" +
                    "wait for c_CLOCK_PERIOD; \n" +
                    "tb_start <= '0';\n" +
                    "wait until tb_done = '1';\n" +
                    "wait until tb_done = '0';\n" +
                    "wait until rising_edge(tb_clk); \n" +
                    "\n" +
                    "assert RAM(1) = " + "\"" + matrix[1] + "\"" + " " + "report \"FAIL high bits\" severity failure;\n" +
                    "assert RAM(0) = " +  "\"" + matrix[0] + "\"" + " " + "report \"FAIL low bits\" severity failure;\n" +
                    "\n" +
                    "\n" +
                    "assert false report \"Simulation Ended!, test passed\" severity failure;\n" +
                    "end process test;\n" +
                    "\n" +
                    "end projecttb; \n"
            );
        }


    }


}



