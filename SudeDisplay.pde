class SudeDisplay {
	int tableWidth, fontSize;
	color fontActive, fontDependent, fontNormal, cellActive, cellDependent, cellNormal, cellBorder, backNormal;
  PFont f, s;

	int activeRow = -16, activeCol = -16;

	SudeDisplay(int _tableWidth) {
		tableWidth = _tableWidth;
		fontSize = tableWidth / 14;

		fontActive =    color(55, 0, 0);
		fontDependent = color(125, 125, 125);
		fontNormal =    color(25, 25, 25);
		cellActive =    color(255, 255, 255);
		cellDependent = color(255, 225, 225);
		cellNormal =    color(255, 255, 255);
		cellBorder =    color(55, 55, 55);
		backNormal =    color(125, 125, 125);

    f = createFont("Calibri Bold", fontSize);
    s = createFont("Calibri Bold", 8);
    textFont(f);
    textAlign(CENTER, CENTER);

    colorMode(RGB, 255);
	}

	void displayAll(SudePuzzle input) {
		displayGrid();
    displayIndices();
		displayNums(input);
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

    fill(100);
    int xOffset = 3;
    int yOffset = 3; 
    int spacing = tableWidth / 9;

    for (int i = 0; i < 9; ++i)
    {
      for (int j = 0; j < 9; ++j)
      {

        int current = j * 9 + i;

        if (current != 0)

          text(current, i*spacing+xOffset, j*spacing+yOffset);
      }
    }

    textFont(f);
    textAlign(CENTER, CENTER);
    fill(0);
  }

	void displayNums(SudePuzzle input) {
    fill(0);
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

        if (current != 0)

          text(current, i*spacing+xOffset, j*spacing+yOffset);
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