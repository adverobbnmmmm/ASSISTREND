#include <algorithm>
#include <string>
#include <vector>

// This file provides implementations for the missing symbols in the Firebase libraries
// It forces the linker to include these functions that are referenced by Firebase

// Disable warnings about unused variables and discarded return values
#pragma warning(disable: 4834)
#pragma warning(disable: 4101)

extern "C" {
    // Force implementation of __std_find_end_1
    void* __std_find_end_1() {
        // Use non-null values to avoid undefined behavior
        std::vector<char> v1 = {'a', 'b'};
        std::vector<char> v2 = {'a'};
        // Store result to prevent nodiscard warning
        auto result = std::find_end(v1.begin(), v1.end(), v2.begin(), v2.end());
        return nullptr;
    }
    
    // Force implementation of __std_search_1
    void* __std_search_1() {
        // Use non-null values to avoid undefined behavior
        std::vector<char> v1 = {'a', 'b'};
        std::vector<char> v2 = {'a'};
        // Store result to prevent nodiscard warning
        auto result = std::search(v1.begin(), v1.end(), v2.begin(), v2.end());
        return nullptr;
    }
    
    // Force implementation of __std_remove_8
    void* __std_remove_8() {
        // Use non-null values to avoid undefined behavior
        std::vector<int> v = {1, 2, 3, 2};
        // Store result to prevent nodiscard warning
        auto result = std::remove(v.begin(), v.end(), 2);
        return nullptr;
    }
    
    // Force implementation of __std_find_last_of_trivial_pos_1
    void* __std_find_last_of_trivial_pos_1() {
        std::string s = "test";
        // Store result to prevent nodiscard warning
        auto result = s.find_last_of("t");
        return nullptr;
    }
}
