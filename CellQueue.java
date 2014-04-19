import java.util.LinkedList;
import java.util.Iterator;

public class CellQueue implements Iterable<SudeCell>{ 
	
	private LinkedList<SudeCell> queue = new LinkedList<SudeCell>();

	public Iterator<SudeCell> iterator() {
		return queue.descendingIterator();
	}

	public void push(SudeCell i) {
		queue.push(i);
	}

	public void push(SudeCell... array) {
		for (SudeCell i : array) {
			queue.push(i);
		}
	}

	public void clear() {
		queue.clear();
	}

	public void remove() {
		queue.remove(queue.size() - 1);
	}

	public boolean hasNext() {
		return (queue.size() != 0);
	}

	public SudeCell next() {
		return (queue.removeLast());
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
}