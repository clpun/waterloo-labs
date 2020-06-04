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

	// Copy the stored object in the original array to the new array.
	for(int i = 0; i < array_capacity; i++) {
		array[i] = stack.array[i];
	}
}

template <typename Type>
Drop_off_stack_as_array<Type>::~Drop_off_stack_as_array() {
	delete [] array; // Deallocate the array memory. 
	array = 0; // Set the array pointer to point to null.
}

template <typename Type>
int Drop_off_stack_as_array<Type>::size() const {
	return entry_count; // Return the number of elements that are stored in the stack.
}

template <typename Type>
bool Drop_off_stack_as_array<Type>::empty() const {
	return (entry_count == 0); // Return true if the number of entries stored in the stack is zero.
}

template <typename  Type>
Type Drop_off_stack_as_array<Type>::top() const {
	if(empty()){
		throw underflow(); // Throw underflow exception if the array is empty.
	}
	return array[itop]; // Return the value of the entry at the top of the stack.
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
	// Check to see if the array is full.
	if(entry_count == array_capacity) {
		array[ibottom] = obj; // Overwrite the entry at the bottom by the new object.
		itop = ibottom; // This would be the top of the stack.
		// Check to see if ibottom has gone out of the range.
		if(ibottom + 1 < array_capacity) {
			ibottom++; // If not, increment ibottom by one.
		} else if (ibottom + 1 == array_capacity){
			ibottom = 0; // If yes, set ibottom to zero.
		}
	} else if(entry_count == 0 || entry_count < array_capacity){
		// If the stack is empty, just simply store the object at the top of the stack.
		if (itop == ibottom && empty()) {
			array[itop] = obj;
		} else {
			// If the array is not full and itop has not gone out of the range, just simply append the new object.
			if(itop + 1 < array_capacity) {
				array[itop + 1] = obj;
				itop++;
			} else if(itop + 1 == array_capacity) {
			// If itop has gone out of the range, set it to zero.
				itop = 0;
				array[itop] = obj;
			}
		}
		entry_count++;
    }
}

template <typename Type>
Type Drop_off_stack_as_array<Type>::pop() {
	// Check to see if the stack is empty.
	if(empty()){
		throw underflow(); // Throw an underflow exception if the stack is empty.
	} else {
		Type tmp = array[itop]; // Get the value that is store at the top of the stack.
		array[itop] = 0; // Removed the top entry.
		entry_count--; // Decrement the size of the stack.
		// update itop...
		if(itop - 1 >= 0) {
			itop--; // Simply decrement itop if itop has not gone out of range.
		} else {
			if (!empty()) {
				itop = array_capacity - 1; // if itop has gone out of range and the stack is not empty, let it point to the last element of the array.
			} else {
				// If the array is empty, set both ibottom and itop back to zero.
				itop = 0;
				ibottom = 0;
			}
		}
		return tmp; // Return the value.
	}
}

template <typename Type>
void Drop_off_stack_as_array<Type>::clear() {
	// Reset member variables.
	entry_count = 0;
	itop = 0;
	ibottom = 0;
	// Delete the old array and create a new one.
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

	for (int i = 0 ; i < stack.array_capacity ; i++) {
		cout << stack.array[i] << " ";
	}
	cout << endl;

	return out;
}

// Is an error showing up in ece250.h or elsewhere?
// Did you forget a closing '}' ?

#endif
