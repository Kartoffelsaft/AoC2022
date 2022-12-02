const std = @import("std");
const RT = @import("./universal.zig").Runtime;

// Used for sorting
fn lt(c: void, l: i32, r: i32) bool {
    _ = c;
    return l < r;
}

pub fn solution(rt: RT) !void {
    // List of the total calorie counts of each elf
    var totals = std.ArrayList(i32).init(rt.alloc);
    defer totals.deinit();
    try totals.append(0);

    while (try rt
        .input
        .readUntilDelimiterOrEofAlloc(
            rt.alloc, 
            '\n', 
            std.math.maxInt(usize)
        )
    ) |line| {
        defer rt.alloc.free(line);

        if (line.len == 0) { try totals.append(0); } // empty line, new elf
        else {
            totals.items[totals.items.len - 1] += try std.fmt.parseInt(i32, line, 10);
        }
    }

    std.sort.sort(i32, totals.items, {}, lt);

    // numbers needed for answer will be printed towards the bottom
    for (totals.items) |calCount| {
        try rt.output.print("{d}\n", .{calCount});
    }
}
