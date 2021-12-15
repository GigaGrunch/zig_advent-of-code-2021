const std = @import("std");

const use_test_input = true;
const filename = if (use_test_input) "example_input" else "real_input";
const draw_count = if (use_test_input) 27 else 100;

pub fn main() !void {
    std.debug.print("--- Day 4 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var draw: [draw_count]u7 = undefined;
    {
        std.debug.print("Draw: ", .{});

        var i: usize = 0;
        while (i < draw_count - 1):(i += 1) {
            draw[i] = try drawNext(file, ',');
        }
        draw[i] = try drawNext(file, '\n');

        std.debug.print("\n", .{});
    }
}

fn drawNext(file: std.fs.File, delimiter: u8) !u7 {
    var buffer: [2]u8 = undefined;
    const draw_string = try file.reader().readUntilDelimiter(buffer[0..], delimiter);
    const draw = try std.fmt.parseInt(u7, draw_string, 10);
    std.debug.print("{} ", .{ draw });
    return draw;
}
