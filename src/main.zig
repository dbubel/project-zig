const std = @import("std");
const net = std.net;

var gpa_server = std.heap.GeneralPurposeAllocator(.{}){};
var salloc = gpa_server.allocator();

pub const asdf struct{
    
}

// var buffer: [10_000]u8 = undefined;
// var fba = std.heap.FixedBufferAllocator.init(&buffer);
// const asdf = fba.allocator();

var gpa_handler = std.heap.GeneralPurposeAllocator(.{}){};
var asdf = gpa_server.allocator();

var buf: [10_000]u8 = undefined;
var fba = std.heap.FixedBufferAllocator.init(&buf);

// var gpa_handler2 = std.heap.GeneralPurposeAllocator(.{}){};
// var fba = gpa_handler2.allocator();

pub const HttpServer = struct {
    server: std.http.Server,

    // fn handle(request: std.http.Request, response: std.http.Response) void {
    //     defer response.stream.close();
    //     _ = request;
    // }

    pub fn listen(self: *HttpServer, address: std.net.Address) !void {
        // create our general purpose allocator
        // var gpa = std.heap.GeneralPurposeAllocator(.{}){};

        // // get an std.mem.Allocator from it
        // var alloc = gpa.allocator();
        self.server = std.http.Server.init(salloc, .{ .reuse_address = true });

        defer self.server.deinit();

        try self.server.listen(address);
        std.log.info("server starting", .{});
        defer std.log.info("server stopping", .{});

        while (true) {
            var res = try std.http.Server.accept(&self.server, .{ .allocator = salloc });
            defer res.deinit();

            while (res.reset() != .closing) {
                res.wait() catch |err| switch (err) {
                    error.EndOfStream => continue,
                    else => return err,
                };

                if (std.mem.startsWith(u8, res.request.target, "/get")) {
                    // try handleRequest(&res);
                }

                if (std.mem.startsWith(u8, res.request.target, "/json")) {
                    try handleRequestJson(&res);
                }

                if (std.mem.startsWith(u8, res.request.target, "/json-stream")) {
                    try handleRequestJsonStream(&res);
                }
            }
        }
    }
};

// fn handleRequest(res: *std.http.Server.Response) !void {
//     const log = std.log.scoped(.server);
//     log.info("{} {s} {s}", .{ res.request.method, @tagName(res.request.version), res.request.target });

//     // if (res.request.headers.contains("expect")) {
//     //     if (std.mem.eql(u8, res.request.headers.getFirstValue("expect").?, "100-continue")) {
//     //         res.status = .@"continue";
//     //         try res.do();
//     //         res.status = .ok;
//     //     } else {
//     //         res.status = .expectation_failed;
//     //         try res.do();
//     //         return;
//     //     }
//     // }

//     const body = try res.reader().readAllAlloc(asdf, 1024);
//     std.debug.print("{s}", .{body});
//     defer asdf.free(body);

//     if (res.request.headers.contains("connection")) {
//         try res.headers.append("connection", "keep-alive");
//     }

//     // if (std.mem.indexOf(u8, res.request.target, "?chunked") != null) {
//     //     res.transfer_encoding = .chunked;
//     // } else {
//     var resp = "hello, world!\n";

//     res.transfer_encoding = .{ .content_length = resp.len };
//     res.status = .ok;

//     try res.headers.append("content-type", "text/plain");

//     try res.do();
//     try res.writeAll(resp);
//     try res.finish();
// }

