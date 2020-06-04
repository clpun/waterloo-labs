#ifndef DYNAMIC_QUEUE_AS_ARRAY_H
#define DYNAMIC_QUEUE_AS_ARRAY_H

/*****************************************
 * UW User ID:  clpun
 * Submitted for ECE 250
 * Semester of Submission:  (Winter) 2012
 *
 * By submitting this file, I affirm that
 * I am the author of all modifications to
 * the provided  code.
 *****************************************/

#include "ece250.h"
#include "Exception.h"

using namespace std;

template <typename Type>
class Dynamic_queue_as_array {
	private:
		int initial_capacity; // The initial capacity of the array
		int array_capacity; // The current capacity of the array
		int ihead; // head index
		int itail; // tail index
		int entry_count; // entry_count
		Type *array; // A pointer to an instance of Type, to be used as an array.
		// other integer member variables, as necessary

	public:
		Dynamic_queue_as_array( int = 10 ); // The constructor takes as an argument the initial capacity 
											// of the array and allocates memory for that array. 
											// If the argument is either 0 or a negative integer, 
											// set the initial capacity of the array to 1. 
		Dynamic_queue_as_array( Dynamic_queue_as_array const & ); // The copy constructor creates a new instance of the queue.
		~Dynamic_queue_as_array(); // Destructor deletes the memory allocated for the array.

		Type head() const; // Returns the object at the head of the queue.
		int size() const; // Returns the number of objects currently stored in the queue.
		bool empty() const; // Returns true if the queue is empty, false otherwise.
		int capacity() const; // Returns the size of the queue.

		void swap( Dynamic_queue_as_array & ); // Swaps all the member variables of this queue with those of the argument.
		Dynamic_queue_as_array &operator = ( Dynamic_queue_as_array const & ); //Makes a copy of the argument and then swaps the member variables of this node with those of the copy.
		void enqueue( Type const & ); // Insert the argument at the tail of the queue. 
		Type dequeue(); // Removes the object at the head of the queue. 
		void clear(); // Empties the queue.

	// Friends

	template <typename T>
	friend std::ostream &operator << ( std::ostream &, Dynamic_queue_as_array<T> const & );
};

template <typename Type>
Dynamic_queue_as_array<Type>::Dynamic_queue_as_array( int n ):
initial_capacity( max( n, 1 ) ),
array_capacity( initial_capacity ),
array( new Type[initial_capacity] ),
ihead( initial_capacity - 1 ),
itail( 0 ),
entry_count( 0 ) {
	// Empty contructor.
}

template <typename Type>
Dynamic_queue_as_array<Type>::Dynamic_queue_as_array( Dynamic_queue_as_array const &queue ):
initial_capacity( queue.initial_capacity ),
array_capacity( queue.array_capacity ),
array( new Type[array_capacity] ),
ihead( queue.ihead ),
itail( queue.itail ),
entry_count( queue.entry_count ) {
	// The above initializations copy the values of the appropriate
	// member variables and allocate memory for the data structure; 
	// however, you must still copy the stored objects.

	// Put the stored object in the original queue to the new created queue.
	for(int i = 0; i < array_capacity; i++) {
		array[i] = queue.array[i];
	}
}

template <typename Type>
Dynamic_queue_as_array<Type>::~Dynamic_queue_as_array() {
	delete [] array; // Delete the memory allocated for the array.
	array = 0; // Set the array pointer to point to null.
}

template <typename Type>
int Dynamic_queue_as_array<Type>::size() const {
	return entry_count; // Return the size fo the queue.
}

template <typename Type>
int Dynamic_queue_as_array<Type>::capacity() const {
	return array_capacity; // Return the cpacity of the queue.
}

template <typename Type>
bool Dynamic_queue_as_array<Type>::empty() const {
	return (entry_count == 0); // Return true if the number of entries stored in the queue is zero.
}

