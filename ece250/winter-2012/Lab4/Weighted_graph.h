#ifndef WEIGHTED_GRAPH_H
#define WEIGHTED_GRAPH_H

#include <iostream>
#include <limits>
#include "Exception.h"

/*****************************************
 * UW User ID:  clpun
 * Submitted for ECE 250
 * Semester of Submission:  (Winter) 2012
 *
 * By submitting this file, I affirm that
 * I am the author of all modifications to
 * the provided code.
 *****************************************/
using namespace std;

class Weighted_graph {
	private:
		static const double INF; // Infinity
		int initial_size; // The initial dimension of the matrix.
		double **edges; // Array of pointers to point at arrays associated with each vertex. 
		int count; // Number of edges. 
		bool *visited; // Keep track of vertices that are visited. Used in mst function.
		bool *path_exist_check; // Keep track of vertices that are checked. Used in path_exist and all_visited.
		int *v_degree; // Store the number of degrees of each vertex.

	public:
		Weighted_graph( int = 50 ); // Constructor
		~Weighted_graph(); // Deconstructor

		int degree( int ) const; // Return the degree of vertex n.
		int edge_count() const; // Return the number of edges in the graph.
		double adjacent( int, int ) const; // Return the weight of the edge between two vertices.
		double minimum_spanning_tree( int ) const; // Return the weight of the minimum spanning tree. 
		bool path_exist(int, int) const; // Check to see if a path exist between two vertices. 
		bool all_visited(int) const; // Check to see if all vertices connected to vertex m are visited.
		bool is_connected() const; // Check to see if the graph is connected. 

		void insert( int, int, double ); // Insert an edge with weight w between two vertices. 

	// Friends

	friend std::ostream &operator << ( std::ostream &, Weighted_graph const & );
};

const double Weighted_graph::INF = std::numeric_limits<double>::infinity();

// Constructor
Weighted_graph::Weighted_graph(int n):
initial_size(max(1, n)), count(0), edges(new double*[initial_size]), 
visited(new bool[initial_size]), path_exist_check(new bool[initial_size]),
v_degree(new int[initial_size]) {
	// Initialize the arrays. 
	for(int i = 0; i < initial_size; i++) {
		edges[i] = new double[initial_size];
		visited[i] = false;
		path_exist_check[i] = false;
		v_degree[i] = 0;
	}
	// Initialize the matrix.
	for(int i = 0; i < initial_size; i++) {
		for(int j = 0; j < initial_size; j++) {
			edges[i][j] = INF;
		}
		edges[i][i] = 0;
	}
}

// Destructor
Weighted_graph::~Weighted_graph() {
	// Deallocation done here. 
	for(int i = 0; i < initial_size; i++) {
		delete [] edges[i];
	}
	delete [] edges;
	delete [] visited;
	delete [] path_exist_check;
	delete [] v_degree;
}

// degree function
int Weighted_graph::degree( int n ) const {
	// If n is out of the range, throw an illegal argument exception. 
	if(n < 0 || n >= initial_size) {
		throw illegal_argument();
	}
	// Return the degree of vertex n. 
	return v_degree[n];
}

// edge_count function
int Weighted_graph::edge_count() const {
	// Return the number of edges in the graph. 
	return count;
}

// adjacent function
double Weighted_graph::adjacent( int m, int n ) const {
	// If any of the arguments are out of the range, throw an illegal argument exception. 
	if(m < 0 || m >= initial_size || n < 0 || n >= initial_size) {
		throw illegal_argument();
	}

	// Return the weight of the edge between m and n. 
	// Return infinity if m and n are not connected. 
	if((edges[m][n] != INF) && (m != n)) {
		return edges[m][n];
	} else if(m == n) {
		return 0;
	} else {
		return INF;
	}
}