fn handleRequestJson(res: *std.http.Server.Response) !void {
    // const log = std.log.scoped(.server);
    // log.info("{} {s} {s}", .{ res.request.method, @tagName(res.request.version), res.request.target });

    // const body = try res.reader().readAllAlloc(asdf, 1024);
    // std.debug.print("{s}", .{body});
    // defer asdf.free(body);

    // if (res.request.headers.contains("connection")) {
    //     try res.headers.append("connection", "keep-alive");
    // }

    var p: Person = Person{
        .name = "John Doe",
        .age = 300,
        .city = "New York",
    };

    try res.headers.append("content-type", "application/json");

    res.do() catch |err| {
        std.debug.print("{}", .{err});
    };

    // var string = std.ArrayList(u8).init(fba.allocator());
    // defer string.deinit();

    // try std.json.stringify(p, .{}, string.writer());

    var buff: [100]u8 = undefined;
    var json_to_send: []const u8 = undefined;
    if (stringifyBuf(&buff, p, .{})) |json| {
        json_to_send = json;
    } else {
        json_to_send = "null";
    }
    std.debug.print("{d}", .{json_to_send.len});
    // const jsond = stringifyBuf(&buff, p, std.json.StringifyOptions{});
    res.transfer_encoding = .{ .content_length = json_to_send.len };
    res.status = .ok;

    try res.writeAll(json_to_send);

    try res.finish();
    // try res.writeAll(list.items);

}

fn handleRequestJsonStream(res: *std.http.Server.Response) !void {
    std.debug.print("hello", .{});
    var p: Person = Person{
        .name = "John Doe",
        .age = 300,
        .city = "New York",
    };

    const body = try res.reader().readAllAlloc(asdf, 1024);
    std.debug.print("{s}", .{body});
    defer asdf.free(body);

    try res.headers.append("content-type", "application/json");

    // res.do() catch |err| {
    //     std.debug.print("{}", .{err});
    // };

    var ws = std.json.writeStream(res.writer(), .{ .whitespace = .indent_4 });
    try ws.write(p);

    res.transfer_encoding = .{ .content_length = 47 };
    res.status = .ok;
    // res.writeAll();
    try res.finish();
}

pub fn main() !void {
    var server: HttpServer = undefined;
    try server.listen(try net.Address.parseIp("127.0.0.1", 8080));
}

// a function to loop over a slice and print each value
fn printSlice(slice: []const u8) void {
    // loop over each value in the slice
    for (slice) |value| {
        // print the value
        std.debug.print("{d}\n", .{value});
    }
}

const Person = struct {
    name: []const u8,
    age: u16,
    city: []const u8,
};

// test "json decode" {
//     const allocator = std.testing.allocator;

//     const jsonString = "{\"name\": \"John Doe\", \"age\": 300, \"city\": \"New York\"}";

//     var options = std.json.ParseOptions{};
//     _ = options;

//     var parsedPerson = try std.json.parseFromSlice(Person, allocator, jsonString, .{});
//     defer parsedPerson.deinit();

//     const person = parsedPerson.value;

//     std.debug.print("Name: {s}\n", .{person.name});
//     std.debug.print("Age: {d}\n", .{person.age});
//     std.debug.print("City: {s}\n", .{person.city});
// }

test "json encode" {
    var p: Person = Person{
        .name = "John Doe",
        .age = 300,
        .city = "New York",
    };

    const test_allocator = std.testing.allocator;
    var list = std.ArrayList(u8).init(test_allocator);
    defer list.deinit();

    try std.json.stringify(p, std.json.StringifyOptions{}, list.writer());

    std.debug.print("\n{s}\n", .{list.items});
}

test "io writer usage" {
    const test_allocator = std.testing.allocator;
    var list = std.ArrayList(u8).init(test_allocator);
    defer list.deinit();
    const bytes_written = try list.writer().write(
        "Hello World!",
    );

    try std.testing.expect(bytes_written == 12);
    try std.testing.expect(std.mem.eql(u8, list.items, "Hello World!"));
}

pub fn stringifyBuf(buffer: []u8, value: anytype, options: std.json.StringifyOptions) ?[]const u8 {
    var fdba = std.heap.FixedBufferAllocator.init(buffer);
    var string = std.ArrayList(u8).init(fdba.allocator());
    if (std.json.stringify(value, options, string.writer())) {
        return string.items;
    } else |_| { // error
        return null;
    }
}
