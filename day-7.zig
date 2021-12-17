const std = @import("std");

var i: usize = undefined;

const use_test_input = true;
const filename = if (use_test_input) "day-7_test-input" else "day-7_real-input";
const input_length = if (use_test_input) 10 else 1000;

pub fn main() !void {
    std.debug.print("--- Day 7 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});

    var crab_positions: [input_length]u16 = undefined;
    i = 0;
    while (i < input_length):(i += 1) {
        var buffer: [4]u8 = undefined;
        const delimiter: u8 = if (i != input_length - 1) ',' else '\n';
        const pos_string = try file.reader().readUntilDelimiter(buffer[0..], delimiter);
        crab_positions[i] = try std.fmt.parseInt(u16, pos_string, 10);
    }

    std.debug.print("positions: ", .{});
    for (crab_positions) |pos| {
        std.debug.print("{} ", .{ pos });
    }
    std.debug.print("\n", .{});
}
