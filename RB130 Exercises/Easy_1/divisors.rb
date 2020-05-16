# Write a method that returns a list of all of the divisors of the positive 
# integer passed in as an argument. The return value can be in any sequence you
# wish.

def divisors(number)
  1.upto(number).select do |candidate|
    number % candidate == 0
  end
end

divisors(1) == [1]
divisors(7) == [1, 7]
divisors(12) == [1, 2, 3, 4, 6, 12]
divisors(98) == [1, 2, 7, 14, 49, 98]
divisors(99400891) == [1, 9967, 9973, 99400891]
