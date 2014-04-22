class SudePuzzle {

	SudeCell[] board;
	CellQueue unknownQueue;
	int passCount;

	SudePuzzle() {
		board = new SudeCell[81];
		unknownQueue = new CellQueue();
		passCount = 0;
	}

	SudePuzzle(String input) {

		board = new SudeCell[81];
		unknownQueue = new CellQueue();
		passCount = 0;

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

		if (passCount == 0) populate();

		for (SudeCell selected : board) {

			if (!selected.isKnown()) {

				unknownQueue.push(selected);
			}
		}

		while (unknownQueue.hasNext()) { //Avoid a foreach loop as the list will be modified after iterator is created.

			SudeCell selected = unknownQueue.next();
			stepBySingle(selected);
			stepByLocked(selected);
			
			if (passCount > 4) {
				CellQueue nakedStep = new CellQueue();
				nakedStep.push(selected);
				stepByNaked(nakedStep, 0);
			}
			
		}

		++passCount;
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

	/** Adds a neighboring SudeCell to a queue. Assumes CellQueue are all within an ascent.
	Returns true on a successful add.*/
	boolean addSimilar(CellQueue current, int ascentType) {

		IntList check = getAscent(current.peek().getPosition(), ascentType);
		int sizeCheck = current.size();

		for (int i : check) {

			if ( (current.contains(i)) || (board[i].isKnown())) {

				continue;
			}
			else {

				current.push(board[i]);

				if (sizeCheck == current.size()) {

					println("addNeighbor error: same size after push.");
					println(current.stringify() + " a:" + ascentType);
				}

				return true;
			}
		}

		return false;
	}

	/** Tries to solve current cell using the 'Hidden Single' rule :
	If any of the current cell's candidates is alone in any ascent, that will be its final value.*/
	void stepBySingle(SudeCell current) {
		
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

	Works via recursion. Given the ascent type and what is already 
	*/
	void stepByNaked(CellQueue cells, int ascentType) {

		if ((ascentType == 0)) { // Start recursing. maybe drop size as a predicate. (cells.size() == 1) &&

			//println("Starting Naked check on " + cells.stringify() + ", Ascent: " + ascentType);

			for (int a = 1; a < 4; ++a) {

				CellQueue child = new CellQueue();
				child.copy(cells);

				if (addSimilar(child, a)) {

					stepByNaked(child, a);
				}
			}
		}
		else {

			//println("Continuing Naked check on " + cells.stringify() + ", Ascent: " + ascentType);

			SudeCell test = new SudeCell();
			test.clearCandidates();

			int cellCount = cells.size();

			if (cellCount > 4) {
				println("...Too big.");
				return;
			}

			for (SudeCell i : cells) {
				test.union(i.getCandidates());
			}

			int candidateCount = test.countCandidates();

			//Prepare remaining unselected, unknown neighbors.
			CellQueue unselected = new CellQueue();
			IntList neighbors = getAscent(cells.peek().getPosition(), ascentType);

			for (int i : neighbors) {
				if ((cells.contains(i) == false) && (board[i].isKnown() == false)) {
					unselected.push(board[i]);
				}
			}

			if (unselected.size() == 0) {
				println("...Nothing left.");
				return;
			}

			//if candidate count and cell count match, start excluding.
			if (cellCount == candidateCount) {

				print("Naked " + cellCount + "-tuple found: " + cells.stringify() + " ");
				test.report();


				println("Excluding from: " + unselected.stringify());
				unselected.subtract(test.getCandidates());

			}

			//if ascent contains no unselected candidates, bail.

			if (((cellCount + 1) == candidateCount) || (cells.size() == 1)) {

				CellQueue child = new CellQueue();
				child.copy(cells);

				if (addSimilar(child, ascentType)) {

					stepByNaked(child, ascentType);
				}
			}
		}
	}

	/** Tries to solve current cell using the 'Hidden N-tuple' rule.
	If (n) 
	*/
	void stepByHidden(SudeCell current) {

	}

	/** Tries to solve current cell using the 'Locked Candidates' rule.
	If the intersection of ascents A and B contains candidate x,
		and that candidate does not exist in A - B,
			then it can be eliminated from B - A.
	(provided that neither A nor B already has x as a known value.)
	*/
	void stepByLocked(SudeCell current) {

		for (int ascentLine = 2; ascentLine < 4; ++ascentLine) {

			CellQueue inter = new CellQueue();
			CellQueue boxed = new CellQueue();
			CellQueue lined = new CellQueue();

			IntList neighborsBox = getAscent(current.getPosition(), 1);
			IntList neighborsLine = getAscent(current.getPosition(), ascentLine);
			IntList combined = new IntList();
			combined.append(neighborsBox);
			combined.append(neighborsLine);

			String lineWord = (ascentLine == 2 ? "Row" : "Col");

			for (int i : combined) {

				if (neighborsBox.hasValue(i)) {

					if (neighborsLine.hasValue(i)) {

						inter.push(board[i]);
					} 
					else {

						boxed.push(board[i]);
					}
				} 
				else {

					lined.push(board[i]);
				}
			}
			
			for (int candidate = 1; candidate < 10; ++candidate) {

				if ((inter.hasValue(candidate) == false) && (inter.hasCandidate(candidate))) {

					if ((boxed.hasValue(candidate) == false) && (boxed.hasCandidate(candidate) == false)) {

						if (lined.hasCandidate(candidate)) {

							println("Box-" + lineWord + current.stringify() + " has no " + 
											candidate + " in the box. Excluding " + lineWord + ".");
							lined.exclude(candidate);
						}
					}
					else if ((lined.hasValue(candidate) == false) && (lined.hasCandidate(candidate) == false)) {

						if (boxed.hasCandidate(candidate)) {

							println("Box-" + lineWord + current.stringify()+ " has no " + 
											candidate + " in the " + lineWord + ". Excluding box.");
							boxed.exclude(candidate);
						}
					}
				}
			}
		}
	}

}