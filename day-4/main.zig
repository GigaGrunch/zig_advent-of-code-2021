const std = @import("std");

const use_test_input = true;
const filename = if (use_test_input) "example_input" else "real_input";
const draw_count = if (use_test_input) 27 else 100;

pub fn main() !void {
    std.debug.print("--- Day 4 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    std.debug.print("\n", .{});

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

    std.debug.print("\n", .{});

    var board: [25]u7 = undefined;
    {
        std.debug.print("Board {:>2}: ", .{ 0 });

        try file.reader().skipUntilDelimiterOrEof('\n');
        var buffer: [3]u8 = undefined;
        const whitespace = [_]u8 { ' ', '\n' };

        var row: usize = 0;
        while (row < 5):(row += 1) {
            var column: usize = 0;
            while (column < 5):(column += 1) {
                const i = row * 5 + column;

                _ = try file.reader().read(buffer[0..]);
                const num_string = std.mem.trim(u8, buffer[0..], whitespace[0..]);
                board[i] = try std.fmt.parseInt(u7, num_string, 10);
                std.debug.print("{:>2} ", .{ board[i] });
            }
            std.debug.print("\n          ", .{});
        }
    }

    std.debug.print("\n", .{});
}

fn drawNext(file: std.fs.File, delimiter: u8) !u7 {
    var buffer: [2]u8 = undefined;
    const draw_string = try file.reader().readUntilDelimiter(buffer[0..], delimiter);
    const draw = try std.fmt.parseInt(u7, draw_string, 10);
    std.debug.print("{} ", .{ draw });
    return draw;
}
