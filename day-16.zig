const std = @import("std");

pub fn main() !void {
    std.debug.print("--- Day 16 ---\n", .{});
}

fn parseBitLength(string: []const u8) !u15 {
    return try std.fmt.parseInt(u15, string[7..22], 2);
}

test "parseBitLength" {
    const data = [_]struct { in: []const u8, out: u15, } {
        .{ .in = "00111000000000000110111101000101001010010001001000000000", .out = 27 },
    };

    for (data) |pair| {
        const result = try parseBitLength(pair.in);
        try std.testing.expectEqual(pair.out, result);
    }
}

const LengthType = enum {
    Bits,
    Packets,
};

fn parseLengthType(string: []const u8) LengthType {
    return switch (string[6]) {
        '0' => .Bits,
        '1' => .Packets,
        else => unreachable
    };
}

test "parseLengthType" {
    const data = [_]struct { in: []const u8, out: LengthType, } {
        .{ .in = "00111000000000000110111101000101001010010001001000000000", .out = .Bits },
        .{ .in = "11101110000000001101010000001100100000100011000001100000", .out = .Packets },
    };

    for (data) |pair| {
        const result = parseLengthType(pair.in);
        try std.testing.expectEqual(pair.out, result);
    }
}

fn parseLiteral(string: []const u8) !u32 {
    var buffer: [1024]u8 = undefined;
    var length: u32 = 0;

    var current_start: usize = 6;
    while (true):(current_start += 5) {
        const current_end = current_start + 5;
        const current = string[current_start..current_end];

        std.mem.copy(u8, buffer[length..], current[1..]);
        length += 4;

        if (current[0] == '0') break;
    }

    return try std.fmt.parseInt(u32, buffer[0..length], 2);
}

test "parseLiteral" {
    const data = [_]struct { in: []const u8, out: u32, } {
        .{ .in = "110100101111111000101000", .out = 2021 },
    };

    for (data) |pair| {
        const result = try parseLiteral(pair.in);
        try std.testing.expectEqual(pair.out, result);
    }
}

const PacketType = enum {
    Literal,
    Operator,
};

fn parseType(string: []const u8) !PacketType {
    const typeInt = try std.fmt.parseInt(u3, string[3..6], 2);
    return switch (typeInt) {
        3,6 => .Operator,
        4 => .Literal,
        else => unreachable
    };
}

test "parseType" {
    const data = [_]struct { in: []const u8, out: PacketType, } {
        .{ .in = "110100101111111000101000", .out = .Literal },
        .{ .in = "00111000000000000110111101000101001010010001001000000000", .out = .Operator },
        .{ .in = "11101110000000001101010000001100100000100011000001100000", .out = .Operator },
    };

    for (data) |pair| {
        const result = try parseType(pair.in);
        try std.testing.expectEqual(pair.out, result);
    }
}

fn parseVersion(string: []const u8) !u3 {
    return try std.fmt.parseInt(u3, string[0..3], 2);
}

test "parseVersion" {
    const data = [_]struct { in: []const u8, out: u3, } {
        .{ .in = "110100101111111000101000", .out = 6 },
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
        .{ .in = "D2FE28", .out = "110100101111111000101000" },
        .{ .in = "38006F45291200", .out = "00111000000000000110111101000101001010010001001000000000" },
        .{ .in = "EE00D40C823060", .out = "11101110000000001101010000001100100000100011000001100000" },
    };

    for (data) |pair| {
        var buffer: [1024]u8 = undefined;
        const result = hexToBinary(pair.in, buffer[0..]);
        try std.testing.expectEqualStrings(pair.out, result);
    }
}
