extends TestSuite

const Inf = ItemCount.Inf


func init_suite():
    tests = [
        "test_init",
        "test_add",
        "test_mul",
        "test_div",
        "test_eq",
        "test_less",
        "test_gt",
        "test_min",
    ]


func test_init() -> void:
    var test_data := [
        {input = 10, expected = {count = 10, inf = false}},
        {input = Inf, expected = {count = Inf, inf = true}},
        {input = -1, expected = {count = Inf, inf = true}},
    ]

    for data in test_data:
        var count = ItemCount.new(data.input)
        assert(count.count == data.expected.count)
        assert(count.is_inf() == data.expected.inf)


func test_add() -> void:
    var test_data := [
        {input = {left = 10, right = 10}, expected = {count = 20, inf = false}},
        {input = {left = 10, right = Inf}, expected = {count = Inf, inf = true}},
        {input = {left = Inf, right = 10}, expected = {count = Inf, inf = true}},
        {input = {left = Inf, right = Inf}, expected = {count = Inf, inf = true}},
    ]

    for data in test_data:
        var count = ItemCount.new(data.input.left)
        var count2 = ItemCount.new(data.input.right)
        count.add(count2)
        assert(count.count == data.expected.count)
        assert(count.is_inf() == data.expected.inf)


func test_mul() -> void:
    var test_data := [
        {input = {left = 10, right = 20}, expected = {count = 200, inf = false}},
        {input = {left = 0, right = 10}, expected = {count = 0, inf = false}},
        {input = {left = 10, right = 0}, expected = {count = 0, inf = false}},
        {input = {left = 0, right = 0}, expected = {count = 0, inf = false}},
        {input = {left = Inf, right = 10}, expected = {count = Inf, inf = true}},
        {input = {left = Inf, right = 0}, expected = {count = 0, inf = false}},
        {input = {left = 10, right = Inf}, expected = {count = Inf, inf = true}},
        {input = {left = 0, right = Inf}, expected = {count = 0, inf = false}},
        {input = {left = Inf, right = Inf}, expected = {count = Inf, inf = true}},
    ]

    for data in test_data:
        var count = ItemCount.new(data.input.left)
        var count2 = ItemCount.new(data.input.right)
        count.mul(count2)
        assert(count.count == data.expected.count)
        assert(count.is_inf() == data.expected.inf)


func test_div() -> void:
    var test_data := [
        {input = {left = 20, right = 10}, expected = {count = 2, inf = false}},
        {input = {left = 0, right = 10}, expected = {count = 0, inf = false}},
        {input = {left = 10, right = Inf}, expected = {count = 0, inf = false}},
        {input = {left = 0, right = Inf}, expected = {count = 0, inf = false}},
        {input = {left = Inf, right = 10}, expected = {count = Inf, inf = true}},
        {input = {left = Inf, right = Inf}, expected = {count = 1, inf = false}},
    ]

    for data in test_data:
        var count = ItemCount.new(data.input.left)
        var count2 = ItemCount.new(data.input.right)
        count.div(count2)
        assert(count.count == data.expected.count)
        assert(count.is_inf() == data.expected.inf)


func test_eq() -> void:
    var test_data := [
        {input = {left = 10, right = 10}, expected = true},
        {input = {left = 10, right = 20}, expected = false},
        {input = {left = 10, right = Inf}, expected = false},
        {input = {left = -1, right = Inf}, expected = true},
        {input = {left = Inf, right = 10}, expected = false},
        {input = {left = Inf, right = -1}, expected = true},
        {input = {left = Inf, right = Inf}, expected = true},
    ]

    for data in test_data:
        var count = ItemCount.new(data.input.left)
        var count2 = ItemCount.new(data.input.right)
        assert(count.eq(count2) == data.expected)


func test_less() -> void:
    var test_data := [
        {input = {left = 10, right = 20}, expected = true},
        {input = {left = 20, right = 10}, expected = false},
        {input = {left = 10, right = 10}, expected = false},
        {input = {left = 10, right = Inf}, expected = true},
        {input = {left = Inf, right = 10}, expected = false},
        {input = {left = Inf, right = Inf}, expected = false},
    ]

    for data in test_data:
        var count = ItemCount.new(data.input.left)
        var count2 = ItemCount.new(data.input.right)
        assert(count.less(count2) == data.expected)


func test_gt() -> void:
    var test_data := [
        {input = {left = 20, right = 10}, expected = true},
        {input = {left = 0, right = 10}, expected = false},
        {input = {left = 10, right = 10}, expected = false},
        {input = {left = Inf, right = 10}, expected = true},
        {input = {left = 10, right = Inf}, expected = false},
        {input = {left = Inf, right = Inf}, expected = false},
    ]

    for data in test_data:
        var count = ItemCount.new(data.input.left)
        var count2 = ItemCount.new(data.input.right)
        assert(count.gt(count2) == data.expected)


func test_min() -> void:
    var test_data := [
        {input = {left = 20, right = 10}, expected = {count = 10, inf = false}},
        {input = {left = 10, right = 20}, expected = {count = 10, inf = false}},
        {input = {left = Inf, right = 20}, expected = {count = 20, inf = false}},
        {input = {left = 10, right = Inf}, expected = {count = 10, inf = false}},
        {input = {left = Inf, right = Inf}, expected = {count = Inf, inf = true}},
    ]

    for data in test_data:
        var left = ItemCount.new(data.input.left)
        var right = ItemCount.new(data.input.right)
        var result := ItemCount.min(left, right)
        assert(result.count == data.expected.count)
        assert(result.is_inf() == data.expected.inf)
