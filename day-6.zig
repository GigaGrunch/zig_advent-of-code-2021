const std = @import("std");

const use_test_input = true;
const filename = if (use_test_input) "day-6_test-input" else "day-6_real-input";

pub fn main() !void {
    std.debug.print("--- Day 6 ---\n", .{});

    var fish_count = [_]u32 {0} ** 9;

    var file = try std.fs.cwd().openFile(filename, .{});
    while (true) {
        const char = try file.reader().readByte();
        if (char == ',') continue;
        if (char == '\n') break;

        const timer = @intCast(usize, char - '0');
        fish_count[timer] += 1;
    }

    std.debug.print("initial fish counts: ", .{});
    for (fish_count) |count, i| {
        std.debug.print("{}x{} ", .{ count, i });
    }
    std.debug.print("\n", .{});
}
