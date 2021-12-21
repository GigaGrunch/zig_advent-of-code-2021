const std = @import("std");

const day_1 = @import("day-1.zig");
const day_2 = @import("day-2.zig");
const day_3 = @import("day-3.zig");
const day_4 = @import("day-4.zig");
const day_5 = @import("day-5.zig");
const day_6 = @import("day-6.zig");
const day_7 = @import("day-7.zig");
const day_8 = @import("day-8.zig");
const day_9 = @import("day-9.zig");
const day_10 = @import("day-10.zig");

pub fn main() !void {
    try run(day_1);
    try run(day_2);
    try run(day_3);
    try run(day_4);
    try run(day_5);
    try run(day_6);
    try run(day_7);
    try run(day_8);
    try run(day_9);
    try run(day_10);
}

fn run(day: anytype) !void {
    try day.main();
    std.debug.print("\n", .{});
}
