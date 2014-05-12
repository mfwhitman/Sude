class SudePuzzle {

	SudeCell[] board;
	CellQueue searchQueue;
	int numPasses;

	SudePuzzle() {
		board = new SudeCell[81];
		searchQueue = new CellQueue();
		numPasses = 0;
	}

	SudePuzzle(String input) {

		board = new SudeCell[81];
		searchQueue = new CellQueue();
		numPasses = 0;

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

	/** Assigns a value to a cell, after checking geometrically, and checking against the cell's internally stored candidates.*/
	void posit(int position, int value) {

		CellQueue temp = new CellQueue();
		temp.push(board[position]);

		CellQueue neighbors = getSimilar(temp, 0);
		boolean checkUnique = true;

		for (SudeCell s : neighbors) {
			if (s.getPosition() == position) {
				continue;
			}
			if (s.isValue(value) == true) {
				checkUnique = false;
				break;
			}
		}

		if (checkUnique ==  true) {
			board[position].checkAssign(value);
			update(board[position]);
		}
	}

/** Does an initial exclusion of obvious candidates. Should be run once. */
	void populate() {

		CellQueue known = new CellQueue();

		for (SudeCell selected : board) {

			if (selected.isKnown()) {

				known.push(selected);
			}
		}

		while (known.hasNext()) {

			SudeCell current = known.next();

			update(current);
		}
	}

/** Call this on a discovery. Updates neighbors' candidates when a new cell is found. */
	void update(SudeCell found) {

		IntList neighbors = getAscent(found.getPosition(), 0);

		for (int i : neighbors) {

			if (board[i].isKnown() == false) {

				board[i].exclude(found.getValue());

				int temp = board[i].getLast();

				if (temp != 0) {

					posit(i, temp);
				}
			}
		}
	}

	void solve() {

		println("Solving...");

		if (numPasses == 0) populate(); //if (numPasses == 0)

		for (SudeCell selected : board) {

			if (!selected.isKnown()) {

				searchQueue.push(selected);
			}
		}

		//searchQueue.sort();
		//println("Prior " + searchQueue.stringify());

		while (searchQueue.hasNext()) { //Avoid a foreach loop as the list will be modified after iterator is created.

			SudeCell selected = searchQueue.next();
			stepBySingle(selected);
			stepByLocked(selected);
			
			if (numPasses > 2) {
				CellQueue nakedStep = new CellQueue();
				nakedStep.push(selected);
				stepByNaked(nakedStep, 0);
			}
			if (numPasses > 3) {
				prepHidden(selected);
			}
		}

		for (int candidate = 1; candidate < 10; ++candidate) {
			prepXWing(candidate);
		}

		++numPasses;
	}

	boolean sharesAscent(int i, int j, int ascentType) {
		
		boolean answer = false;

		switch(ascentType) {

			case -1: // Either Line
				answer = ( (i/9 == j/9) ||
									 ((i-j) % 9 == 0) );
				break;

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

	/** Checks the contents of a CellQueue, and adds any missing neighbors in the given ascent.*/
	CellQueue getSimilar(CellQueue current, int ascentType) {

		IntList check = getAscent(current.peek().getPosition(), ascentType);
		int sizeCheck = current.size();
		CellQueue similars = new CellQueue();

		for (int i : check) {

			if ( (current.contains(i)) || (board[i].isKnown())) {

				continue;
			}
			else {

				similars.push(board[i]);
			}
		}

		return similars;
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
				posit(current.getPosition(), answer);
				//current.checkAssign(answer);
				//update(board[answer]);
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

		if (ascentType == 0) {

			//println("Starting Naked check on " + cells.stringify() + ", Ascent: " + ascentType);

			for (int a = 1; a < 4; ++a) {

				CellQueue child = new CellQueue();
				child.copy(cells);

				for (SudeCell similar : getSimilar(child, a)) {

					CellQueue temp = new CellQueue();
					temp.push(cells);
					temp.push(similar);
					temp.sort();
					stepByNaked(temp, a);
					temp.clear();
				}
			}
		}
		else {

			//println("Continuing Naked check on " + cells.stringify() + ", Ascent: " + ascentType);

			SudeCell test = new SudeCell();
			test.clearCandidates();
			int cellCount = cells.size();

			for (SudeCell i : cells) {
				test.union(i.getCandidates());
			}

			int candidateCount = test.countCandidates();
			CellQueue unselected = new CellQueue();
			IntList neighbors = getAscent(cells.peek().getPosition(), ascentType);

			for (int i : neighbors) {

				if ((cells.contains(i) == false) && (board[i].isKnown() == false)) {

					unselected.push(board[i]);
				}
			}

			if (unselected.size() == 0) {
				//println("...Nothing left.");
				return;
			}

			//if candidate count and cell count match, start excluding.
			if (cellCount == candidateCount) {

				//print("Naked " + cellCount + "-tuple found: " + cells.stringify() + " ");
				//test.report();

				//TODO: Rewrite this to print only on successful exclusions.

				//println("Excluding Naked from: " + unselected.stringify());
				unselected.subtract(test.getCandidates());

			}

			if (((cellCount + 1) == candidateCount) || (cells.size() == 1)) {

				CellQueue child = new CellQueue();
				child.copy(cells);

				for (SudeCell similar : getSimilar(child, ascentType)) {

					child.push(similar);
					child.sort();

					if (child.size() <= 4) {
						stepByNaked(child, ascentType);
					}
					
					child.removeFirst();
				}
			}
		}
	}

	/** Tries to solve current cell using the 'Hidden N-tuple' rule.
	If the same (n) candidates are restricted to the same (n) cells in
	an ascent,
	(i.e. they don't appear in any other cell in the ascent)
		then all other candidates can be eliminated from those cells.

	This is the dual of the naked problem. By switching the cell's
	candidates and locations, it can be solved in the same manner.

	Usually there are easier alternatives. This is a last resort.
	*/
	void prepHidden(SudeCell current) {

		//println("");
		//println("------------------------------------------");
		//println("Start Hidden Search " + current.stringify());

		for (int a = 1; a < 4; ++a) {
			IntList neighbors = getAscent(current.getPosition(), a);
			CellQueue ascent = new CellQueue();
			ascent.push(current);

			for (int n : neighbors) {

				ascent.push(board[n]);
			}

			ascent.sort();

			DualQueue d = new DualQueue();
			d.dualize(ascent);

			//println("Ascent" + ascent.stringify());
			//println("Dual:" + d.stringify());

			for (int i = 1; i < 10; ++i) {
				if (d.isKnown(i) == true) {
					continue;
				}
				IntList start = new IntList();
				start.append(i);
				runHidden(d, start);
				start.clear();
			}

		}
	}

	void runHidden(DualQueue dual, IntList candidates) {

		int[] posQuery = dual.query(candidates.array());

		int positionCount = posQuery.length;
		int candidateCount = candidates.size();

		/*print("Step Hidden Candidates (" + candidateCount + "):");
		for (int c : candidates) {

			print(" [" + c + "]");
		}
		print("                       ");
		print("Query returned (" + positionCount + ")");
		for (int p : posQuery) {

			print(" " + p);
		}
		println("");
		*/

		if ((candidateCount > 1) && (candidateCount == positionCount)) {


			/*println("Found Hidden " + positionCount + "-Tuple in ");
			for (int p : posQuery) {

				print(" " + p);
			}

			println("");*/

			for (int i : posQuery) {

				for (int j = 1; j < 10; ++j) {

					if ( (candidates.hasValue(j) == false) && (board[i].hasCandidate(j)) ) {

						println("Excluding Hidden " + j + " at [" + i + "] (Muted)");
						//board[i].exclude(j);
					}					
				}
			}
		}
		else if ( ( (candidateCount < 2) ||
			((candidateCount + 1) == positionCount)) &&
			(candidateCount < (dual.getUnknownCount() - 1)) ) {
			
			IntList temp = new IntList();
			temp.append(candidates);

			for (int i = 1; i < 10; ++i) {
				boolean isHigher = false;
				for (int t : temp) {
					if (t > i) {
						isHigher = true;
					}
				}
				if (isHigher) continue;

				if ((dual.isKnown(i)) || (temp.hasValue(i) == true)) {
					continue;
				}

				temp.append(i);
				runHidden(dual, temp);
				temp.remove(temp.size()-1);
			}
		}
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
											candidate + " in the " + lineWord + ". Excluding Box.");
							boxed.exclude(candidate);
						}
					}
				}
			}
		}
	}

	void prepXWing(int candidate) {
		/* Looks for occurances of 2x2 or 3x3 grids of the same candidate. Rook-based elimination.
		  Excludes candidates on the edges (but not points) of the grid.
		*/

		println("Running XWing");

		//
		

		for (int ascentType = 2; ascentType < 4; ++ascentType) {

			ArrayList<CellQueue> pairs = new ArrayList<CellQueue>();

			String word = (ascentType == 2)? "Row" : "Col";

			for (int ascentLine = 0; ascentLine < 9; ++ascentLine) {
				int firstCell = (ascentType == 2)? (ascentLine * 9) : ascentLine;
				CellQueue check = new CellQueue();
				check.push(board[firstCell]);
				CellQueue checkLine = getSimilar(check, ascentType);
				checkLine.push(board[firstCell]);
				checkLine.sort();

				int occurances = checkLine.countCandidates(candidate);
				if (occurances == 2) {
					print(word + " " + ascentLine + " has only two " + candidate + ",");
					CellQueue temp = new CellQueue();
					for (SudeCell o : checkLine) {
						
						if (o.hasCandidate(candidate)) temp.push(o);
					}
					println(" Storing " + temp.stringify());
					pairs.add(temp);
				}
			}

			for (CellQueue i : pairs) {
				for (CellQueue j : pairs) {
					if (i == j) continue;
					if ((i.size() == 0) || (j.size() == 0)) continue;
					if ( (sharesAscent(i.get(0).getPosition(), j.get(0).getPosition(),ascentType)) &&
						 (sharesAscent(i.get(1).getPosition(), j.get(1).getPosition(),ascentType)) )
					{
						println("Found "+ candidate + " Xwing on " + word + "(" + i.stringify() + " " + j.stringify());
					}
				}
			}
		}

		//check all cols for 2 (and 2 only) occurances of candidate.


		//of those cols, check if a combination of 2 cols' offsets (rows with the candidate) are identical.

		//of those cols, check if a combination of 3 cols has the same three offsets total. (partial swordfish)

		//check all cols for 3 (and 3 only) occurances of candidate.
		//of those cols, check if a combination of 3 cols has three offsets total.

		//repeat, but switch col->row and row->col.


	}

}