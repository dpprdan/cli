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
#> 1 __cli_update_due        10.01ns   10.1ns 81488071.        0B        0
#> 2 fun()                  110.01ns  131.1ns  5055669.        0B        0
#> 3 .Call(ccli_tick_reset)  99.88ns  110.9ns  7960328.        0B        0
#> 4 interactive()            9.89ns   19.9ns 57253711.        0B        0
```

``` r

ben_st2 <- bench::mark(
  if (`__cli_update_due`) foobar()
)
ben_st2
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 if (`__cli_update_due`) fo…  30ns 50.1ns 19730203.        0B        0
```

### `cli_progress_along()`

``` r

seq <- 1:100000
ta <- cli_progress_along(seq)
bench::mark(seq[[1]], ta[[1]])
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 seq[[1]]      110ns    130ns  6810687.        0B        0
#> 2 ta[[1]]       120ns    141ns  6017843.        0B        0
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
#> 1 f0()         24.2ms   24.2ms      41.3    21.6KB     330.
#> 2 fp()         26.7ms   27.2ms      36.8    82.5KB     276.
(ben_taf$median[2] - ben_taf$median[1]) / 1e5
#> [1] 29.5ns
```

``` r

ben_taf2 <- bench::mark(f0(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf2
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     264ms    264ms      3.79        0B     34.1
#> 2 fp(1e+06)     289ms    291ms      3.44    1.88KB     29.2
(ben_taf2$median[2] - ben_taf2$median[1]) / 1e6
#> [1] 27.1ns
```

``` r

ben_taf3 <- bench::mark(f0(1e7), fp(1e7))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf3
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+07)      2.7s     2.7s     0.370        0B     17.8
#> 2 fp(1e+07)     2.74s    2.74s     0.365    1.88KB     17.5
(ben_taf3$median[2] - ben_taf3$median[1]) / 1e7
#> [1] 4.34ns
```

``` r

ben_taf4 <- bench::mark(f0(1e8), fp(1e8))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf4
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+08)     26.1s    26.1s    0.0384        0B     20.3
#> 2 fp(1e+08)     27.8s    27.8s    0.0359    1.88KB     18.8
(ben_taf4$median[2] - ben_taf4$median[1]) / 1e8
#> [1] 17.8ns
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
#> 1 f0()         85.2ms   90.4ms      8.49     781KB    13.6 
#> 2 f01()       107.1ms    118ms      8.70     781KB    13.9 
#> 3 fp()        124.3ms  134.9ms      6.67     783KB     8.34
(ben_tam$median[3] - ben_tam$median[1]) / 1e5
#> [1] 445ns
```

``` r

ben_tam2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     1.11s    1.11s     0.902    7.63MB     6.32
#> 2 f01(1e+06)    1.96s    1.96s     0.510    7.63MB     2.04
#> 3 fp(1e+06)     1.21s    1.21s     0.826    7.63MB     4.96
(ben_tam2$median[3] - ben_tam2$median[1]) / 1e6
#> [1] 103ns
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
#> 1 f0()         75.3ms   75.8ms      13.1    1.44MB     9.84
#> 2 f01()        93.3ms   93.3ms      10.7   781.3KB    10.7 
#> 3 fp()         90.8ms   91.1ms      10.9  783.24KB     5.45
(ben_pur$median[3] - ben_pur$median[1]) / 1e5
#> [1] 154ns
(ben_pur$median[3] - ben_pur$median[2]) / 1e5
#> [1] 1ns
```

``` r

ben_pur2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  908.89ms 908.89ms     1.10     7.63MB     3.30
#> 2 f01(1e+06)    1.14s    1.14s     0.881    7.63MB     2.64
#> 3 fp(1e+06)     1.65s    1.65s     0.605    7.63MB     2.42
(ben_pur2$median[3] - ben_pur2$median[1]) / 1e6
#> [1] 744ns
(ben_pur2$median[3] - ben_pur2$median[2]) / 1e6
#> [1] 518ns
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
#> 1 f0()        24.09ms   24.3ms    40.9      39.3KB     1.95
#> 2 fp()          3.86s    3.86s     0.259   100.8KB     2.85
(ben_tk$median[2] - ben_tk$median[1]) / 1e5
#> [1] 38.3µs
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
#> 1 f0()        23.01ms  23.37ms    39.3      18.7KB     3.93
#> 2 ff()        31.92ms   32.1ms    29.9      27.6KB     2.00
#> 3 fp()          2.23s    2.23s     0.449    25.1KB     2.69
(ben_api$median[3] - ben_api$median[1]) / 1e5
#> [1] 22µs
(ben_api$median[2] - ben_api$median[1]) / 1e5
#> [1] 87.4ns
```

``` r

