const std = @import("std");
const RT = @import("./universal.zig").Runtime;

fn Set(comptime T: type) type { return std.hash_map.AutoHashMap(T, void); }

fn setFromSlice(rt: RT, what: []u8) !Set(u8) {
    var ret = Set(u8).init(rt.alloc);

    for (what) |val| { try ret.put(val, {}); }

    return ret;
}

fn getPriority(symbol: u8) u8 {
    return switch (symbol) {
        'a' ... 'z' => symbol - 'a' + 1,
        'A' ... 'Z' => symbol - 'A' + 27,
        else => 255,
    };
}

pub fn solution(rt: RT) anyerror!void {
    var totalPriority: i32 = 0;

    while (true) {
        var elves = [3][]u8{
            (try rt.input.readUntilDelimiterOrEofAlloc(rt.alloc, '\n', std.math.maxInt(usize))) orelse break,
            (try rt.input.readUntilDelimiterOrEofAlloc(rt.alloc, '\n', std.math.maxInt(usize))) orelse break,
            (try rt.input.readUntilDelimiterOrEofAlloc(rt.alloc, '\n', std.math.maxInt(usize))) orelse break,
        };
        defer { for (elves) |elf| { rt.alloc.free(elf); } }

        var inventories = [3]Set(u8){
            try setFromSlice(rt, elves[0]),
            try setFromSlice(rt, elves[1]),
            try setFromSlice(rt, elves[2]),
        };
        defer { for (inventories) |_, invI| { inventories[invI].deinit(); } }

        var common: u8 = 0;
        var iter = inventories[0].keyIterator();

        while (iter.next()) |item| {
            if (inventories[1].contains(item.*) and inventories[2].contains(item.*)) {
                common = item.*;
                break;
            }
        }
        if (common == 0) {
            try rt.err.print("No common item found between {s}, {s}, {s}\n",
                .{elves[0], elves[1], elves[2]}
            );
            return;
        }

        totalPriority += getPriority(common);
    }

    try rt.output.print("total priority: {d}\n", .{totalPriority});
}

pub fn solutionP1(rt: RT) anyerror!void {
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

        totalPriority += getPriority(common);
    }

    try rt.output.print("Total: {d}\n", .{totalPriority});
}
