const std = @import("std");

var allocator: std.mem.Allocator = undefined;
var numbers: std.ArrayList(*u32) = undefined;

pub fn main() !void {
    std.debug.print("--- Day 18 ---\n", .{});

    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    allocator = alloc.allocator();
    numbers = std.ArrayList(*u32).init(allocator);

    const input = "[[[[[9,8],1],2],3],4]";
    // const input = "[[[[1,2],[3,4]],[[5,6],[7,8]]],9]";
    // const input = "[7,[6,[5,[4,[3,2]]]]]";
    var input_it = StringIterator { .string = input };

    var outer_value = try parseValue(&input_it, 0);

    var value_it = try ValueIterator.init(outer_value);
    while (try value_it.next()) |value| {
        printValue(value);
        std.debug.print("\n", .{});
    }
}

fn printValue(value: *Value) void {
    switch (value.*) {
        .number => |number| std.debug.print("{}", .{ number }),
        .pair => |pair| {
            std.debug.print("[", .{});
            printValue(pair.lhs);

            if (pair.shouldExplode()) std.debug.print("!", .{})
            else std.debug.print(",", .{});

            printValue(pair.rhs);
            std.debug.print("]", .{});
        }
    }
}

fn parseValue(it: *StringIterator, level: u32) std.mem.Allocator.Error!*Value {
    var result = try allocator.create(Value);

    const char = it.next();
    switch (char) {
        '[' => {
            var pair: Pair = undefined;
            pair.level = level;
            pair.lhs = try parseValue(it, level + 1);
            it.gobble(',');
            pair.rhs = try parseValue(it, level + 1);
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

const ValueIterator = struct {
    stack: std.ArrayList(*Value),

    fn init(first_value: *Value) !ValueIterator {
        var it = ValueIterator { .stack = std.ArrayList(*Value).init(allocator) };
        try it.stack.append(first_value);
        return it;
    }

    fn next(it: *ValueIterator) !?*Value {
        if (it.stack.items.len == 0) return null;
        var result = it.stack.pop();
        switch (result.*) {
            .number => { },
            .pair => |pair| {
                try it.stack.append(pair.lhs);
                try it.stack.append(pair.rhs);
            }
        }
        return result;
    }
};

const ValueType = enum { number, pair };

const Value = union(ValueType) {
    number: u32,
    pair: Pair,
};

const Pair = struct {
    lhs: *Value,
    rhs: *Value,
    level: u32,

    fn shouldExplode(pair: Pair) bool {
        const lhs_number = @as(ValueType, pair.lhs.*) == .number;
        const rhs_number = @as(ValueType, pair.rhs.*) == .number;
        return lhs_number and rhs_number and pair.level > 3;
    }
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
