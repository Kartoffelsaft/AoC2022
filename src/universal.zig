const std = @import("std");

pub const Runtime = struct {
    alloc: std.mem.Allocator,
    input: std.fs.File.Reader,
    output: std.fs.File.Writer,
    err: std.fs.File.Writer,

    pub fn deinit(_: *@This()) void {
    }
};
