const std = @import("std");

const use_test_input = false;
const filename = if (use_test_input) "day-9_test-input" else "day-9_real-input";
const line_length = if (use_test_input) 10 else 100;
const line_count = if (use_test_input) 5 else 100;

pub fn main() !void {
    std.debug.print("--- Day 9 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buffers: [3][line_length + 1]u8 = undefined;
    var next_buffer_index: usize = 0;

    var prev_line: []const u8 = undefined;
    var line: []const u8 = undefined;
    var next_line: []const u8 = undefined;

    next_line = try file.reader().readUntilDelimiter(buffers[next_buffer_index][0..], '\n');
    next_buffer_index = (next_buffer_index + 1) % buffers.len;

    var low_points_sum: u32 = 0;

    var line_index: u8 = 0;
    while (line_index < line_count):(line_index += 1) {
        if (line_index > 0) {
            prev_line = line;
        }

        line = next_line;

        if (line_index < line_count - 1) {
            next_line = try file.reader().readUntilDelimiter(buffers[next_buffer_index][0..], '\n');
            next_buffer_index = (next_buffer_index + 1) % buffers.len;
        }

        for (line) |char, char_index| {
            if (char_index > 0) {
                if (line[char_index - 1] <= char) continue;
            }
            if (char_index < line_length - 1) {
                if (line[char_index + 1] <= char) continue;
            }
            if (line_index > 0) {
                if (prev_line[char_index] <= char) continue;
            }
            if (line_index < line_count - 1) {
                if (next_line[char_index] <= char) continue;
            }

            low_points_sum += parseInt(char) + 1;
        }
    }

    std.debug.print("sum of all low points is {}\n", .{ low_points_sum });
}

fn parseInt(char: u8) u8 {
    return char - '0';
}
