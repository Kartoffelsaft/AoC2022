const std = @import("std");
const RT = @import("./universal.zig").Runtime;

const StackMoveCommand = struct {
    amount: usize,
    from: usize,
    to: usize,
};

pub fn solution(rt: RT) anyerror!void {
    var stacks = try getStacks(rt);
    defer { 
        for (stacks) |stack| {
            stack.deinit();
        } 
        rt.alloc.free(stacks); 
    }

    try rt.input.skipUntilDelimiterOrEof('\n');

    while (try getStackCommand(rt)) |cmd| {
        var fromStack = &stacks[cmd.from - 1];
        var toStack = &stacks[cmd.to - 1];

        try rt.output.print("{d}x {d} -> {d}\n", .{cmd.amount, cmd.from, cmd.to});
        for (stacks) |stk| {
            try rt.output.print("]{s}\n", .{stk.items});
        }
        try rt.output.writeByte('\n');

        try toStack.*.appendSlice(fromStack.*.items[fromStack.*.items.len - cmd.amount ..]);
        try fromStack.*.resize(fromStack.*.items.len - cmd.amount);
    }

    for (stacks) |stk| {
        try rt.output.print("{s}\n", .{stk.items});
    }
}

pub fn solutionP1(rt: RT) anyerror!void {
    var stacks = try getStacks(rt);
    defer { 
        for (stacks) |stack| {
            stack.deinit();
        } 
        rt.alloc.free(stacks); 
    }

    try rt.input.skipUntilDelimiterOrEof('\n');

    while (try getStackCommand(rt)) |cmd| {
        var amountMoved: usize = 0;
        while (amountMoved < cmd.amount) {
            try stacks[cmd.to - 1].append(stacks[cmd.from - 1].pop());
            amountMoved += 1;
        }
    }

    for (stacks) |stk| {
        try rt.output.print("{s}\n", .{stk.items});
    }
}

fn getStacks(rt: RT) anyerror![]std.ArrayList(u8) {
    var cratesDescription = std.ArrayList([]u8).init(rt.alloc);
    defer {
        for (cratesDescription.items) |descLine| {
            rt.alloc.free(descLine);
        }
        cratesDescription.deinit();
    }

    var stackCount: isize = -1;

    while (true) { 
        const nextDesc = try rt.input.readUntilDelimiterAlloc(
            rt.alloc, 
            '\n', 
            std.math.maxInt(usize)
        ); 

        if (nextDesc[0] != '[') {
            stackCount = @intCast(isize, (nextDesc.len + 1) / 4);
            rt.alloc.free(nextDesc);
            break;
        } else {
            try cratesDescription.append(nextDesc);
        }
    }

    var stacks = try rt.alloc.alloc(std.ArrayList(u8), @intCast(usize, stackCount));
    for (stacks) |*stack| {
        stack.* = std.ArrayList(u8).init(rt.alloc);
    } 

    for (cratesDescription.items) |_, i| {
        const layer = cratesDescription.items[cratesDescription.items.len - i - 1];

        for (stacks) |*stk, j| {
            const val = layer[4 * j + 1];
            if (val == ' ') continue;

            try stk.*.append(val);
        }
    }

    return stacks;
}

fn getStackCommand(rt: RT) anyerror!?StackMoveCommand {
    rt.input.skipBytes("move ".len, .{})
        catch |err| if (err == error.EndOfStream) { return null; } else { return err; };

    const amountStr = try rt.input.readUntilDelimiterAlloc(rt.alloc, ' ', std.math.maxInt(usize));
    defer rt.alloc.free(amountStr);

    try rt.input.skipBytes("from ".len, .{});

    const fromStr = try rt.input.readUntilDelimiterAlloc(rt.alloc, ' ', std.math.maxInt(usize));
    defer rt.alloc.free(fromStr);

    try rt.input.skipBytes("to ".len, .{});

    const toStr = rt.input.readUntilDelimiterAlloc(rt.alloc, '\n', std.math.maxInt(usize))
        catch |err| if (err == error.EndOfStream) { return null; } else { return err; };
    defer rt.alloc.free(toStr);

    return StackMoveCommand{
        .amount = try std.fmt.parseInt(usize, amountStr, 10),
        .from = try std.fmt.parseInt(usize, fromStr, 10),
        .to = try std.fmt.parseInt(usize, toStr, 10),
    };
}
