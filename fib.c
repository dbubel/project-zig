#include <stdio.h>

int fibonacci(int n) {
    int first = 0, second = 1;

    if (n == 0)
        return first;
    else if (n == 1)
        return second;
    else {
        int fib = 0;
        for (int i = 2; i <= n; i++) {
            fib = first + second;
            first = second;
            second = fib;
        }
        return fib;
    }
}