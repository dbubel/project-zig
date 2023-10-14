const std = @import("std");
const crap = @import("fib.zig");

pub fn main() !void {
    std.debug.print("asdf", .{});
    // var array: [6]c_int = [_]c_int{ 6, 1, 2, 3, 4, 5 };
    // crap.int_sort(&array[0], array.len);
    // std.debug.print("{d}\n", .{array});
    var fnum: c_int = 30;
    std.debug.print("{d}\n", .{crap.fibonacci(fnum)});
}
// test "c lib" {
//     var fnum: c_int = 30;
//     std.debug.print("{d}\n", .{crap.fibonacci(fnum)});
// }
// test "json stuff" {
//     // const name = req.param("name").?;
//     var ws = std.json.writeStream(std.io.getStdOut().writer(), .{ .whitespace = .indent_4 });
//     try ws.beginObject();
//     try ws.objectField("name");
//     try ws.write("hello");

//     try ws.objectField("name 3");
//     try ws.write("hello 3");
//     try ws.endObject();
// }

// test "leap" {
//     std.debug.print("{d}\n", .{200 % 13});
// }

pub fn isLeapYear(year: u32) bool {
    if (year % 4 != 0) {
        return false;
    }

    if (year % 100 != 0) {
        return true;
    }

    if (year % 400 != 0) {
        return false;
    }
    return true;
}

test "sum sq" {
    // std.debug.print("{d}\n", .{squareOfSum(1)});
    // try std.testing.expect(squareOfSum(1) == 0);
}

test "sum sqs" {
    std.debug.print("{d}\n", .{differenceOfSquares(100)});
    // std.debug.print("{d}\n", .{squareOfSum(1)});
    // try std.testing.expect(sumOfSquares(1) == 1);
}

test "colatz" {
    const c = try steps(12);
    // _ = c;
    std.debug.print("{d}\n", .{c});
}
const ComputationError = error{
    IllegalArgument,
};

pub fn steps(number: usize) anyerror!usize {
    if (number == 0) {
        return ComputationError.IllegalArgument;
    }

    var colatz: usize = number;
    var count: u32 = 0;
    while (true) {
        if (colatz == 1) {
            return count;
        }

        if (colatz % 2 == 0) {
            colatz = colatz / 2;
            count += 1;
            // std.debug.print("even {d}\n", colatz);
            continue;
        }

        if (colatz % 2 == 1) {
            count += 1;
            // std.debug.print("odd {d}\n", colatz);
            colatz = colatz * 3 + 1;
            continue;
        }
    }
}

pub fn squareOfSum(number: usize) usize {
    var i: usize = 0;
    var total: usize = 0;
    while (i <= number) : (i += 1) {
        total = total + i;
    }

    return std.math.pow(usize, total, 2);
}

pub fn sumOfSquares(number: usize) usize {
    var i: usize = 0;
    var total: usize = 0;

    while (i <= number) : (i += 1) {
        total = total + std.math.pow(usize, i, 2);
    }

    return total;
}

pub fn differenceOfSquares(n: usize) usize {
    return squareOfSum(n) - sumOfSquares(n);
}

pub fn mayFail() !void {
    return error.SomeError;
}

// pub fn main() !void {
//     const result = mayFail() catch |err| {
//         std.debug.warn("Caught an error: {}\n", .{err});
//         return err;
//     };
// }

pub fn score(s: []const u8) u32 {
    var word_score: u32 = 0;
    for (s) |c| {
        switch (std.ascii.toUpper(c)) {
            'A', 'E', 'I', 'O', 'U', 'L', 'N', 'R', 'S', 'T' => {
                word_score += 1;
            },
            'D', 'G' => {
                word_score += 2;
            },
            'B', 'C', 'M', 'P' => {
                word_score += 3;
            },
            'F', 'H', 'V', 'W', 'Y' => {
                word_score += 4;
            },
            'K' => {
                word_score += 5;
            },
            'J', 'X' => {
                word_score += 8;
            },
            'Q', 'Z' => {
                word_score += 10;
            },
            else => {},
        }
    }
    return word_score;
}

test "score" {
    std.debug.print("{any}\n", .{score("cabbage")});
}

test "pangram" {
    // std.debug.print("is pangram {any}", .{isPangram("hello")});
}

pub fn isPangram(str: []const u8) bool {
    var gpa_server = std.heap.GeneralPurposeAllocator(.{}){};
    var salloc = gpa_server.allocator();

    var map = std.AutoHashMap(u8, bool).init(salloc);
    defer map.deinit();

    for (str) |c| {
        const char = std.ascii.toLower(c);
        if (char < 97 or char > 122) {
            continue;
        }

        map.put(char, true) catch |e| {
            std.debug.print("{any}", .{e});
        };
    }

    if (map.count() == 26) {
        return true;
    }
    return false;
}

fn println(s: []const u8) void {
    std.debug.print("{s}\n", .{s});
}

test "hash" {
    std.debug.print("{any}\n", .{isPangram("The quick brown fox jumps over the lazy dog")});
}

pub fn isArmstrongNumber(n: u128) bool {
    var temp = n;
    var sum: u128 = 0;
    var length: u8 = 0;

    while (temp != 0) {
        temp /= 10;
        length += 1;
    }

    temp = n;
    while (temp != 0) {
        var digit = temp % 10;
        sum += std.math.pow(u128, digit, length);
        temp /= 10;
    }

    return n == sum;
}

test "isArmstrongNumber" {
    try std.testing.expect(isArmstrongNumber(153));
    try std.testing.expect(!isArmstrongNumber(123));
}

pub fn isArmstrongNumber2(num: u128) bool {
    var buf: [39]u8 = undefined;
    const slice = std.fmt.bufPrint(&buf, "{}", .{num}) catch unreachable;
    var product: u128 = 0;
    for (slice) |d| product += std.math.pow(u128, d - '0', slice.len);
    return num == product;
}

test "arm2" {
    try std.testing.expect(isArmstrongNumber2(153));
}

pub fn isIsogram(str: []const u8) bool {
    var gpa_server = std.heap.GeneralPurposeAllocator(.{}){};
    var salloc = gpa_server.allocator();

    var map = std.AutoHashMap(u8, bool).init(salloc);
    defer map.deinit();

    for (str) |c| {
        const char = std.ascii.toLower(c);
        if (char < 97 or char > 122) {
            continue;
        }

        map.put(char, true) catch |e| {
            std.debug.print("{any}", .{e});
        };
    }

    if (map.count() == 26) {
        return true;
    }
    return false;
}
