import java.util.Comparator;

public class SudeCell implements Comparable<SudeCell>{

	private int position;
	private int value;
	private boolean[] candidate; //maps 1 -> 1. Thus, boolean[0] is meaningless.

	/** Constructor for an unknown value */
	SudeCell(int _position) {

		position = _position;

		value = 0;
		candidate = new boolean[10];

		for (int i = 0; i < 10; ++i) {
			
			candidate[i] = true;
		}

		candidate[0] = false;
	}

	/** Constructor for a known value */
	SudeCell(int _position, int _value) {

		position = _position;

		if ((_value < 10) && (_value > 0)) {

			value = _value;
		}
		else {

			value = 0;
		}

		candidate = new boolean[10];

		if (value == 0) {

			for (int i = 0; i < 10; ++i) {
			
				candidate[i] = (i == 0) ? false: true;
			}
		} else {

			for (int i = 0; i < 10; ++i) {
			
				candidate[i] = (i == value) ? true : false;
			}
		}
	}

	SudeCell(boolean[] _candidates) {

		position = -1;
		value = 0;
		candidate = new boolean[10];

		for (int i = 0; i < 10; ++i) {

			candidate[i] = _candidates[i];
		}
	}

	SudeCell() {
		
		position = -1;
		value = 0;
		candidate = new boolean[10];

		for (int i = 0; i < 10; ++i) {

			candidate[i] = true;
		}
	}

	public int getPosition() {
		return position;
	}

	public boolean isKnown() {
		return (this.value != 0);
	}

	public boolean isValue(int i) {
		return (this.value == i);
	}

	public int getValue() {
		return value;
	}

	public boolean hasCandidate(int i) {
		return (candidate[i]);
	}

	public boolean[] getCandidates() {
		return candidate;
	}

	public int countCandidates() {

		int sum = 0;

		for (int i = 1; i < 10; ++i) {

			if (candidate[i] == true) {

				++sum;
			}
		}

		return sum;
	}

	public void clearCandidates() {

		for (int i = 1; i < 10; ++i) {

			candidate[i] = false;
		}
	}

	/** Removes the possibility of this number. */
	public void exclude(int i) {

		this.candidate[i] = false;
	}

	public void exclude(int[] array) { //void eliminateCandidate(int... array)

		for (int i : array) {

			candidate[i] = false;
		}
	}

	/** Sets value without any checks, and clears candidates.*/
	public void forceAssign(int i) {
		
		value = i;

		if (i != 0) {

			this.clearCandidates();
		}
	}

	/** Sets value after referencing the candidate list. */
	public boolean checkAssign(int i) {

		if (hasCandidate(i)) {

			forceAssign(i);
			System.out.println(i + " found at [" + position + "]");
			return true;
		}
		else {

			System.out.println("Assignment failed! Not a " + i + "!");
		}

		return false;
	}

	/** Returns the one remaining candidate, or a zero (failure to solve by elimination). */
	public int getLast() {

		int eliminated = 0;
		int lastCandidate = 0;
		int answer = 0;

		for (int i = 1; i < 10; ++i) {
			
			if (!this.hasCandidate(i)) {

				eliminated++;
			}
			else {

				lastCandidate = i;
			}
		}

		if (eliminated == 8) {

			answer = lastCandidate;
		}

		return answer;
	}

	/** Returns an array of candidates common to both. */
	public boolean[] intersection(boolean[] other) {

		boolean[] result = new boolean[10];

		for (int i = 1; i < 10; ++i) {

			result[i] = (this.candidate[i] && other[i]); //other.candidate[i]
		}

		result[0] = false; //Not strictly necessary

		return result;
	}

	public void subtract(boolean[] other) {

		for (int i = 1; i < 10; ++i) {

			candidate[i] = (candidate[i] && !other[i]); //other.candidate[i]
		}

		candidate[0] = false; //Not strictly necessary
	}

	public void union(boolean[] other) {

		for (int i = 1; i < 10; ++i) {

			candidate[i] = (candidate[i] || other[i]);
		}

		candidate[0] = false;
	}

	public void report() {

		if (position != -1) {
			System.out.print("[" + position + "] ");
		}
		else {
			System.out.print("It ");
		}

		if (value > 0) {

			System.out.println("is " + value);
		}
		else {

			System.out.print("can be ");

			for (int i = 1; i < 10; ++i) {

				if (candidate[i] == true) {

					System.out.print(i + " ");
				}
			}

			System.out.println("");
		}
	}

	public String stringify() {
		String word = " [" + this.getPosition() + "] ";
		return word;
	}

	public int inCommon(SudeCell other) {

		int commonCandidates = 0;

		for (int i = 1; i < 10; ++i) {

			if (this.candidate[i] == other.hasCandidate(i)) {

				commonCandidates++;
			}
		}		

		return commonCandidates;
	}

	public boolean isNeighbor(SudeCell other, int ascentType) {

		int i = this.position;
		int j = other.getPosition();

		boolean answer = false;

		switch(ascentType) {

			case 0: // Any Ascent
				answer = (	((i/27 == j/27) && (i%9/3 == j%9/3)) ||
										(i/9 == j/9) ||
										((i-j) % 9 == 0) );
				break;
			
			case 1: // Same Box
				answer = ((i/27 == j/27) && (i%9/3 == j%9/3));
				break;
			case 2: // Same Row
				answer = (i/9 == j/9);
				break;
			case 3: // Same Column
				answer = ((i-j) % 9 == 0);
				break;
			default:
				System.out.println("isNeighbor ascent failure: " + ascentType);
				break;
			}
		return answer;
	}

	@Override
	public int compareTo(SudeCell o) {
		int answer = 0;
		if (this.position < o.getPosition()) {
			answer = -1;
		} else if (this.position == o.getPosition()) {
			answer = 0;
		} else if (this.position > o.getPosition()) {
			answer = 1;
		}
		return answer;
	}
}