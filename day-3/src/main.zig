const std = @import("std");

var i: usize = undefined;

const use_test_input = true;
const filename = if (use_test_input) "test_input" else "real_input";
const sample_count = if (use_test_input) 12 else 1000;
const sample_length = if (use_test_input) 5 else 12;

pub fn main() !void {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(filename, .{});
    defer file.close();

    var buffer: [sample_length]u8 = undefined;

    //const one_counts = [_]u32{0} ** sample_length;
    i = 0;
    while (i < sample_count):(i += 1) {
        const line = try file.reader().readUntilDelimiter(buffer[0..], '\n');
        std.debug.print("{s} ", .{ line });
    }
}
