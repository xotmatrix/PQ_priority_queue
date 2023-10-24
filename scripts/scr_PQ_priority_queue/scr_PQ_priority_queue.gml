// README /////////////////////////////////////////////////////////////////

// This library re-implements the built-in priority queue functions using GML
// for cross-platform compatibility. GameMaker Studio's provided runtimes do
// not work exactly the same on every platform. These functions behave as
// documented in the GameMaker Studio manual and they should work the same
// on all platforms. This library cannot interoperate with built-in ds_priority
// functions but it can transparently and effortlessly replace the built-in
// ds_priority functions by overriding them with macros.
//
// Notes:
// - Items are added to queues with an insertion sort storage scheme. Items
//   in a queue are always in order by priority. Adding items may have a
//   higher cost but retrieving them can be faster.
// - Minimum and maximum priority searches are done in O(1) constant time.
// - Specific priority searches are done in O(n) linear time. 
// - Relative item queue positions are stable when items are added or deleted.
// - When searching for an item with a specific or minimum priority, items 
//   with the same priority are found in first-in-first-out order.
// - When searching for an item with maximum priority, items with the same
//   priority are found in last-in-first-out order.
// - When items are deleted from a queue by minimum or maximum priority, the
//   order items are removed by one method is the reverse order of the other.
// - Read/Write functions support structs.
// - Read/Write functions use human-readable JSON.
// - Priority queue indices are not recycled.
//
// Future:
// - Consider using a binary search for improved O(log n) logarithmic time
//   when adding items or searching for items with specific priorities.




// LICENSE ////////////////////////////////////////////////////////////////

// Copyright (c) 2023 John Leffingwell
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.




// CONFIGURATION //////////////////////////////////////////////////////////

/*
// Uncomment these macros to override built-in ds_priority functions.
#macro ds_priority_create PQ_priority_create
#macro ds_priority_destroy PQ_priority_destroy
#macro ds_priority_clear PQ_priority_clear
#macro ds_priority_empty PQ_priority_empty
#macro ds_priority_size PQ_priority_size
#macro ds_priority_add PQ_priority_add
#macro ds_priority_change_priority PQ_priority_change_priority
#macro ds_priority_delete_max PQ_priority_delete_max
#macro ds_priority_delete_min PQ_priority_delete_min
#macro ds_priority_delete_value PQ_priority_delete_value
#macro ds_priority_find_max PQ_priority_find_max
#macro ds_priority_find_min PQ_priority_find_min
#macro ds_priority_find_priority PQ_priority_find_priority
#macro ds_priority_copy PQ_priority_copy
#macro ds_priority_write PQ_priority_write
#macro ds_priority_read PQ_priority_read
*/




// EXTERNAL ///////////////////////////////////////////////////////////////

// Create a new priority queue and returns its index value.
function PQ_priority_create() {
    static _id = 0;
    var q = new PQ_queue(_id++);
    array_push(g_PQ_collection, q);
    return q._id;
}


// Remove a priority queue from memory.
function PQ_priority_destroy(_id) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    array_delete(g_PQ_collection, i, 1);
}


// Clear the contents of a priority queue.
function PQ_priority_clear(_id) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    g_PQ_collection[i]._items = [];
}


// Return true if a priority queue is empty.
function PQ_priority_empty(_id) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    return (array_length(g_PQ_collection[i]._items) == 0);
}


// Return the size of a priority queue.
function PQ_priority_size(_id) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    return array_length(g_PQ_collection[i]._items);
}


// Add an item to a priority queue.
function PQ_priority_add(_id, _val, _priority) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    var item = new PQ_item(_val, _priority);
    var q = g_PQ_collection[i];
    var qlen = array_length(q._items);
    for (var j=0; j<qlen; j++) {
        if (item._priority < q._items[j]._priority) {
            array_insert(q._items, j, item);
            return;
        }
    }
    array_push(q._items, item);
}


// Change the priority of an item in a priority queue.
function PQ_priority_change_priority(_id, _val, _priority) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    var q = g_PQ_collection[i];
    var qlen = array_length(q._items);
    for (var j=0; j<qlen; j++) {
        if (_val == q._items[j]._val) {
            array_delete(q._items, j, 1);
            PQ_priority_add(_id, _val, _priority);
        }
    }
}


// Delete and return the item with the highest priority in a priority queue.
function PQ_priority_delete_max(_id) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    var q = g_PQ_collection[i];
    var qlen = array_length(q._items);
    if (qlen == 0) return 0;
    var item = q._items[qlen-1];
    array_delete(q._items, qlen-1, 1);
    return item._val;
}


// Delete and return the item with the lowest priority in a priority queue.
function PQ_priority_delete_min(_id) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    var q = g_PQ_collection[i];
    var qlen = array_length(q._items);
    if (qlen == 0) return 0;
    var item = q._items[0];
    array_delete(q._items, 0, 1);
    return item._val;
}


// Delete an item in a priority queue.
function PQ_priority_delete_value(_id, _val) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    var q = g_PQ_collection[i];
    var qlen = array_length(q._items);
    for (var j=0; j<qlen; j++) {
        if (_val == q._items[j]._val) {
            array_delete(q._items, j, 1);
            return;
        }
    }
}


// Return the item with the highest priority in a priority queue.
function PQ_priority_find_max(_id) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    var q = g_PQ_collection[i];
    var qlen = array_length(q._items);
    if (qlen == 0) return undefined;
    var item = q._items[qlen-1];
    return item._val;
}


// Return the item with the lowest priority in a priority queue.
function PQ_priority_find_min(_id) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    var q = g_PQ_collection[i];
    var qlen = array_length(q._items);
    if (qlen == 0) return undefined;
    var item = q._items[0];
    return item._val;
}


// Return priority of an item in a priority queue.
function PQ_priority_find_priority(_id, _val) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    var q = g_PQ_collection[i];
    var qlen = array_length(q._items);
    if (qlen == 0) return undefined;
    for (var j=0; j<qlen; j++) {
        if (_val == q._items[j]._val) {
            return q._items[j]._priority;
        }
    }
    return undefined;
}


// Copy the contents of one priority queue to another.
function PQ_priority_copy(_id, _source) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    var j = PQ_find(_source);
    if (j < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    var dst = g_PQ_collection[i];
    var src = g_PQ_collection[j];
    PQ_priority_clear(dst._id);
    array_copy(dst._items, 0, src._items, 0, array_length(src._items));
}


// Write the contents of a priority queue to a JSON string.
function PQ_priority_write(_id) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    var q = g_PQ_collection[i];
    return json_stringify(q._items);
}


// Populate a priority queue with the conents of a JSON string.
function PQ_priority_read(_id, _str) {
    var i = PQ_find(_id);
    if (i < 0) {
        show_error("Data structure with index does not exist.", true);
    }
    var q = g_PQ_collection[i];
    q._items = json_parse(_str);
}




// INTERNAL ///////////////////////////////////////////////////////////////

// Global Priority Queue Collection
globalvar g_PQ_collection;
g_PQ_collection = [];


// Priority Queue
function PQ_queue(_id) constructor {
    self._id = _id;
    self._items = [];
}


// Priority Queue Item
function PQ_item(_val, _priority) constructor {
    self._val = _val;
    self._priority = _priority;
}


// Return index of priority queue.
function PQ_find(_id) {
    var len = array_length(g_PQ_collection);
    for (var i=0; i<len; i++) {
        var q = g_PQ_collection[i];
        if (_id == q._id) {
            return i;
        }
    }
    return -1;
}
