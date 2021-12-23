const std = @import("std");

const real_input = @embedFile("day-12_real-input");
const test_input_1 = @embedFile("day-12_test-input-1");
const test_input_2 = @embedFile("day-12_test-input-2");
const test_input_3 = @embedFile("day-12_test-input-3");

pub fn main() !void {
    std.debug.print("--- Day 12 ---\n", .{});
    var result = try execute(real_input);
    std.debug.print("there are {} distinct paths\n", .{ result });
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

    var initial_path = std.ArrayList(Cave).init(alloc.allocator());
    try initial_path.append("start");
    const path_count = try continuePath(initial_path, connections.items);

    return path_count;
}

fn addUnique(list: *std.ArrayList(Cave), cave: Cave) !void {
    if (contains(list.items, cave)) return;
    try list.append(cave);
}

fn getCaveType(cave: []const u8) CaveType {
    if (equals(cave, "start")) return .Start;
    if (equals(cave, "end")) return .End;
    if (cave[0] >= 'A' and cave[0] <= 'Z') return .Large;
    if (cave[0] >= 'a' and cave[0] <= 'z') return .Small;
    unreachable;
}

fn continuePath(path: std.ArrayList(Cave), connections: []Connection) PathError!u32 {
    const pos = path.items[path.items.len - 1];

    if (getCaveType(pos) == .End) return 1;

    var sub_paths: u32 = 0;

    for (connections) |connection| {
        if (!equals(connection.from, pos)) continue;

        switch (getCaveType(connection.to)) {
            .Start => continue,
            .Small => if (contains(path.items, connection.to)) continue,
            else => { }
        }

        var sub_path = try std.ArrayList(Cave).initCapacity(path.allocator, path.items.len + 1);
        try sub_path.appendSlice(path.items);
        try sub_path.append(connection.to);
        sub_paths += try continuePath(sub_path, connections);
        sub_path.deinit();
    }

    return sub_paths;
}

const PathError = @typeInfo(@typeInfo(@TypeOf(std.ArrayListAligned([]const u8,null).initCapacity)).Fn.return_type.?).ErrorUnion.error_set;

fn contains(haystack: []Cave, needle: Cave) bool {
    return for (haystack) |cave| {
        if (equals(cave, needle)) break true;
    } else false;
}

fn equals(lhs: Cave, rhs: Cave) bool {
    return std.mem.eql(u8, lhs, rhs);
}

const Cave = []const u8;

const CaveType = enum {
    Start,
    End,
    Small,
    Large,
};

const Connection = struct {
    from: Cave,
    to: Cave,
};

test "test-input-1" {
    const result = try execute(test_input_1);
    const expected: u32 = 10;
    try std.testing.expectEqual(expected, result);
}

test "test-input-2" {
    const result = try execute(test_input_2);
    const expected: u32 = 19;
    try std.testing.expectEqual(expected, result);
}

test "test-input-3" {
    const result = try execute(test_input_3);
    const expected: u32 = 226;
    try std.testing.expectEqual(expected, result);
}
