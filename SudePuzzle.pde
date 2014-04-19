class SudePuzzle {

	SudeCell[] board;
	CellQueue unknownQueue;

	SudePuzzle() {
		board = new SudeCell[81];
		unknownQueue = new CellQueue();
	}

	SudePuzzle(String input) {

		board = new SudeCell[81];
		unknownQueue = new CellQueue();

		if (input.length() != 81) {

				println("ERROR Making SudePuzzle: Incorrect string length, " + input.length());
			}

		for (int i = 0; i < 81; i++) {

			int strVal = int(input.charAt(i)) - int('0');

			if ((strVal >= 1) || (strVal <= 9)) {

				board[i] = new SudeCell(i, strVal);
			} else if (strVal == 0) {

				board[i] = new SudeCell(i);
			} else {

				println("ERROR Making SudePuzzle: Unsanitized string input, " + strVal);
			}
		}
	}

/** Does an initial exclusion of obvious candidates. Should be run once. */
	void populate() {

		println("Populating...");

		CellQueue known = new CellQueue();

		for (SudeCell selected : board) {

			if (selected.isKnown()) {

				//println("populate: " + selected.getPosition() + " is known to be " + selected.getValue() + "."); //Working here.

				known.push(selected);
			}
		}

		//for (int i = 0; i < known.size(); ++i) {
			while (known.hasNext()) {

			SudeCell current = known.next();

			update(current);

		}

		println("...Populating finished");
	}

/** Updates neighbors' candidates when a new cell is found. */
	void update(SudeCell found) {

		IntList neighbors = new IntList(81);
		neighbors = getAscent(found.getPosition(), 0);
		//print(found.getValue() + " at " + found.getPosition());
		//println(" has neighbors: "+neighbors);

		for (int i : neighbors) {

			if (!board[i].isKnown()) {

				board[i].exclude(found.getValue());

				int temp = board[i].getLast();

				if (temp != 0) {

					checkAnswer(board[i], temp);
				}
			}
		}

	}

	/** Suggests an answer, and if it returns true, puts it through to update the neighbors.*/
	void checkAnswer(SudeCell selected, int candidate) {

		boolean check = selected.checkAssign(candidate);

		if (check) {

			update(selected);
		}
	}

	void solve() {

		populate();

		for (SudeCell selected : board) {

			if (!selected.isKnown()) {

				unknownQueue.push(selected);
			}
		
}		while (unknownQueue.hasNext()) { //Avoid a foreach loop as the list will be modified after iterator is created.
			SudeCell selected = unknownQueue.next();
			stepBySingle(selected);

		}
	}

	boolean sharesAscent(int i, int j, int ascentType) {
		
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
				println("Ascent Switcher failure: " + ascentType);
				break;
			}

	 return answer;
	}

	/** Gets a list of the others cells in an ascent.*/
	IntList getAscent(int selected, int ascentType) {

		IntList neighbors = new IntList(21);

		for (int i = 0; i < 81; ++i) {

			if (( selected != i) && (sharesAscent(selected, i, ascentType))) {

				neighbors.append(i);
			}
		}

		return neighbors;
	}

	/** Tries to solve current cell using the 'Hidden Single' rule :
	If any of the current cell's candidates is alone in any ascent, that will be its final value.*/
	void stepBySingle(SudeCell current) {

		//println("Checking if [" + current.getPosition() + "] is hidden single? ");
		
		for (int ascent = 1; ascent < 4; ++ascent) {
			
			SudeCell accumulator = new SudeCell(current.getCandidates());
			IntList neighbors = new IntList(20);
			neighbors = getAscent(current.getPosition(), ascent);
			int answer = 0;

			for (int i : neighbors) {

				if (board[i].isKnown()) {

					accumulator.exclude(board[i].getValue());
				}
				else {

					accumulator.subtract(board[i].getCandidates());
					/*for (int j = 1; j < 10; ++j) {
						if (board[i].hasCandidate(j)) {
							accumulator.exclude(j);
						}
					}*/
				}

				answer = accumulator.getLast();
			}

			if (answer != 0) {

				println("Hidden Single " + answer + " at [" + current.getPosition() + "]");
				current.checkAssign(answer);
				break;
			}
		}
	}

	/** Tries to solve the current cell using the 'Naked N-tuple' rule.
	(n) cells in an ascent share the same (n) candidates and nothing else.
	Checks only for tuples that are 
	If the union of n cells' candidate lists has length n,
		and it is unique,
			every other candidate belonging to those cells can be eliminated.
	*/
	void stepByNaked() {

	}

	/** Tries to solve current cell using the 'Hidden N-tuple' rule.
	If (n) 
	*/
	void stepByHidden() {

	}

	/** Tries to solve current cell using the 'Locked Candidates' rule.
	If the intersection of ascents A and B contains a candidate,
		and that candidate does not exist in A - B,
			then it can be eliminated from B - A.
	*/
	void stepByLocked() {

	}

	/** To solve by elimination, all numbers but one have to be eliminated from a cell's co-dependents. 
	void stepElimination(SudeCell active) {

		//boolean[] found = new boolean[10];

		for (SudeCell i : board) {

			if (!active.isValue(0)) {
				continue;
			}
			else if (sameRow(active, i) || sameCol(active, i) || sameBox(active, i)) {
				if ((eliminatedNumbers[active][board[i]] == false) && (board[i] != 0)) {
					eliminatedNumbers[active][board[i]] = true;

					//println("bStep Debug: " + board[i] + " eliminated at " + active);
				}
			}
		}

		int candidate = active.getLast();

		if (candidate != 0)	{
			println("Solved ");
		}

	}*/

	/** To solve by deduction, an unknown number in an ascent has to be eliminated from all but one cell. 
	void stepDeduction(int active, int ascentType) {

		CellQueue contents = new CellQueue();

		for (int i = 0; i < 81; ++i) {
			if (sameAscent(active, i, ascentType)) {
				contents.push(i);
			}
		}

		boolean[] numeralsFound = new boolean[10];
		int[] possible = new int[10];

		for (int i = 0; i < 10; ++i) {
			numeralsFound[i] = false;
			possible[i] = 0;
		}

		for (int i = 0; i < contents.size(); ++i) {
			int current = contents.get(i);

			if (board[current] != 0) {
				numeralsFound[board[current]] = true;
			}
			else {
				for (int num = 1; num < 10; ++num) {
					if (eliminatedNumbers[current][num] == false) {
						possible[num]++;
					}
				}
			}
		}

		for (int i = 1; i < 10; ++i) {
			if (numeralsFound[i] == false) {
				//println(i + "s location is unknown, with " + possible[i] + " possible positions.");
				if (possible[i] == 1) {
					for (int search = 0; search < contents.size(); ++search) {
						int current = contents.get(search);
						if ((board[current] == 0) && (eliminatedNumbers[current][i] == false)) {
							println("Found " + i + " at " + current + " by deduction.");
							set(current, i);
						}
					}
				}
			}
		}

		contents.clear();

	}*/

	/*
	void search() {

		for (SudeCell selected : board) {

			if  ((!unknownQueue.contains(selected)) && (selected.isValue(0))) {

				unknownQueue.push(selected);
			}
		}

		for (int i = 0; i < unknownQueue.size(); ++i) {

			SudeCell currentCell = unknownQueue.pop();

			stepElimination(currentCell);

			if (currentCell.isValue(0)) {
				//println("Breadth Search: nothing found at " + currentCell);
				unknownQueue.push(currentCell);
			}

		}

		for (int i = 0; i < 9; ++i) {
			int currentCell = i * 10;

			stepDeduction(currentCell, 0);
			stepDeduction(currentCell, 1);

			currentCell = i * 9;

		}

		for (int i = 0; i < 3; ++i) {
			for (int j = 0; j < 3; ++j) {
				int currentCell = i * 27 + j * 3;
				stepDeduction(currentCell, 2);
			}
		}

	}

	boolean sameRow(int i, int j)
	{
		return (i/9 == j/9);
	}

	boolean sameCol(int i, int j) {
		return ((i-j) % 9 == 0);
	}

	boolean sameBox(int i, int j) {
		return ((i/27 == j/27) && (i%9/3 == j%9/3));
	}*/


}