const std = @import("std");

pub const Node = struct {
    value: []u8,
    next: ?*Node,
    prev: ?*Node,
};

pub const linked_list = struct {
    allocator: *std.mem.Allocator,
    head: ?*Node,
    tail: ?*Node,

    pub fn init(allocator: *std.mem.Allocator) linked_list {
        return linked_list{ .head = null, .tail = null, .allocator = allocator };
    }

    pub fn pushFront(self: *linked_list, value: []u8) !void {
        var new_node: *Node = try self.allocator.create(Node);
        new_node.* = Node{ .value = value, .next = self.head };
        self.head = new_node;
    }

    pub fn print(self: *linked_list) void {
        var current_node: ?*Node = self.head;
        while (current_node) |i| {
            std.debug.print("{d}\n", .{i.value});
            current_node = i.next;
        }
    }
};

test "diff allocator" {
    var arena = std.testing.allocator;
    // defer arena.deinit();
    var allocator = arena;
    var ll: linked_list = linked_list.init(&allocator);
    _ = try ll.pushFront(1337);
}
