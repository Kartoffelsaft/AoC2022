const std = @import("std");
const RT = @import("./universal.zig").Runtime;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leak = gpa.deinit();
        if(leak) _ = std.io.getStdErr().writer().write("WARNING: LEAK\n") catch 0;
    }
    const alloc = gpa.allocator();

    // Command line arguments, skipping the executable name
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

    const inpF = std.fs.cwd().openFile(
        inputFileName.items,
        .{.read = true}
    ) catch {
        std.log.err(
            "Attempted input file name appears to be wrong: `{s}` It might be missing or misspelled", 
            .{inputFileName.items}
        );
        return;
    };
    defer inpF.close();

    var runtime = RT{
        .alloc = gpa.allocator(),
        .input = inpF.reader(),
        .output = std.io.getStdOut().writer(),
        .err = std.io.getStdErr().writer(),
    };
    defer runtime.deinit();

    // Figure out which function to call based on command line argument.
    // Could probably be a macro but I'm lazy
    try std.ComptimeStringMap(fn (RT) anyerror!void, .{
        .{ "1", @import("./day1.zig").solution },
        .{ "2", @import("./day2.zig").solution },
        .{ "3", @import("./day3.zig").solution },
    }).get(whichDay).?(runtime);
}

