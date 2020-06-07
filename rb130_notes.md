RB130 Course Notes
===

Closures
---

A _closure_ is:
- a general programming concept that allows programmers to save a "chunk of code" and execute it at a later time.
- said to bind its surrounding artifacts (ie, variables, methods, objects, etc) and build an "enclosure" around everything so that they can be referenced when the closure is later executed. 
- a method that you can pass around and execute, but it's not defined with an explicit name.

In Ruby, a closure is implemented through a Proc object, a lambda, or a block. That is, we can pass around these items as a "chunk of code" and execute them later. The idea of having an unnamed "chunk of code" that we can pass around is very handy, especially when we pass them into existing methods. The only thing to remember is that this "chunk of code" retains references to its surrounding artifacts -- it's binding.

To understand procs and lambdas, we first need to focus on blocks.

```ruby
[1, 2, 3].each do |num|
  puts num
end
```

Take the above code example above. We've been writing code like this throughout much of the LS curriculum without much thought to why we do this. As we'll see later on, we never knew that `each` is a method with it's own implementation. So far we've just been using `each` with blocks with the thought that the block is the implementation. The block is an argument to the method call. In other words, our familiar method, [1, 2, 3].each { |num| puts num }, is actually passing in the block of code to the Array#each method.

Why is it that sometimes the code in the block affects the return value, and sometimes not?

The answer lies in how each of those methods are implemented. Remember that the code we wrote in the block is not the method implementation -- in fact, that code has nothing to do with the method implementation. The entire block is passed in to the method like any other argument, and it's up to the method implementation to decide what to do with the block, or chunk of code, that you passed in. The method could take that block and execute it, or just as likely, it could completely ignore it -- it's up to the method implementation to decide what to do with the block of code given to it. 

Writing Methods that take Blocks
---

In order for methods to be able to work with a block, the `yield` keyword must be included in the method implementation, otherwise you can pass in any block you want to a method, but the method will act as if it doesn't even know the block is there because it's implementation has no way to access it. 

On the other hand, if you include the `yield` keyword in your method implementation, but don't pass a `block` during method invocation, then 
`LocalJumpError` will be raised. To counter this error, we need some sort of conditional to allow the method to be called with, or without a block. We can do this with `Kernel#block_given?`. 

For example:

```ruby
def echo_with_yield(str)
  yield if block_given?
  str
end
```

Now if we pass in a block at method invocation, `block_given?` will evaluate to `true` and yield will allow the block to be executed. If no block is passed in as an argument to the method, then `block_given?` will evaluate to false and the block will not be executed, and the method will only return `str`.

Yielding with an Argument
---

Sometimes a block we pass into a method requires an argument. This isn't new, we've been doing this the whole time. 

```ruby
 3.times do |num|
  puts num
end
```

the `num` between the `|`'s is a block parameter. Withing the block, `num` is _block local variable_. So that means within the `times` implementation, when we `yield` to the block, we can pass in an argument to the block like this : `yield(5)`. What would happen if we didn't pass in any arguments, or passed in more arguments than there are block parameters? We would expect an error just like when we pass a method the incorrect number of parameters and the `ArgumentError` is raised. This is not the case with block parameters:

```ruby
# method implementation
def test
  yield(1)                              # passing 1 block argument at block invocation time
end

# method invocation
test do |num1, num2|                    # expecting 2 parameters in block implementation
  puts "#{num1} #{num2}"
end
```

In the above example, we are passing in one argument to the block when it's expecting two. This code will output `1`. `1` is assigned to `num1` and `num2` is ignored. The same result would occur if we passed in two arguments to the block but only had one block parameter. 

The rules regarding the number of arguments that you can pass to a block, Proc, or lambda in Ruby is called its arity. In Ruby, blocks have lenient arity rules, which is why it doesn't complain when you pass in different number of arguments; `Proc` objects and `lambdas` have different arity rules. Just realize that blocks don't enforce argument count, unlike normal methods in Ruby. 

**Return Value of Yielding to a Block**

This is yet another behavior of blocks that's similar to normal methods: they have a return value, and that return value is determined based on the last expression in the block. This implies that just like normal methods, blocks can either mutate the argument with a destructive method call or the block can return a value. Just like writing good normal methods, writing good blocks requires you to keep this distinction in mind.

