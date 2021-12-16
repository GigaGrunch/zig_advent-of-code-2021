const std = @import("std");

const use_test_input = false;
const filename = if (use_test_input) "day-5_test-input" else "day-5_real-input";
const edge_length = if (use_test_input) 10 else 1000;
const line_count = if (use_test_input) 10 else 500;

pub fn main() !void {
    std.debug.print("--- Day 5 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});

    var vent_counts = [_]i32 {0} ** (edge_length * edge_length);
    {
        var buffer: [3]u8 = undefined;
        var line_index: usize = 0;
        while (line_index < line_count):(line_index += 1) {
            const x1_string = try file.reader().readUntilDelimiter(buffer[0..], ',');
            const x1 = try std.fmt.parseInt(i32, x1_string, 10);
            const y1_string = try file.reader().readUntilDelimiter(buffer[0..], ' ');
            const y1 = try std.fmt.parseInt(i32, y1_string, 10);
            _ = try file.reader().readUntilDelimiter(buffer[0..], ' ');
            const x2_string = try file.reader().readUntilDelimiter(buffer[0..], ',');
            const x2 = try std.fmt.parseInt(i32, x2_string, 10);
            const y2_string = try file.reader().readUntilDelimiter(buffer[0..], '\n');
            const y2 = try std.fmt.parseInt(i32, y2_string, 10);

            const is_horizontal = x1 == x2;
            const is_vertical = y1 == y2;
            // const is_diagonal = !is_horizontal and !is_vertical;

            if (is_horizontal) {
                const increment: i32 = if (y1 < y2) 1 else -1;
                var y = y1;
                while (y != y2 + increment):(y += increment) {
                    const i = @intCast(usize, y * edge_length + x1);
                    vent_counts[i] += 1;
                }
            } else if (is_vertical) {
                const increment: i32 = if (x1 < x2) 1 else -1;
                var x = x1;
                while (x != x2 + increment):(x += increment) {
                    const i = @intCast(usize, y1 * edge_length + x);
                    vent_counts[i] += 1;
                }
            }
        }
    }

    var at_least_two: u32 = 0;
    {
        var y: usize = 0;
        while (y < edge_length):(y += 1) {
            var x: usize = 0;
            while (x < edge_length):(x += 1) {
                const i = y * edge_length + x;
                if (vent_counts[i] >= 2) {
                    at_least_two += 1;
                }
            }
        }
    }

    std.debug.print("at {} points do at least two lines overlap\n", .{ at_least_two });
}
