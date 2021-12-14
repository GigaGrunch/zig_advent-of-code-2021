const std = @import("std");

const use_test_input = false;
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

    var gamma_string: [sample_length]u8 = undefined;
    var epsilon_string: [sample_length]u8 = undefined;
    for (one_counts) |count, i| {
        gamma_string[i] = if (count > sample_count / 2) '1' else '0';
        epsilon_string[i] = if (count > sample_count / 2) '0' else '1';
    }

    const gamma = try std.fmt.parseInt(u32, gamma_string[0..], 2);
    const epsilon = try std.fmt.parseInt(u32, epsilon_string[0..], 2);
    const power_consumption = gamma * epsilon;

    std.debug.print("power consumption is {d}\n", .{ power_consumption });
}
