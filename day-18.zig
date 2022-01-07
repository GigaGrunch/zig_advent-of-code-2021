const std = @import("std");
const test_input = @embedFile("day-18_test-input");

var allocator: std.mem.Allocator = undefined;

pub fn main() !void {
    std.debug.print("--- Day 18 ---\n", .{});
}

test "full thing" {
    std.debug.print("\n", .{});
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();
    allocator = alloc.allocator();
    try execute(test_input);
}

fn execute(input: []const u8) !void {
    var line_it = std.mem.tokenize(u8, input, "\n\r");

    var current = try parseValue(line_it.next().?);

    std.debug.print("  ", .{});
    printValue(current);
    std.debug.print("\n", .{});

    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        var other = try parseValue(line);
        std.debug.print("+ ", .{});
        printValue(other);
        std.debug.print("\n", .{});

        current = try add(current, other);
        try reduce(current);

        std.debug.print("= ", .{});
        printValue(current);
        std.debug.print("\n", .{});
    }
}

fn add(lhs: *Node, rhs: *Node) !*Node {
    var result = try allocator.create(Node);
    result.* = .{
        .parent = null,
        .value = .{
            .pair = .{
                .left = lhs,
                .right = rhs,
            }
        }
    };

    lhs.parent = result;
    rhs.parent = result;

    return result;
}

fn reduce(root: *Node) !void {
    while (true) {
        if (try handleFirstExplosion(root)) {
            continue;
        }
        if (try handleFirstSplit(root)) {
            continue;
        }
        break;
    }
}

fn handleFirstSplit(root: *Node) !bool {
    var it = try TreeIterator.init(root);
    return while (try it.next()) |node| {
        switch (node.value) {
            .number => |number| {
                if (number >= 10) {
                    const float = @intToFloat(f32, number);
                    const div = float / 2;

                    var left = try allocator.create(Node);
                    left.* = .{
                        .parent = node.parent,
                        .value = .{ .number = @floatToInt(u32, @floor(div)) },
                    };

                    var right = try allocator.create(Node);
                    right.* = .{
                        .parent = node.parent,
                        .value = .{ .number = @floatToInt(u32, @ceil(div)) }
                    };

                    node.value = .{
                        .pair = .{
                            .left = left,
                            .right = right,
                        }
                    };

                    break true;
                }
            },
            .pair => { },
        }
    } else false;
}

fn handleFirstExplosion(root: *Node) !bool {
    var it = try TreeIterator.init(root);
    var last_number: ?*u32 = null;

    return while (try it.next()) |node| {
        switch (node.value) {
            .number => |*number| {
                last_number = number;
            },
            .pair => |pair| {
                if (node.level() >= 4 and pair.canExplode()) {
                    _ = (try it.next()).?;
                    _ = (try it.next()).?;

                    if (last_number) |number| {
                        number.* += pair.left.value.number;
                    }

                    while (try it.next()) |next| {
                        switch (next.value) {
                            .number => |*number| {
                                number.* += pair.right.value.number;
                                break;
                            },
                            .pair => { },
                        }
                    }

                    node.value = .{ .number = 0 };
                    break true;
                }
            },
        }
    } else false;
}

fn printValue(root: *Node) void {
    switch (root.value) {
        .number => |number| std.debug.print("{}", .{ number }),
        .pair => |pair| {
            std.debug.print("[", .{});
            printValue(pair.left);
            std.debug.print(",", .{});
            printValue(pair.right);
            std.debug.print("]", .{});
        }
    }
}

fn parseValue(string: []const u8) !*Node {
    var it = StringIterator { .string = string };
    return parseValueRecursive(&it, null);
}

fn parseValueRecursive(it: *StringIterator, parent: ?*Node) std.mem.Allocator.Error!*Node {
    var result = try allocator.create(Node);
    const char = it.next();

    switch (char) {
        '[' => {
            var left = try parseValueRecursive(it, result);
            it.gobble(',');
            var right = try parseValueRecursive(it, result);
            it.gobble(']');

            result.* = .{
                .parent = parent,
                .value = .{
                    .pair = .{
                        .left = left,
                        .right = right,
                    }
                },
            };
        },
        '0'...'9' => {
            result.* = .{
                .parent = parent,
                .value = .{ .number = char - '0' },
            };
        },
        else => {
            std.debug.print("nothing implemented for {c}\n", .{ char });
            unreachable;
        }
    }

    return result;
}

const Node = struct {
    parent: ?*Node,
    value: Value,

    fn level(node: Node) u32 {
        var parent = node.parent;
        var result: u32 = 0;

        while (parent != null) {
            parent = parent.?.parent;
            result += 1;
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
    left: *Node,
    right: *Node,

    fn canExplode(pair: Pair) bool {
        const lhs_number = @as(ValueType, pair.left.value) == .number;
        const rhs_number = @as(ValueType, pair.right.value) == .number;
        return lhs_number and rhs_number;
    }
};

const TreeIterator = struct {
    stack: std.ArrayList(*Node),

    fn init(root: *Node) !@This() {
        var it = @This() { .stack = std.ArrayList(*Node).init(allocator) };
        try it.stack.append(root);
        return it;
    }

    fn next(it: *@This()) !?*Node {
        if (it.stack.items.len == 0) return null;
        var result = it.stack.pop();
        switch (result.value) {
            .number => { },
            .pair => |pair| {
                try it.stack.append(pair.right);
                try it.stack.append(pair.left);
            }
        }
        return result;
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
