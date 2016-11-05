package edu.uno.ai.planning.bfs;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.PriorityQueue;

import edu.uno.ai.planning.Plan;
import edu.uno.ai.planning.Step;
import edu.uno.ai.planning.logic.Conjunction;
import edu.uno.ai.planning.logic.Expression;
import edu.uno.ai.planning.logic.Literal;
import edu.uno.ai.planning.ss.StateSpaceNode;
import edu.uno.ai.planning.ss.StateSpaceProblem;
import edu.uno.ai.planning.ss.StateSpaceSearch;
import edu.uno.ai.planning.util.ImmutableArray;

/**
 * Searches using A* search
 * 
 * @author Manish Bhatt
 */
public class AStarSearch extends StateSpaceSearch {

		
	Comparator<Node> comparator = new Node();
	protected final PriorityQueue<Node> Q = new PriorityQueue<Node>(10, comparator);
	protected Hashtable<Literal, Double> literals_map = new Hashtable<Literal, Double>();
	protected HashSet<Literal> literals = new java.util.HashSet<>();
	ImmutableArray<Step> steps = null;
	
	/**
	 * Constructs a new A* search planner.
	 * 
	 * @param problem the state space search problem to be solved
	 */
	public AStarSearch(StateSpaceProblem problem) {
		super(problem);
		Node rootNode = new Node();
		rootNode.ssn = root;
		rootNode.value = 0.0;
		Q.offer(rootNode);
		
	}
	@Override
	public Plan findNextSolution() {
		
		HashSet<Literal> all_literals = getLiterals(problem);
		ArrayList<StateSpaceNode> visited = new ArrayList<StateSpaceNode>();
				
		while(!Q.isEmpty()) {
			Node qn = Q.poll();
			StateSpaceNode node = qn.ssn;
			visited.add(node);
			
			if(problem.isSolution(node.plan))
				return node.plan;
			for(Step childStep : problem.steps){
				
				if (childStep.precondition.isTrue(node.state) && !visited.contains(node.expand(childStep))){
					StateSpaceNode child = node.expand(childStep);	
				int dist_from_root_to_current = child.plan.size();
				Node subNode = new Node();
				subNode.ssn = child;
				subNode.value = dist_from_root_to_current+evaluate(subNode.ssn, problem.goal, all_literals, steps);
				Q.offer(subNode);
			}
			}
					
			
		}
				
		return null;
	}
	
	
	/**
	 * This method generates the literals from the states
	 * @param problem
	 * @return all_literals
	 */
	
	public HashSet<Literal> getLiterals(StateSpaceProblem problem){
		
		steps = problem.steps;
		Expression goal_exp = problem.goal;
		Expression root_exp = root.state.toExpression();
		
		if(goal_exp instanceof Literal){
			
			literals.add((Literal) goal_exp);
						
		}else {
			
			Conjunction conjun = (Conjunction) goal_exp;
		    for(Expression conjunct : conjun.arguments)
		        literals.add((Literal) conjunct);
			
		}
		
		if(root_exp instanceof Literal){
			
			literals.add((Literal) root_exp);
						
		}else {
			
			Conjunction conjun = (Conjunction) root_exp;
		    for(Expression conjunct : conjun.arguments)
		        literals.add((Literal) conjunct);
			
		}
		for(int i = 0 ; i < steps.length; i++){
			
			Expression precond_exp = steps.get(i).precondition;
			Expression effect = steps.get(i).effect;
			
			if(precond_exp instanceof Literal){
				
				literals.add((Literal) precond_exp);
							
			}else {
				
				Conjunction conjun = (Conjunction) precond_exp;
			    for(Expression conjunct : conjun.arguments)
			        literals.add((Literal) conjunct);
				
			}
			
			if(effect instanceof Literal){
				
				literals.add((Literal) effect);
							
			}else {
				
				Conjunction conjun = (Conjunction) effect;
			    for(Expression conjunct : conjun.arguments)
			        literals.add((Literal) conjunct);
				
			}
						
			
		}
		
		
		return literals;
		
	}
	
