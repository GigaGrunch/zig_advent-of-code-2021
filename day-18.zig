const std = @import("std");

var allocator: std.mem.Allocator = undefined;

pub fn main() !void {
    std.debug.print("--- Day 18 ---\n", .{});

    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    allocator = alloc.allocator();
    defer alloc.deinit();

    const input = "[[[[[9,8],1],2],3],4]";
    var it = StringIterator { .string = input };

    const value = try parseValue(&it);
    printValue(value);
}

fn printValue(value: *Value) void {
    switch (value.*) {
        .number => |number| std.debug.print("{}", .{ number }),
        .pair => |pair| {
            std.debug.print("[", .{});
            printValue(pair.lhs);
            std.debug.print(",", .{});
            printValue(pair.rhs);
            std.debug.print("]", .{});
        }
    }
}

fn parseValue(it: *StringIterator) std.mem.Allocator.Error!*Value {
    var result = try allocator.create(Value);

    const char = it.next();
    switch (char) {
        '[' => {
            var pair: Pair = undefined;
            pair.lhs = try parseValue(it);
            it.gobble(',');
            pair.rhs = try parseValue(it);
            it.gobble(']');
            result.* = .{ .pair = pair };
        },
        '0'...'9' => {
            result.* = .{ .number = char - '0' };
        },
        else => {
            std.debug.print("nothing implemented for {c}\n", .{ char });
            unreachable;
        }
    }

    return result;
}

const ValueType = enum { number, pair };

const Value = union(ValueType) {
    number: u32,
    pair: Pair,
};

const Pair = struct {
    lhs: *Value,
    rhs: *Value,
};

const StringIterator = struct {
    string: []const u8,
    current: usize = 0,

    fn next(reader: *@This()) u8 {
        if (reader.current >= reader.string.len) @panic("out of bounds!");
        defer reader.current += 1;
        return reader.string[reader.current];
    }

    fn gobble(reader: *@This(), expected: u8,) void {
        const char = reader.next();
        if (char != expected) {
            std.debug.print("expected {c}, but found {c}\n", .{ expected, char });
            unreachable;
        }
    }
};
