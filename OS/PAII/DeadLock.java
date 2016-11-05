import java.util.*;
import java.io.*;

/**
 * Name: Manish Bhatt
 * CSCI 4401 Programming Assignment 2
 * Date: 11/2015
 *  - running program on command line: $ java DeadLock InputFile.txt > OutputFile.txt
 */
public class DeadLock{

    /**
     * DeadLock Constructor
     */
    private DeadLock(){
    }


    /**
     * @param args A parameter of command line arguments. Need an input file as first command line argument.
     */
    public static void main(String[] args){
        (new DeadLock()).run(args[0]);
    }


    /**
     * @param input must include the first argument on the command line, which should be the input file.
     */

    public void run(String input){
        try{
            String inFileName = input; //first argument on command line (input file)
            File inFile = new File(inFileName);
            Scanner in = new Scanner(inFile);
            RAG rag = new RAG();
            int process = 0;
            int resource = 0;
            String NorR = " ";
            boolean cycleDetected = false;
            boolean errorDetected = false;
            int i = 0;
            while(cycleDetected == false && errorDetected == false && in.hasNext()){
                process = Integer.parseInt(in.next().trim());
                NorR = in.next();
                resource = -1*(Integer.parseInt(in.next().trim()));
                if(NorR.equalsIgnoreCase("N")){
                    rag.needsResource(resource, process);
                    if(i != 0 || i != 2)//Only 2 lines of input cannot have DeadLock no need to check
                        cycleDetected = rag.checkForCycle();
                }
                else if(NorR.equalsIgnoreCase("R")){
                    rag.releaseResource(resource, process);
                    //no need to check for cycle
                }
                else{
                    rag.errorOccuredInFormatting();
                    errorDetected = true;
                }
                i++;
            }

            //If no cycle detected
            if(cycleDetected == false){
                rag.noDeadLock();
            }

        }catch (Exception e){
            e.printStackTrace();
        }
    }


    /**
     * Class RAG: Simulates a Resource Allocation Graph using a linked list of Edges, Edges consistings of a pair of resource and process.
     */
    class RAG{
        List<Edge> table;
        boolean hasDeadLock;
        boolean hasCycle;
        boolean cycle;

        /**
         * RAG Constructor
         *
         */
        private RAG(){
            table = new LinkedList<Edge>();
            hasDeadLock = false;
            hasCycle = false;
            cycle = false;
        }

        /**
         * Class Edge: Used to hold pairs of a Resource and Process.  (Left is the left side of the simulated table, and Right is the right side of the simulated table)
         */
        class Edge{
            int left;
            int right;
            boolean visited;


            /**
             * Edge Constructor
             *
             * @param l 
             * @param r 
             */
            private Edge(int l, int r){
                this.left = l;
                this.right = r;
                visited = false;

            }

            @Override
            public boolean equals(Object o){
                Edge c = (Edge) o;
                return (c.left == this.left && c.right == this.right);
            }

        }


        /**
         * Method noDeadLock
         */
        public void noDeadLock(){
            System.out.println("EXECUTION COMPLETED: No DeadLock encountered.");
        }

        /**
         * Method errorOccuredInFormatting
         */
        public void errorOccuredInFormatting(){
            System.out.println("ERROR: Improper formatting in Input File, error occured while reading.");
        }

        /**
         * Method checkForCycle
         * Checks for a cycle(DeadLock) using Depth First Search, using visited nodes in Edge class.
         * @return The return value is true if a DeadLock occured, and false if a DeadLock is not present.
         */
        public boolean checkForCycle(){
            int i = 0;
            for(; i < table.size(); i++){ //set all Edges visited to false
                table.get(i).visited = false;
            }
            i = 0;
            for(; hasDeadLock == false && i < table.size(); i++){
                if(table.get(i).visited == false){
                    List<Integer> cycleList = new ArrayList<Integer>(); //keep list of cycles resources and processes
                    hasDeadLock = hasDeadLock(table.get(i), cycleList);
                }
            }
            return hasDeadLock;
        }


        /**
         * Uses a dummy Edge to determine the end of a traversal, where a next Edge cannot be found (Edge(0, 0) where Edge.left == 0, and Edge.right == 0).
         * @param e A parameter that represents the current Edge being traversed for DeadLock detection.
         * @param cycleList A parameter the current traversal list being kept incase a DeadLock occurs.
         * @return The return value is true if a cycle is detected
         */
        public boolean hasDeadLock(Edge e, List<Integer> cycleList){
            //uses global variable hasCycle
            e.visited = true;
            Edge nextEdge = getNext(e); //get the next edge to search for a cycle
            cycleList.add(e.left);

            if(hasCycle(cycleList)){
                hasCycle = true;
                Collections.sort(cycleList); //To get processes and resources from least to greatest
                System.out.println("DeadLock DETECTED: Processes "+processesInCycle(cycleList)+"and Resources "+resourcesInCycle(cycleList));
            }
            else{ //if no next edge found break recursion here
                if(!(nextEdge.right == 0 && nextEdge.left == 0))
                    hasDeadLock(nextEdge, cycleList);
                else
                    hasCycle = false;
            }
            return hasCycle;

        }

