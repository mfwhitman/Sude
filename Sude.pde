PFont f;

SudePuzzle test;
SudeDisplay display;

int sketchSize = 668;
int sketchMargin = 10;
int puzzleSize = sketchSize - sketchMargin * 2;

void setup() {
  size(sketchSize, sketchSize);
  background(0);

  //Solvable using basic patterns and locked candidates only:
  //test = new SudePuzzle("700060009501000000000401060200010090005000400010020006030607000000000305900030007");
  //test = new SudePuzzle("060000004800900010510000020000700000704509306000006000030000061050004007100000030");

  //Not solvable at this time:
  test = new SudePuzzle("000040080000008100870010600400200000361000729000001005004030058006900000020070000");
  

  display = new SudeDisplay(puzzleSize);
} 

void draw() {

  background(125);
  translate(sketchMargin, sketchMargin);
  display.displayAll(test);

}

void mouseReleased() {

  if ((mouseX > sketchMargin) || (mouseX < (sketchSize + sketchMargin))) {

    int temp = (mouseX-sketchMargin) * 9 / sketchSize ;
    display.setActiveRow(temp);
  }
  else {

    display.setActiveRow(-16);
  }
  if ((mouseY > sketchMargin) || (mouseY < (sketchSize + sketchMargin))) {

    int temp = (mouseY - sketchMargin) * 9 / sketchSize ;
    display.setActiveCol(temp);
  }
  else {

    display.setActiveCol(-16);
  }

  if ((display.activeCol != -16) || (display.activeRow != -16)) {

    test.board[display.activeCol * 9 + display.activeRow].report();
  }
}

void keyPressed() {

  if (key == ENTER) {

    println("Starting search...");
    test.solve();
  }
  if (key == '0') {

    test.board[display.activeCol * 9 + display.activeRow].forceAssign(0);
    println("Erasing: " + test.board[display.activeCol * 9 + display.activeRow]);
  }
}