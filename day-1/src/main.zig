const std = @import("std");

var read_buffer_array: [100]u8 = undefined;
var read_buffer = read_buffer_array[0..];

pub fn main() !void {
    var cwd = std.fs.cwd();
    var input_file = try cwd.openFile("input", .{});
    defer input_file.close();
    
    var depths: [2000]u32 = undefined;
    var i: u32 = 0;
    while (i < 2000):(i += 1) {
        depths[i] = try getNextInt(input_file);
        std.debug.print("{d} ", .{ depths[i] });
    }

    var increase_count: u32 = 0;
    std.debug.print("increase count: {d}\n", .{ increase_count });
}

fn getNextInt(file: std.fs.File) !u32 {
    const line = try file.reader().readUntilDelimiter(read_buffer, '\n');
    return try std.fmt.parseInt(u32, line, 10);
}
