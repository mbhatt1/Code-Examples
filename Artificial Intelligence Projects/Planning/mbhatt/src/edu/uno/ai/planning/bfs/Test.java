package edu.uno.ai.planning.bfs;

import java.io.File;

import edu.uno.ai.planning.Domain;
import edu.uno.ai.planning.Planner;
import edu.uno.ai.planning.Problem;
import edu.uno.ai.planning.Result;
import edu.uno.ai.planning.Step;
import edu.uno.ai.planning.io.Parser;
import edu.uno.ai.planning.ss.StateSpacePlanner;

/**
 * This class provides an UNOFFICIAL way to test your planner from inside your
 * IDE.  Note that this IS NOT how your project will be graded.
 * 
 * @author Stephen G. Ware
 */
public class Test {

	/** Represents an individual benchmark problem */
	private static final class Benchmark {
		
		/** The name of the domain */
		public final String domain;
		/** The name of the problem */
		public final String problem;
		/** The maximum number of nodes that may be visited during search */
		public final int limit;
		
		/**
		 * Constructs a new benchmark problem.
		 * 
		 * @param domain the name of the domain
		 * @param problem the name of the problem
		 * @param limit the maximum number of nodes that may be visited during search
		 */
		public Benchmark(String domain, String problem, int limit) {
			this.domain = domain;
			this.problem = problem;
			this.limit = limit;
		}
	}
	
	/**
	 * A list of all the benchmark planning problems.  You can comment out
	 * lines to test on a subset of problems.  Students enrolled in 4525 may
	 * change all the limits to 100,000 nodes.
	 */
	private static final Benchmark[] BENCHMARKS = new Benchmark[]{
		new Benchmark("cake", "do_nothing", 10),
		new Benchmark("cake", "eat_cake", 10),
		new Benchmark("cake", "have_eat_cake", 10),
		new Benchmark("blocks", "easy_stack", 10),
		new Benchmark("blocks", "easy_unstack", 10),
		new Benchmark("blocks", "sussman", 50),
		new Benchmark("blocks", "reverse_2", 10),
		new Benchmark("blocks", "reverse_4", 50),
		new Benchmark("blocks", "reverse_6", 50),
		new Benchmark("blocks", "reverse_8", 50),
		new Benchmark("blocks", "reverse_10", 100),
		new Benchmark("blocks", "reverse_12", 500),
		new Benchmark("cargo", "deliver_1", 10),
		new Benchmark("cargo", "deliver_2", 50),
		new Benchmark("cargo", "deliver_3", 500),
		new Benchmark("cargo", "deliver_4", 1000),
		new Benchmark("cargo", "deliver_return_1", 50),
		new Benchmark("cargo", "deliver_return_2", 500),
		new Benchmark("cargo", "deliver_return_3", 100000),
		new Benchmark("cargo", "deliver_return_4", 100000),
		new Benchmark("wumpus", "easy_wumpus", 10),
		new Benchmark("wumpus", "medium_wumpus", 50),
		new Benchmark("wumpus", "hard_wumpus", 10000),
	};
	
	/**
	 * Runs the planner on all benchmark problems and prints the results to the
	 * console.
	 * 
	 * @param args ignored
	 * @throws Exception if any exceptions occur during execution
	 */
	public static void main(String[] args) throws Exception {
		StateSpacePlanner planner = new MBhattPlanner();
		System.out.println("Testing " + planner.name);
		Parser parser = new Parser();
		int passed = 0;
		for(Benchmark benchmark : BENCHMARKS) {
			parser.parse(new File("benchmarks/" + benchmark.domain + ".pddl"), Domain.class);
			Problem problem = parser.parse(new File("benchmarks/" + benchmark.problem + ".pddl"), Problem.class);
			Result result = planner.findSolutuion(problem, benchmark.limit, Planner.NO_TIME_LIMIT);

			System.out.println("-------------------------");
			System.out.println("Domain:        " + benchmark.domain);
			System.out.println("Problem:       " + benchmark.problem);
			System.out.println("Result:        " + (result.success ? "success" : "failure"));
			System.out.println("Nodes Visited: " + result.visited);
			if(result.success) {
				passed++;
				System.out.println("Plan:");
				for(Step step : result.solution)
					System.out.println("  " + step);
			}
		}
		System.out.println("-------------------------");
		System.out.println("Results:       " + passed + "/" + BENCHMARKS.length + " benchmarks passed");
	}
}
