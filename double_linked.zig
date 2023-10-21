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
        new_node.* = Node{ .value = value, .prev = null, .next = self.head };
        self.head = new_node;
    }

    pub fn pushBack(self: *linked_list, value: []u8) !void {
        var new_node: *Node = try self.allocator.create(Node);
        new_node.* = Node{ .value = value, .prev = self.tail, .next = null };
        // std.debug.print("new node {any}\n", .{new_node});
        self.tail = new_node;
        if (!self.head) |head| {
            _ = head;
            std
                .
            // std.debug.print("adding head {any}\n", .{head});
                self.head = new_node;
        } else {
            // std.debug.print("not adding head\n", .{});
            self.head = new_node;
            // std.debug.print("adding head {any} {any}\n", .{ self.head, new_node });
        }
    }

    pub fn printHead(self: *linked_list) void {
        std.debug.print("HEAD {any}\n", .{self.head});
        std.debug.print("\n", .{});
    }

    pub fn print(self: *linked_list) void {
        var current_node: ?*Node = self.head;
        while (current_node) |i| {
            std.debug.print("{d} {any} {any}\n", .{ i.value, i.next, i.prev });
            current_node = i.next;
        }
    }

    pub fn removeAll(self: *linked_list) void {
        var current_node: ?*Node = self.head;
        while (current_node) |i| {
            current_node = i.next;

            self.allocator.destroy(i);
        }
        self.head = null;
    }
};

test "diff allocator" {
    // var arena = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    std.debug.print("\n", .{});
    var allocator = arena.allocator();
    var ll: linked_list = linked_list.init(&allocator);
    var x = [_]u8{1};
    var y = [_]u8{2};
    var z = [_]u8{3};
    // _ = try ll.pushFront(&x);
    // _ = try ll.pushFront(&y);
    // _ = try ll.pushFront(&z);
    var i = [_]u8{4};
    _ = i;
    _ = try ll.pushBack(&x);
    ll.printHead();
    _ = try ll.pushBack(&y);
    ll.printHead();
    _ = try ll.pushBack(&z);
    ll.printHead();
    ll.print();
    ll.removeAll();
}
