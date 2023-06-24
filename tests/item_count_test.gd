extends TestSuite

const Inf = ItemCount.Inf


func init_suite():
    tests = ["test_init", "test_expand", "test_eq", "test_less"]


func test_init() -> void:
    var test_data = [
        {input = 10, expected = {space = 10, inf = false}},
        {input = Inf, expected = {space = -1, inf = true}},
        {input = -1, expected = {space = -1, inf = true}},
    ]

    for data in test_data:
        var space = ItemCount.new(data.input)
        assert(space.space == data.expected.space)
        assert(space.is_inf() == data.expected.inf)


func test_expand() -> void:
    var test_data = [
        {input = {left = 10, right = 10}, expected = {space = 20, inf = false}},
        {input = {left = 10, right = Inf}, expected = {space = -1, inf = true}},
        {input = {left = Inf, right = 10}, expected = {space = -1, inf = true}},
        {input = {left = Inf, right = Inf}, expected = {space = -1, inf = true}},
    ]

    for data in test_data:
        var space = ItemCount.new(data.input.left)
        var space2 = ItemCount.new(data.input.right)
        space.expand(space2)
        assert(space.space == data.expected.space)
        assert(space.is_inf() == data.expected.inf)


func test_eq() -> void:
    var test_data = [
        {input = {left = 10, right = 10}, expected = true},
        {input = {left = 10, right = 20}, expected = false},
        {input = {left = 10, right = Inf}, expected = false},
        {input = {left = -1, right = Inf}, expected = true},
        {input = {left = Inf, right = 10}, expected = false},
        {input = {left = Inf, right = -1}, expected = true},
        {input = {left = Inf, right = Inf}, expected = true},
    ]

    for data in test_data:
        var space = ItemCount.new(data.input.left)
        var space2 = ItemCount.new(data.input.right)
        assert(space.eq(space2) == data.expected)


func test_less() -> void:
    var test_data =[
        {input = {left = 10, right = 20}, expected = true},
        {input = {left = 20, right = 10}, expected = false},
        {input = {left = 10, right = 10}, expected = false},
        {input = {left = 10, right = Inf}, expected = true},
        {input = {left = Inf, right = 10}, expected = false},
        {input = {left = Inf, right = Inf}, expected = false},
    ]

    for data in test_data:
        var space = ItemCount.new(data.input.left)
        var space2 = ItemCount.new(data.input.right)
        assert(space.less(space2) == data.expected)
