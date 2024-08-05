#!/bin/sh
set -e
cc -g helloworld.c
gdb --batch --nx \
	-ex 'source ../gdb-findmap.py' \
	-ex 'file a.out' \
	-ex 'break main' \
	-ex 'run' \
	-ex 'echo Step 1: argc\n' \
	-ex 'findmap &argc' \
	-ex 'echo Step 2: #symbol main\n' \
	-ex 'findmap main' \
	-ex 'echo Step 3: printf\n' \
	-ex 'findmap printf' \
	-ex 'echo Step 4: malloc\n' \
	-ex 'findmap malloc(1)' \
	-ex 'echo Step 5: null\n' \
	-ex 'findmap 0' \
	-ex 'echo Step 6: #symbol constant\n' \
	-ex 'findmap &constant' \
	-ex 'echo Step 7: stack pointer\n' \
	-ex 'findmap $rsp' \
	-ex 'q' > gdb.out

fail() {
	sed 's/^/=== /' gdb.out
	printf '\x1b[91mSome tests failed!\x1b[0m\n'
	exit 1
}

extract_results() {
	awk '
		/Step [0-9]/ {print}
		printnext==1 {print $NF; printnext=0}
		/Start Addr/ {printnext=1}
	' | sed 's/.*libc.*/LIBC/; s/.*a\.out.*/EXE/g'
}

nth_line_after_match() {
	awk -vN="$1" -vpattern="$2" '
		c && !--c {print}
		$0 ~ pattern { c=N }
	'
}

compare_symbol() {
	symbol=$1
	expected="$(nm a.out | awk -vs="$symbol" '$3 == s {print "0x" $1}')"
	actual="$(nth_line_after_match <gdb.out 4 "Step.*#symbol $symbol" | awk '{ print $NF }')"
	expected=$((expected))
	actual=$((actual))
	echo "Symbol $symbol from nm: $expected, from findmap: $actual"
	if [ "$expected" != "$actual" ]; then
		fail
	fi
}

compare_symbol main
compare_symbol constant

if extract_results <gdb.out | diff --color=always -u - expected; then
	printf '\x1b[92mAll tests passed!\x1b[0m\n'
else
	fail
fi
