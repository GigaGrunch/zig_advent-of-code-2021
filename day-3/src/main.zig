const std = @import("std");

const use_test_input = true;
const filename = if (use_test_input) "test_input" else "real_input";
const sample_count = if (use_test_input) 12 else 1000;
const sample_length = if (use_test_input) 5 else 12;

pub fn main() !void {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(filename, .{});
    defer file.close();

    var buffer: [sample_length]u8 = undefined;

    var one_counts = [_]u32{0} ** sample_length;
    var sample_index: usize = 0;
    while (sample_index < sample_count):(sample_index += 1) {
        const line = try file.reader().readUntilDelimiter(buffer[0..], '\n');
        
        for (line) |char, i| {
            if (char == '1') {
                one_counts[i] += 1;
            }
        }
    }

    std.debug.print("one counts: ", .{});
    for (one_counts) |count| {
        std.debug.print("{d}", .{ count });
    }
    std.debug.print("\n", .{});
}
