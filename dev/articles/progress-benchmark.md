# cli progress bar benchmark

## Introduction

We make sure that the timer is not `TRUE`, by setting it to ten hours.

``` r

library(cli)
# 10 hours
cli:::cli_tick_set(10 * 60 * 60 * 1000)
cli_tick_reset()
#> NULL
`__cli_update_due`
#> [1] FALSE
```

## R benchmarks

### The timer

``` r

fun <- function() NULL
ben_st <- bench::mark(
  `__cli_update_due`,
  fun(),
  .Call(ccli_tick_reset),
  interactive(),
  check = FALSE
)
ben_st
#> # A tibble: 4 × 6
#>   expression                  min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>             <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 __cli_update_due              0     10ns 86849812.        0B        0
#> 2 fun()                  130.04ns  150.1ns  4571966.        0B        0
#> 3 .Call(ccli_tick_reset)    100ns  120.1ns  7864508.        0B        0
#> 4 interactive()            8.96ns   10.1ns 68638703.        0B        0
```

``` r

ben_st2 <- bench::mark(
  if (`__cli_update_due`) foobar()
)
ben_st2
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 if (`__cli_update_due`) fo…  40ns 41.1ns 21542577.        0B        0
```

### `cli_progress_along()`

``` r

seq <- 1:100000
ta <- cli_progress_along(seq)
bench::mark(seq[[1]], ta[[1]])
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 seq[[1]]      130ns    141ns  6295667.        0B        0
#> 2 ta[[1]]       140ns    160ns  5830897.        0B        0
```

#### `for` loop

This is the baseline:

``` r

f0 <- function(n = 1e5) {
  x <- 0
  seq <- 1:n
  for (i in seq) {
    x <- x + i %% 2
  }
  x
}
```

With progress bars:

``` r

fp <- function(n = 1e5) {
  x <- 0
  seq <- 1:n
  for (i in cli_progress_along(seq)) {
    x <- x + seq[[i]] %% 2
  }
  x
}
```

Overhead per iteration:

``` r

ben_taf <- bench::mark(f0(), fp())
ben_taf
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0()           22ms   22.1ms      45.3    21.6KB     408.
#> 2 fp()         24.6ms     25ms      40.1    82.5KB     320.
(ben_taf$median[2] - ben_taf$median[1]) / 1e5
#> [1] 29ns
```

``` r

ben_taf2 <- bench::mark(f0(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf2
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     243ms    243ms      4.09        0B     36.8
#> 2 fp(1e+06)     259ms    293ms      3.42    1.88KB     25.6
(ben_taf2$median[2] - ben_taf2$median[1]) / 1e6
#> [1] 49.1ns
```

``` r

ben_taf3 <- bench::mark(f0(1e7), fp(1e7))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf3
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+07)     2.42s    2.42s     0.413        0B     19.8
#> 2 fp(1e+07)     2.49s    2.49s     0.402    1.88KB     19.3
(ben_taf3$median[2] - ben_taf3$median[1]) / 1e7
#> [1] 6.49ns
```

``` r

ben_taf4 <- bench::mark(f0(1e8), fp(1e8))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf4
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+08)     23.5s    23.5s    0.0426        0B     22.5
#> 2 fp(1e+08)     25.3s    25.3s    0.0396    1.88KB     20.8
(ben_taf4$median[2] - ben_taf4$median[1]) / 1e8
#> [1] 17.9ns
```

#### Mapping with `lapply()`

This is the baseline:

``` r

f0 <- function(n = 1e5) {
  seq <- 1:n
  ret <- lapply(seq, function(x) {
    x %% 2
  })
  invisible(ret)
}
```

With an index vector:

``` r

f01 <- function(n = 1e5) {
  seq <- 1:n
  ret <- lapply(seq_along(seq), function(i) {
    seq[[i]] %% 2
  })
  invisible(ret)
}
```

With progress bars:

``` r

fp <- function(n = 1e5) {
  seq <- 1:n
  ret <- lapply(cli_progress_along(seq), function(i) {
    seq[[i]] %% 2
  })
  invisible(ret)
}
```

Overhead per iteration:

