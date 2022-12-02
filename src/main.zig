const std = @import("std");
const RT = @import("./universal.zig").Runtime;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leak = gpa.deinit();
        if(leak) _ = std.io.getStdErr().writer().write("WARNING: LEAK\n") catch 0;
    }
    const alloc = gpa.allocator();

    var argIt = std.process.args();
    const exeName = argIt.next(alloc);
    if (exeName != null) alloc.free(try exeName.?);

    // Arena Allocator is needed because sometimes whichDay is heap and sometimes
    // it is static
    var whichDayArenaAlloc = std.heap.ArenaAllocator.init(alloc);
    const whichDay = argIt.next(whichDayArenaAlloc.allocator()) orelse "1" catch "1";
    defer whichDayArenaAlloc.deinit();

    var inputFileName = std.ArrayList(u8).init(alloc);
    defer inputFileName.deinit();
    try std.fmt.format(inputFileName.writer(), "day{s}Input", .{whichDay});

    const inpF = try std.fs.cwd().openFile(
        inputFileName.items,
        .{.read = true}
    );
    defer inpF.close();

    const runtime = RT{
        .alloc = gpa.allocator(),
        .input = inpF.reader(),
        .output = std.io.getStdOut().writer(),
        .err = std.io.getStdErr().writer(),
    };

    try std.ComptimeStringMap(fn (RT) anyerror!void, .{
        .{ "1", @import("./day1.zig").solution },
    }).get(whichDay).?(runtime);
}

