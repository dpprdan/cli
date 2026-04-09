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
#> 1 __cli_update_due              0     10ns    1.08e8        0B        0
#> 2 fun()                  130.04ns  160.1ns    4.27e6        0B        0
#> 3 .Call(ccli_tick_reset)    100ns    120ns    8.19e6        0B        0
#> 4 interactive()            8.96ns   10.1ns    6.08e7        0B        0
```

``` r
ben_st2 <- bench::mark(
  if (`__cli_update_due`) foobar()
)
ben_st2
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 if (`__cli_update_due`) fo…  40ns 50.1ns 20530181.        0B        0
```

### `cli_progress_along()`

``` r
seq <- 1:100000
ta <- cli_progress_along(seq)
bench::mark(seq[[1]], ta[[1]])
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 seq[[1]]      110ns    131ns  6986555.        0B       0 
#> 2 ta[[1]]       130ns    150ns  5821058.        0B     582.
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
#> 1 f0()         22.3ms   22.3ms      44.8    21.6KB     254.
#> 2 fp()         25.1ms   25.4ms      39.1    82.3KB     195.
(ben_taf$median[2] - ben_taf$median[1]) / 1e5
#> [1] 30.5ns
```

``` r
ben_taf2 <- bench::mark(f0(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf2
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     247ms    250ms      4.00        0B     33.3
#> 2 fp(1e+06)     271ms    274ms      3.65    1.88KB     31.0
(ben_taf2$median[2] - ben_taf2$median[1]) / 1e6
#> [1] 24ns
```

``` r
ben_taf3 <- bench::mark(f0(1e7), fp(1e7))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf3
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+07)     2.57s    2.57s     0.389        0B     32.7
#> 2 fp(1e+07)     2.65s    2.65s     0.378    1.88KB     31.8
(ben_taf3$median[2] - ben_taf3$median[1]) / 1e7
#> [1] 7.67ns
```

``` r
ben_taf4 <- bench::mark(f0(1e8), fp(1e8))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf4
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+08)     23.9s    23.9s    0.0418        0B     20.4
#> 2 fp(1e+08)     25.8s    25.8s    0.0388    1.88KB     18.8
(ben_taf4$median[2] - ben_taf4$median[1]) / 1e8
#> [1] 18.4ns
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
#> 1 f0()         84.8ms   93.2ms     10.6      781KB     12.4
#> 2 f01()       118.2ms  122.6ms      7.55     781KB     13.2
#> 3 fp()        129.7ms  134.9ms      7.40     783KB     12.9
(ben_tam$median[3] - ben_tam$median[1]) / 1e5
#> [1] 417ns
```

``` r
ben_tam2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  900.17ms 900.17ms     1.11     7.63MB     4.44
#> 2 f01(1e+06)    1.14s    1.14s     0.878    7.63MB     5.27
#> 3 fp(1e+06)     1.42s    1.42s     0.704    7.63MB     3.52
(ben_tam2$median[3] - ben_tam2$median[1]) / 1e6
#> [1] 520ns
(ben_tam2$median[3] - ben_tam2$median[2]) / 1e6
#> [1] 281ns
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
#> 1 f0()           78ms   78.3ms      12.7    1.41MB     5.07
#> 2 f01()        89.3ms   89.7ms      11.2   781.3KB    11.2 
#> 3 fp()         93.4ms   93.9ms      10.5  783.24KB     7.01
(ben_pur$median[3] - ben_pur$median[1]) / 1e5
#> [1] 156ns
(ben_pur$median[3] - ben_pur$median[2]) / 1e5
#> [1] 42ns
```

``` r
ben_pur2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     2.15s    2.15s     0.464    7.63MB    0.928
#> 2 f01(1e+06)    1.08s    1.08s     0.927    7.63MB    2.78 
#> 3 fp(1e+06)     1.59s    1.59s     0.630    7.63MB    3.15
(ben_pur2$median[3] - ben_pur2$median[1]) / 1e6
#> [1] 1ns
(ben_pur2$median[3] - ben_pur2$median[2]) / 1e6
#> [1] 509ns
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
#> 1 f0()        24.41ms  30.88ms    29.7      39.3KB     1.98
#> 2 fp()          4.46s    4.46s     0.224   100.4KB     2.92
(ben_tk$median[2] - ben_tk$median[1]) / 1e5
#> [1] 44.3µs
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
#> 1 f0()        35.28ms  42.63ms    23.7      18.7KB     1.98
#> 2 ff()        42.84ms  51.68ms    19.5      27.6KB     1.95
#> 3 fp()          2.55s    2.55s     0.392    25.1KB     2.75
(ben_api$median[3] - ben_api$median[1]) / 1e5
#> [1] 25.1µs
(ben_api$median[2] - ben_api$median[1]) / 1e5
#> [1] 90.5ns
```

``` r
ben_api2 <- bench::mark(f0(1e6), ff(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)   222.9ms  223.2ms    4.48          0B     4.48
#> 2 ff(1e+06)   334.3ms  355.2ms    2.82       1.9KB     2.82
#> 3 fp(1e+06)     23.3s    23.3s    0.0429     1.9KB     2.31
(ben_api2$median[3] - ben_api2$median[1]) / 1e6
#> [1] 23.1µs
(ben_api2$median[2] - ben_api2$median[1]) / 1e6
#> [1] 132ns
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
#> 1 test_baseline()   625.17ms 625.17ms     1.60     2.08KB        0
#> 2 test_modulo()        1.25s    1.25s     0.799    2.24KB        0
#> 3 test_cli()           1.25s    1.25s     0.802    23.9KB        0
#> 4 test_cli_unroll() 625.39ms 625.39ms     1.60     3.56KB        0
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
#> ■                                  0% | ETA:  5m
#> ■                                  0% | ETA:  2h
#> ■                                  0% | ETA:  1h
#> ■                                  0% | ETA:  1h
#> ■                                  0% | ETA:  1h
#> ■                                  0% | ETA: 47m
#> ■                                  0% | ETA: 42m
#> ■                                  0% | ETA: 38m
#> ■                                  0% | ETA: 35m
#> ■                                  0% | ETA: 33m
#> ■                                  0% | ETA: 31m
#> ■                                  0% | ETA: 29m
#> ■                                  0% | ETA: 28m
#> ■                                  0% | ETA: 26m
#> ■                                  0% | ETA: 25m
#> ■                                  0% | ETA: 25m
#> ■                                  0% | ETA: 24m
#> ■                                  0% | ETA: 23m
#> ■                                  0% | ETA: 22m
#> ■                                  0% | ETA: 22m
#> ■                                  0% | ETA: 21m
#> ■                                  0% | ETA: 21m
#> ■                                  0% | ETA: 20m
#> ■                                  0% | ETA: 20m
#> ■                                  0% | ETA: 20m
#> ■                                  0% | ETA: 19m
#> ■                                  0% | ETA: 20m
#> ■                                  0% | ETA: 19m
#> ■                                  0% | ETA: 19m
#> ■                                  0% | ETA: 19m
#> ■                                  0% | ETA: 19m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 17m
#> ■                                  0% | ETA: 17m
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
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 6.56ms 6.71ms      143.     1.4MB     2.05
cli_progress_done()
```

### Iterator without a bar

``` r
cli_progress_bar(total = NA)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ⠙ 1 done (469/s) | 3ms
#> ⠹ 2 done (65/s) | 31ms
#> ⠸ 3 done (78/s) | 39ms
#> ⠼ 4 done (86/s) | 47ms
#> ⠴ 5 done (92/s) | 55ms
#> ⠦ 6 done (97/s) | 62ms
#> ⠧ 7 done (100/s) | 70ms
#> ⠇ 8 done (103/s) | 78ms
#> ⠏ 9 done (106/s) | 86ms
#> ⠋ 10 done (108/s) | 93ms
#> ⠙ 11 done (110/s) | 101ms
#> ⠹ 12 done (111/s) | 108ms
#> ⠸ 13 done (113/s) | 116ms
#> ⠼ 14 done (114/s) | 124ms
#> ⠴ 15 done (115/s) | 131ms
#> ⠦ 16 done (116/s) | 139ms
#> ⠧ 17 done (117/s) | 146ms
#> ⠇ 18 done (117/s) | 154ms
#> ⠏ 19 done (118/s) | 161ms
#> ⠋ 20 done (119/s) | 169ms
#> ⠙ 21 done (119/s) | 177ms
#> ⠹ 22 done (116/s) | 190ms
#> ⠸ 23 done (116/s) | 198ms
#> ⠼ 24 done (116/s) | 207ms
#> ⠴ 25 done (117/s) | 215ms
#> ⠦ 26 done (117/s) | 224ms
#> ⠧ 27 done (117/s) | 232ms
#> ⠇ 28 done (117/s) | 240ms
#> ⠏ 29 done (117/s) | 249ms
#> ⠋ 30 done (117/s) | 257ms
#> ⠙ 31 done (117/s) | 266ms
#> ⠹ 32 done (117/s) | 275ms
#> ⠸ 33 done (117/s) | 283ms
#> ⠼ 34 done (117/s) | 291ms
#> ⠴ 35 done (117/s) | 299ms
#> ⠦ 36 done (118/s) | 307ms
#> ⠧ 37 done (118/s) | 314ms
#> ⠇ 38 done (118/s) | 322ms
#> ⠏ 39 done (118/s) | 330ms
#> ⠋ 40 done (119/s) | 338ms
#> ⠙ 41 done (119/s) | 346ms
#> ⠹ 42 done (119/s) | 354ms
#> ⠸ 43 done (119/s) | 362ms
#> ⠼ 44 done (119/s) | 370ms
#> ⠴ 45 done (119/s) | 377ms
#> ⠦ 46 done (120/s) | 385ms
#> ⠧ 47 done (120/s) | 393ms
#> ⠇ 48 done (120/s) | 401ms
#> ⠏ 49 done (120/s) | 409ms
#> ⠋ 50 done (120/s) | 417ms
#> ⠙ 51 done (120/s) | 424ms
#> ⠹ 52 done (120/s) | 432ms
#> ⠸ 53 done (121/s) | 440ms
#> ⠼ 54 done (121/s) | 448ms
#> ⠴ 55 done (121/s) | 455ms
#> ⠦ 56 done (121/s) | 463ms
#> ⠧ 57 done (121/s) | 471ms
#> ⠇ 58 done (121/s) | 479ms
#> ⠏ 59 done (121/s) | 487ms
#> ⠋ 60 done (121/s) | 495ms
#> ⠙ 61 done (122/s) | 502ms
#> ⠹ 62 done (122/s) | 510ms
#> ⠸ 63 done (122/s) | 518ms
#> ⠼ 64 done (122/s) | 526ms
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 7.44ms 7.82ms      127.     265KB     2.05
cli_progress_done()
```
