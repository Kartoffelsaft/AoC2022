const std = @import("std");
const RT = @import("./universal.zig").Runtime;

const RPS = enum {
    Rock,
    Paper,
    Scissors,
};

const Outcome = enum {
    Lose,
    Draw,
    Win,
};

fn getScoreP1(opponent: RPS, response: RPS) i32 {
    return switch (opponent) {
        RPS.Rock => @as(i32, switch (response) {
            RPS.Rock     => 4,
            RPS.Paper    => 8,
            RPS.Scissors => 3,
        }),
        RPS.Paper => @as(i32, switch (response) {
            RPS.Rock     => 1,
            RPS.Paper    => 5,
            RPS.Scissors => 9,
        }),
        RPS.Scissors => @as(i32, switch (response) {
            RPS.Rock     => 7,
            RPS.Paper    => 2,
            RPS.Scissors => 6,
        }),
    };
}

fn getScoreP2(opponent: RPS, response: Outcome) i32 {
    return switch (opponent) {
        RPS.Rock => @as(i32, switch (response) {
            Outcome.Lose => 3,
            Outcome.Draw => 4,
            Outcome.Win  => 8,
        }),
        RPS.Paper => @as(i32, switch (response) {
            Outcome.Lose => 1,
            Outcome.Draw => 5,
            Outcome.Win  => 9,
        }),
        RPS.Scissors => @as(i32, switch (response) {
            Outcome.Lose => 2,
            Outcome.Draw => 6,
            Outcome.Win  => 7,
        }),
    };
}

pub fn solution(rt: RT) anyerror!void {
    const opponentMap = std.ComptimeStringMap(RPS, .{
        .{"A", RPS.Rock},
        .{"B", RPS.Paper},
        .{"C", RPS.Scissors},
    });
    const responseMap = std.ComptimeStringMap(RPS, .{
        .{"X", RPS.Rock},
        .{"Y", RPS.Paper},
        .{"Z", RPS.Scissors},
    });
    const outcomeMap = std.ComptimeStringMap(Outcome, .{
        .{"X", Outcome.Lose},
        .{"Y", Outcome.Draw},
        .{"Z", Outcome.Win},
    });

    var totalScore1: i32 = 0;
    var totalScore2: i32 = 0;

    var line = [4]u8{0, 0, 0, 0}; // all lines are 4 bytes

    while (4 == rt.input.read(line[0..]) catch {
        _ = try rt.err.write("Read Error"); 
        return;
    }) {
        const opponentMove = opponentMap.get(line[0..1]) 
            orelse {try rt.err.print("Line `{s}` is not valid (opp)\n", .{line}); return;};
        const responseMove = responseMap.get(line[2..3])
            orelse {try rt.err.print("Line `{s}` is not valid (res)\n", .{line}); return;};
        const outcomeMove = outcomeMap.get(line[2..3])
            orelse {try rt.err.print("Line `{s}` is not valid (out)\n", .{line}); return;};

        totalScore1 += getScoreP1(opponentMove, responseMove);
        totalScore2 += getScoreP2(opponentMove, outcomeMove);
    }

    try rt.output.print(
        "Total score (p1): {d}\nTotal score (p2): {d}\n", 
        .{totalScore1, totalScore2}
    );
}

test "Rock vs Scissors" {
    try std.testing.expectEqual(@as(i32, 3), getScoreP1(RPS.Rock, RPS.Scissors));
}
