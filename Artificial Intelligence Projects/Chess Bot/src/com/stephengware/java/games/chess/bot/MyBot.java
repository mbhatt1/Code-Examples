package com.stephengware.java.games.chess.bot;
import java.util.Iterator;
import com.stephengware.java.games.chess.bot.Bot;
import com.stephengware.java.games.chess.state.Bishop;
import com.stephengware.java.games.chess.state.Board;
import com.stephengware.java.games.chess.state.Knight;
import com.stephengware.java.games.chess.state.Pawn;
import com.stephengware.java.games.chess.state.Piece;
import com.stephengware.java.games.chess.state.Player;
import com.stephengware.java.games.chess.state.Queen;
import com.stephengware.java.games.chess.state.Rook;
import com.stephengware.java.games.chess.state.State;

/**
 * A chess bot which selects its next move at random.
 * 
 * @author Manish Bhatt
 */
public class MyBot extends Bot {
	class Node {
		State state;
		double value;
	}

	/**
	 * Constructs a new chess bot named "My Chess Bot" and whose random  number
	 * generator (see {@link java.util.Random}) begins with a seed of 0.
	 */
	public MyBot() {
		super("mbhatt");
	}

	protected State getBestMove(State bestLeaf, State root){
		if (bestLeaf.previous.equals(root)){
			return bestLeaf;
		}
		getBestMove(bestLeaf.previous, root);
		return null;
	}
	

	@Override
	protected State chooseMove(State root) {
		int depth = 4;
				Node selectedNode = new Node();
				State nextMove = null;
				if (root.player.equals(Player.WHITE)) {
					selectedNode = findMax(root, Double.NEGATIVE_INFINITY,Double.POSITIVE_INFINITY, depth);
					if (selectedNode.state.previous.equals(root)) {
						return nextMove = selectedNode.state;
					} else {
						while (!selectedNode.state.previous.equals(root)) {
							selectedNode.state = selectedNode.state.previous;
							nextMove = selectedNode.state;
						}
						return nextMove;
					}
				} else {
					selectedNode = findMin(root, Double.NEGATIVE_INFINITY,Double.POSITIVE_INFINITY, depth);
					if (selectedNode.state.previous.equals(root)) {
						return nextMove = selectedNode.state;
					} else {
						while (!selectedNode.state.previous.equals(root)) {
							selectedNode.state = selectedNode.state.previous;
							nextMove = selectedNode.state;
						}
						return nextMove;
					}
				}
	}

	private Node findMax(State root, double alpha, double beta, int depth) {
		if (root.over || depth <= 0) {
			Node node = new Node();
			node.state = root;
			node.value = evaluate(node.state);
			return node;
		}
		double max = Double.NEGATIVE_INFINITY;
		Node returned = new Node();
		Node bestNode = new Node();
		Iterable<State> iterate = root.next();
		Iterator<State> itr = iterate.iterator();

		while (itr.hasNext() && !root.searchLimitReached()) {

			Node nextState = new Node();
			nextState.state = itr.next();
			returned = findMin(nextState.state, alpha, beta, depth - 1);
			if (returned.value > max) {

				bestNode = returned;
			}
			max = Math.max(max, returned.value);

			if (max >= beta)
				return bestNode;
			alpha = Math.max(alpha, max);
		}
		
		if (bestNode.state == null) {
			bestNode.state = root;
			bestNode.value = 0;
			return bestNode;

		} else {

			return bestNode;
		}
	}

	private Node findMin(State root, double alpha, double beta, int depth) {

		if (root.over || depth <= 0) {
			Node node = new Node();
			node.state = root;
			node.value = evaluate(node.state);
			return node;
		}

		double min = Double.POSITIVE_INFINITY;
		Node returned = new Node();
		Node bestNode = new Node();
		Iterable<State> iterate = root.next();
		Iterator<State> itr = iterate.iterator();

		while (itr.hasNext() && !root.searchLimitReached()) {

			Node nextState = new Node();
			nextState.state = itr.next();
			returned = findMax(nextState.state, alpha, beta, depth - 1);

			if (returned.value < min) {

				bestNode = returned;

			}
			min = Math.min(min, returned.value);
			if (min <= alpha)
				return bestNode;
			beta = Math.min(beta, min);
		}

		if (bestNode.state == null) {
			bestNode.state = root;
			bestNode.value = 0;
			return bestNode;

		} else {

			return bestNode;
		}
	}

	public static double evaluate(State root) {
		double WhiteValue = 0.0;
		double BlackValue = 0.0;
		double returnValue = 0.0;
		if (root.check)
	      {
			if (root.player.equals(Player.WHITE)){
	        	
	        	return -10000;
	        }
	        else if (root.player.equals(Player.BLACK)){
	        	
	        	return 10000;
	        }
	        
	      }
		for(Piece piece : root.board){
			if(piece.player.equals(Player.WHITE) && (piece instanceof Queen)){
				WhiteValue += 8.8; 
				if(root.player == piece.player){
					WhiteValue +=1.2;
				}
			}else if(piece.player.equals(Player.BLACK) && (piece instanceof Queen)){
				BlackValue +=8.8;
			}else if(piece.player.equals(Player.WHITE) && (piece instanceof Bishop)){
				WhiteValue +=3.33+((piece.rank)*0.02);
			}else if(piece.player.equals(Player.BLACK) && (piece instanceof Bishop)){
				BlackValue +=3.33+((7-piece.rank)*0.02);
			}else if(piece.player.equals(Player.WHITE) && (piece instanceof Knight)){
				WhiteValue +=3.2+((piece.rank)*0.03);
			}else if(piece.player.equals(Player.BLACK) && (piece instanceof Knight)){
				BlackValue +=3.2+((7-piece.rank)*0.03);
			}else if(piece.player.equals(Player.WHITE) && (piece instanceof Rook)){
				WhiteValue +=5.1;
			}else if(piece.player.equals(Player.BLACK) && (piece instanceof Rook)){
				BlackValue +=5.1;
			}else if(piece.player.equals(Player.WHITE) && (piece instanceof Pawn)){
				WhiteValue +=1+((piece.rank)*0.07);
			}else if(piece.player.equals(Player.BLACK) && (piece instanceof Pawn)){
				BlackValue +=1+(6-piece.rank)*0.07;
			}
		}

		if(root.over){
			returnValue = BlackValue-WhiteValue;
		}else{
			returnValue = WhiteValue-BlackValue;
		}
		return returnValue;
	}



	
}