public class SudeCell {

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

	public int getPosition() {
		return position;
	}

	public boolean isKnown() {
		return (!(this.value == 0));
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

	/*public boolean[] subtract(boolean[] other) {

		boolean[] result = new boolean[10];

		for (int i = 1; i < 10; ++i) {

			result[i] = (this.candidate[i] && !other[i]); //other.candidate[i]
		}

		result[0] = false; //Not strictly necessary

		return result;
	}*/

	public void subtract(boolean[] other) {

		for (int i = 1; i < 10; ++i) {

			candidate[i] = (candidate[i] && !other[i]); //other.candidate[i]
		}

		candidate[0] = false; //Not strictly necessary
	}

	public void report() {

		System.out.print("[" + position + "] ");

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
}