const std = @import("std");
const math = std.math;

pub fn update(first: *u32, last: *u32, got_first: *bool, number: u32) void {
    if (number >= 0 and number <= 9) {
        if (!got_first.*) {
            first.* = number;
            got_first.* = true;
        }
        last.* = number;
    }
}

pub fn main() !void {
    const B: u64 = 972663749;
    _ = B;
    const fileName = "second.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(read_buf);
    defer file.close();

    var total: u32 = 0;
    var it = std.mem.split(u8, read_buf, "\n");
    while (it.next()) |line| {
        var first: u32 = 0;
        var last: u32 = 0;
        var got_first: bool = false;
        for (0..line.len) |idx| {
            const number: u8 = line[idx];
            update(&first, &last, &got_first, number - 48);
            if (idx + 2 < line.len) {
                if (line[idx] == 'o' and line[idx + 1] == 'n' and line[idx + 2] == 'e') {
                    update(&first, &last, &got_first, 1);
                } else if (line[idx] == 't') {
                    if (line[idx + 1] == 'w' and line[idx + 2] == 'o') {
                        update(&first, &last, &got_first, 2);
                    } else if (idx + 4 < line.len and line[idx + 1] == 'h' and line[idx + 2] == 'r' and line[idx + 3] == 'e' and line[idx + 3] == 'e') {
                        update(&first, &last, &got_first, 3);
                    }
                } else if (line[idx] == 'f') {
                    if (idx + 3 < line.len) {
                        if (idx + 3 < line.len and line[idx + 1] == 'o' and line[idx + 2] == 'u' and line[idx + 3] == 'r') {
                            update(&first, &last, &got_first, 4);
                        } else if (line[idx + 1] == 'i' and line[idx + 2] == 'v' and line[idx + 3] == 'e') {
                            update(&first, &last, &got_first, 5);
                        }
                    }
                } else if (line[idx] == 's') {
                    if (line[idx + 1] == 'i' and line[idx + 2] == 'x') {
                        update(&first, &last, &got_first, 6);
                    } else if (idx + 4 < line.len and line[idx + 1] == 'e' and line[idx + 2] == 'v' and line[idx + 3] == 'e' and line[idx + 4] == 'n') {
                        update(&first, &last, &got_first, 7);
                    }
                } else if (idx + 4 < line.len and line[idx] == 'e' and line[idx + 1] == 'i' and line[idx + 2] == 'g' and line[idx + 3] == 'h' and line[idx + 4] == 't') {
                    update(&first, &last, &got_first, 8);
                } else if (idx + 3 < line.len and line[idx] == 'n' and line[idx + 1] == 'i' and line[idx + 2] == 'n' and line[idx + 3] == 'e') {
                    update(&first, &last, &got_first, 9);
                }
            }
        }
        std.debug.print("{} {}\n", .{ first, last });
        total += 10 * first + last;
    }
    std.debug.print("{}\n", .{total});
}