``` r

ben_tam <- bench::mark(f0(), f01(), fp())
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0()           91ms     95ms      7.95     781KB    15.9 
#> 2 f01()         106ms    111ms      8.38     781KB     8.38
#> 3 fp()          116ms    126ms      8.12     783KB    11.4
(ben_tam$median[3] - ben_tam$median[1]) / 1e5
#> [1] 308ns
```

``` r

ben_tam2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     1.09s    1.09s     0.914    7.63MB     6.40
#> 2 f01(1e+06)    2.65s    2.65s     0.378    7.63MB     3.02
#> 3 fp(1e+06)     1.14s    1.14s     0.876    7.63MB     1.75
(ben_tam2$median[3] - ben_tam2$median[1]) / 1e6
#> [1] 46.7ns
(ben_tam2$median[3] - ben_tam2$median[2]) / 1e6
#> [1] 1ns
```

#### Mapping with purrr

This is the baseline:

``` r

f0 <- function(n = 1e5) {
  seq <- 1:n
  ret <- purrr::map(seq, function(x) {
    x %% 2
  })
  invisible(ret)
}
```

With index vector:

``` r

f01 <- function(n = 1e5) {
  seq <- 1:n
  ret <- purrr::map(seq_along(seq), function(i) {
    seq[[i]] %% 2
  })
  invisible(ret)
}
```

With progress bars:

``` r

fp <- function(n = 1e5) {
  seq <- 1:n
  ret <- purrr::map(cli_progress_along(seq), function(i) {
    seq[[i]] %% 2
  })
  invisible(ret)
}
```

Overhead per iteration:

``` r

ben_pur <- bench::mark(f0(), f01(), fp())
ben_pur
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0()         79.2ms   79.6ms     12.4     1.44MB     6.22
#> 2 f01()        95.5ms   97.4ms     10.1    781.3KB     2.03
#> 3 fp()          100ms    105ms      9.57  783.24KB     2.39
(ben_pur$median[3] - ben_pur$median[1]) / 1e5
#> [1] 255ns
(ben_pur$median[3] - ben_pur$median[2]) / 1e5
#> [1] 76.1ns
```

``` r

ben_pur2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  889.86ms 889.86ms     1.12     7.63MB     1.12
#> 2 f01(1e+06)    1.16s    1.16s     0.860    7.63MB     2.58
#> 3 fp(1e+06)     1.51s    1.51s     0.663    7.63MB     1.99
(ben_pur2$median[3] - ben_pur2$median[1]) / 1e6
#> [1] 619ns
(ben_pur2$median[3] - ben_pur2$median[2]) / 1e6
#> [1] 347ns
```

### `ticking()`

``` r

f0 <- function(n = 1e5) {
  i <- 0
  x <- 0 
  while (i < n) {
    x <- x + i %% 2
    i <- i + 1
  }
  x
}
```

``` r

fp <- function(n = 1e5) {
  i <- 0
  x <- 0 
  while (ticking(i < n)) {
    x <- x + i %% 2
    i <- i + 1
  }
  x
}
```

``` r

ben_tk <- bench::mark(f0(), fp())
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tk
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0()        22.87ms  22.99ms    43.2      39.3KB     1.97
#> 2 fp()          4.04s    4.04s     0.248   100.7KB     1.73
(ben_tk$median[2] - ben_tk$median[1]) / 1e5
#> [1] 40.1µs
```

### Traditional API

``` r

f0 <- function(n = 1e5) {
  x <- 0
  for (i in 1:n) {
    x <- x + i %% 2
  }
  x
}
```

``` r

fp <- function(n = 1e5) {
  cli_progress_bar(total = n)
  x <- 0
  for (i in 1:n) {
    x <- x + i %% 2
    cli_progress_update()
  }
  x
}
```

``` r

ff <- function(n = 1e5) {
  cli_progress_bar(total = n)
  x <- 0
  for (i in 1:n) {
    x <- x + i %% 2
    if (`__cli_update_due`) cli_progress_update()
  }
  x
}
```

``` r

ben_api <- bench::mark(f0(), ff(), fp())
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0()        21.43ms  21.68ms    42.8      18.7KB     1.95
#> 2 ff()        30.91ms  31.16ms    28.9      27.6KB     3.85
#> 3 fp()          2.29s    2.29s     0.436    25.1KB     1.75
(ben_api$median[3] - ben_api$median[1]) / 1e5
#> [1] 22.7µs
(ben_api$median[2] - ben_api$median[1]) / 1e5
#> [1] 94.8ns
```

