=begin
Enumerable#all? processes elements in a collection by passing each element 
value to a block that is provided in the method call. If the block returns a 
value of true for every element, then #all? returns true. Otherwise, #all? 
returns false. Note in particular that #all? will stop searching the collection 
the first time the block returns false.

Write a method called all? that behaves similarly for Arrays. It should take 
an Array as an argument, and a block. It should return true if the block 
returns true for all of the element values. Otherwise, it should return false.

Your method should stop processing elements of the Array as soon as the block 
returns false.

If the Array is empty, all? should return true, regardless of how the block is 
defined.

Your method may not use any standard ruby method that is named all?, any?, 
none?, or one?.
=end

def all?(collection)
  collection.each { |item| return false unless yield(item) }
  true
end

p all?([1, 3, 5, 6]) { |value| value.odd? } == false
p all?([1, 3, 5, 7]) { |value| value.odd? } == true
p all?([2, 4, 6, 8]) { |value| value.even? } == true
p all?([1, 3, 5, 7]) { |value| value % 5 == 0 } == false
p all?([1, 3, 5, 7]) { |value| true } == true
p all?([1, 3, 5, 7]) { |value| false } == false
p all?([]) { |value| false } == true
