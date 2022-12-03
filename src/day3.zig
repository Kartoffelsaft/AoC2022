const std = @import("std");
const RT = @import("./universal.zig").Runtime;

fn Set(comptime T: type) type { return std.hash_map.AutoHashMap(T, void); }

fn setFromSlice(rt: RT, what: []u8) !Set(u8) {
    var ret = Set(u8).init(rt.alloc);

    for (what) |val| { try ret.put(val, {}); }

    return ret;
}

pub fn solution(rt: RT) anyerror!void {
    var totalPriority: i32 = 0;

    while (try rt.input
        .readUntilDelimiterOrEofAlloc(rt.alloc, '\n', std.math.maxInt(usize))
    ) |line| {
        defer rt.alloc.free(line);

        var sectionASet = try setFromSlice(rt, line[0 .. line.len/2]);
        var sectionBSet = try setFromSlice(rt, line[line.len/2 .. line.len]);
        defer sectionASet.deinit();
        defer sectionBSet.deinit();

        var common: u8 = 0;
        var iterA = sectionASet.keyIterator();
        while (iterA.next()) |c| {
            if (sectionBSet.contains(c.*)) {
                common = c.*;
                break;
            }
        }
        if (common == 0) {
            try rt.err.print("Nothing common found in line {s}\n", .{line}); 
            return;
        }

        try rt.output.print("{s}: {c}\n", .{line, common});

        if (common >= 'a' and common <= 'z') { common -= ('a' - 1); }
        else if (common >= 'A' and common <= 'Z') { common -= ('A' - 27); }

        totalPriority += common;
    }

    try rt.output.print("Total: {d}\n", .{totalPriority});
}
