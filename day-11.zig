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
                try file.reader().skipUntilDelimiterOrEof('\n');
            }
        }
    }

    std.debug.print("initial grid:\n", .{});
    printGrid(grid[0..]);

    var iteration: u32 = 0;
    while (iteration < 100):(iteration += 1) {
        var flash_buffer: [1000]u8 = undefined;
        var flash_allocator = std.heap.FixedBufferAllocator.init(flash_buffer[0..]);
        var flash_indices = std.ArrayList(usize).init(flash_allocator.allocator());

        for (grid) |*value, i| {
            value.* += 1;
            if (value.* > 9) {
                try flash_indices.append(i);
            }
        }
    }
}

fn printGrid(grid: []u8) void {
    var i: usize = 0;
    while (i < edge_length):(i += 1) {
        const start = i * edge_length;
        const end = start + edge_length;
        std.debug.print("{s}\n", .{ grid[start..end] });
    }
}
