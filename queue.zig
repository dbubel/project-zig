const std = @import("std");

pub fn Queue(comptime T: type) type {
    return struct {
        const This = @This();
        const Node = struct {
            data: T,
            next: ?*Node,
        };

        allocator: *std.mem.Allocator,
        head: ?*Node,
        tail: ?*Node,

        pub fn init(allocator: *std.mem.Allocator) This {
            return .{
                .allocator = allocator,
                .head = null,
                .tail = null,
            };
        }

        // Enqueues 'data' onto the queue.
        pub fn enqueue(self: *This, data: T) !void {
            const new_node = try self.allocator.create(Node);
            new_node.* = Node{ .data = data, .next = null };

            // if the tail is not null, then make the current tail
            // point to the new node we are adding.
            // else the queue is empty so also set the head to
            // the same node.
            if (self.tail) |tail| {
                tail.next = new_node;
            } else {
                self.head = new_node;
            }
            self.tail = new_node;
        }

        // Dequeues data from the queue and returns null if the queue
        // is empty.
        pub fn dequeue(self: *This) ?T {
            // the statement below checks if self.head is null essentially
            // and if it is, we just return null.
            const head = self.head orelse return null;

            defer self.allocator.destroy(head);
            // if head has a next node, then swap head with next so we can
            // dequeue the item
            if (head.next) |next| {
                self.head = next;
            } else {
                self.head = null;
                self.tail = null;
            }
            return head.data;
        }

        pub fn print(self: *This, depth: usize) void {
            var idx: usize = 1;
            var current_node = self.head;
            std.debug.print("\n", .{});
            while (current_node) |node| {
                std.debug.print("idx={d} value={any}\n", .{ idx, node.data });
                current_node = node.next;
                idx = idx + 1;
                if (idx > depth) return;
            }
        }
    };
}

test "queue init" {
    var mem_arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer mem_arena.deinit();
    var allocator = mem_arena.allocator();
    var q = Queue(u8).init(&allocator);
    _ = try q.enqueue(1);
    _ = try q.enqueue(2);
    _ = q.print(100);
    var val: ?u8 = q.dequeue();
    _ = q.print(100);
    val = q.dequeue();

    _ = q.print(100);
}

test "queue loop" {
    var mem_arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer mem_arena.deinit();
    var allocator = mem_arena.allocator();

    var q = Queue(usize).init(&allocator);
    for (0..100000) |i| {
        _ = try q.enqueue(i);
        // _ = try std.debug.print("{d}\n", .{i});
    }
}
