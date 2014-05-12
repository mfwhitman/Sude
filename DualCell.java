import java.util.TreeSet;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Collections;

public class DualCell implements Comparable<DualCell> {

	private int candidate;
	private int value;
	private TreeSet<Integer> positions;

	DualCell(int _candidate) {
		candidate = _candidate;
		value = 0;
		positions = new TreeSet<Integer>();
	}

	public void addPosition(Integer _position) {
		positions.add(_position);

	}

	public boolean isKnown() {
		return (value != 0);
	}

	public void setValue(int _value) {
		value = _value;
	}

	public boolean hasPosition(int _position) {
		return positions.contains(_position);
	}

	public int[] getPositions() {
		int[] temp = new int[positions.size()];
		int i = 0;
		for (int p : positions) {
			temp[i++] = p;
		}
		return temp;
	}

	/*public void addPositions(ArrayList<Integer> a) {
		for (Integer i : a) {
			if (a.contains(i) == false)
				a.add(i);
		}
	}*/

	public int getCandidate() {
		return candidate;
	}

	public String stringify() {
		String word = "";
		if (this.isKnown() == false) {
			word += "(" + candidate + ")";
		} else {
			word += "(X)";
		}
		for (int i : positions) {
			word += " " + i;
		}
		return word;
	}

	@Override
	public int compareTo(DualCell o) {
		int answer = 0;
		if (this.candidate < o.getCandidate()) {
			answer = -1;
		} else if (this.candidate == o.getCandidate()) {
			answer = 0;
		} else if (this.candidate > o.getCandidate()) {
			answer = 1;
		}
		return answer;
	}

}