#ifndef DROP_OFF_STACK_AS_ARRAY_H
#define DROP_OFF_STACK_AS_ARRAY_H

/*****************************************
 * UW User ID:  clpun
 * Submitted for ECE 250
 * Semester of Submission:  (Winter) 2012
 *
 * By submitting this file, I affirm that
 * I am the author of all modifications to
 * the provided code.
 *****************************************/

#include "Exception.h"

using namespace std;

template <typename Type>
class Drop_off_stack_as_array {
	private:
		int itop; // top index
		int ibottom; // bottom index
		int entry_count; // Entry counter
		int array_capacity; //The capacity of the array
		Type *array; // A pointer to an instance of Type, to be used as an array

	public:
		Drop_off_stack_as_array( int = 10 ); // The constructor takes as an argument the capacity of 
											 // the array (n) and allocates memory for that array. 
											 // The default number of entries is 10.
		Drop_off_stack_as_array( Drop_off_stack_as_array const & ); // The copy constructor creates a new instance of the stack.
		~Drop_off_stack_as_array(); // The destructor deletes the memory allocated for the array.

		int size() const; // Returns the number of elements currently stored in the stack.
		bool empty() const; // Returns true if the stack is empty, false otherwise.
		Type top() const; // Return the object at the top of the stack.

		void swap( Drop_off_stack_as_array & ); // The swap function swaps all the member variables of this stack with those of the argument.
		Drop_off_stack_as_array &operator = ( Drop_off_stack_as_array const & ); // The assignment operator makes a copy of the argument and 
																				 // then swaps the member variables of this node with those of the copy.
		void push( Type const & ); // Insert the new element at the top of the stack. If the stack is full, the element at the bottom of the stack is removed.
		Type pop(); // Removes the element at the top of the stack.
		void clear(); // Removes all the elements in the stack.

	// Friends

	template <typename T>
	friend std::ostream &operator << ( std::ostream &, Drop_off_stack_as_array<T> const & );
};

template <typename Type>
Drop_off_stack_as_array<Type>::Drop_off_stack_as_array( int n ):
	itop(0), ibottom(0), entry_count(0), array_capacity(max( 1, n )), array(new Type[array_capacity]){
	
		// empty constructor
}

template <typename Type>
Drop_off_stack_as_array<Type>::Drop_off_stack_as_array( Drop_off_stack_as_array<Type> const &stack ):
itop( stack.itop ),
ibottom( stack.ibottom ),
entry_count( stack.entry_count ),
array_capacity( stack.array_capacity ),
array( new Type[array_capacity] ) {
	// The above initializations copy the values of the appropriate
	// member variables and allocate memory for the data structure; 
	// however, you must still copy the stored objects.

	for(int i = 0; i < entry_count; i++) {
		array[i] = stack.array[i];
	}
}

template <typename Type>
Drop_off_stack_as_array<Type>::~Drop_off_stack_as_array() {
	delete [] array;
	array = 0;
}

template <typename Type>
int Drop_off_stack_as_array<Type>::size() const {
	return entry_count;
}

template <typename Type>
bool Drop_off_stack_as_array<Type>::empty() const {
	return (entry_count == 0);
}

template <typename  Type>
Type Drop_off_stack_as_array<Type>::top() const {
	if(empty()){
		throw underflow();
	}
	return array[entry_count-1];
}

template <typename Type>
void Drop_off_stack_as_array<Type>::swap( Drop_off_stack_as_array<Type> &stack ) {
	std::swap( itop, stack.itop );
	std::swap( ibottom, stack.ibottom );
	std::swap( entry_count, stack.entry_count );
	std::swap( array_capacity, stack.array_capacity );
	std::swap( array, stack.array );
}

template <typename Type>
Drop_off_stack_as_array<Type> &Drop_off_stack_as_array<Type>::operator = ( Drop_off_stack_as_array<Type> const &rhs ) {
	Drop_off_stack_as_array<Type> copy( rhs );

	swap( copy );
	
	return *this;
} 

template <typename Type>
void Drop_off_stack_as_array<Type>::push( Type const &obj ) {
	if(entry_count == array_capacity) {
		// array[ibottom] = obj;
		for(int i = 0; i < itop; i++) {
			array[i] = array[i + 1];
		}
		array[itop] = obj;
	} else if(entry_count == 0 || entry_count < array_capacity){
		array[entry_count] = obj;
		itop = entry_count;
		entry_count++;
    }
}

template <typename Type>
Type Drop_off_stack_as_array<Type>::pop() {
	if(empty()){
		throw underflow();
	} else {
		Type tmp = array[entry_count - 1];
		array[entry_count - 1] = 0;
		entry_count--;
		itop = entry_count - 1;
		return tmp;
	}
}

template <typename Type>
void Drop_off_stack_as_array<Type>::clear() {
	entry_count = 0;
	itop = 0;
	ibottom = 0;

	delete [] array;
	array = new Type[array_capacity];
}

// You can modify this function however you want:  it will not be tested

template <typename T>
std::ostream &operator << ( std::ostream &out, Drop_off_stack_as_array<T> const &stack ) {
	// I don't know how you are implementing your stack so I cannot print it.
	// If you want, you can print whatever you want here and then call cout
	// in the driver.

	// Remember to redirect to out, e.g.,
	//      out << "Hello!";

	return out;
}

// Is an error showing up in ece250.h or elsewhere?
// Did you forget a closing '}' ?

#endif
