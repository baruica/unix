#!/bin/awk

# Compute integer factorizations of integers supplied one per line.
# Usage:
#		awk -f factorize.awk
{
	n = int($1)
	m = n = (n >= 2) ? n : 2
	factors = ""
	for (k = 2; (m > 1) && (k^2 <= n); )
	{
		if (int(m % k) != 0)
		{
			k++					# notice that the loop variable k is incremented
			continue			# the continue statement is executed
		}
		m /= k					# only when we find that k is not a divisor of m, so the third expression in the for statement is empty
		factors = (factors == "") ? ("" k) : (factors " * " k)
	}
	if ((1 < m) && (m < n))
		factors = factors " * " m
	print n, (factors == "") ? "is prime" : ("= " factors)
}

# awk -f factorize.awk test.dat
# 2147483540 = 2 * 2 * 5 * 107374177
# 2147483541 = 3 * 7 * 102261121
# 2147483542 = 2 * 3137 * 342283
# 2147483543 is prime
# 2147483544 = 2 * 2 * 2 * 3 * 79 * 1132639
# 2147483545 = 5 * 429496709
# 2147483546 = 2 * 13 * 8969 * 9209
# 2147483547 = 3 * 3 * 11 * 21691753
# 2147483548 = 2 * 2 * 7 * 76695841
# 2147483549 is prime
# 2147483550 = 2 * 3 * 5 * 5 * 19 * 23 * 181 * 181
