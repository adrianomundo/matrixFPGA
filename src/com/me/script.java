package com.me;

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


}



