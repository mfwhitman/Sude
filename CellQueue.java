import java.util.LinkedList;
import java.util.Iterator;
import java.util.Collections;
import java.util.Comparator;

public class CellQueue implements Iterable<SudeCell> {
	
	private LinkedList<SudeCell> queue = new LinkedList<SudeCell>();


	public Iterator<SudeCell> iterator() {
		return queue.descendingIterator();
	}

	public void copy(CellQueue other) {
		
		for (SudeCell i : other) {
		
			this.push(i);
		}
	}

	public void push(SudeCell i) {
		if (queue.contains(i) == false) {
		
			queue.push(i);
		}
		/*
		else {
			System.out.print("?");
		}
		*/
	}

	public void push(SudeCell... array) {
		for (SudeCell i : array) {
			queue.push(i);
		}
	}

	public void push(CellQueue queue) {
		for (SudeCell i : queue) {
			queue.push(i);
		}
	}

	public void clear() {
		queue.clear();
	}


	public boolean hasNext() {
		return (queue.size() != 0);
	}

	public SudeCell next() {
		return queue.removeLast();
	}

	public SudeCell removeLast() {
		return (queue.removeLast());
	}

	public SudeCell removeFirst() {
		return (queue.removeFirst());
	}

	public SudeCell peek() {
		return (queue.peek());
	}

	public int size() {
		return (queue.size());
	}

	public SudeCell get(int i) {
		return (queue.get(i));
	}

	public boolean contains(SudeCell i) {
		return (queue.contains(i));
	}

	public boolean contains(int i) {

		boolean isPresent = false;

		for (SudeCell current : queue) {

			if (current.getPosition() == i) {

				isPresent = true;
				break;
			}
		}

		return isPresent;
	}

	/** Checks the queue to see if ANY cell has a candidate. */

	public boolean hasValue(int i) {

		boolean isPresent = false;

		for (SudeCell current : queue) {

			if (current.isValue(i) == true) {

				isPresent = true;
				break;
			}
		}
		
		return isPresent;
	}

	public boolean hasCandidate(int i) {

		boolean isPresent = false;

		for (SudeCell current : queue) {

			if (current.hasCandidate(i) == true) {

				isPresent = true;
				break;
			}
		}
		
		return isPresent;
	}

	public int countCandidates(int i) {

		int count = 0;

		for (SudeCell current : queue) {

			if (current.hasCandidate(i) == true) {

				count++;
			}
		}
		return count;
	}

	/** Excludes a candidate from an entire queue. */
	public void exclude(int i) {

		for (SudeCell current : queue) {
			current.exclude(i);
		}
	}

	public void subtract(boolean[] other) {

		for (SudeCell current : queue) {

			current.subtract(other);
		}
	}

	public String stringify() {

		String concatenator = "";

		for (SudeCell current: queue) {

			concatenator += current.stringify();
		}

		return concatenator;
	}

	public void sort() {

		Collections.sort(this.queue, new Comparator<SudeCell>() {

			@Override
			public int compare(SudeCell left, SudeCell right) {
				
				return left.compareTo(right);
			}
		});
	}
}