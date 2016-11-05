/**
 * This class creates worker threads
 * @author Admin
 *
 */
class WorkerThread extends Thread           // thread for computing one
{                                           // matrix element C[row][col]
  private int row;
  private int col;
  private double[][] A;
  private double[][] B;
  private double[][] C;

  public WorkerThread(int row, int col, double[][] A, double[][] B, double[][] C)
  { 
    this.row = row;                         // thread constructor
    this.col = col;
    this.A = A;
    this.B = B;
    this.C = C;
  }
/**
 * This method is the run method that needs to be implemented because this class
 * extends the threads class.  
 */
public void run()                         // here we do all the job 
  {
    System.out.println("Thread(" + row + "," + col + ") started");
    try
    {
      Thread.sleep(5);                      // this call simulates longer
    }                                       // computations (for demo only)
    catch(InterruptedException e){}
    C[row][col] = 0;
    for (int k=0; k<A[0].length; k++)
      C[row][col] += A[row][k] * B[k][col]; 
    System.out.println("Thread(" + row + "," + col + ") stopped");
  }
}