const std = @import("std");
const RT = @import("./universal.zig").Runtime;

pub fn solution(rt: RT) anyerror!void {
    var totalPriority: i32 = 0;

    while (try rt.input
        .readUntilDelimiterOrEofAlloc(rt.alloc, '\n', std.math.maxInt(usize))
    ) |line| {
        defer rt.alloc.free(line);

        var sectionASet = std.hash_map.AutoHashMap(u8, void).init(rt.alloc);
        var sectionBSet = std.hash_map.AutoHashMap(u8, void).init(rt.alloc);
        defer sectionASet.deinit();
        defer sectionBSet.deinit();

        for (line[0 .. line.len/2]) |item| {
            try sectionASet.put(item, {});
        }
        for (line[line.len/2 .. line.len]) |item| {
            try sectionBSet.put(item, {});
        }

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
