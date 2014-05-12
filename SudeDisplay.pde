class SudeDisplay {
	int tableWidth, fontSize;
	color fontActive, fontDependent, fontNormal, cellActive, cellDependent, cellNormal, cellBorder, cellHidden, backNormal;
  PFont f, s, m;

	int activeRow = -16, activeCol = -16;

  boolean visibleIndices, visibleCandidates;

	SudeDisplay(int _tableWidth) {
    visibleCandidates = false;
    visibleIndices = true;

		tableWidth = _tableWidth;
		fontSize = tableWidth / 14;

		fontActive =    color(55, 0, 0);
		fontDependent = color(125, 125, 125);
		fontNormal =    color(25, 25, 25);
		cellActive =    color(255, 255, 255);
		cellDependent = color(255, 225, 225);
		cellNormal =    color(255, 255, 255);
		cellBorder =    color(55, 55, 55);
    cellHidden =    color(200,200,200);
		backNormal =    color(125, 125, 125);

    f = createFont("Calibri Bold", fontSize);
    m = createFont("Calibri Bold", 18);
    s = createFont("Calibri Bold", 8);
    textFont(f);
    textAlign(CENTER, CENTER);

    colorMode(RGB, 255);
	}

	void displayAll(SudePuzzle input) {
		displayGrid();
    if (visibleIndices) displayIndices();
		displayNums(input);
    if (visibleCandidates) displayCands(input);
	}

  void toggleVisible() {
    visibleIndices = !visibleIndices;
    visibleCandidates = !visibleCandidates;
  }

	void displayGrid() {
    
  	//Background
    fill(backNormal);
    noStroke();
    rect(0,0,tableWidth,tableWidth);

    //Cells
    stroke(cellBorder);
    strokeWeight(1);
    fill(255);
    int cellSize = tableWidth / 9;
    int spacing = tableWidth / 9;

    for (int i = 0; i < 9; ++i)
    {
      for (int j = 0; j < 9; ++j)
      {
      	if ((i == activeRow) && (j == activeCol)) {
      		fill(cellActive);
      	}
      	else if ((i == activeRow) || (j == activeCol)) {
          fill(cellDependent);
      	}
        else if (((i / 3) == (activeRow / 3)) && ((j / 3) == (activeCol / 3))) {
          fill(cellDependent);
        }
        else {
          fill(cellNormal);
        }

	    rect(spacing*i, spacing*j, cellSize, cellSize);

      }
    }

    //Internal borders
    for (int i = 1; i < 9; i++)
    {
      if ((i % 3) == 0)
      {
        strokeWeight(2);
        stroke(60);
        line(0,				i*tableWidth/9,	tableWidth,		i*tableWidth/9);
        line(i*tableWidth/9,0,				i*tableWidth/9,	tableWidth);
      }

    }

  }

  void displayIndices() {
    textFont(s);
    textAlign(LEFT, TOP);

    fill(cellHidden);
    int xOffset = 3;
    int yOffset = 3; 
    int spacing = tableWidth / 9;

    for (int i = 0; i < 9; ++i)
    {
      for (int j = 0; j < 9; ++j)
      {

        int current = j * 9 + i;

        if (current != 0) {

          int localx = i*spacing+xOffset;
          int localy = j*spacing+yOffset;

          text(current, localx, localy);
        }
      }
    }

    
    fill(0);
  }

	void displayNums(SudePuzzle input) {
    fill(0);
    textFont(f);
    textAlign(CENTER, CENTER);

    int xOffset = tableWidth / 18;
    int yOffset = tableWidth / 18 - 4; 
    int spacing = tableWidth / 9;

    for (int i = 0; i < 9; ++i)
    {
      for (int j = 0; j < 9; ++j)
      {
        if ((i == activeRow) && (j == activeCol)) {
          fill(fontActive);
        }
        else if ((i == activeRow) || (j == activeCol)) {
          fill(fontDependent);
        }
        else if ((i / 3 == activeRow / 3) && (j / 3 == activeCol / 3)) {
          fill(fontDependent);
        }
        else {
          fill(fontNormal);
        }

      	int current = input.board[j * 9 + i].getValue();

        if (current != 0) {

          text(current, i*spacing+xOffset, j*spacing+yOffset);
        }
      }
    }
  }

  void displayCands(SudePuzzle input) {

    fill(200);
    textFont(m);
    textAlign(CENTER, CENTER);

    int xOffset = 10;
    int yOffset = 10; 
    int spacing = tableWidth / 9;

    for (int i = 0; i < 9; ++i)
    {
      for (int j = 0; j < 9; ++j)
      {
        if ((i == activeRow) && (j == activeCol)) {
          fill(fontActive);
        }
        else if ((i == activeRow) || (j == activeCol)) {
          fill(fontDependent);
        }
        else if ((i / 3 == activeRow / 3) && (j / 3 == activeCol / 3)) {
          fill(fontDependent);
        }
        else {
          fill(cellHidden);
        }

        int check = input.board[j * 9 + i].getValue();

        if (check == 0) {

          boolean[] current = input.board[j * 9 + i].getCandidates();

          for (int cand = 1; cand < 10; ++cand) {
            
            if (current[cand] == true) {
              int localx = i * spacing + xOffset + spacing / 3 * ((cand-1) % 3);
              int localy = j * spacing + yOffset + spacing / 3 * ((cand-1) / 3); 
              text(cand, localx, localy);
            }
          }
        }
      }
    }
  }

  void setActiveRow(int _val) {
    activeRow = _val;
  }

  void setActiveCol(int _val) {
    activeCol = _val;
  }
}