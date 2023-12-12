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
    const fileName = "puzzle.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    var it_line = std.mem.split(u8, read_buf, "\n");
    var total: usize = 0;
    while (it_line.next()) |line| {
        var it_2 = std.mem.split(u8, line, " ");
        const content = it_2.next().?;
        var nums = std.ArrayList(usize).init(allocator);
        const nums_as_string = it_2.next().?;
        var it_3 = std.mem.split(u8, nums_as_string, ",");
        while (it_3.next()) |n_as_string| {
            try nums.append(try std.fmt.parseInt(usize, n_as_string, 10));
        }
        total += try get_count(content, 0, nums, 0);
    }
    std.debug.print("{}\n", .{total});
}

// fn fits(line: []const u8, cur_idx: usize, size: usize) bool {
//     var idx = cur_idx;
//     while (idx < cur_idx + size and idx < line.len) : (idx += 1) {
//         if (line[idx] == '.') {
//             return false;
//         }
//     }
//     if (idx != line.len and line[idx] == '#') {
//         return false;
//     }
//     return true;
// }

// fn rec(line: []const u8, cur_idx: usize, record: std.ArrayList(usize), broken_count: usize) !usize {
//     if (record.items.len == 0) {
//         var idx_2 = cur_idx;
//         while (idx_2 < line.len) : (idx_2 += 1) {
//             if (line[idx_2] == '#') {
//                 return 0;
//             }
//         }
//         return 1;
//     }
//     if (cur_idx >= line.len) {
//         if (record.items.len == 1 and broken_count != 0 and record.items[0] == broken_count) {
//             return 1;
//         }
//         return 0;
//     }
//     var res: usize = 0;
//     var r = try record.clone();
//     if (line[cur_idx] == '#') {
//         res += try rec(line, cur_idx + 1, r, broken_count + 1);
//         if (broken_count == 0) {
//             if (fits(line, cur_idx, r.items[0])) {
//                 const idx = cur_idx + r.items[0];
//                 _ = r.orderedRemove(0);
//                 if (line.len > idx and line[idx] == '?') {
//                     res += try rec(line, idx + 1, r, 0); //without 3 6 0 1 4 10 with 1 4 0 1 4 1
//                 } else {
//                     res += try rec(line, idx, r, 0); // need more checks: what if broken_count != 0 Maybe add case so that groups can also start at # instead of only ?
//                 }
//             } // now too muchx
//         }
//     } else if (line[cur_idx] == '.') {
//         if (broken_count != 0 and broken_count != r.items[0]) {
//             return 0;
//         } else if (broken_count != 0) {
//             _ = r.orderedRemove(0);
//         }
//         return try rec(line, cur_idx + 1, r, 0);
//     } else {
//         var fit: bool = fits(line, cur_idx, r.items[0]);
//         const idx = cur_idx + r.items[0];
//         res += try rec(line, cur_idx + 1, r, 0);
//         if (fit) {
//             _ = r.orderedRemove(0);
//             if (line.len > idx and line[idx] == '?') {
//                 res += try rec(line, idx + 1, r, 0); //without 3 6 0 1 4 10 with 1 4 0 1 4 1
//             } else {
//                 res += try rec(line, idx, r, 0); // need more checks: what if broken_count != 0 Maybe add case so that groups can also start at # instead of only ?
//             }
//         }
//     }
//     return res;
// }
