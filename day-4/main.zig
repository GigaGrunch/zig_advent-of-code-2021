const std = @import("std");

const use_test_input = true;
const filename = if (use_test_input) "example_input" else "real_input";
const draw_count = if (use_test_input) 27 else 100;

pub fn main() !void {
    std.debug.print("--- Day 4 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    std.debug.print("\n", .{});

    var draw_numbers: [draw_count]u7 = undefined;
    {
        std.debug.print("Draw numbers: ", .{});

        var i: usize = 0;
        while (i < draw_count - 1):(i += 1) {
            draw_numbers[i] = try drawNext(file, ',');
        }
        draw_numbers[i] = try drawNext(file, '\n');

        std.debug.print("\n", .{});
    }

    std.debug.print("\n", .{});

    var board: [25]u7 = undefined;
    var draw_turns = [_]?u7 {null} ** 25;
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

                for (draw_numbers) |draw, turn| {
                    if (draw == board[i]) {
                        draw_turns[i] = @intCast(u7, turn);
                        break;
                    }
                }

                std.debug.print("{:>2}", .{ board[i] });
                var turn_string_buffer: [5]u8 = undefined;
                var turn_string: []u8 = undefined;
                if (draw_turns[i]) |turn| {
                    turn_string = try std.fmt.bufPrint(turn_string_buffer[0..], "({})", .{ turn });
                } else {
                    turn_string = try std.fmt.bufPrint(turn_string_buffer[0..], "(-)", .{});
                }
                std.debug.print("{s:<5} ", .{ turn_string });
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
