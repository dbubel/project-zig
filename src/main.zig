// const std = @import("std");

// pub fn main() !void {
//     // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
//     std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

//     // stdout is for the actual output of your application, for example if you
//     // are implementing gzip, then only the compressed bytes should be sent to
//     // stdout, not any debugging messages.
//     const stdout_file = std.io.getStdOut().writer();
//     var bw = std.io.bufferedWriter(stdout_file);
//     const stdout = bw.writer();

//     try stdout.print("Run `zig build test` to run the tests.\n", .{});

//     try bw.flush(); // don't forget to flush!
// }

// test "simple test" {
//     var list = std.ArrayList(i32).init(std.testing.allocator);
//     defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//     try list.append(42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }

const std = @import("std");
const net = std.net;

var gpa_server = std.heap.GeneralPurposeAllocator(.{}){};
// var gpa_client = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 12 }){};

var salloc = gpa_server.allocator();

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

var buffer: [10_000]u8 = undefined;
var fba = std.heap.FixedBufferAllocator.init(&buffer);
const asdf = fba.allocator();

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
    defer asdf.free(body);

    // std.io.bufferedReader(reader: anytype).

    // if (res.request.headers.contains("connection")) {
    //     try res.headers.append("connection", "keep-alive");
    // }

    // if (std.mem.startsWith(u8, res.request.target, "/get")) {

    // if (std.mem.indexOf(u8, res.request.target, "?chunked") != null) {
    //     res.transfer_encoding = .chunked;
    // } else {
    var resp = "hello, world!\n";
    res.transfer_encoding = .{ .content_length = resp.len };
    // }
    // defer fn () void{};
    // res.finish();
    try res.headers.append("content-type", "text/plain");

    try res.do();

    // if (res.request.method != .HEAD) {
    try res.writeAll(resp);
    try res.finish();
    // } else {
    //     try std.testing.expectEqual(res.writeAll("errors"), error.NotWriteable);
    // }
    // }
}

pub fn main() !void {
    var server: HttpServer = undefined;
    try server.listen(try net.Address.parseIp("127.0.0.1", 8080));
}
