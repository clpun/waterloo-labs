#ifndef DYNAMIC_DOUBLE_HASH_TABLE_H
#define DYNAMIC_DOUBLE_HASH_TABLE_H

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
#include "ece250.h"

using namespace std;

enum state { EMPTY, OCCUPIED, DELETED };

template<typename Type>
class Dynamic_double_hash_table {
	private:
		int power;
		int count; // A count of elements
		int deleted_count; // A count of deleted bins
		int array_size; // Current array size
		int initial_size; // Initial array size

		Type *array; // An array of objects
		state *occupied; // An array storing the current state of a bin

		int hash1(Type const &) const; // First hash function
		int hash2(Type const &, Type const &) const; // Second hash function
	public:
		Dynamic_double_hash_table( int = 5 ); // The contructor creates a hash table of 2^m bins. 
		~Dynamic_double_hash_table(); // Destructor
		int size() const; // Return the number of elements in the array.
		int capacity() const; // Return the number of bins.
		double load_factor() const; // Returns the load factor of hash table.
		double deleted_factor() const; // Returns the number of deleted bins over the number of bins.
		bool empty() const; // See if the array is empty
		bool member( Type const & ) const; // Returns true if object is in the hash table, false otherwise.
		int search( Type const & ) const; // Search for an element.
		Type bin( int ) const; // Return the bin for an element.

		void print() const;

		void insert( Type const & ); // Insert element into hash table.
		bool remove( Type const & ); // Remove element from hash table
		void clear(); // Removes all the elements in the hash table and resets the size to the initial size.

	// Friends

	template <typename T>
	friend std::ostream &operator << ( std::ostream &, Dynamic_double_hash_table<T> const & );
};

template<typename Type>
Dynamic_double_hash_table<Type>::Dynamic_double_hash_table( int m ):
power( max(2, m) ), count( 0 ), deleted_count( 0 ),
array_size( 1 << power ),
initial_size( 1 << power ),
array( new Type[array_size] ),
occupied( new state[array_size] ) {
	for ( int i = 0; i < array_size; ++i ) {
		occupied[i] = EMPTY; // Initial the occupied array.
	}
}

template<typename Type>
Dynamic_double_hash_table<Type>::~Dynamic_double_hash_table() {
	delete [] array; // Deallocate array
	delete [] occupied; // Deallocate occupied
	array = 0;
	occupied = 0;
}

template<typename Type>
int Dynamic_double_hash_table<Type>::size() const {

	return count; // Return element count.
}

template<typename Type>
int Dynamic_double_hash_table<Type>::capacity() const {

	return array_size; // Return the current size of the array.
}

template<typename Type>
double Dynamic_double_hash_table<Type>::load_factor() const {
	double loadfactor = (double)count/array_size;
	return loadfactor; // Returns the load factor of hash table.
}

template<typename Type>
double Dynamic_double_hash_table<Type>::deleted_factor() const {
	double deletefactor = (double)deleted_count/array_size;
	return deletefactor; // Returns the deleted factor of hash table.
}

template<typename Type>
bool Dynamic_double_hash_table<Type>::empty() const {

	return (count == 0); // Return true if hash table is empty, false otherwise.
}

template<typename Type>
bool Dynamic_double_hash_table<Type>::member( Type const &obj ) const {
	int index = hash1(obj);

	// Search for matching object, stop when an empty bin is reached.
	while(occupied[index] == OCCUPIED || occupied[index] == DELETED){
		if(occupied[index] != DELETED) {
			if(array[index] == obj) {
				return true; // Return true if object is found
			}
		}

		index = hash2(index, obj); // Keeps jumping if object is not found yet. 
	}

	return false; // Return false if object is not found.
}

template<typename Type>
int Dynamic_double_hash_table<Type>::search( Type const &obj ) const {
	int bin = 0;
	int index = hash1(obj);

	// Search for the bin that contains the object, stop when an empty bin is reached.
	while(occupied[index] == OCCUPIED || occupied[index] == DELETED){
		if(occupied[index] != DELETED) {
			if(array[index] == obj) {
				bin = index;
				return bin; // Return bin if object is found
			}
		}

		index = hash2(index, obj);
		// if index is out of bound, use index % array_size to determine appropriate location
		if(index >= array_size){
			index = index % array_size;
		}
	}

	return bin; // Return 0 if object is not found.
}

template<typename Type>
int Dynamic_double_hash_table<Type>::hash1(Type const &x) const{
	// First hash function, bin is determined by using x mod array_size
	int hash_value = 0;
	if (x % array_size >= 0) {
		hash_value = x % array_size;
	} else if (x % array_size < 0) {
		hash_value = array_size + (x % array_size);
	}
	return hash_value;
}

template<typename Type>
int Dynamic_double_hash_table<Type>::hash2(Type const &x, Type const &object) const{
	// Second hash function, the jump size is determined by using (object/array_size) % array_size
	// We want to make sure that the jump size is an odd number, so we have to "or" it with 1.
	int doublehashed = 0;
	int jump = ((object/array_size) % array_size) | 1;
	if (jump < 0) {
		doublehashed = x + (jump + array_size);
	} else {
		doublehashed = x + jump;
	}

	// If the doublehashed value is out of range, 
	// use doublehashed % array_size to determine appropriate location.
	if (doublehashed >= array_size) {
		doublehashed = doublehashed % array_size;
	}
	return doublehashed;
}

