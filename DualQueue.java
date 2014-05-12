import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.TreeMap;

public class DualQueue implements Iterable<DualCell> {

	private TreeMap<Integer, DualCell> dualGraph;

	DualQueue() {

		dualGraph = new TreeMap<Integer, DualCell>();

		for (int i = 1; i < 10; ++i) {

			DualCell temp = new DualCell(i);
			dualGraph.put(i,temp);
		}
	}

	public Iterator<DualCell> iterator() {

		Collection entrySet = dualGraph.entrySet();
		return entrySet.iterator();
	}

	public void dualize(CellQueue c) {

		for (SudeCell s : c) {

			if (s.isKnown()) {

				dualGraph.get(s.getValue()).addPosition(s.getPosition());
				dualGraph.get(s.getValue()).setValue(s.getPosition());
			}
			else { 

				for (int i = 1; i < 10; ++i) {

					if (s.hasCandidate(i)) {

						dualGraph.get(i).addPosition(s.getPosition());
					}
				}
			}
		}
	}

	public int[] query(int[] array) {

		HashSet<Integer> walked = new HashSet<Integer>();

		for (int i : array) {

			if (dualGraph.get(i).isKnown() == true) {
				continue;
			}

			int[] positions = dualGraph.get(i).getPositions();
			for (int p : positions) {
				walked.add(p);
			}
		}

		int[] temp = new int[walked.size()];
		int i = 0;

		for (Integer o : walked) {
			if (o != 0)
				temp[i++] = o.intValue();
		}

		return temp;
	}

	public boolean isKnown(int _candidate) {
		
		return dualGraph.get(_candidate).isKnown();
	}

	public int getUnknownCount() {

		int accumulator = 0;

		for (Integer i : dualGraph.keySet()) {
			if (dualGraph.get(i).isKnown() == false)
				accumulator++;
		}

		return accumulator;
	}

	public String stringify() {
		String accumulator = "";

		for (Integer i : dualGraph.keySet()) {
			accumulator += dualGraph.get(i).stringify();
			accumulator += " ";
		}

		return accumulator;
	}

}