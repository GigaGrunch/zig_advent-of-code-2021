const std = @import("std");

const real_input = @embedFile("day-12_real-input");
const test_input_1 = @embedFile("day-12_test-input-1");

pub fn main() !void {
    std.debug.print("--- Day 12 ---\n", .{});
    var result = try execute(real_input);
    std.debug.print("there are {} paths\n", .{ result });
}

fn execute(input: []const u8) !u32 {
    var alloc_buffer: [1024 * 1024]u8 = undefined;
    var alloc = std.heap.FixedBufferAllocator.init(alloc_buffer[0..]);

    var small_caves = std.ArrayList([]const u8).init(alloc.allocator());
    var large_caves = std.ArrayList([]const u8).init(alloc.allocator());
    var connections = std.ArrayList(Connection).init(alloc.allocator());

    var line_it = std.mem.tokenize(u8, input, "\r\n");
    while (line_it.next()) |line| {
        if (line.len == 0) break;

        var cave_it = std.mem.split(u8, line, "-");

        const from_cave = cave_it.next() orelse unreachable;
        switch (getCaveType(from_cave)) {
            .Small => try addUnique(&small_caves, from_cave),
            .Large => try addUnique(&large_caves, from_cave),
            else => { }
        }

        const to_cave = cave_it.next() orelse unreachable;
        switch (getCaveType(to_cave)) {
            .Small => try addUnique(&small_caves, to_cave),
            .Large => try addUnique(&large_caves, to_cave),
            else => { }
        }

        const connection = Connection {
            .from = from_cave,
            .to = to_cave,
        };
        try connections.append(connection);
        const reverse = Connection {
            .from = to_cave,
            .to = from_cave,
        };
        try connections.append(reverse);
    }

    std.debug.print("small caves: ", .{});
    for (small_caves.items) |cave| {
        std.debug.print("{s} ", .{ cave });
    }
    std.debug.print("\n", .{});

    std.debug.print("large caves: ", .{});
    for (large_caves.items) |cave| {
        std.debug.print("{s} ", .{ cave });
    }
    std.debug.print("\n", .{});

    std.debug.print("connections:\n", .{});
    for (connections.items) |connection| {
        std.debug.print("{s} -> {s}\n", .{ connection.from, connection.to });
    }
    std.debug.print("\n", .{});

    return 0;
}

fn addUnique(list: *std.ArrayList([]const u8), cave: []const u8) !void {
    for (list.items) |item| {
        if (std.mem.eql(u8, cave, item[0..])) return;
    }
    try list.append(cave);
}

fn getCaveType(cave: []const u8) CaveType {
    if (std.mem.eql(u8, cave, "start")) return .Start;
    if (std.mem.eql(u8, cave, "end")) return .End;
    if (cave[0] >= 'A' and cave[0] <= 'Z') return .Large;
    if (cave[0] >= 'a' and cave[0] <= 'z') return .Small;
    unreachable;
}

const CaveType = enum {
    Start,
    End,
    Small,
    Large,
};

const Connection = struct {
    from: []const u8,
    to: []const u8,
};

test "test-input-1" {
    std.debug.print("\n", .{});
    const result = try execute(test_input_1);
    const expected: u32 = 10;
    try std.testing.expectEqual(expected, result);
}
