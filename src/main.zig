const std = @import("std");
const net = std.net;

var gpa_server = std.heap.GeneralPurposeAllocator(.{}){};
var salloc = gpa_server.allocator();

// var buffer: [10_000]u8 = undefined;
// var fba = std.heap.FixedBufferAllocator.init(&buffer);
// const asdf = fba.allocator();

var gpa_handler = std.heap.GeneralPurposeAllocator(.{}){};
var asdf = gpa_server.allocator();

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

                try handleRequest(&res);
            }
        }
    }
};

fn handleRequest(res: *std.http.Server.Response) !void {
    // const log = std.log.scoped(.server);

    // log.info("{} {s} {s}", .{ res.request.method, @tagName(res.request.version), res.request.target });

    // if (res.request.headers.contains("expect")) {
    //     if (std.mem.eql(u8, res.request.headers.getFirstValue("expect").?, "100-continue")) {
    //         res.status = .@"continue";
    //         try res.do();
    //         res.status = .ok;
    //     } else {
    //         res.status = .expectation_failed;
    //         try res.do();
    //         return;
    //     }
    // }

    const body = try res.reader().readAllAlloc(asdf, 1024);
    std.debug.print("{s}", .{body});
    defer asdf.free(body);

    if (res.request.headers.contains("connection")) {
        try res.headers.append("connection", "keep-alive");
    }

    // if (std.mem.startsWith(u8, res.request.target, "/get")) {

    // if (std.mem.indexOf(u8, res.request.target, "?chunked") != null) {
    //     res.transfer_encoding = .chunked;
    // } else {
    var resp = "hello, world!\n";

    res.transfer_encoding = .{ .content_length = resp.len };
    res.status = .ok;

    try res.headers.append("content-type", "text/plain");

    try res.do();
    try res.writeAll(resp);
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
    name: []u8,
    age: u16,
    city: []u8,
};

test "json test" {
    const allocator = std.testing.allocator;

    const jsonString = "{\"name\": \"John Doe\", \"age\": 300, \"city\": \"New York\"}";

    var options = std.json.ParseOptions{};
    _ = options;

    var parsedPerson = try std.json.parseFromSlice(Person, allocator, jsonString, .{});
    defer parsedPerson.deinit();

    const person = parsedPerson.value;

    std.debug.print("Name: {s}\n", .{person.name});
    std.debug.print("Age: {d}\n", .{person.age});
    std.debug.print("City: {s}\n", .{person.city});
}
