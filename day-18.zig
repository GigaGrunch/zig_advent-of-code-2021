const std = @import("std");
const test_input = @embedFile("day-18_test-input");

var allocator: std.mem.Allocator = undefined;

pub fn main() !void {
    std.debug.print("--- Day 18 ---\n", .{});
}

fn addList(input: []const u8) !*Node {
    var line_it = std.mem.tokenize(u8, input, "\n\r");
    var current = try parseValue(line_it.next().?);

    while (line_it.next()) |line| {
        if (line.len == 0) continue;

        var other = try parseValue(line);
        current = try add(current, other);
        try reduce(current);
    }

    return current;
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
                        .parent = node,
                        .value = .{ .number = @floatToInt(u32, @floor(div)) },
                    };

                    var right = try allocator.create(Node);
                    right.* = .{
                        .parent = node,
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

    fn toString(node: *Node, buffer: []u8) ![]const u8 {
        var alloc = std.heap.FixedBufferAllocator.init(buffer);
        var string = std.ArrayList(u8).init(alloc.allocator());
        try toStringRecursive(node, &string);
        return string.items;
    }

    fn toStringRecursive(node: *Node, string: *std.ArrayList(u8)) std.ArrayList(u8).Writer.Error!void {
        switch (node.value) {
            .number => |number| try string.writer().print("{}", .{ number }),
            .pair => |pair| {
                try string.writer().print("[", .{});
                try toStringRecursive(pair.left, string);
                try string.writer().print(",", .{});
                try toStringRecursive(pair.right, string);
                try string.writer().print("]", .{});
            },
        }
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

test "explode" {
    std.debug.print("\n", .{});
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var string_buffer: [1024 * 1024]u8 = undefined;
    defer alloc.deinit();
    allocator = alloc.allocator();

    const cases = [_]struct { input: []const u8, expected: []const u8 } {
        .{ .input = "[[[[[9,8],1],2],3],4]", .expected = "[[[[0,9],2],3],4]" },
        .{ .input = "[7,[6,[5,[4,[3,2]]]]]", .expected = "[7,[6,[5,[7,0]]]]" },
        .{ .input = "[[6,[5,[4,[3,2]]]],1]", .expected = "[[6,[5,[7,0]]],3]" },
        .{ .input = "[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]", .expected = "[[3,[2,[8,0]]],[9,[5,[7,0]]]]" },
    };

    for (cases) |case, i| {
        var root = try parseValue(case.input);
        try reduce(root);
        const result = try root.toString(string_buffer[0..]);
        std.debug.print("case {}: {s} -> {s}\n", .{ i, case.input, result });
        try std.testing.expectEqualStrings(case.expected, result);
    }
}

test "add" {
    std.debug.print("\n", .{});
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var string_buffer: [1024 * 1024]u8 = undefined;
    defer alloc.deinit();
    allocator = alloc.allocator();

    const cases = [_]struct { lhs: []const u8, rhs: []const u8, expected: []const u8 } {
        .{ // case 0
            .lhs = "[[[[4,3],4],4],[7,[[8,4],9]]]",
            .rhs = "[1,1]",
            .expected = "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]",
        },
        .{ // case 1
            .lhs = "[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]",
            .rhs = "[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]",
            .expected = "[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]",
        },
        .{ // case 2
            .lhs = "[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]",
            .rhs = "[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]",
            .expected = "[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]",
        },
        .{ // case 3
            .lhs = "[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]",
            .rhs = "[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]",
            .expected = "[[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]",
        }, // case 4
        .{
            .lhs = "[[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]",
            .rhs = "[7,[5,[[3,8],[1,4]]]]",
            .expected = "[[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]",
        },
        .{ // case 5
            .lhs = "[[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]",
            .rhs = "[[2,[2,2]],[8,[8,1]]]",
            .expected = "[[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]]",
        },
        .{ // case 6
            .lhs = "[[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]]",
            .rhs = "[2,9]",
            .expected = "[[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]]"
        },
        .{ // case 7
            .lhs = "[[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]]",
            .rhs = "[1,[[[9,3],9],[[9,0],[0,7]]]]",
            .expected = "[[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]]",
        },
        .{ // case 8
            .lhs = "[[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]]",
            .rhs = "[[[5,[7,4]],7],1]",
            .expected = "[[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]",
        },
        .{ // case 9
            .lhs = "[[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]",
            .rhs = "[[[[4,2],2],6],[8,7]]",
            .expected = "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]",
        },
    };

    for (cases) |case, i| {
        var lhs = try parseValue(case.lhs);
        var rhs = try parseValue(case.rhs);
        var root = try add(lhs, rhs);
        try reduce(root);
        const result = try root.toString(string_buffer[0..]);
        std.debug.print("case {}: {s} + {s} -> {s}\n", .{ i, case.lhs, case.rhs, result });
        try std.testing.expectEqualStrings(case.expected, result);
    }
}

test "addList" {
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var buffer: [1024 * 1024]u8 = undefined;
    defer alloc.deinit();
    allocator = alloc.allocator();
    const result = try addList(test_input);
    const expected = "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]";
    try std.testing.expectEqualStrings(expected, try result.toString(buffer[0..]));
}