``` r

ben_api2 <- bench::mark(f0(1e6), ff(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)   234.9ms    239ms    4.11          0B     2.74
#> 2 ff(1e+06)   320.2ms  329.9ms    3.03       1.9KB     3.03
#> 3 fp(1e+06)     23.6s    23.6s    0.0425     1.9KB     1.78
(ben_api2$median[3] - ben_api2$median[1]) / 1e6
#> [1] 23.3µs
(ben_api2$median[2] - ben_api2$median[1]) / 1e6
#> [1] 90.9ns
```

## C benchmarks

Baseline function:

``` c
SEXP test_baseline() {
  int i;
  int res = 0;
  for (i = 0; i < 2000000000; i++) {
    res += i % 2;
  }
  return ScalarInteger(res);
}
```

Switch + modulo check:

``` c
SEXP test_modulo(SEXP progress) {
  int i;
  int res = 0;
  int progress_ = LOGICAL(progress)[0];
  for (i = 0; i < 2000000000; i++) {
    if (i % 10000 == 0 && progress_) cli_progress_set(R_NilValue, i);
    res += i % 2;
  }
  return ScalarInteger(res);
}
```

cli progress bar API:

``` c
SEXP test_cli() {
  int i;
  int res = 0;
  SEXP bar = PROTECT(cli_progress_bar(2000000000, NULL));
  for (i = 0; i < 2000000000; i++) {
    if (CLI_SHOULD_TICK) cli_progress_set(bar, i);
    res += i % 2;
  }
  cli_progress_done(bar);
  UNPROTECT(1);
  return ScalarInteger(res);
}
```

``` c
SEXP test_cli_unroll() {
  int i = 0;
  int res = 0;
  SEXP bar = PROTECT(cli_progress_bar(2000000000, NULL));
  int s, final, step = 2000000000 / 100000;
  for (s = 0; s < 100000; s++) {
    if (CLI_SHOULD_TICK) cli_progress_set(bar, i);
    final = (s + 1) * step;
    for (i = s * step; i < final; i++) {
      res += i % 2;
    }
  }
  cli_progress_done(bar);
  UNPROTECT(1);
  return ScalarInteger(res);
}
```

``` r

library(progresstest)
ben_c <- bench::mark(
  test_baseline(),
  test_modulo(),
  test_cli(),
  test_cli_unroll()
)
ben_c
#> # A tibble: 4 × 6
#>   expression             min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>        <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 test_baseline()   625.77ms 625.77ms     1.60     2.08KB        0
#> 2 test_modulo()        1.25s    1.25s     0.802    2.24KB        0
#> 3 test_cli()           1.25s    1.25s     0.803   24.09KB        0
#> 4 test_cli_unroll() 623.18ms 623.18ms     1.60     3.56KB        0
(ben_c$median[3] - ben_c$median[1]) / 2000000000
#> [1] 1ns
```

## Display update

We only update the display a fixed number of times per second.
(Currently maximum five times per second.)

Let’s measure how long a single update takes.

### Iterator with a bar

``` r

cli_progress_bar(total = 100000)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ■                                  0% | ETA:  4m
#> ■                                  0% | ETA:  2h
#> ■                                  0% | ETA:  1h
#> ■                                  0% | ETA:  1h
#> ■                                  0% | ETA:  1h
#> ■                                  0% | ETA: 45m
#> ■                                  0% | ETA: 40m
#> ■                                  0% | ETA: 36m
#> ■                                  0% | ETA: 34m
#> ■                                  0% | ETA: 31m
#> ■                                  0% | ETA: 29m
#> ■                                  0% | ETA: 28m
#> ■                                  0% | ETA: 26m
#> ■                                  0% | ETA: 25m
#> ■                                  0% | ETA: 24m
#> ■                                  0% | ETA: 23m
#> ■                                  0% | ETA: 23m
#> ■                                  0% | ETA: 22m
#> ■                                  0% | ETA: 21m
#> ■                                  0% | ETA: 21m
#> ■                                  0% | ETA: 20m
#> ■                                  0% | ETA: 20m
#> ■                                  0% | ETA: 20m
#> ■                                  0% | ETA: 19m
#> ■                                  0% | ETA: 19m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 17m
#> ■                                  0% | ETA: 17m
#> ■                                  0% | ETA: 17m
#> ■                                  0% | ETA: 17m
#> ■                                  0% | ETA: 17m
#> ■                                  0% | ETA: 16m
#> ■                                  0% | ETA: 16m
#> ■                                  0% | ETA: 16m
#> ■                                  0% | ETA: 16m
#> ■                                  0% | ETA: 16m
#> ■                                  0% | ETA: 16m
#> ■                                  0% | ETA: 16m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 14m
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 6.17ms 6.29ms      156.    1.41MB     2.03
cli_progress_done()
```