template <typename  Type>
Type Dynamic_queue_as_array<Type>::head() const {
	// Check to see if the queue is empty. 
	if(empty()) {
		throw underflow(); // If empyt, throw an underflow exception.
	}
	return array[ihead]; // Retrun the object at the head of the queue.
}

template <typename Type>
void Dynamic_queue_as_array<Type>::swap( Dynamic_queue_as_array<Type> &queue ) {
	std::swap( initial_capacity, queue.initial_capacity );
	std::swap( array_capacity, queue.array_capacity );
	std::swap( array, queue.array );
	std::swap( ihead, queue.ihead );
	std::swap( itail, queue.itail );
	std::swap( entry_count, queue.entry_count );
}

template <typename Type>
Dynamic_queue_as_array<Type> &Dynamic_queue_as_array<Type>::operator = ( Dynamic_queue_as_array<Type> const &rhs ) {
	Dynamic_queue_as_array<Type> copy( rhs );

	swap( copy );
	
	return *this;
} 

template <typename Type>
void Dynamic_queue_as_array<Type>::enqueue( Type const &obj ) {
	// Check to see if the array is full.
	if(size() == capacity()) {
		// Double the size.
		Type *tmp_array = new Type[2*array_capacity];
		// Put the stored objects of the original queue into the new queue.
		for(int i = 0; i < array_capacity; i++) {
          tmp_array[i] = array[i];
		}
		delete [] array; // Delete the memory allocated for the original array.
		array = tmp_array; // Set the array pointer to point to the new created array.
		array_capacity = 2*array_capacity; // Updated the capacity of the queue.
	}

	// Check to see if the queue is empty.
	if(empty()) {
		ihead = itail; // Make sure that ihead and itail is indicating the same position.
		array[itail] = obj; // Store the new object at the position indicated by itail. 
	} else {
		itail++; // First, update the position of itail.

		// Check to see if itail is out of range.
		if(itail > capacity() - 1) {
			itail = 0; // If yes, set is back to zero. 
		}

		array[itail] = obj; // Store the new object at the position indicated by itail.
	}
	entry_count++; // Increment entry_count by one.
}

template <typename Type>
Type Dynamic_queue_as_array<Type>::dequeue() {
	// If the queue is empty, throw an underflow exception.
	if(empty()) {
		throw underflow();
	}

	Type tmp = array[ihead]; // Get the object at the head of the queue.
	array[ihead] = 0; // Remove the object.
	
	// Check to see if ihead has gone out of range.
	if(ihead > capacity() - 1) {
		ihead = 0; // If yes, set it back to the zero position.
	} else {
		ihead++; // If not, simply increment ihead.
	}
	entry_count--; // Update the entry count.

	// If the array is 1/4 full and the array capacity is greater than the initial capacity, the capacity of the array is halved.
	if(entry_count >= (array_capacity/4) && array_capacity > initial_capacity) {
		Type *tmp_array = new Type[array_capacity/2];
		for(int i = 0; i < array_capacity/2; i++) {
          tmp_array[i] = array[i];
		}
		delete [] array;
		array = tmp_array;
		array_capacity = array_capacity/2;
	}
	return tmp; // Return the object.
}

template <typename Type>
void Dynamic_queue_as_array<Type>::clear() {
	// Reset all member variables.
	initial_capacity = 10;
	array_capacity = initial_capacity;
	ihead = 0;
	itail = 0;
	entry_count = 0;
	delete [] array;
	array = new Type[array_capacity];
}

// You can modify this function however you want:  it will not be tested

template <typename T>
std::ostream &operator << ( std::ostream &out, Dynamic_queue_as_array<T> const &queue ) {
	// I don't know how you are implementing your queue so I cannot print it.
	// If you want, you can print whatever you want here and then call cout
	// in the driver.

	// Remember to redirect to out, e.g.,
	//      out << "Hello!";

	return out;
}

// Is an error showing up in ece250.h or elsewhere?
// Did you forget a closing '}' ?

#endif