	/**
	 * This method returns the Heuristic Value
	 * @param curr_node, goal, all_literals, 
	 */
	public double evaluate(StateSpaceNode curr_node, Expression goal, HashSet<Literal> all_literals, ImmutableArray<Step> steps){
		boolean flag = true;
		Double cost_to_reach_goal = 0.0;
		for(int i = 0; i < all_literals.size(); i++){
			Literal literal = (Literal) all_literals.toArray()[i];
			if(literal.isTrue(curr_node.state)){
				literals_map.put(literal, 0.0);
			}else{
				literals_map.put(literal, Double.MAX_VALUE);
			}
		}
		while(flag){
			flag = false;
			for(int i = 0 ; i < steps.length; i++){
				Expression precondition = steps.get(i).precondition;
				Expression effect = steps.get(i).effect;
				Double cost_of_pre_cond = 0.0;
				if(precondition instanceof Literal){
					Literal key = (Literal)precondition;
					cost_of_pre_cond = literals_map.get(key);
					if(effect instanceof Literal){
						Literal key1 = (Literal)effect;
						Double current_cost = literals_map.get(key1);
						Double updated_cost = Math.min(current_cost, cost_of_pre_cond+1);
						if(Double.compare(updated_cost, current_cost) != 0){
							flag = true;
						}
						literals_map.put(key1, updated_cost);
					}else {
						Conjunction conjunction = (Conjunction) effect;
						for(Expression conjunction1 : conjunction.arguments){
							Literal key1 = (Literal)conjunction1;
							Double current_cost = literals_map.get(key1);
							Double updated_cost = Math.min(current_cost, cost_of_pre_cond+1);
							if(Double.compare(updated_cost, current_cost) != 0){
								flag = true;
							}
							literals_map.put(key1, updated_cost);
						}
					}
				}else {
					Conjunction conjunction = (Conjunction) precondition;
					for(Expression conjunction1 : conjunction.arguments){
						Literal key = (Literal)conjunction1;
						Double literal_cost = literals_map.get(key);
						if(literal_cost.equals(Double.MAX_VALUE)){
							cost_of_pre_cond = Double.MAX_VALUE;
							break;    // because if any one of the literal has infinite value then the whole expression will have infinite value
														
						}else{
							
							cost_of_pre_cond += literal_cost;
						}
					}
					if(effect instanceof Literal){
						Literal key = (Literal)effect;
						Double current_cost = literals_map.get(key);
						Double updated_cost = Math.min(current_cost, cost_of_pre_cond+1);
						if(Double.compare(updated_cost, current_cost) != 0){
							flag = true;
						}
						literals_map.put(key, updated_cost);
					}else {
						Conjunction conjunction1 = (Conjunction) effect;
						for(Expression conjunction11 : conjunction1.arguments){
							Literal key = (Literal)conjunction11;
							Double current_cost = literals_map.get(key);
							Double updated_cost = Math.min(current_cost, cost_of_pre_cond+1);
							if(Double.compare(updated_cost, current_cost) != 0){
								flag = true;
							}
							literals_map.put(key, updated_cost);
						}
					}
				}
			}
		}
		if(goal instanceof Literal){
			
			Literal key = (Literal)goal;
			cost_to_reach_goal = literals_map.get(key); 
		}else {
			Conjunction conjunction = (Conjunction) goal;
			for(Expression conjunction1 : conjunction.arguments){
				Literal key = (Literal)conjunction1;
				Double literal_cost = literals_map.get(key);
				if(literal_cost.equals(Double.MAX_VALUE)){
					cost_to_reach_goal = Double.MAX_VALUE;
					break;    
				}else{
					cost_to_reach_goal += literal_cost;
				}
			}
		}
		return cost_to_reach_goal;
	}
	


class Node implements Comparator<Node> {
	/**
	 * Need a Comparator for the Priority Queue
	 * @author Manish Bhatt
	 */
	StateSpaceNode ssn;
	Double value;
	
	@Override
	public int compare(Node Q1, Node Q2) {
		return Double.compare(Q1.value, Q2.value);				 
		
	}

}
}