**When to use Blocks in your own Methods**

If your method implementation contains a yield, a developer using your method can come in after this method is fully implemented and inject additional code in the middle of this method (without modifying the method implementation), by passing in a block of code. This is indeed one of the major use cases of using blocks.

1. Defer some implementation code to method invocation decision.
  There are two roles involved with an method:
    - method implementor
    - method caller
  These two roles could be the same person but if they are not, there are times when the method implementor is not %100 sure how the method will be called, so the use of blocks allows the method caller to refine the method implementation at method invocation time through the use of blocks, without actually modifying the method for other users. We don't know the specifcs of the scenario in which a method will use, by allowing blocks, we can create generic methods that can be called with blocks to refine the method into a more specific use.

  Many of the core library's most useful methods are useful precisely because they are built in a generic sense, allowing us (the method callers) to refine the method through a block at invocation time. For example, take the Array#select method. We love the select method because we can pass in any expression that evaluates to a boolean in the block parameter. 

2. Methods that need to perform some "before" and "after" actions - sandwich code.

Sandwich code is a good example of the previous point about deferring implementation to method invocation. There will be times when you want to write a generic method that performs some "before" and "after" action. Before and after what? That's exactly the point -- the method implementor doesn't care: before and after anything.

There are many useful use cases for "sandwich code". Timing, logging, notification systems are all examples where before/after actions are important.

Another area where before/after actions are important is in resource management, or interfacing with the operating system. Many OS interfaces require you, the developer, to first allocate a portion of a resource, then perform some clean-up to free up that resource. Forgetting to do the clean-up can result in dramatic bugs -- system crashes, memory leaks, file system corruption. Wouldn't it be great if we can automate this clean-up?

```ruby
File.open("some_file.txt", "w+") do |file|
  # write to this file using file.write
end
```

Now that you understand how yield works, you can guess that the method implementor of `File::open` opens the file, yields to the block, then closes the file. 

**Methods with an Explicit Block Parameter**

Every method, regardless of its definition, takes an implicit block. It may ignore the implicit block, but it still accepts it. However, there are times when you want a method to take an explicit block; you do that by defining a parameter prefixed by an & character in the method definition:

```ruby
def test(&block)
  puts "What's &block? #{block}" # local variable `block` will be a Proc object
end

test { sleep(1) } # What's &block? #<Proc:0x007f98e32b83c8@(irb):59>
```
Why do we now need an explicit block instead? Chiefly, the answer is that it provides additional flexibility. Before, we didn't have a handle (a variable) for the implicit block, so we couldn't do much with it except yield to it and test whether a block was provided. Now we have a variable that represents the block, so we can pass the block to another method.