template<typename Type>
Type Dynamic_double_hash_table<Type>::bin( int n ) const {
	// DO NOT CHANGE
	return array[n];
}

template<typename Type>
void Dynamic_double_hash_table<Type>::insert( Type const &obj ) {
	// before the insertion the load factor greater or equal than 0.75, 
	// double the size of the hash table and rehash all original entries into the new hash table.
	if (load_factor() >= 0.75) {
		int old_array_size = array_size;
		Type *tmp_array = new Type[2*array_size]; // create a resized array
		state *old_state = occupied;
		occupied = new state[2*array_size]; // resize the state array

		for(int i = 0; i < 2*array_size; i++){
			occupied[i] = EMPTY; // Initialize the occupied array.
		}

		array_size = 2*array_size; // Update the array size
		Type tmp_value = 0;
		int index = 0;

		// Insert elements in the old array to the new array
		for(int i = 0; i < old_array_size; i++) {
			if (old_state[i] != DELETED && old_state[i] != EMPTY) {
				tmp_value = bin(i);
				index = hash1(tmp_value);
				while (occupied[index] == OCCUPIED) {
					index = hash2(index, tmp_value);
				}
				tmp_array[index] = tmp_value;
				occupied[index] = OCCUPIED;
			}
		}

		delete [] array;
		array = tmp_array;
		delete [] old_state; 
		tmp_array = 0;
		old_state = 0;
	}

	// add the new entry if obj >= 0.
	// do not add obj if it is already in the hash table.
	if (obj >= 0) {
		int bin = 0;
		if (member(obj) == false) {
			bin = hash1(obj);
			
			while (occupied[bin] == OCCUPIED) {
				bin = hash2(bin, obj);
			}
			array[bin] = obj;
			occupied[bin] = OCCUPIED;
			count++;
		}
	}
}

template<typename Type>
bool Dynamic_double_hash_table<Type>::remove( Type const &obj ) {
	// Remove the object from the hash table if it is in the hash table by setting the flag to DELETED.

		// After removing, halve the size of the hash table if not initial size && load factor <= 0.25
		// Re-insert the elements.
		// If the table was not halved in size but deleted_factor >= 0.25, 
		// rehash all the entries into the same sized hash table

	// Return false if object is not in the hash table.
	int index = 0;
	if (member(obj)) {
		index = search(obj);
		occupied[index] = DELETED;
		count--;
		deleted_count++;
		
		if ((array_size != initial_size) && (load_factor() <= 0.25)) {

			int old_array_size = array_size;
			Type *tmp_array = new Type[array_size/2];
			state *tmp_state = new state[array_size/2];
			for (int i = 0; i < array_size/2; i++) {
				tmp_state[i] = EMPTY;
				tmp_array[i] = 0;
			}

			array_size = array_size/2;
			
			for (int i = 0; i < old_array_size; i++) {
				Type tmp_value = 0;
				int bin = 0;
				if (occupied[i] == OCCUPIED) {
					tmp_value = array[i];
					bin = hash1(tmp_value);
					while (tmp_state[bin] == OCCUPIED) {
						bin = hash2(bin, tmp_value);
					}
					tmp_array[bin] = tmp_value;
					tmp_state[bin] = OCCUPIED;
				}
			}

			delete [] array;
			array = tmp_array;
			delete [] occupied;
			occupied = tmp_state;

			tmp_array = 0;
			tmp_state = 0;

			deleted_count = 0;

		} else if (deleted_factor() >= 0.25) {
			Type *tmp_array = new Type[array_size];
			state *tmp_state = new state[array_size];
			for (int i = 0; i < array_size; i++) {
				tmp_state[i] = EMPTY;
				tmp_array[i] = 0;
			}

			for (int i = 0; i < array_size; i++) {
				Type tmp_value = 0;
				int bin = 0;
				if (occupied[i] == OCCUPIED) {
					tmp_value = array[i];
					bin = hash1(tmp_value);
					while (tmp_state[bin] == OCCUPIED) {
						bin = hash2(bin, tmp_value);
					}

					tmp_array[bin] = tmp_value;
					tmp_state[bin] = OCCUPIED;
				}
			}

			delete [] array;
			array = tmp_array;

			delete [] occupied;
			occupied = tmp_state;

			tmp_array = 0;
			tmp_state = 0;

			deleted_count = 0;
		}
		return true;
	} else {
		return false;
	}
}

template<typename Type>
void Dynamic_double_hash_table<Type>::clear() {
	count = 0; // Reset element count to 0.
	delete [] array; // Deallocate original array
	delete [] occupied; // Deallocate original state array
	array = new Type[initial_size]; // Allocate new array
	occupied = new state[initial_size]; // Allocate new state array

	// Initialize all bins to 0.
	for(int i = 0; i < initial_size; ++i){
		array[i] = 0;
	}

	// Initialize states
	for(int i = 0; i < initial_size; i++){
		occupied[i] = EMPTY;
	}

	array_size = initial_size;
}


// You can modify this function however you want:  it will not be tested

template <typename T>
std::ostream &operator << ( std::ostream &out, Dynamic_double_hash_table<T> const &list ) {

	return out;
}

// Is an error showing up in ece250.h or elsewhere?
// Did you forget a closing '}' ?

#endif
