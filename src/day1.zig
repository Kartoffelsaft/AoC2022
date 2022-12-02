const std = @import("std");
const RT = @import("./universal.zig").Runtime;

fn lt(c: void, l: i32, r: i32) bool {
    _ = c;
    return l < r;
}

pub fn solution(rt: RT) !void {
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

        if (line.len == 0) { try totals.append(0); }
        else {
            totals.items[totals.items.len - 1] += try std.fmt.parseInt(i32, line, 10);
        }
    }

    std.sort.sort(i32, totals.items, {}, lt);

    for (totals.items) |calCount| {
        try rt.output.print("{d}\n", .{calCount});
    }
}
