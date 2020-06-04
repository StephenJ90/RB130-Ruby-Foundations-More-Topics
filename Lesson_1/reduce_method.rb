def reduce(array, default=nil)
  accumulator = default ? default : array.first

  array.each_with_index do |num, idx|
    next if idx == 0 && default == nil 
    accumulator = yield(accumulator, num)
  end
  accumulator
end

array = [1, 2, 3, 4, 5]

reduce(array) { |acc, num| acc + num }                    # => 15
reduce(array, 10) { |acc, num| acc + num }                # => 25
reduce(['a', 'b', 'c']) { |acc, value| acc += value }     # => 'abc'
reduce([[1, 2], ['a', 'b']]) { |acc, value| acc + value } # => [1, 2, "a", "b"]
