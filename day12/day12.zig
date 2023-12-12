const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

fn get_additional_size(line: []const u8, cur_idx: usize) usize {
    var idx = cur_idx;
    while (idx < line.len) : (idx += 1) {
        if (line[idx] != '#') {
            break;
        }
    }
    return idx - cur_idx;
}

fn get_count(line: []const u8, cur_idx: usize, record: std.ArrayList(usize), broken_count: usize) !usize {
    if (record.items.len == 0) {
        var idx_2 = cur_idx;
        while (idx_2 < line.len) : (idx_2 += 1) {
            if (line[idx_2] == '#') {
                return 0;
            }
        }
        return 1;
    }
    if (cur_idx >= line.len) {
        if (record.items.len == 1 and broken_count != 0 and record.items[0] == broken_count) {
            return 1;
        }
        return 0;
    }
    var res: usize = 0;
    var r = try record.clone();
    if (line[cur_idx] == '#') {
        res += try get_count(line, cur_idx + 1, r, broken_count + 1);
    }
    if (line[cur_idx] == '.') {
        if (broken_count == 0) {
            res += try get_count(line, cur_idx + 1, r, 0);
        } else {
            if (broken_count == r.items[0]) {
                _ = r.orderedRemove(0);
                res += try get_count(line, cur_idx + 1, r, 0);
            } else {
                return 0;
            }
        }
    }
    if (line[cur_idx] == '?') {
        const add_size = @max(1, get_additional_size(line, cur_idx));
        if (r.items[0] >= broken_count + add_size) res += try get_count(line, cur_idx + add_size, r, broken_count + add_size);
        if (broken_count == 0) {
            res += try get_count(line, cur_idx + 1, r, 0);
        } else {
            if (broken_count == r.items[0]) {
                _ = r.orderedRemove(0);
                res += try get_count(line, cur_idx + 1, r, 0);
            }
        }
    }
    return res;
}

pub fn main() !void {
    const fileName = "test.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    var it_line = std.mem.split(u8, read_buf, "\n");
    var total: usize = 0;
    while (it_line.next()) |line| {
        var it_2 = std.mem.split(u8, line, " ");
        const content = it_2.next().?;
        var content_2: [10000]u8 = undefined;
        for (0..5) |i| {
            std.mem.copy(u8, content_2[i * (content.len + 1) .. (i + 1) * (content.len + 1)], content);
            content_2[i * (content.len + 1) + content.len] = '?';
        }
        var nums = std.ArrayList(usize).init(allocator);
        const nums_as_string = it_2.next().?;
        var it_3 = std.mem.split(u8, nums_as_string, ",");
        while (it_3.next()) |n_as_string| {
            try nums.append(try std.fmt.parseInt(usize, n_as_string, 10));
        }
        var new_nums = std.ArrayList(usize).init(allocator);
        for (0..5) |_| {
            try new_nums.appendSlice(nums.items);
        }
        const val = try get_count(content_2[0 .. content.len * 5 + 5], 0, new_nums, 0);
        std.debug.print("{}\n", .{val});
        total += val;
    }
    std.debug.print("{}\n", .{total});
}
