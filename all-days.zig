const std = @import("std");

const day_1 = @import("day-1.zig");
const day_2 = @import("day-2.zig");
const day_3 = @import("day-3.zig");
const day_4 = @import("day-4.zig");
const day_5 = @import("day-5.zig");

pub fn main() !void {
    try day_1.main();
    std.debug.print("\n", .{});
    try day_2.main();
    std.debug.print("\n", .{});
    try day_3.main();
    std.debug.print("\n", .{});
    try day_4.main();
    std.debug.print("\n", .{});
    try day_5.main();
}
