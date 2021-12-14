const std = @import("std");

var read_buffer_array: [100]u8 = undefined;
var read_buffer = read_buffer_array[0..];

pub fn main() !void {
    var cwd = std.fs.cwd();
    var input_file = try cwd.openFile("input", .{});
    defer input_file.close();

    var increase_count: u32 = 0;
    var previous = (try getNextInt(input_file)) orelse unreachable;
    while (try getNextInt(input_file)) |depth| {
        if (depth > previous) increase_count += 1;
        previous = depth;
    }

    std.debug.print("increase count: {d}\n", .{ increase_count });
}

fn getNextInt(file: std.fs.File) !?u32 {
    if (try file.reader().readUntilDelimiterOrEof(read_buffer, '\n')) |line| {
        return try std.fmt.parseInt(u32, line, 10);
    } else {
        return null;
    }
}
