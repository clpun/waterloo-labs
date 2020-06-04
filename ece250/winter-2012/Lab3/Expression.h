#ifndef EXPRESSION_H
#define EXPRESSION_H

/*****************************************
 * UW User ID:  clpun
 * Submitted for ECE 250
 * Department of Electrical and Computer Engineering
 * University of Waterloo
 * Calender Term of Submission:  (Winter) 2012
 *
 * By submitting this file, I affirm that
 * I am the author of all modifications to
 * the provided code.
 *****************************************/

#include "ece250.h"
#include "ExpressionTree.h"

class Expression {
	private:
		ExpressionTree *root; // A pointer to the root of an ExpressionTree. 

	public:
		Expression( int n = 0 ); // Constructor
		~Expression(); // Destructor

		// Accessors
		
		int evaluate() const; // Do calculation of the tree
		void in_fix() const; // Prints out the nodes using the in-fix format
		void reverse_polish() const; // Prints out the nodes using the reverse polish format

		// Mutators

		void add( int );
		void subtract( int );
		void subtracted_from( int );
		void times( int );
		void divided_by( int );
		void divides( int );
};

Expression::Expression( int n ):
root( new ExpressionTree( n ) ) {
	// Empty contructor.
}

Expression::~Expression() {
	// If the tree has at least one element, call the clear function in the ExpressionTree class. 
	if (root != 0) {
		root->clear();
		root = 0;
	}
}

void Expression::add(int v) {
	// Create a new node with a plus sign, with the original root be its left child and the new node with value v be its right child.
	ExpressionTree obj;
	ExpressionTree *plus_sign = new ExpressionTree(obj.PLUS, root, new ExpressionTree(v));  
	root = plus_sign; // Set the new node as the root
}

void Expression::subtract(int v) {
	// Create a new node with a minus sign, with the original root be its left child and the new node with value v be its right child.
	ExpressionTree obj;
	ExpressionTree *minus_sign = new ExpressionTree(obj.MINUS, root, new ExpressionTree(v)); 
	root = minus_sign; // Set the new node as the root
}

void Expression::subtracted_from(int v) {
	// Create a new node with a minus sign, with the new node with value v be its left child and the original root be its right child.
	ExpressionTree obj;
	ExpressionTree *sub_from = new ExpressionTree(obj.MINUS, new ExpressionTree(v), root);
	root = sub_from;
}

void Expression::times(int v) {
	// Create a new node with a times sign, with the original root be its left child and the new node with value v be its right child.
	ExpressionTree obj;
	ExpressionTree *times_sign = new ExpressionTree(obj.TIMES, root, new ExpressionTree(v));
	root = times_sign;
}

void Expression::divided_by(int v) {
	// Create a new node with a division sign, with the original root be its left child and the new node with value v be its right child.
	ExpressionTree obj;
	ExpressionTree *div_by = new ExpressionTree(obj.DIVIDE, root, new ExpressionTree(v));
	root = div_by;
}

void Expression::divides(int v) {
	// Create a new node with a division sign, with the new node with value v be its left child and the original root be its right child.
	ExpressionTree obj;
	ExpressionTree *divide_sign = new ExpressionTree(obj.DIVIDE, new ExpressionTree(v), root);
	root = divide_sign;
}

int Expression::evaluate() const {
	return root->evaluate(); // Call the evaluate function in the ExpressionTree class.
}

void Expression::in_fix() const {
	ExpressionTree obj;
	if ((root->retrieve() == obj.PLUS) || (root->retrieve() == obj.MINUS) || (root->retrieve() == obj.TIMES) || (root->retrieve() == obj.DIVIDE)) {
		root->in_fix(-1); // Call the in_fix function in the ExpressionTree class if the node is a sign
		cout << ' ' << endl;
	} else {
		cout << root->retrieve() << endl; // Just print out the value of the root if the root is not a sign. 
	}
}

void Expression::reverse_polish() const {
	root->reverse_polish(); // Call the reverse_polish function in the ExpressionTree class.
	cout << ' ' << endl;
}

#endif
