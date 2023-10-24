Priority Queue GML Implementation
=================================

This library re-implements the built-in priority queue functions using GML
for cross-platform compatibility. GameMaker Studio's provided runtimes do
not work exactly the same on every platform. These functions behave as
documented in the GameMaker Studio manual and they should work the same
on all platforms. This library cannot interoperate with built-in ds_priority
functions but it can transparently and effortlessly replace the built-in
ds_priority functions by overriding them with macros.

Notes:
- Items are added to queues with an insertion sort storage scheme. Items
  in a queue are always in order by priority. Adding items may have a
  higher cost but retrieving them can be faster.
- Minimum and maximum priority searches are done in O(1) constant time.
- Specific priority searches are done in O(n) linear time.
- Relative item queue positions are stable when items are added or deleted.
- When searching for an item with a specific or minimum priority, items
  with the same priority are found in first-in-first-out order.
- When searching for an item with maximum priority, items with the same
  priority are found in last-in-first-out order.
- When items are deleted from a queue by minimum or maximum priority, the
  order items are removed by one method is the reverse order of the other.
- Read/Write functions support structs.
- Read/Write functions use human-readable JSON.
- Priority queue indices are not recycled.

Future:
- Consider using a binary search for improved O(log n) logarithmic time
  when adding items or searching for items with specific priorities.

copyright © 2023, John Leffingwell

MIT License
