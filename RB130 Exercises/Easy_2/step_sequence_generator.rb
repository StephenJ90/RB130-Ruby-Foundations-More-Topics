def step(start, ending, step)
  while start <= ending
    yield(start)
    start += step
  end
end

p step(1, 10, 3) { |value| puts "value = #{value}" }
