const std = @import("std");

const Number = struct {
    value: usize,
    line: usize,
    begin: usize,
    end: usize,
};

const Gear = struct {
    row: usize,
    column: usize,
};

fn are_adjacent(number: Number, gear: Gear) bool {
    if (@abs(@as(i128, number.line) - @as(i128, gear.row)) <= 1) {
        if (@max(1, number.begin) - 1 <= gear.column and number.end + 1 >= gear.column) return true;
    }
    return false;
}

pub fn main() !void {
    const fileName = "second.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    var input_arr = std.ArrayList([]const u8).init(allocator);
    var list_of_numbers = std.ArrayList(Number).init(allocator);
    var list_of_gears = std.ArrayList(Gear).init(allocator);
    defer allocator.free(read_buf);
    // defer allocator.free(input_arr);
    // defer allocator.free(list_of_numbers);
    defer file.close();
    var it = std.mem.split(u8, read_buf, "\n");
    var line_idx: usize = 0;
    while (it.next()) |line| : (line_idx += 1) {
        try input_arr.append(line);
        var flag: u1 = 0;
        var value: usize = 0;
        var begin: usize = 0;
        var end: usize = 0;
        for (line, 0..) |char, idx| {
            if (char == '*') try list_of_gears.append(Gear{ .row = line_idx, .column = idx });
            if (char <= '9' and char >= '0') {
                if (flag == 0) begin = idx;
                flag = 1;
                value *= 10;
                value += char - '0';
                end = idx;
            } else if (flag == 1) {
                try list_of_numbers.append(Number{ .value = value, .line = line_idx, .begin = begin, .end = end });
                flag = 0;
                value = 0;
                begin = 0;
                end = 0;
            }
        }
        if (flag == 1) try list_of_numbers.append(Number{ .value = value, .line = line_idx, .begin = begin, .end = end });
    }
    var total: usize = 0;

    gears: for (list_of_gears.items) |gear| {
        var found_1 = false;
        var found_2 = false;
        var first: usize = 0;
        var second: usize = 0;
        for (list_of_numbers.items) |number| {
            if (are_adjacent(number, gear)) {
                if (!found_1) {
                    found_1 = true;
                    first = number.value;
                } else if (!found_2) {
                    found_2 = true;
                    second = number.value;
                } else {
                    continue :gears;
                }
            }
        }
        if (found_1 and found_2) {
            total += first * second;
        }
    }
    std.debug.print("{}\n", .{total});
}
