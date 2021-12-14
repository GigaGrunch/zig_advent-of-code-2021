const std = @import("std");

const use_test_input = true;
const input_filename = if (use_test_input) "test_input" else "real_input";
const input_length = if (use_test_input) 12 else 1000;

pub fn main() !void {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(input_filename, .{});
    defer file.close();
}
