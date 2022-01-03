const std = @import("std");

pub fn main() !void {
    std.debug.print("--- Day 16 ---\n", .{});
}

fn parseVersion(string: []const u8) !u3 {
    return try std.fmt.parseInt(u3, string[0..3], 2);
}

test "parseVersion" {
    const data = [_]struct { in: []const u8, out: u3, } {
        .{ .in = "00111000000000000110111101000101001010010001001000000000", .out = 1 },
        .{ .in = "11101110000000001101010000001100100000100011000001100000", .out = 7 },
    };

    for (data) |pair| {
        const result = try parseVersion(pair.in);
        try std.testing.expectEqual(pair.out, result);
    }
}

fn hexToBinary(hex: []const u8, buffer: []u8) []const u8 {
    var count: u32 = 0;

    for (hex) |char| {
        const string = switch (char) {
            '0' => "0000",
            '1' => "0001",
            '2' => "0010",
            '3' => "0011",
            '4' => "0100",
            '5' => "0101",
            '6' => "0110",
            '7' => "0111",
            '8' => "1000",
            '9' => "1001",
            'A' => "1010",
            'B' => "1011",
            'C' => "1100",
            'D' => "1101",
            'E' => "1110",
            'F' => "1111",
            else => unreachable
        };

        std.mem.copy(u8, buffer[count..], string);
        count += 4;
    }

    return buffer[0..count];
}

test "hexToBinary" {
    const data = [_]struct { in: []const u8, out: []const u8, } {
        .{ .in = "38006F45291200", .out = "00111000000000000110111101000101001010010001001000000000" },
        .{ .in = "EE00D40C823060", .out = "11101110000000001101010000001100100000100011000001100000" },
    };

    for (data) |pair| {
        var buffer: [1024]u8 = undefined;
        const result = hexToBinary(pair.in, buffer[0..]);
        try std.testing.expectEqualStrings(pair.out, result);
    }
}
