import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.*;
import java.util.*;
/**
 * This class uses threading to find matrix product.
 * @author Manish
 *
 */

public class matrixmul
{ 
  private static BufferedReader br;
  private static BufferedReader br2;
  public static void main(String[] args)
  {
    double[][] A = new double[100][100];       // create matrices
    double[][] B = new double [100] [100];
    double[][] C = new double[A.length][B[0].length];
    int cores = Runtime.getRuntime().availableProcessors();
    System.out.println(cores + " cores.");
    Scanner input = new Scanner(System.in);
    System.out.println("Enter location of input file: ");
    String file = input.next();//reading input location
    try {
        br = new BufferedReader(new FileReader(file));
        br2 = new BufferedReader(new FileReader(file));
        br.mark(99999);
        br2.mark(99999);
    } catch (Exception e) {
        e.printStackTrace();
    }

    String sCurrentLine;

    try {
        while (br.readLine() != null) {
            br.reset();
            int columns1 = 0;
            int rows1 = 0;
            int columns2 = 0;
            int rows2 = 0;
            System.out.println("Starting to Parse Matrix "  );
            while ((sCurrentLine = br.readLine()) != null && !sCurrentLine.isEmpty()) {//getting first matrix size
                if (rows1 == 0) {
                    columns1 = sCurrentLine.split(",").length;
                } 
                rows1++;
            }
            int n = rows1;
            while ((sCurrentLine = br.readLine()) != null && !sCurrentLine.isEmpty()) {//getting second matrix size
                if (rows2 == 0) {
                    columns2 = sCurrentLine.split(",").length;
                } 
                rows2++;
            }
            int max = 100;
           
            br.mark(9999);
            A = new double[rows1][columns1];
            B = new double[rows2][columns2];
            C = new double[rows1][columns2];
            int counter = 0;
            while ((sCurrentLine = br2.readLine()) != null && !sCurrentLine.isEmpty()) {//reading first matrix
                A[counter] = StringToDoubleArray(sCurrentLine.split(","));
                counter++;
            }
            counter = 0;
            while ((sCurrentLine = br2.readLine()) != null && !sCurrentLine.isEmpty()) {//reading second matrix
                B[counter] = StringToDoubleArray(sCurrentLine.split(","));
                counter++;
            }
    
            System.out.println(rows1);
            System.out.println(columns1);
            System.out.println(rows2);
            System.out.println(columns2);
    
    
    printMatrix(A);                          // print matrices for control
    System.out.println();
    printMatrix(B);
    System.out.println();

    Thread[][] workers = new Thread[C.length ][ C[0].length];
    int k = C.length*C[0].length;
	System.out.println("Number of Threads created: " + k );
	System.out.println("Now creating Threads " );
    for (int i=0; i<C.length; i++)           // create working threads
      for (int j=0; j<C[0].length; j++)
      { 
    	
        workers[i][j] = new WorkerThread(i, j, A, B, C);    
        workers[i][j].start();
        
        workers[i][j].join();
        
        
       
      }

      System.out.println("Threads killed "  );

    printMatrix(C);
    }
        }catch(Exception e){
    	
    }                          // print the result
    
  }
        
  
  
  public static double[] column(double matrix[][], int x) {
            int elements = matrix.length;
            double array[] = new double[elements];
            for (int i = 0; i < elements; i++) {
                array[i] = matrix[i][x];
            }
            return array;
        }

        //method to parse strings to doubles
        public static double[] StringToDoubleArray(String array[]) {
            double doubles[] = new double[array.length];
            for (int i = 0; i < array.length; i++) {
                doubles[i] = Double.parseDouble(array[i]);
            }
            return doubles;
        }
  public static void printMatrix(double[][] a)  // prints a matrix
  {
    for (int i=0; i<a.length; i++)
    {
      for (int j=0; j<a[0].length; j++)
        System.out.println( a[i][j] + " ");
      System.out.println();
    }
  }
}
