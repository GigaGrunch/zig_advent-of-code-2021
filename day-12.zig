const std = @import("std");

const input: enum {
    Test1,
    Test2,
    Test3,
    Real,
} = .Test1;
const filename = switch (input) {
    .Test1 => "day-12_test-input-1",
    else => unreachable
};
const path_count = switch (input) {
    .Test1 => 7,
    else => unreachable
};
const cavename_length = switch (input) {
    .Test1 => 1,
    else => unreachable
};

pub fn main() !void {
    std.debug.print("--- Day 12 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var alloc_buffer: [1024 * 1024]u8 = undefined;
    var alloc = std.heap.FixedBufferAllocator.init(alloc_buffer[0..]);

    var small_caves = std.ArrayList([cavename_length]u8).init(alloc.allocator());
    var large_caves = std.ArrayList([cavename_length]u8).init(alloc.allocator());
    {
        var cave_buffer: [100]u8 = undefined;
        var path_index: u32 = 0;
        while (path_index < path_count):(path_index += 1) {
            const from_cave = try file.reader().readUntilDelimiter(cave_buffer[0..], '-');
            switch (getCaveType(from_cave)) {
                .Small => try addUnique(&small_caves, from_cave),
                .Large => try addUnique(&large_caves, from_cave),
                else => { }
            }

            const to_cave_untrimmed = try file.reader().readUntilDelimiter(cave_buffer[0..], '\n');
            const to_cave = std.mem.trimRight(u8, to_cave_untrimmed, "\r");
            switch (getCaveType(to_cave)) {
                .Small => try addUnique(&small_caves, to_cave),
                .Large => try addUnique(&large_caves, to_cave),
                else => { }
            }
        }
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
}

fn addUnique(list: *std.ArrayList([cavename_length]u8), cave: []const u8) !void {
    for (list.items) |item| {
        if (std.mem.eql(u8, cave, item[0..])) return;
    }

    var copy: [cavename_length]u8 = undefined;
    std.mem.copy(u8, copy[0..], cave);
    try list.append(copy);
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

const Path = struct {
    from: []const u8,
    to: []const u8,
};
