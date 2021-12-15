const std = @import("std");

const use_example_input = false;
const input_filename = if (use_example_input) "day-2_test-input" else "day-2_real-input";
const input_length = if (use_example_input) 6 else 1000;

var i: usize = undefined;

pub fn main() !void {
    std.debug.print("--- Day 2 ---\n", .{});

    var cwd = std.fs.cwd();
    var input_file = try cwd.openFile(input_filename, .{});
    defer input_file.close();

    var horizontal_position: u32 = 0;
    var aim: u32 = 0;
    var depth: u32 = 0;

    i = 0;
    while (i < input_length):(i += 1) {
        const command = try getNextCommand(input_file);
        switch (command.type) {
            .Forward => {
                horizontal_position += command.value;
                depth += aim * command.value;
            },
            .Down => aim += command.value,
            .Up => aim -= command.value,
        }
    }

    std.debug.print(
        "horizontal position: {d}, depth: {d}, product: {d}\n", 
        .{ horizontal_position, depth, horizontal_position * depth });
}

fn getNextCommand(file: std.fs.File) !Command {
    var buffer: [100]u8 = undefined;
    const line = try file.reader().readUntilDelimiter(buffer[0..], '\n');
    var split_it = std.mem.split(u8, line, " ");
    const type_string = split_it.next() orelse unreachable;
    const value_string = split_it.next() orelse unreachable;
    const value = try std.fmt.parseInt(u32, value_string, 10);

    var command = Command { .value = value };

    if (std.mem.eql(u8, type_string, "forward")) {
        command.type = .Forward;
    } else if (std.mem.eql(u8, type_string, "down")) {
        command.type = .Down;
    } else if (std.mem.eql(u8, type_string, "up")) {
        command.type = .Up;
    } else unreachable;

    return command;
}

const Command = struct {
    type: enum { Forward, Down, Up } = undefined,
    value: u32,
};
