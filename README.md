# Sude

This project is a Sudoku solver written in Processing/Java that operates on deductive logic. Currently incomplete.

The aim of this project is to solve a Sudoku puzzle just as a person would. To that effect, no brute force methods are used. The solver uses deductive patterns described by [Angus Johnson](http://angusj.com/sudoku/hints.php). The solver searches for the occurance of these patterns until the board is solved.

## Installation

Extract files to a folder named 'Sude' in your Processing sketches directory.

## Instructions

Press Enter to perform a single sweep of the board.


## Files

| Filename | Description |
| ---------|-------------|
| .pde | Processing Files |
| Sude.pde | Runs the Processing Sketch, catches keyboard/mouse presses. |
| SudePuzzle.pde | Establishes the basic board logic, and the deductive patterns. |
| SudeDisplay.pde | Renders the Sudoku board. |
| ---------|-------------|
| .java | Java Classes |
| SudeCell.java | Describes a single cell of a Sudoku board. |
| CellQueue.java | Describes a collection of cells. |
| SudeGraph.java | Converts a collection of cells into a multigraph. |
| GraphEdge.java | Describes an edge of a multigraph. |


## Terminology

**Cell**: One of 81 spaces on a Sudoku board. These are stored in row-major order. Each cell has a value.

**Candidate**: A possible value of a cell. Initially, each cell has nine candidates (1 to 9) that will be eliminated/excluded until one remains.

**Ascent**: Any row, column or 3*3 box that contains the numbers 1 to 9.


## Deductive Patterns

### Naked Tuple:
When *n* cells in an ascent share the same *n* candidates, and nothing else.
(These candidates may appear in other cells in the ascent.)
As the final value of these *n* cells will be a permutation of those *n* candidates, they can be eliminated from the other cells in the ascent.

### Hidden Tuple:
When *n* candidates only occur in *n* cells in an ascent.
(These cells may contain other candidates.)
As no other cell has these candidates, every other candidate can be eliminated from these cells.

### Locked Candidate:
If a candidate occurs in the intersection of ascents *A AND B* (i.e. Box and Row/Col),
and *A NOT B* doesn't contain that candidate,
then *B NOT A* cannot either.

