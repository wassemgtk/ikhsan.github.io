/*:
# Swift - Validating Credit Card Numbers
### [Lab 2, FP101x Introduction to Functional Programming @ edX](https://www.edx.org/course/introduction-functional-programming-delftx-fp101x-0)
Have you ever wondered how websites validate your credit card number when you shop online? They don’t check a massive database of numbers, and they don’t use magic. In fact, most credit providers rely on a checksum formula for distinguishing valid numbers from random collection of digits (or typing mistakes).

In this lab, you will implement a __validation algorithm for credit cards__. The algorithm follows these steps:

* Double the value of every second digit beginning with the rightmost
* Add the digits of the doubled values and the undoubled digits from the original number
* Calculate the modulus of the sum divided by 10

If the result equals 0, then the number is valid. Here is an example of the results of each step on the number _4012888888881881_.

* In order to start with the rightmost digit, we produce a reversed list of digits. Then, we double every second digit.

    Result: [1,16,8,2,8,16,8,16,8,16,8,16,2,2,0,8]


* We sum all of the digits of the resulting list above. Note that we must again split the elements of the list into their digits (e.g. 16 becomes [1, 6]).

    Result: 90


* Finally, we calculate the modulus of 90 over 10.

    Result: 0

Since the final value is 0, we know that the above number is a valid credit card number. If we make a mistake in typing the credit card number and instead provide _4012888888881891_, then the result of the last step is 2, proving that the number is invalid.

*/

/*: 
__Ex. 0__
Define a function 

`toDigits(digit: Int) -> [Int]` 

that takes a `n: Integer` where `n >= 0` and returns a list of the digits of n. More precisely, `toDigits` should satisfy the following properties, for all `n : Integer`  where `n >= 0` :

* eval(toDigits(n)) == n
* all (\d -> d >= 0 && d < 10) (toDigits n) << !!!!
* String(n).count == (toDigits(n)).count

Note: `eval` is specified in the `helper.swift` file
*/

func toDigits(digit: Int) -> [Int] {
    // TODO: to be implemented
    return []
}

/*:
__Ex. 1__
Define a function

`toDigitsRev(digit: Int) -> [Int]`

that takes a `n: Integer` where `n >= 0` and returns a list of the digits of n in reverse order. More precisely, `toDigitsRev` should satisfy the following properties, for all `n : Integer`  where `n >= 0`:

* n == evalRev(toDigitsRev(n))
* all (\d -> d >= 0 && d < 10) (toDigits n) << !!!!
* String(n).count == (toDigitsRev(n)).count

Note: `evalRev` is specified in the `helper.swift` file
*/

func toDigitsRev(digit: Int) -> [Int] {
    // TODO: to be implemented
    return []
}

/*:
__Ex. 2__
Define the function

`doubleSecond(digits: [Int]) -> [Int]`

that doubles every second number in the input list

For example, the result of `doubleSecond([8, 7, 6, 5])` is `[8, 14, 6, 10]`.
*/

func doubleSecond(digits: [Int]) -> [Int] {
    // TODO: to be implemented
    return []
}

/*:
__Ex. 3__
The output of `doubleSecond` has a mix of one-digit and two-digit numbers. Define a function

`sumDigits(digits: [Int]) -> Int`

to calculate the sum of all individual digits, even if a number in the list has more than 2 digits.

Example:  
`sumDigits [8,14,6,10] = 8 + (1 + 4) + 6 + (1 + 0) = 20`

`sumDigits [3,9,4,15,8] = 3 + 9 + 4 + (1 + 5) + 8 = 30`
*/

func sumDigits(digits: [Int]) -> Int {
    // TODO: to be implemented
    return 0
}

/*:
__Ex. 4__

Define the function

`isValid(digit: Int) -> Bool`

that tells whether any input `n : Integer`  where `n >= 0`  could be a valid credit card number, using the algorithm outlined in the introduction.

Hint: make use of the functions defined in the previous exercises.
*/

func isValid(digit: Int) -> Bool {
    // TODO: to be implemented
    return false
}

/*:
__Ex. 5__

A list of credit card numbers is defined as `creditCards` inside `helpers.swift`. Calculate how many valid cards from `creditCard` using `numValid`

*/

func numValid(digits: [Int]) -> Int {
    return digits
        .filter(isValid)
        .count
}
