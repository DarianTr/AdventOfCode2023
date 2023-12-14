const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

fn print(input: std.ArrayList(std.ArrayList(u8))) void {
    for (input.items) |r| {
        for (r.items) |i| {
            std.debug.print("{c}", .{i});
        }
        std.debug.print("\n", .{});
    }
}

fn to_east(input: *std.ArrayList(std.ArrayList(u8))) !void {
    for (0..input.getLast().items.len) |i| {
        var smallest_next_point: usize = input.items.len - 1;
        for (0..input.items.len) |j1| {
            const j = input.items.len - 1 - j1;
            if (input.items[i].items[j] == 'O') {
                input.items[i].items[j] = '.';
                input.items[i].items[smallest_next_point] = 'O';
                if (j != 0) smallest_next_point -= 1;
            }
            if (input.items[i].items[j] == '.') {
                input.items[i].items[j] = '.';
            }
            if (input.items[i].items[j] == '#') {
                smallest_next_point = @max(1, j) - 1;
                input.items[i].items[j] = '#';
            }
        }
    }
    // std.debug.print("\n", .{});
    // print(input.*);
}

fn to_west(input: *std.ArrayList(std.ArrayList(u8))) !void {
    for (0..input.getLast().items.len) |i| {
        var smallest_next_point: usize = 0;
        for (0..input.items.len) |j| {
            if (input.items[i].items[j] == 'O') {
                input.items[i].items[j] = '.';
                input.items[i].items[smallest_next_point] = 'O';
                smallest_next_point += 1;
            }
            if (input.items[i].items[j] == '.') {
                input.items[i].items[j] = '.';
            }
            if (input.items[i].items[j] == '#') {
                smallest_next_point = j + 1;
                input.items[i].items[j] = '#';
            }
        }
    }
    // std.debug.print("\n", .{});
    // print(input.*);
}

fn to_north(input: *std.ArrayList(std.ArrayList(u8))) !void { // std.ArrayList(std.ArrayList(u8))
    //std.debug.print("\n", .{});
    for (0..input.getLast().items.len) |i| {
        var smallest_next_point: usize = 0;
        for (0..input.items.len) |s| {
            if (input.items[s].items[i] == 'O') {
                input.items[s].items[i] = '.';
                input.items[smallest_next_point].items[i] = 'O';
                smallest_next_point += 1;
            }
            if (input.items[s].items[i] == '.') {
                input.items[s].items[i] = '.';
            }
            if (input.items[s].items[i] == '#') {
                smallest_next_point = s + 1;
                input.items[s].items[i] = '#';
            }
        }
    }
    // print(input.*);
}

fn to_south(input: *std.ArrayList(std.ArrayList(u8))) !void { // std.ArrayList(std.ArrayList(u8))
    //std.debug.print("\n", .{});
    for (0..input.getLast().items.len) |i| {
        var smallest_next_point: usize = input.items.len - 1;
        for (0..input.items.len) |s1| {
            const s = input.items.len - 1 - s1;
            if (input.items[s].items[i] == 'O') {
                input.items[s].items[i] = '.';
                input.items[smallest_next_point].items[i] = 'O';
                if (s != 0) smallest_next_point -= 1;
            }
            if (input.items[s].items[i] == '.') {
                input.items[s].items[i] = '.';
            }
            if (input.items[s].items[i] == '#') {
                smallest_next_point = @max(s, 1) - 1;
                input.items[s].items[i] = '#';
            }
        }
    }
    //print(input.*);
}

fn one_cycle(input: *std.ArrayList(std.ArrayList(u8))) !void {
    var map = std.AutoHashMap(*std.ArrayList(std.ArrayList(u8)), usize).init(allocator);
    var total: usize = 0;
    var counter: usize = 1000000000;
    while (counter > 0) {
        if (map.contains(input)) {
            break;
        }
        try map.put(input, counter);
        try to_north(input);
        try to_west(input);
        try to_south(input);
        try to_east(input);
        counter -= 1;
    }
    total = 0;
    for (0..input.getLast().items.len) |i| {
        var sum: usize = 0;
        var smallest_next_point: usize = input.items.len;
        for (0..input.items.len) |s| {
            if (input.items[s].items[i] == 'O') {
                sum += smallest_next_point;
                smallest_next_point = smallest_next_point - 1;
            }
            if (input.items[s].items[i] == '.') continue;
            if (input.items[s].items[i] == '#') {
                smallest_next_point = (input.items.len - s) - 1;
            }
        }
        total += sum;
    }
    print(input.*);
    std.debug.print("{}\n", .{total});
}

pub fn main() !void {
    const fileName = "test.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    var input = std.ArrayList(std.ArrayList(u8)).init(allocator);
    var it = std.mem.split(u8, read_buf, "\n");
    while (it.next()) |l| {
        var line = std.ArrayList(u8).init(allocator);
        for (l) |i| {
            try line.append(i);
        }
        try input.append(line);
    }
    // try to_north(&input);
    // try to_south(&input);
    // try to_west(&input);
    // try to_east(&input);
    try one_cycle(&input);
    // var total: usize = 0;
    // for (0..input.getLast().len) |i| {
    //     var sum: usize = 0;
    //     var smallest_next_point: usize = input.items.len;
    //     for (0..input.items.len) |s| {
    //         if (input.items[s][i] == 'O') {
    //             sum += smallest_next_point;
    //             smallest_next_point = smallest_next_point - 1;
    //         }
    //         if (input.items[s][i] == '.') continue;
    //         if (input.items[s][i] == '#') {
    //             smallest_next_point = (input.items.len - s) - 1;
    //         }
    //     }
    //     total += sum;
    // }
    // std.debug.print("{}\n", .{total});
}