        /**
         *this method is called to pull out the processes in the cycleList,
         * and order them from least to greatest, and return a string of these processes for print out.
         * @param cycleList A parameter that contains the cycleList where a cycle was detected.
         * @return The return value is a String of processes contained in the cycle, ordered from least to greatest.
         */
        public String processesInCycle(List<Integer> cycleList){
            String s = "";
            for(int i = 0; i < cycleList.size(); i++){
                if(cycleList.get(i) > 0)
                    s+= (Integer.toString(cycleList.get(i)) + ", ");
            }
            return s;
        }

        /**
         * If a cycle is detected in hasDeadLock, this method is called to pull out the resources in the cycleList, convert them to positive numbers,
         * and order them from least to greatest, and return a string of these resources for print out.
         * @param cycleList A parameter that contains the cycleList where a cycle was detected.
         * @return The return value is a String of resources contained in the cycle, ordered from least to greatest.
         */
        public String resourcesInCycle(List<Integer> cycleList){
            String s = "";
            List<Integer> tempList = new LinkedList<Integer>();
            for(int i = 0; i < cycleList.size(); i++){
                if(cycleList.get(i) < 0)
                    tempList.add(cycleList.get(i)*-1);
            }

            Collections.sort(tempList); //sort the positive list of resources
            for(int i = 0; i < tempList.size(); i++)
                s+= (Integer.toString(tempList.get(i)) + ", ");

            return s;
        }

        /**
         * Method hasCycle
         * Checks for a repeated process # in the cycleList to determine whether a cycle exists
         * @param cycleList A parameter that consists of the current cycleList from traversing the Edges.
         * @return The return value returns true if the last element in the List is repeated at any point earlier in the list, then a cycle has occured.  Returns false otherwise.
         */
        public boolean hasCycle(List<Integer> cycleList){

            int last = cycleList.get(cycleList.size()-1); //get the last added element of cycleList for comparison
            for(int i = 0; cycle == false && i < cycleList.size()-1; i++){
                if(cycleList.get(i).equals(last)){
                    cycle = true;
                    cycleList.remove(i);//remove last added element from cycleList for printout of process/resource in cycle for in proccessesInCycle method and resourcesInCycle method.
                }
            }
            return cycle;
        }
        
        /**
         * Gets the next Edge of traversal by checking if the right side of the edge is equal to any edge's left side in the entire table.
         * @param e A parameter pointing to the current Edge.
         * @return The return value is the next Edge to be processed.
         */
        public Edge getNext(Edge e){
            int i = 0;
            Edge next = new Edge(0,0);
            boolean nextFound = false;
            for(; nextFound == false && i < table.size(); i++){
                if(table.get(i).left == e.right){
                    next = table.get(i);
                    nextFound = true;
                }
            }
            return next;

        }

        /**
         * A process requests a resource. If the resource is taken then the process must wait. If the resource is not on the left side of the table(taken) then
         * @param resource A parameter containing the resource needed.
         * @param process A parameter containing the process requesting the resource.
         */
        public void needsResource(int resource, int process){
            System.out.print("Process " + Integer.toString(process)+ " needs resource " +Integer.toString(resource*-1) + " - ");
            boolean exists = false;
            int i = 0;
            while(exists == false && i < table.size()){
                if(table.get(i).left == resource){
                    exists = true; //Resource is taken right now
                    System.out.println("Process " +Integer.toString(process) + " must wait.");
                }
                i++;
            }
            if(exists == false){ //If the resource isn't taken add the edge to the table
                Edge e = new Edge(resource, process);
                table.add(e);
                System.out.println("Resource " +Integer.toString(resource*-1) + " is allocated to process " + Integer.toString(process)+".");
            }
            else{
                Edge e = new Edge(process, resource); //process waiting on left side of table
                table.add(e); //add to end
            }
        }


        /**
         * A process is realeasing a resource.  
         * @param resource A parameter containing the resource to release.
         * @param process A parameter containing the process holding the resource to release.
         */
        public void releaseResource(int resource, int process){
            System.out.print("Process " +Integer.toString(process)+ " releases resource " +Integer.toString(resource*-1)+ " - ");
            //create edge to find equal edge in table if it exists
            Edge e = new Edge(resource, process);
            boolean edgeFound = false;
            int j = 0;
            while(edgeFound == false && j < table.size()){//find edge
                if(e.equals(table.get(j)))
                    edgeFound = true;
                else
                    j++;
            }

            //remove edge if the edge was found
            if(edgeFound)
                table.remove(j);
            else{
                System.out.println("ERROR EDGE NOT FOUND");
                errorOccuredInFormatting();
            }
            int i = 0;
            boolean resourceFoundBeingWaitedOn = false;
            while(resourceFoundBeingWaitedOn == false && i < table.size()){
                if(table.get(i).right == resource)
                    resourceFoundBeingWaitedOn = true;
                else
                    i++;
            }

            if(resourceFoundBeingWaitedOn){
                int newLeft = table.get(i).right;
                int newRight = table.get(i).left;
                table.get(i).left = newLeft;
                table.get(i).right = newRight;
                System.out.println("Resource "+(resource*-1)+" is allocated to process "+newRight+".");
            }
            //else resource is now free
            else{
                System.out.println("Resource " +(resource*-1)+" is now free.");
            }

        }

    }
}