For now, you just need to know that Ruby converts blocks passed in as explicit blocks to a simple Proc object (this is why we need to use #call to invoke the Proc object). ex `block.call` would be needed in the abov example if string interpolation was not used.

**Lecture Summary**

- blocks are one way that Ruby implements closures. Closures are a way to pass around an unnamed "chunk of code" to be executed later.
- blocks can take arguments, just like normal methods. But unlike normal methods, it won't complain about wrong number of arguments passed to it.
- blocks return a value, just like normal methods.
- blocks are a way to defer some implementation decisions to method invocation time. It allows method callers to refine a method at invocation time for a specific use case. It allows method implementors to build generic methods that can be used in a variety of ways.
- blocks are a good use case for "sandwich code" scenarios, like closing a File automatically.

**Todo List Assignment**

Look carefully at the difference between the two method calls. It's `list.each` vs `list.todos.each`. In the first case, we're calling `TodoList#each`, whereas in the second case we're calling `Array#each`.

In most cases, we prefer to work with the TodoList object directly and invoke method calls on list. We would rather not access an internal state of the TodoList, which in this case is `@todos`. This is the idea behind **encapsulation**: we want to hide implementation details from users of the TodoList class, and not encourage users of this class to reach into its internal state. Instead, we want to encourage users of the class to use the interfaces (ie, public methods) we created for them.

The entire goal of creating a class and encapsulating logic in a class is to hide implementation details and contain ripple effects when things change. Prefer to use the class's interface where possible.

**Closure and Binding**

In Ruby, a "chunk of code" or closure is represented by a Proc object, a lambda, or a block. Remember that blocks are a form of Proc. Let's take a look at an example:

```ruby
def call_me(some_code)
  some_code.call            # call will execute the "chunk of code" that gets passed in
end

name = "Robert"
chunk_of_code = Proc.new {puts "hi #{name}"}

call_me(chunk_of_code)
```
This implies that the Proc keeps track of its surrounding context, and drags it around wherever the chunk of code is passed to. In Ruby, we call this its binding, or surrounding environment/context. A closure must keep track of its surrounding context in order to have all the information it needs in order to be executed later. This not only includes local variables, but also method references, constants and other artifacts in your code -- whatever it needs to execute correctly, it will drag all of it around. It's why code like the above will work fine, seemingly violating the variable scoping rules we learned earlier.

**Symbol to Proc**

What is happening here?

```ruby
[1, 2, 3, 4, 5].map(&:to_s) 
```

Somehow `:to_s` is converted to this `{ |n| n.to_s }`

How is this happening?

When we add `&` in front of an object, it tells Ruby to try and convert this object into a block. To do so, it's expecting a Proc object. If this object is not a Proc, it will call `#to_proc` on the object. 

 - Ruby checks whether the object after `&` is a `Proc`. If it is, it uses the object as-is. Otherwise, it tries to call `#to_proc` on the object, which should return a `Proc` object. An error will occur if the `#to_proc` fails to return a `Proc` object.
 - If all is well, the `&` turns the `Proc` into a block.

Let's pause here and look again at `(&:to_s)`. This means that Ruby is trying to turn `:to_s` into a block. However, it's not a Proc; it's a Symbol. Ruby will then try to call the `Symbol#to_proc` method -- and there is one! This method will return a `Proc` object, which will execute the method based on the name of the symbol. In other words, `Symbol#to_proc` returns a `Proc`, which `&` turns into a block, which turns our shortcut into the long form block usage.


Testing
---

**Why do we write tests?**

For beginners, we write tests to prevent regression -- that's it! That's the only benefit of testing we'll focus on for now. We want to write tests so that when we make changes in our code, we don't have to manually verify everything still works. You can write tests first if you like, or you can write your tests after implementation. Most likely, you'll need to take some mixture of both, jumping back and forth between implementation and testing code.

**Minitest**

Though many people use RSpec, Minitest is the default testing library that comes with Ruby. From a pure functionality standpoint, Minitest can do everything RSpec can, except Minitest uses a more straight forward syntax. RSpec bends over backwards to allow developers to write code that reads like natural English, but at the cost of simplicity. RSpec is what we call a Domain Specific Language; it's a DSL for writing tests.

We use Minitest because it reads just like normal Ruby code, without a lot of magical syntax. It's not a DSL, it's just Ruby.

**Vocabulary**

- Test Suite: This is the entire set of tests that accompanies your program or application. You can think of this as _all the tests_ for a project.
- Test: this describes a situation or context in which tests are run. For example, this test is about making sure you get an error message after trying to log in with the wrong password. A test can contain multiple assertions.
- Assertion: this is the actual verification step to confirm that the data returned by your program or application is indeed what is expected. You make one or more assertions within a test. 

**What's in the test file?**

Let's take a closer look at what's in the actual test file, `car_test.rb`, and break it down line by line.

```ruby
require 'minitest/autorun'

require_relative 'car'

class CarTest < MiniTest::Test
  def test_wheels
    car = Car.new
    assert_equal(4, car.wheels)
  end
end
```

On line 1 is require 'minitest/autorun', which loads all the necessary files from the minitest gem. That's all we need to use Minitest. Next, on line 3 we require the file that we're testing, car.rb, which contains the Car class. We use require_relative to specify the file name from the current file's directory. Now when we make references to the Car class, Ruby knows where to look for it.

Finally, line 5 is where we create our test class. Note that this class must subclass MiniTest::Test. This will allow our test class to inherit all the necessary methods for writing tests.

Within our test class, `CarTest`, we can write tests by creating an instance method that starts with **test_**. Through this naming convention, Minitest will know that these methods are individual tests that need to be run. Within each test (or instance method that starts with "test_"), we will need to make some assertions. These assertions are what we are trying to verify. Before we make any assertions, however, we have to first set up the appropriate data or objects to make assertions against. For example, on line 7, we first instantiate a `Car` object. We then use this car object in our assertion to verify that newly created `Car` objects indeed have 4 wheels.

There are many types of assertions, but for now, just focus on `assert_equal`. Since we are inside an instance method, you can guess that `assert_equal` is an inherited instance method from somewhere up the hierarchy. `assert_equal` takes two parameters: the first is the expected value, and the second is the test or actual value. If there's a discrepancy, `assert_equal` will save the error and Minitest will report that error to you at the end of the test run.

**Reading test output**

```ruby
Run options: --seed 62238

# Running:

CarTest .

Finished in 0.001097s, 911.3428 runs/s, 911.3428 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

There are many options in Minitest, including various formatting options, but by default the output looks like the above. The first "seed" tells Minitest what order the tests were run in. In our example, we only have 1 test, but most test suites have many tests that are run in random order. The "seed" is how you tell Minitest to run the entire test suite in a particular order. This is rarely used, but is sometimes helpful when you have an especially tricky bug that only comes up when certain specific situations come up.

The next important thing to notice is the dot. There's only 1 here, so it looks like an inconsequential period, but it's very important. That means the test was run and nothing went wrong. If you skip a test with the "skip" keyword, it'll say "S". If you have a failure, it'll say "F". Pay attention to that to see if you have a failing test.

**Skipping tests**

Sometimes you'll want to skip certain tests. Perhaps you are in the middle of writing a test, and do not want it run yet, or for any other reason. Minitest allows for this via the `skip` keyword. All you have to do is put `skip` at the beginning of the test, and Minitest will skip it. It will also dutifully report that you have skipped tests in your suite, and output an "S" instead of a dot. For example, let's skip our second test that doesn't pass. You could also pass a string into `skip` if you want a more custom display message.

Minitest comes in two syntax flavors: assertion style and expectation style. The latter is to appease RSpec users, but the former is far more intuitive for beginning Ruby developers.


Assertions
---

For a full list of assertions, click [here].(http://docs.seattlerb.org/minitest/Minitest/Assertions.html)

Here are a few of the popular ones:

**Assertion**            /               **Description**
* `assert(test)` -                    Fails unless `test` is truthy.
* `assert_equal(exp, act)` -          Fails unless `exp == act`.
* `assert_nil(obj)` -                 Fails unless `obj` is `nil`.
* `assert_raises(*exp) { ... }` -     Fails unless block raises one of `*exp`.
* `assert_instance_of(cls, obj)` -    Fails unless `obj` is an instance of `cls`
* `assert_includes(collection, obj)` - Fails unless `collection` includes `obj`.

`assert_equal` uses `==` for _value equality_ while `assert_same` tests for _object equality_.

Refutations are the opposite of assertions but are not as commonly used.

Seat Approach
---

There are usually 4 steps to writing a test:

1. **S**etup the neccessary objects.
2. **E**xecute the code against the object we're testing.
3. **A**ssert the results of the execution.
4. **T**ear down and clean up any lingering artifacts.

[Introduction to Minitest](https://launchschool.com/blog/assert-yourself-an-introduction-to-minitest) blog post

**Code Coverage**

When writing tests, we want to get an idea of code coverage, or how much of our actual program code is tested by a test suite. You can see from our TodoList tests that all of our public methods are covered. If we are measuring code coverage based on testing the public methods, we could say that we have achieved 100% code coverage. Note that even though we are only testing public code, code coverage is based on all of your code, both public and private. Also, this doesn't mean every edge case is considered, or that even our program is working correctly. It only means that we have some tests in place for every method. There are other ways to measure code coverage too besides looking at public methods. For example, more sophisticated tools can help with ensuring that all branching logic is tested. While not foolproof, code coverage is one metric that you can use to gauge code quality.
