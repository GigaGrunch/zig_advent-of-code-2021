const std = @import("std");

const use_test_input = false;
const filename = if (use_test_input) "example_input" else "real_input";
const draw_count = if (use_test_input) 27 else 100;
const board_count = if (use_test_input) 3 else 100;

pub fn main() !void {
    std.debug.print("--- Day 4 ---\n", .{});

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var draw_numbers: [draw_count]u7 = undefined;
    {
        var i: usize = 0;
        while (i < draw_count - 1):(i += 1) {
            draw_numbers[i] = try drawNext(file, ',');
        }
        draw_numbers[i] = try drawNext(file, '\n');
    }

    var first_board_index: usize = 127;
    var first_board_turn: u7 = 127;
    var first_board_score: u32 = 0;

    var board_index: usize = 0;
    while (board_index < board_count):(board_index += 1) {
        var board: [25]u7 = undefined;
        var draw_turns = [_]?u7 {null} ** 25;
        {
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
                }
            }
        }

        var win_turn: u7 = 127;

        var o_winning_row: ?usize = null;
        {
            var row: usize = 0;
            while (row < 5):(row += 1) {
                var o_row_win_turn: ?u7 = null;

                var column: usize = 0;
                while (column < 5):(column += 1) {
                    const i = row * 5 + column;

                    if (draw_turns[i]) |turn| {
                        if (o_row_win_turn) |row_win_turn| {
                            o_row_win_turn = @maximum(turn, row_win_turn);
                        } else {
                            o_row_win_turn = turn;
                        }
                    } else {
                        o_row_win_turn = null;
                        break;
                    }
                }

                if (o_row_win_turn) |row_win_turn| {
                    if (row_win_turn < win_turn) {
                        win_turn = row_win_turn;
                        o_winning_row = row;
                    }
                }
            }
        }

        var o_winning_column: ?usize = null;
        {
            var column: usize = 0;
            while (column < 5):(column += 1) {
                var o_column_win_turn: ?u7 = null;

                var row: usize = 0;
                while (row < 5):(row += 1) {
                    const i = row * 5 + column;

                    if (draw_turns[i]) |turn| {
                        if (o_column_win_turn) |column_win_turn| {
                            o_column_win_turn = @maximum(turn, column_win_turn);
                        } else {
                            o_column_win_turn = turn;
                        }
                    } else {
                        o_column_win_turn = null;
                        break;
                    }
                }

                if (o_column_win_turn) |column_win_turn| {
                    if (column_win_turn < win_turn) {
                        win_turn = column_win_turn;
                        o_winning_row = null;
                        o_winning_column = column;
                    }
                }
            }
        }

        var score: u32 = 0;
        for (board) |num, i| {
            if (draw_turns[i] == null or draw_turns[i].? > win_turn) {
                score += num;
            }
        }
        score *= draw_numbers[win_turn];

        if (win_turn < first_board_turn) {
            first_board_turn = win_turn;
            first_board_score = score;
            first_board_index = board_index;
        }
    }

    std.debug.print(
        "board {} wins at turn {} with score of {}\n",
        .{ first_board_index, first_board_turn, first_board_score });
}

fn drawNext(file: std.fs.File, delimiter: u8) !u7 {
    var buffer: [2]u8 = undefined;
    const draw_string = try file.reader().readUntilDelimiter(buffer[0..], delimiter);
    const draw = try std.fmt.parseInt(u7, draw_string, 10);
    return draw;
}
