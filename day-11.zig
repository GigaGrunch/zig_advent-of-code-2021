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
            const char = try file.reader().readByte();
            grid[i] = char - '0';

            if (i % edge_length == edge_length - 1) {
                try file.reader().skipUntilDelimiterOrEof('\n');
            }
        }
    }

    var flash_count: u32 = 0;

    var iteration: u32 = 0;
    while (iteration < 100):(iteration += 1) {
        var flash_buffer: [3 * edge_length * edge_length * @sizeOf(usize)]u8 = undefined;
        var flash_allocator = std.heap.FixedBufferAllocator.init(flash_buffer[0..]);
        var flash_indices = try std.ArrayList(usize).initCapacity(flash_allocator.allocator(), edge_length * edge_length);
        var handles_indices = try std.ArrayList(usize).initCapacity(flash_allocator.allocator(), edge_length * edge_length);

        for (grid) |*value, i| {
            value.* += 1;
            if (value.* > 9) {
                value.* = 100;
                try flash_indices.append(i);
            }
        }

        while (flash_indices.items.len > 0) {
            const flash_index = flash_indices.pop();
            if (grid[flash_index] == 200) continue;

            grid[flash_index] = 200;
            try handles_indices.append(flash_index);
            flash_count += 1;

            var coords = getCoords(flash_index);
            for ([_]i8 { -1, 0, 1 }) |y_offset| {
                for ([_]i8 { -1, 0, 1 }) |x_offset| {
                    if (x_offset == 0 and y_offset == 0) continue;

                    const x = coords.x + x_offset;
                    const y = coords.y + y_offset;

                    if (x < 0 or x >= edge_length) continue;
                    if (y < 0 or y >= edge_length) continue;

                    const i = getIndex(x, y);
                    if (grid[i] < 100) {
                        grid[i] += 1;
                        if (grid[i] > 9) {
                            grid[i] = 100;
                            try flash_indices.append(i);
                        }
                    }
                }
            }
        }

        for (handles_indices.items) |i| {
            grid[i] = 0;
        }
    }

    std.debug.print("total flash count is {} after {} iterations\n", .{ flash_count, iteration });
}

fn printGrid(grid: []u8) void {
    for (grid) |value, i| {
        std.debug.print("{}", .{ value });
        if (i % edge_length == edge_length - 1) {
            std.debug.print("\n", .{});
        }
    }
}

fn getCoords(index: usize) struct { x: i32, y: i32, } {
    return .{
        .x = @intCast(i32, index % edge_length),
        .y = @intCast(i32, index / edge_length),
    };
}

fn getIndex(x: i32, y: i32) usize {
    return @intCast(usize, y * edge_length + x);
}