// is_connected function
bool Weighted_graph::is_connected() const {
	// The following checks if a path exist between every vertex in the graph. 
	// path_exist is used to determine if a path exist between i and j. Return false if not. 
	for(int i = 0; i < initial_size; i++) {
		for(int j = 0; j < initial_size; j++) {
			if(path_exist(i, j) == false) {
				return false;
			}
			// Reset the array after a vertex is checked. 
			for(int k = 0; k < initial_size; k++) {
				path_exist_check[k] = false;
			}
		}
	}

	return true;
}

// minimum_spanning_tree function. 
double Weighted_graph::minimum_spanning_tree( int m ) const {
	// Throw illegal argument exception if m is out of range. 
	if(m < 0 || m >= initial_size) {
		throw illegal_argument();
	}
 
	visited[m] = true; // Set the current vertex as visited.
	int n = -1; // n is used to keep track of the index of the visited vertex. 
	double min_span_tree_sum = 0; // Initialize the total weight of the minimum spanning tree to 0.
	double min; // min is used to store the minimum weight. 

		while(!all_visited(m)) {
			min = INF; // Set min to infinity first. 
			for(int i = 0; i < initial_size; i++) {
				// Find the neighbour with the minimum weight. 
				if(visited[i]) {
					for(int j = 0; j < initial_size; j++) {
						if(visited[j] == false) {
							if(min > edges[i][j]) {
								min = edges[i][j];
								n = j;
							}
						}
					}
				}
			}

			visited[n] = true; // Set the neighbour with minimum weight as visited. 
			min_span_tree_sum += min; // Add the edge to the spanning tree. 
		}

	// Reset the visited array. 
	for(int k = 0; k < initial_size; k++) {
		visited[k] = false;
	}

	return min_span_tree_sum;
}

// path_exist function
bool Weighted_graph::path_exist(int m, int n) const {
	// Throw illegal argument exception if m and n is out of range.
	if(m == n || edges[m][n] != INF) {
		return true;
	}

	path_exist_check[m] = true; // Set the current vertex as checked. 
	// Check to see if a path exist between m and n. 
	for(int i = 0; i < initial_size; i++) {
		if(path_exist_check[i] == false && adjacent(m, i) != INF) {
			path_exist_check[i] = true;
			if(path_exist(i, n)) {
				return true;
			}
		}
	}

	return false;
}

// all_visited function
bool Weighted_graph::all_visited(int m) const {
	// First reset the path_exist_check array. 
	for(int j = 0; j < initial_size; j++) {
		path_exist_check[j] = false;
	}

	// If a path exist between m and the vertex i and i is not visited yet, return false. 
	for(int i = 0; i < initial_size; i++) {
		if(path_exist(m, i) && visited[i] == false && m != i) {
			return false;
		}
		// Reset the path_exist_check array. 
		for(int j = 0; j < initial_size; j++) {
			path_exist_check[j] = false;
		}
	}

	return true;
}

// insert function
void Weighted_graph::insert( int m, int n, double w ) {
	// Throw illegal argument exception if m and n are out of range or m is equal to n. 
	// If w is 0, remove the edge between m and n. (only if they are connected)
	// Else, add an edge between m and n. Update edge count if they are not connected before insertion. 
	// Update degree of the associated vertices as well. 
	if(w < 0 || w == INF || m < 0 || m >= initial_size || n < 0 || n >= initial_size || m == n) {
		throw illegal_argument();
	} else if(w == 0) {
		if(edges[m][n] != INF) {
			edges[m][n] = INF;
			edges[n][m] = INF;
			count--;
			v_degree[m]--;
			v_degree[n]--;
		}
	} else {
		if(edges[m][n] == INF) {
			edges[m][n] = w;
			edges[n][m] = w;
			count++;
			v_degree[m]++;
			v_degree[n]++;
		} else {
			edges[m][n] = w;
			edges[n][m] = w;
		}
	}
}

std::ostream &operator << ( std::ostream &out, Weighted_graph const &graph ) {
	// Your implementation

	return out;
}

#endif
