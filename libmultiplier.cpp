#include "libmultiplier.h"
#include "libadder.h"

int make_double(int a) {
    return adder(a, a);
}