### Iterator without a bar

``` r

cli_progress_bar(total = NA)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ⠙ 1 done (502/s) | 3ms
#> ⠹ 2 done (69/s) | 29ms
#> ⠸ 3 done (82/s) | 37ms
#> ⠼ 4 done (90/s) | 45ms
#> ⠴ 5 done (97/s) | 52ms
#> ⠦ 6 done (101/s) | 60ms
#> ⠧ 7 done (105/s) | 67ms
#> ⠇ 8 done (108/s) | 74ms
#> ⠏ 9 done (111/s) | 82ms
#> ⠋ 10 done (113/s) | 89ms
#> ⠙ 11 done (115/s) | 97ms
#> ⠹ 12 done (116/s) | 104ms
#> ⠸ 13 done (118/s) | 111ms
#> ⠼ 14 done (119/s) | 119ms
#> ⠴ 15 done (120/s) | 126ms
#> ⠦ 16 done (121/s) | 133ms
#> ⠧ 17 done (121/s) | 141ms
#> ⠇ 18 done (122/s) | 148ms
#> ⠏ 19 done (123/s) | 155ms
#> ⠋ 20 done (123/s) | 163ms
#> ⠙ 21 done (124/s) | 170ms
#> ⠹ 22 done (124/s) | 178ms
#> ⠸ 23 done (125/s) | 185ms
#> ⠼ 24 done (125/s) | 193ms
#> ⠴ 25 done (125/s) | 200ms
#> ⠦ 26 done (126/s) | 208ms
#> ⠧ 27 done (126/s) | 215ms
#> ⠇ 28 done (126/s) | 222ms
#> ⠏ 29 done (127/s) | 230ms
#> ⠋ 30 done (127/s) | 237ms
#> ⠙ 31 done (127/s) | 244ms
#> ⠹ 32 done (127/s) | 252ms
#> ⠸ 33 done (128/s) | 259ms
#> ⠼ 34 done (128/s) | 267ms
#> ⠴ 35 done (128/s) | 274ms
#> ⠦ 36 done (128/s) | 281ms
#> ⠧ 37 done (128/s) | 289ms
#> ⠇ 38 done (129/s) | 296ms
#> ⠏ 39 done (129/s) | 303ms
#> ⠋ 40 done (129/s) | 311ms
#> ⠙ 41 done (129/s) | 318ms
#> ⠹ 42 done (129/s) | 325ms
#> ⠸ 43 done (130/s) | 332ms
#> ⠼ 44 done (130/s) | 340ms
#> ⠴ 45 done (130/s) | 347ms
#> ⠦ 46 done (130/s) | 355ms
#> ⠧ 47 done (130/s) | 362ms
#> ⠇ 48 done (130/s) | 369ms
#> ⠏ 49 done (130/s) | 377ms
#> ⠋ 50 done (130/s) | 384ms
#> ⠙ 51 done (131/s) | 391ms
#> ⠹ 52 done (131/s) | 399ms
#> ⠸ 53 done (131/s) | 406ms
#> ⠼ 54 done (131/s) | 413ms
#> ⠴ 55 done (131/s) | 421ms
#> ⠦ 56 done (131/s) | 428ms
#> ⠧ 57 done (121/s) | 473ms
#> ⠇ 58 done (121/s) | 480ms
#> ⠏ 59 done (121/s) | 487ms
#> ⠋ 60 done (122/s) | 494ms
#> ⠙ 61 done (122/s) | 501ms
#> ⠹ 62 done (122/s) | 509ms
#> ⠸ 63 done (122/s) | 516ms
#> ⠼ 64 done (122/s) | 523ms
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 7.12ms 7.35ms      136.     265KB     2.19
cli_progress_done()
```
