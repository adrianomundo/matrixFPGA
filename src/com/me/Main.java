package com.me;


import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


public class Main {


    public static void main(String[] args) {

        String msb;
        String lsb;
        int squareToFill;
        String[] matrix;

        script script = new script();
        matrix = new String[65536];

        script.setHeight(matrix);
        script.setLength(matrix);
        script.setThreshold(matrix);
        script.fillMatrix(matrix);

        //List<Integer> list = new ArrayList<>(script.values(matrix));

        //for (Integer value : list) {
          //  System.out.println(value);
        //}


        squareToFill = Integer.parseInt(matrix[2],2) * Integer.parseInt(matrix[3], 2);
        //System.out.println("square matrix " + squareToFill);

        //System.out.println("min rect");
        List<Integer> val  = script.minRectCalculator(matrix);
        //System.out.println(val);

        String bin = Integer.toBinaryString(val.get(0));
        String binArea = script.binSquare(bin);
        msb = binArea.substring(0, 8);
        lsb = binArea.substring(8, 16);
        //System.out.println(msb);
        //System.out.println(lsb);

        matrix[1] = msb;
        matrix[0] = lsb;

        com.me.script.fillMatrixTest(matrix, squareToFill);

        try {
            script.testBench(val, matrix, squareToFill);
        } catch (IOException e) {
            e.printStackTrace();
        }

    }


}
