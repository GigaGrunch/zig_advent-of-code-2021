const std = @import("std");

const use_test_input = true;
const filename = if (use_test_input) "day-9_test-input" else "day-9_real-input";
const line_length = if (use_test_input) 10 else 100;
const line_count = if (use_test_input) 5 else 100;

pub fn main() !void {
    std.debug.print("--- Day 9 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buffer: [1024 * 1024]u8 = undefined;

    var map: [line_length * line_count]u4 = undefined;
    {
        var line_i: usize = 0;
        while (line_i < line_count):(line_i += 1) {
            const line = try file.reader().readUntilDelimiter(buffer[0..], '\n');
            for (line) |char, char_i| {
                const map_i = line_i * line_length + char_i;
                map[map_i] = parseInt(char);
            }
        }
    }

    var buffer_allocator = std.heap.FixedBufferAllocator.init(buffer[0..]);

    var low_points = std.ArrayList(usize).init(buffer_allocator.allocator());
    {
        var y: usize = 0;
        while (y < line_count):(y += 1) {
            var x: usize = 0;
            while (x < line_length):(x += 1) {
                if (x > 0) {
                    if (map[getIndex(x - 1, y)] <= map[getIndex(x, y)]) continue;
                }
                if (x < line_length - 1) {
                    if (map[getIndex(x + 1, y)] <= map[getIndex(x, y)]) continue;
                }
                if (y > 0) {
                    if (map[getIndex(x, y - 1)] <= map[getIndex(x, y)]) continue;
                }
                if (y < line_count - 1) {
                    if (map[getIndex(x, y + 1)] <= map[getIndex(x, y)]) continue;
                }

                try low_points.append(getIndex(x, y));
            }
        }
    }

    // var basin_sizes = [_]u32 {0} ** 3;
    {
        for (low_points.items) |low_point_index| {
            var size: u32 = 1;

            var visited = std.ArrayList(usize).init(buffer_allocator.allocator());
            var frontier = std.ArrayList(usize).init(buffer_allocator.allocator());

            const low_point_coords = getCoords(low_point_index);
            if (low_point_coords.x > 0) {
                try frontier.append(low_point_index - 1);
            }
            if (low_point_coords.x < line_length - 1) {
                try frontier.append(low_point_index + 1);
            }
            if (low_point_coords.y > 0) {
                try frontier.append(low_point_index - line_length);
            }
            if (low_point_coords.y < line_count - 1) {
                try frontier.append(low_point_index + line_length);
            }

            while (frontier.items.len != 0) {
                const index = frontier.pop();
                if (index == low_point_index) continue;
                if (map[index] == 9) continue;
                if (contains(visited.items, index)) continue;
                try visited.append(index);

                size += 1;

                const coords = getCoords(index);
                if (coords.x > 0) {
                    try frontier.append(index - 1);
                }
                if (coords.x < line_length - 1) {
                    try frontier.append(index + 1);
                }
                if (coords.y > 0) {
                    try frontier.append(index - line_length);
                }
                if (coords.y < line_count - 1) {
                    try frontier.append(index + line_length);
                }
            }

            std.debug.print("basin size: {}\n", .{ size });
        }
    }
}

fn contains(haystack: []usize, needle: usize) bool {
    for (haystack) |item| {
        if (item == needle) return true;
    }
    return false;
}

fn getCoords(index: usize) struct { x: usize, y: usize } {
    return .{
        .x = index % line_length,
        .y = index / line_length,
    };
}

fn getIndex(x: usize, y: usize) usize {
    return y * line_length + x;
}

fn parseInt(char: u8) u4 {
    return @intCast(u4, char - '0');
}
