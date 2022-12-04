const std = @import("std");
const RT = @import("./universal.zig").Runtime;

fn readInt(rt: RT, delim: u8) !?i32 {
    var str = (try rt.input.readUntilDelimiterOrEofAlloc(
        rt.alloc, 
        delim, 
        std.math.maxInt(usize)
    )) orelse return null;
    defer rt.alloc.free(str);

    return try std.fmt.parseInt(i32, str, 10);
}

pub fn solution(rt: RT) anyerror!void {
    var overlapCount: i32 = 0;

    while (true) {
        const rangeAStart = (try readInt(rt, '-' )) orelse break;
        const rangeAEnd   = (try readInt(rt, ',' )) orelse break;
        const rangeBStart = (try readInt(rt, '-' )) orelse break;
        const rangeBEnd   = (try readInt(rt, '\n')) orelse break;

        if ((rangeAEnd >= rangeBStart and rangeBEnd >= rangeAStart)
        or  (rangeBEnd >= rangeAStart and rangeAEnd >= rangeBStart)) {
            overlapCount += 1;
        }
    }

    try rt.output.print("number of overlaps: {d}\n", .{overlapCount});
}
