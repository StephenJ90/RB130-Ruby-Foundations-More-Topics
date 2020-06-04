def groups(array)
  yield(array)
end

birds = %w(raven finch hawk eagle)

groups(birds) {|_, _, *raptors| p raptors }