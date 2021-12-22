const std = @import("std");

const use_test_input = false;
const filename = if (use_test_input) "day-11_test-input" else "day-11_real-input";
const edge_length = 10;

pub fn main() !void {
    std.debug.print("--- Day 11 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var grid: [edge_length * edge_length]u8 = undefined;
    {
        var i: usize = 0;
        while (i < grid.len):(i += 1) {
            grid[i] = try file.reader().readByte();

            if (i % edge_length == edge_length - 1) {
                try file.reader().skipBytes(1, .{});
            }
        }
    }

    std.debug.print("initial grid:\n", .{});
    {
        var i: usize = 0;
        while (i < edge_length):(i += 1) {
            const start = i * edge_length;
            const end = start + edge_length;
            std.debug.print("{s}\n", .{ grid[start..end] });
        }
    }
}
