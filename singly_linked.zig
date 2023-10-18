const std = @import("std");

pub const Node = struct {
    value: i32,
    next: ?*Node,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();
    var ll: linked_list = linked_list.init(&allocator);
    var i: i32 = 1;
    while (i <= 10_000_000) : (i += 1) {
        _ = try ll.push(i);
        // std.debug.print("{d}\n", .{i});
    }
}

pub const linked_list = struct {
    allocator: *std.mem.Allocator,
    head: ?*Node,
    len: i32,

    pub fn init(allocator: *std.mem.Allocator) linked_list {
        return linked_list{ .head = null, .allocator = allocator, .len = 0 };
    }

    pub fn remove(self: *linked_list, value: i32) void {
        // case that the value were looking for is the head of the list
        if (self.head) |head| {
            if (head.value == value) {
                self.head = head.next;
                self.allocator.destroy(head);
                self.len -= 1;
                return;
            }
        }

        var current_node: ?*Node = self.head;
        var prev_node: *Node = undefined;

        while (current_node) |i| {
            if (i.value == value) {
                prev_node.next = i.next;
                self.allocator.destroy(i);
                self.len -= 1;
                return;
            }

            current_node = i.next;
            prev_node = i;
        }
    }

    pub fn removeAll(self: *linked_list) void {
        var current_node: ?*Node = self.head;
        while (current_node) |i| {
            current_node = i.next;
            self.allocator.destroy(i);
            self.len -= 1;
        }
        self.head = null;
    }

    pub fn push(self: *linked_list, value: i32) !void {
        var new_node: *Node = try self.allocator.create(Node);
        new_node.* = Node{ .value = value, .next = self.head };
        self.head = new_node;
        self.len += 1;
    }

    pub fn pop(self: *linked_list) ?i32 {
        if (self.head) |head| {
            self.head = head.next;
            var x = head.value;
            self.allocator.destroy(head);
            self.len -= 1;
            return x;
        }
        return null;
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
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();
    var ll: linked_list = linked_list.init(&allocator);
    _ = try ll.push(1337);
}
//

test "linked list" {
    _ = std.DoublyLinkedList([]u8);
}
// test "linked list pop" {
//    std.debug.print("\n", .{});
//     var testing_allocator = std.testing.allocator;
//     var ll = linked_list.init(&testing_allocator);
//
//     _ = try ll.push(1);
//     _ = try ll.push(2);
//     try std.testing.expect(ll.len == 2);
//
//     var item = ll.pop();
//     try std.testing.expect(ll.len == 1);
//     std.debug.print("{any}\n", .{item});
//
//     item = ll.pop();
//     try std.testing.expect(ll.len == 0);
//     std.debug.print("{any}\n", .{item});
//
//     item = ll.pop();
//     std.debug.print("{any}\n", .{item});
//     ll.removeAll();
// }
