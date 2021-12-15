const std = @import("std");

var i: usize = undefined;

pub fn main() !void {
    std.debug.print("--- Day 1 ---\n", .{});

    var cwd = std.fs.cwd();
    var input_file = try cwd.openFile("day-1_real-input", .{});
    defer input_file.close();
    
    var depths: [2000]u32 = undefined;
    i = 0;
    while (i < 2000):(i += 1) {
        depths[i] = try getNextInt(input_file);
    }

    var increase_count: u32 = 0;

    var previous = getDepthSum(depths[0..3]);
    i = 1;
    while (i < 1998):(i += 1) {
        const depth = getDepthSum(depths[i..i+3]);
        if (depth > previous) {
            increase_count += 1;
        }
        previous = depth;
    }

    std.debug.print("increase count: {d}\n", .{ increase_count });
}

fn getNextInt(file: std.fs.File) !u32 {
    var read_buffer: [100]u8 = undefined;
    const line = try file.reader().readUntilDelimiter(read_buffer[0..], '\n');
    return try std.fmt.parseInt(u32, line, 10);
}

fn getDepthSum(window: []u32) u32 {
    return window[0] + window[1] + window[2];
}
