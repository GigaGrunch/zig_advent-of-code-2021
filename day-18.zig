const std = @import("std");

var allocator: std.mem.Allocator = undefined;
var numbers: std.ArrayList(*u32) = undefined;

pub fn main() !void {
    std.debug.print("--- Day 18 ---\n", .{});

    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    allocator = alloc.allocator();
    numbers = std.ArrayList(*u32).init(allocator);

    const input_1 = "[[[[4,3],4],4],[7,[[8,4],9]]]";
    const input_2 = "[1,1]";

    var value_1 = try parseValue(input_1);
    var value_2 = try parseValue(input_2);

    std.debug.print("value 1: ", .{});
    printValue(value_1);
    std.debug.print("\n", .{});
    std.debug.print("value 2: ", .{});
    printValue(value_2);
    std.debug.print("\n", .{});

    var root_value = try add(value_1, value_2);

    try reduce(root_value);
}

fn add(lhs: *Value, rhs: *Value) !*Value {
    var result = try allocator.create(Value);
    result.* = .{
        .pair = .{
            .lhs = lhs,
            .rhs = rhs,
            .level = 0,
        }
    };

    var lhs_it = try ValueIterator.init(lhs);
    while (try lhs_it.next()) |value| {
        switch (value.*) {
            .number => { },
            .pair => |*pair| {
                pair.level += 1;
            },
        }
    }

    var rhs_it = try ValueIterator.init(rhs);
    while (try rhs_it.next()) |value| {
        switch (value.*) {
            .number => { },
            .pair => |*pair| {
                pair.level += 1;
            },
        }
    }

    return result;
}

fn reduce(root_value: *Value) !void {
    while (true) {
        printValue(root_value);
        std.debug.print("\n", .{});
        if (try handleFirstExplosion(root_value)) continue;
        if (try handleFirstSplit(root_value)) continue;
        break;
    }
}

fn handleFirstSplit(root_value: *Value) !bool {
    var value_it = try ValueIterator.init(root_value);
    var current_level: u32 = 0;
    return while (try value_it.next()) |value| {
        switch (value.*) {
            .number => |number| {
                if (number >= 10) {
                    const float = @intToFloat(f32, number);
                    const div = float / 2;
                    var left = try allocator.create(Value);
                    var right = try allocator.create(Value);
                    left.* = .{ .number = @floatToInt(u32, @floor(div)) };
                    right.* = .{ .number = @floatToInt(u32, @ceil(div)) };
                    value.* = .{
                        .pair = .{
                            .lhs = left,
                            .rhs = right,
                            .level = current_level + 1,
                        }
                    };
                    break true;
                }
            },
            .pair => |pair| {
                current_level = pair.level;
            },
        }
    } else false;
}

fn handleFirstExplosion(root_value: *Value) !bool {
    var value_it = try ValueIterator.init(root_value);
    var last_number: ?*u32 = null;
    return while (try value_it.next()) |value| {
        switch (value.*) {
            .number => |*number| {
                last_number = number;
            },
            .pair => |pair| {
                if (pair.shouldExplode()) {
                    _ = (try value_it.next()).?;
                    _ = (try value_it.next()).?;

                    if (last_number) |number| {
                        number.* += pair.lhs.number;
                    }

                    while (try value_it.next()) |next_value| {
                        switch (next_value.*) {
                            .number => |*number| {
                                number.* += pair.rhs.number;
                                break;
                            },
                            .pair => { },
                        }
                    }

                    value.* = .{ .number = 0 };
                    break true;
                }
            },
        }
    } else false;
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

fn parseValue(string: []const u8) !*Value {
    var it = StringIterator { .string = string };
    return parseValueRecursive(&it, 0);
}

fn parseValueRecursive(it: *StringIterator, level: u32) std.mem.Allocator.Error!*Value {
    var result = try allocator.create(Value);
    const char = it.next();
    switch (char) {
        '[' => {
            var pair: Pair = undefined;
            pair.level = level;
            pair.lhs = try parseValueRecursive(it, level + 1);
            it.gobble(',');
            pair.rhs = try parseValueRecursive(it, level + 1);
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
                try it.stack.append(pair.rhs);
                try it.stack.append(pair.lhs);
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
