const std = @import("std");

const use_test_input = true;
const filename = if (use_test_input) "day-5_test-input" else "day-5_real-input";
const edge_length = if (use_test_input) 10 else 1000;
const line_count = if (use_test_input) 10 else 500;

pub fn main() !void {
    std.debug.print("--- Day 5 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});

    // var vent_counts = [_]u9 {0} ** (edge_length * edge_length);

    {
        var buffer: [3]u8 = undefined;
        var line_index: usize = 0;
        while (line_index < line_count):(line_index += 1) {
            const x1_string = try file.reader().readUntilDelimiter(buffer[0..], ',');
            const x1 = try std.fmt.parseInt(u9, x1_string, 10);
            const y1_string = try file.reader().readUntilDelimiter(buffer[0..], ' ');
            const y1 = try std.fmt.parseInt(u9, y1_string, 10);
            _ = try file.reader().readUntilDelimiter(buffer[0..], ' ');
            const x2_string = try file.reader().readUntilDelimiter(buffer[0..], ',');
            const x2 = try std.fmt.parseInt(u9, x2_string, 10);
            const y2_string = try file.reader().readUntilDelimiter(buffer[0..], '\n');
            const y2 = try std.fmt.parseInt(u9, y2_string, 10);

            std.debug.print("{},{} -> {},{}\n", .{x1,y1,x2,y2});

            // check if line is vertical or horizontal

            // increase count for all covered spots
        }
    }
}
