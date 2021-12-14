const std = @import("std");

var read_buffer_array: [100]u8 = undefined;
var read_buffer = read_buffer_array[0..];

pub fn main() !void {
    var cwd = std.fs.cwd();
    var input_file = try cwd.openFile("input", .{});
    defer input_file.close();

    const first_depth = (try getNextInt(input_file)) orelse unreachable;
    std.debug.print("{d}\n", .{ first_depth });
}

fn getNextInt(file: std.fs.File) !?u32 {
    if (try file.reader().readUntilDelimiterOrEof(read_buffer, '\n')) |line| {
        return try std.fmt.parseInt(u32, line, 10);
    } else {
        return null;
    }
}
