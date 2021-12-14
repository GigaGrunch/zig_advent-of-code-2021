const std = @import("std");

var i: usize = undefined;
const input_length = 1000;

pub fn main() !void {
    var cwd = std.fs.cwd();
    var input_file = try cwd.openFile("input", .{});
    defer input_file.close();

    i = 0;
    while (i < input_length):(i += 1) {
        const command = try getNextCommand(input_file);
        std.debug.print("{} {} ", .{ command.type, command.value });
    }
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
