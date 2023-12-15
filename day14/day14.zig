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

fn flatten(input: *std.ArrayList(std.ArrayList(u8))) !std.ArrayList(u8) {
    var res = std.ArrayList(u8).init(allocator);
    for (input.items) |r| {
        for (r.items) |i| {
            try res.append(i);
        }
    }
    return res;
}

fn matrix_to_string(input: *std.ArrayList(std.ArrayList(u8))) ![]const u8 {
    const flattend = try flatten(input);
    var string_buffer: [10000]u8 = undefined;
    std.mem.copy(u8, string_buffer[0..10000], flattend.items);
    return string_buffer[0..];
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

fn get_load(input: *std.ArrayList(std.ArrayList(u8))) usize {
    var total: usize = 0;
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
    return total;
}

fn one_cycle(input: *std.ArrayList(std.ArrayList(u8))) !void {
    var map = std.StringHashMap(usize).init(allocator); //AutoHashMap -> HashMap -> LSP-Crash!
    var total: usize = 0;
    var counter: usize = 1000000000;
    var key: []const u8 = undefined;
    while (counter > 0) {
        key = try matrix_to_string(input);
        key = key[0 .. input.items.len * input.getLast().items.len];
        if (map.contains(key)) {
            break;
        }
        map.put(key, counter) catch |e| {
            std.debug.print("{}", .{e});
        };
        try to_north(input);
        try to_west(input);
        try to_south(input);
        try to_east(input);
        counter -= 1;
    }
    const found_cycle = 1000000000 - counter;
    std.debug.print("{} {s}\n", .{ found_cycle, key });
    const first_appearence = 1000000000 - map.get(key).?;
    const cycle_size = found_cycle - first_appearence;
    const ans = 1000000000 - first_appearence % cycle_size;
    std.debug.print("{} {} {} {}\n", .{ found_cycle, first_appearence, cycle_size, ans });
    counter = 0;
    while (counter < ans) : (counter += 1) {
        key = try matrix_to_string(input);
        try map.put(key, counter);
        try to_north(input);
        try to_west(input);
        try to_south(input);
        try to_east(input);
    }
    total = get_load(input);
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
