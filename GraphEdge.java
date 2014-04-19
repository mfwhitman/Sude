public class GraphEdge {
	public int type;
	public int first;
	public int second;

	GraphEdge(int _type, int _a, int _b) {

		type = _type;

		if (_a < _b) {

			first = _a;
			second = _b;
		}
		else {

			first = _b;
			second = _a;
		}
	}

	public void report() {
		System.out.println(type + "-Edge connects [" + first + "] and [" + second + "]");
	}
}