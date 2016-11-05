package edu.uno.ai.planning.bfs;

import edu.uno.ai.planning.ss.StateSpacePlanner;
import edu.uno.ai.planning.ss.StateSpaceProblem;
import edu.uno.ai.planning.ss.StateSpaceSearch;

/**
 * A simple, inefficient state-space planner that explores the search space
 * using breadth-first search.
 * @author Manish Bhatt
 */
public class MBhattPlanner extends StateSpacePlanner {

	/**
	 * Constructs a new instance of this planner.
	 */
	public MBhattPlanner() {
		super("mbhatt");
	}

	@Override
	protected StateSpaceSearch makeStateSpaceSearch(StateSpaceProblem problem) {
		return new AStarSearch(problem);
	}
}
