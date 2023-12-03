const std = @import("std");

const Number = struct {
    value: usize,
    line: usize,
    begin: usize,
    end: usize,
};

fn check_number(input_arr: std.ArrayList([]const u8), number: Number) bool {
    for (@max(1, number.begin) - 1..@min(number.end + 2, input_arr.getLast().len)) |inner_idx| {
        if (number.line > 0) {
            const char = input_arr.items[number.line - 1][inner_idx];
            if (char != '.') return true;
        }
        if (number.line + 1 < input_arr.items.len) {
            const char = input_arr.items[number.line + 1][inner_idx];
            if (char != '.') return true;
        }
    }
    for (@max(1, number.line) - 1..@min(input_arr.items.len, number.line + 2)) |line_idx| {
        if (number.begin > 0) {
            const char = input_arr.items[line_idx][number.begin - 1];
            if (char != '.') return true;
        }
        if (number.end + 1 < input_arr.items.len) {
            const char = input_arr.items[line_idx][number.end + 1];
            if (char != '.') return true;
        }
    }
    return false;
}

pub fn main() !void {
    const fileName = "first.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    var input_arr = std.ArrayList([]const u8).init(allocator);
    var list_of_numbers = std.ArrayList(Number).init(allocator);
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
    for (list_of_numbers.items) |number| {
        if (check_number(input_arr, number)) {
            total += number.value;
            continue;
        }
    }
    std.debug.print("{}\n", .{total});
}
