const std = @import("std");

const HandType = enum(u4) {
    five_of_a_kind,
    four_of_a_kind,
    full_house,
    three_of_a_kind,
    two_pair,
    one_pair,
    high_card,
};

const Hand = struct {
    cards: []const u8,
    bid: usize,
    hand_type: HandType,
};

fn cmp(context: void, a: Hand, b: Hand) bool {
    _ = context;
    if (@intFromEnum(a.hand_type) > @intFromEnum(b.hand_type)) return true;
    if (a.hand_type == b.hand_type) {
        for (0..a.cards.len) |i| {
            if (a.cards[i] != b.cards[i]) return a.cards[i] < b.cards[i]; //Watch out letters
        }
    }
    return false;
}

fn get_hand_type(cards: []const u8) !HandType {
    var arr = [_]usize{0} ** 13;

    for (cards) |card| {
        arr[card - '2'] += 1;
    }

    var max_1: usize = 0;
    var max_2: usize = 0;
    var max_3: usize = 0;

    for (arr) |count| {
        if (count >= max_1) {
            max_3 = max_2;
            max_2 = max_1;
            max_1 = count;
        } else if (count >= max_2) {
            max_3 = max_2;
            max_2 = count;
        } else if (count >= max_1) {
            max_3 = count;
        }
    }
    if (max_1 == 5) return HandType.five_of_a_kind;
    if (max_1 == 4) return HandType.four_of_a_kind;
    if (max_1 == 3 and max_2 == 2) return HandType.full_house;
    if (max_1 == 3) return HandType.three_of_a_kind;
    if (max_1 == 2 and max_2 == 2) return HandType.two_pair;
    if (max_1 == 2) return HandType.one_pair;
    return HandType.high_card;
}

pub fn main() !void {
    const fileName = "first.txt";
    const file = try std.fs.cwd().openFile(fileName, .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(read_buf);
    defer file.close();
    var hand_arr = std.ArrayList(Hand).init(allocator);
    defer allocator.destroy(&hand_arr);

    var hands = std.mem.split(u8, read_buf, "\n");
    while (hands.next()) |h| {
        var tokenized = std.mem.tokenizeAny(u8, h, " ");
        const cards = tokenized.next().?;
        const output = try allocator.dupe(u8, cards);
        std.mem.replaceScalar(u8, output, 'T', '9' + 1);
        std.mem.replaceScalar(u8, output, 'J', '9' + 2);
        std.mem.replaceScalar(u8, output, 'Q', '9' + 3);
        std.mem.replaceScalar(u8, output, 'K', '9' + 4);
        std.mem.replaceScalar(u8, output, 'A', '9' + 5);
        const bid = try std.fmt.parseInt(usize, tokenized.next().?, 10);
        const hand_type = try get_hand_type(output);
        try hand_arr.append(Hand{ .cards = output, .bid = bid, .hand_type = hand_type });
    }

    std.mem.sort(Hand, hand_arr.items, {}, cmp);
    var total: usize = 0;
    for (hand_arr.items, 1..) |hand, i| {
        total += hand.bid * i;
        //std.debug.print("{} {}\n", .{ hand.bid, i });
    }
    std.debug.print("{}\n", .{total});
}