ben_api2 <- bench::mark(f0(1e6), ff(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)   238.3ms  241.1ms    4.15          0B     5.54
#> 2 ff(1e+06)   319.9ms  320.7ms    3.12       1.9KB     3.12
#> 3 fp(1e+06)     22.3s    22.3s    0.0449     1.9KB     2.51
(ben_api2$median[3] - ben_api2$median[1]) / 1e6
#> [1] 22µs
(ben_api2$median[2] - ben_api2$median[1]) / 1e6
#> [1] 79.7ns
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
#> 1 test_baseline()   703.95ms 703.95ms     1.42     2.08KB        0
#> 2 test_modulo()        1.41s    1.41s     0.710    2.24KB        0
#> 3 test_cli()           1.02s    1.02s     0.984   24.09KB        0
#> 4 test_cli_unroll() 705.31ms 705.31ms     1.42     3.56KB        0
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
#> ■                                  0% | ETA: 44m
#> ■                                  0% | ETA: 39m
#> ■                                  0% | ETA: 35m
#> ■                                  0% | ETA: 32m
#> ■                                  0% | ETA: 30m
#> ■                                  0% | ETA: 28m
#> ■                                  0% | ETA: 27m
#> ■                                  0% | ETA: 25m
#> ■                                  0% | ETA: 24m
#> ■                                  0% | ETA: 23m
#> ■                                  0% | ETA: 23m
#> ■                                  0% | ETA: 22m
#> ■                                  0% | ETA: 21m
#> ■                                  0% | ETA: 21m
#> ■                                  0% | ETA: 20m
#> ■                                  0% | ETA: 19m
#> ■                                  0% | ETA: 19m
#> ■                                  0% | ETA: 19m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 17m
#> ■                                  0% | ETA: 17m
#> ■                                  0% | ETA: 17m
#> ■                                  0% | ETA: 17m
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
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
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
#> 1 cli_progress_update(force… 5.81ms 5.91ms      164.    1.41MB     2.04
cli_progress_done()
```

### Iterator without a bar

``` r

cli_progress_bar(total = NA)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ⠙ 1 done (525/s) | 3ms
#> ⠹ 2 done (73/s) | 28ms
#> ⠸ 3 done (86/s) | 35ms
#> ⠼ 4 done (96/s) | 42ms
#> ⠴ 5 done (103/s) | 49ms
#> ⠦ 6 done (109/s) | 56ms
#> ⠧ 7 done (113/s) | 63ms
#> ⠇ 8 done (116/s) | 70ms
#> ⠏ 9 done (119/s) | 76ms
#> ⠋ 10 done (121/s) | 83ms
#> ⠙ 11 done (123/s) | 90ms
#> ⠹ 12 done (125/s) | 97ms
#> ⠸ 13 done (126/s) | 103ms
#> ⠼ 14 done (128/s) | 110ms
#> ⠴ 15 done (129/s) | 117ms
#> ⠦ 16 done (130/s) | 124ms
#> ⠧ 17 done (131/s) | 131ms
#> ⠇ 18 done (132/s) | 137ms
#> ⠏ 19 done (132/s) | 144ms
#> ⠋ 20 done (133/s) | 151ms
#> ⠙ 21 done (133/s) | 158ms
#> ⠹ 22 done (134/s) | 165ms
#> ⠸ 23 done (134/s) | 172ms
#> ⠼ 24 done (131/s) | 183ms
#> ⠴ 25 done (131/s) | 191ms
#> ⠦ 26 done (131/s) | 198ms
#> ⠧ 27 done (131/s) | 206ms
#> ⠇ 28 done (131/s) | 214ms
#> ⠏ 29 done (131/s) | 221ms
#> ⠋ 30 done (131/s) | 229ms
#> ⠙ 31 done (131/s) | 237ms
#> ⠹ 32 done (131/s) | 245ms
#> ⠸ 33 done (131/s) | 252ms
#> ⠼ 34 done (131/s) | 260ms
#> ⠴ 35 done (131/s) | 268ms
#> ⠦ 36 done (131/s) | 275ms
#> ⠧ 37 done (131/s) | 283ms
#> ⠇ 38 done (132/s) | 290ms
#> ⠏ 39 done (132/s) | 296ms
#> ⠋ 40 done (132/s) | 303ms
#> ⠙ 41 done (133/s) | 310ms
#> ⠹ 42 done (133/s) | 317ms
#> ⠸ 43 done (133/s) | 324ms
#> ⠼ 44 done (133/s) | 330ms
#> ⠴ 45 done (134/s) | 337ms
#> ⠦ 46 done (134/s) | 344ms
#> ⠧ 47 done (134/s) | 351ms
#> ⠇ 48 done (134/s) | 358ms
#> ⠏ 49 done (135/s) | 365ms
#> ⠋ 50 done (135/s) | 372ms
#> ⠙ 51 done (135/s) | 379ms
#> ⠹ 52 done (135/s) | 385ms
#> ⠸ 53 done (135/s) | 392ms
#> ⠼ 54 done (136/s) | 399ms
#> ⠴ 55 done (136/s) | 406ms
#> ⠦ 56 done (136/s) | 413ms
#> ⠧ 57 done (136/s) | 420ms
#> ⠇ 58 done (136/s) | 427ms
#> ⠏ 59 done (136/s) | 433ms
#> ⠋ 60 done (136/s) | 440ms
#> ⠙ 61 done (137/s) | 447ms
#> ⠹ 62 done (137/s) | 454ms
#> ⠸ 63 done (137/s) | 461ms
#> ⠼ 64 done (137/s) | 468ms
#> ⠴ 65 done (137/s) | 475ms
#> ⠦ 66 done (137/s) | 482ms
#> ⠧ 67 done (137/s) | 488ms
#> ⠇ 68 done (137/s) | 495ms
#> ⠏ 69 done (138/s) | 502ms
#> ⠋ 70 done (138/s) | 509ms
#> ⠙ 71 done (138/s) | 516ms
#> ⠹ 72 done (138/s) | 523ms
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 6.72ms 6.85ms      143.     265KB     2.04
cli_progress_done()
```
