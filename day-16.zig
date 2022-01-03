const std = @import("std");

pub fn main() !void {
    std.debug.print("--- Day 16 ---\n", .{});
}

fn sumVersions(input: []const u8) !u32 {
    var buffer: [1024]u8 = undefined;
    const binary = hexToBinary(input, buffer[0..]);
    var reader = Reader { .string = binary };
    return try sumVersionsRecursive(&reader);
}

fn sumVersionsRecursive(reader: *Reader) !u32 {
    var version_sum = try parseVersion(reader.read(3));

    const packet_type = try parseType(reader.read(3));
    switch (packet_type) {
        .Literal => { },
        .Operator => {
            // const length_type = parseLengthType(reader.read(1));
        }
    }

    return version_sum;
}

test "sumVersions" {
    const data = [_]struct { in: []const u8, out: u32, } {
        .{ .in = "D2FE28", .out = 6 },
    };

    for (data) |pair| {
        const result = try sumVersions(pair.in);
        try std.testing.expectEqual(pair.out, result);
    }
}

const Reader = struct {
    string: []const u8,
    current: usize = 0,

    pub fn read(reader: *@This(), length: usize) []const u8 {
        const start = reader.current;
        const end = start + length;
        reader.current = end;
        return reader.string[start..end];
    }
};

test "integration: literal" {
    const input = "D2FE28";
    var buffer: [1024]u8 = undefined;
    const binary = hexToBinary(input, buffer[0..]);
    var reader = Reader { .string = binary };

    const version = try parseVersion(reader.read(3));
    try std.testing.expectEqual(@as(u3, 6), version);

    const packet_type = try parseType(reader.read(3));
    try std.testing.expectEqual(PacketType.Literal, packet_type);

    const literal_value = try parseLiteral(&reader);
    try std.testing.expectEqual(@as(u32, 2021), literal_value);
}

fn parsePacketCount(string: []const u8) !u11 {
    return try std.fmt.parseInt(u11, string, 2);
}

test "parsePacketCount" {
    const input: []const u8 = "00000000011";
    const expected: u11 = 3;
    const result = try parsePacketCount(input);
    try std.testing.expectEqual(expected, result);
}

fn parseBitLength(string: []const u8) !u15 {
    return try std.fmt.parseInt(u15, string, 2);
}

test "parseBitLength" {
    const data = [_]struct { in: []const u8, out: u15, } {
        .{ .in = "000000000011011", .out = 27 },
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
    return switch (string[0]) {
        '0' => .Bits,
        '1' => .Packets,
        else => unreachable
    };
}

test "parseLengthType" {
    const data = [_]struct { in: []const u8, out: LengthType, } {
        .{ .in = "0", .out = .Bits },
        .{ .in = "1", .out = .Packets },
    };

    for (data) |pair| {
        const result = parseLengthType(pair.in);
        try std.testing.expectEqual(pair.out, result);
    }
}

fn parseLiteral(reader: *Reader) !u32 {
    var buffer: [1024]u8 = undefined;
    var length: u32 = 0;

    while (true) {
        const current = reader.read(5);

        std.mem.copy(u8, buffer[length..], current[1..]);
        length += 4;

        if (current[0] == '0') break;
    }

    return try std.fmt.parseInt(u32, buffer[0..length], 2);
}

test "parseLiteral" {
    var reader = Reader { .string = "101111111000101000" };
    const value = try parseLiteral(&reader);
    try std.testing.expectEqual(@as(u32, 2021), value);
}

const PacketType = enum {
    Literal,
    Operator,
};

fn parseType(string: []const u8) !PacketType {
    const typeInt = try std.fmt.parseInt(u3, string, 2);
    return switch (typeInt) {
        3,6 => .Operator,
        4 => .Literal,
        else => unreachable
    };
}

test "parseType" {
    const data = [_]struct { in: []const u8, out: PacketType, } {
        .{ .in = "100", .out = .Literal },
        .{ .in = "110", .out = .Operator },
        .{ .in = "011", .out = .Operator },
    };

    for (data) |pair| {
        const result = try parseType(pair.in);
        try std.testing.expectEqual(pair.out, result);
    }
}

fn parseVersion(string: []const u8) !u3 {
    return try std.fmt.parseInt(u3, string, 2);
}

test "parseVersion" {
    const data = [_]struct { in: []const u8, out: u3, } {
        .{ .in = "110", .out = 6 },
        .{ .in = "001", .out = 1 },
        .{ .in = "111", .out = 7 },
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
