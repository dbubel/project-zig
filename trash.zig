const std = @import("std");
const crap = @import("fib.zig");
pub fn main() !void {
    // var array: [6]c_int = [_]c_int{ 6, 1, 2, 3, 4, 5 };
    // crap.int_sort(&array[0], array.len);
    // std.debug.print("{d}\n", .{array});
    var fnum: c_int = 30;
    std.debug.print("{d}\n", .{crap.fibonacci(fnum)});
}
