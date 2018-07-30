package com.me;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


public class Main {

    private static String msb;
    private static String lsb;
    private static int squareToFill;
    private static String[] matrix;

    public static void main(String[] args) {

        script script = new script();
        matrix = new String[65536];

        script.setHeight(matrix);
        script.setLength(matrix);
        script.setThreshold(matrix);
        script.fillMatrix(matrix);

        //matrix[4] = "11111111";

        List<Integer> list = new ArrayList<>(script.values(matrix));
        for (Integer value : list) {
            System.out.println(value);
        }


        squareToFill = Integer.parseInt(matrix[2],2) * Integer.parseInt(matrix[3], 2);
        System.out.println("square matrix " + squareToFill);

        /*System.out.println("start matrix");
        int count = 0;
        for(int i = 5; i <= squareToFill + 4; i++) {
            count++;
            System.out.println(matrix[i]);
            System.out.println(count);
        }*/

        System.out.println("min rect");
        List<Integer> val  = script.minRectCalculator(matrix);
        System.out.println(val);

        String bin = Integer.toBinaryString(val.get(0));
        String binArea = script.binSquare(bin);
        msb = binArea.substring(0, 8);
        lsb = binArea.substring(8, 16);
        System.out.println(msb);
        System.out.println(lsb);

        fillMatrixTest(matrix);

        /*try {
            Main.testBench(val, matrix);
        } catch (IOException e) {
            e.printStackTrace();
        }*/

    }

    static String fillMatrixTest(String[] matrix) {

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


    static void testBench(List<Integer> list, String[] matrix) throws IOException {

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
                    "signal RAM: ram_type := (" + fillMatrixTest(matrix) + ");\n" +
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
                    "assert RAM(1) = " + "\"" + msb + "\"" + " " + "report \"FAIL high bits\" severity failure;\n" +
                    "assert RAM(0) = " +  "\"" + lsb + "\"" + " " + "report \"FAIL low bits\" severity failure;\n" +
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
