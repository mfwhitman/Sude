import java.util.*;

public class SudeGraph {
	private HashMap<Integer, SudeCell> nodes = new HashMap<Integer, SudeCell>();
	private ArrayList<GraphEdge> edges = new ArrayList<GraphEdge>();

	public void addNode(SudeCell cell) {

		Integer temp = cell.getPosition();
		nodes.put(temp, cell);
	}

	public void addNode(SudeCell... cell) {

		for (SudeCell current : cell) {
			Integer temp = current.getPosition();
			nodes.put(temp, current);
		}
	}

	public void addEdge(GraphEdge newEdge) {

		if ((newEdge.type < 1) && (newEdge.type > 9)) {

			System.out.println("Invalid candidate number: " + newEdge.type);
			return;
		}

		SudeCell a = nodes.get(newEdge.first);
		SudeCell b = nodes.get(newEdge.second);

		if ((a.hasCandidate(newEdge.type)) && b.hasCandidate(newEdge.type)) {

			edges.add(newEdge);
		}
	}

	public void populateEdges() {
		
		Iterator it = nodes.entrySet().iterator();

		for (SudeCell first : nodes.values()) {

			for (SudeCell second : nodes.values()) {

				if (first == second) {

					continue;
				}
				else {

					for (int i = 1; i < 10; ++i) {

						if ((first.hasCandidate(i)) && second.hasCandidate(i)) {

							GraphEdge temp = new GraphEdge(i, first.getPosition(), second.getPosition());
							this.addEdge(temp);
						}
					}
				}
			}
		}
	}


}