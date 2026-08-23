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
#> 1 __cli_update_due              0     10ns    1.09e8        0B        0
#> 2 fun()                  130.04ns  160.1ns    4.49e6        0B        0
#> 3 .Call(ccli_tick_reset)    100ns    120ns    7.99e6        0B        0
#> 4 interactive()            8.96ns   10.1ns    7.18e7        0B        0
```

``` r

ben_st2 <- bench::mark(
  if (`__cli_update_due`) foobar()
)
ben_st2
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 if (`__cli_update_due`) fo…  40ns 50.1ns 20321769.        0B        0
```

### `cli_progress_along()`

``` r

seq <- 1:100000
ta <- cli_progress_along(seq)
bench::mark(seq[[1]], ta[[1]])
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 seq[[1]]      130ns    150ns  6430178.        0B        0
#> 2 ta[[1]]       140ns    160ns  5833779.        0B        0
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
#> 1 f0()         22.3ms   22.4ms      44.7    21.6KB     403.
#> 2 fp()         24.7ms   24.7ms      40.4    82.5KB     344.
(ben_taf$median[2] - ben_taf$median[1]) / 1e5
#> [1] 23.9ns
```

``` r

ben_taf2 <- bench::mark(f0(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf2
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     241ms    246ms      4.08        0B     35.4
#> 2 fp(1e+06)     264ms    293ms      3.41     1.9KB     25.6
(ben_taf2$median[2] - ben_taf2$median[1]) / 1e6
#> [1] 47.3ns
```

``` r

ben_taf3 <- bench::mark(f0(1e7), fp(1e7))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf3
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+07)     2.43s    2.43s     0.412        0B     19.3
#> 2 fp(1e+07)     2.49s    2.49s     0.401     1.9KB     18.8
(ben_taf3$median[2] - ben_taf3$median[1]) / 1e7
#> [1] 6.54ns
```

``` r

ben_taf4 <- bench::mark(f0(1e8), fp(1e8))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf4
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+08)     23.7s    23.7s    0.0422        0B     22.2
#> 2 fp(1e+08)     25.5s    25.5s    0.0392     1.9KB     20.3
(ben_taf4$median[2] - ben_taf4$median[1]) / 1e8
#> [1] 18.3ns
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
#> 1 f0()         90.7ms    103ms      7.88     781KB    17.3 
#> 2 f01()       105.9ms    109ms      8.98     781KB    10.8 
#> 3 fp()        129.7ms    132ms      7.20     783KB     7.20
(ben_tam$median[3] - ben_tam$median[1]) / 1e5
#> [1] 290ns
```

``` r

ben_tam2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  934.65ms 934.65ms     1.07     7.63MB     7.49
#> 2 f01(1e+06)    1.55s    1.55s     0.644    7.63MB     5.15
#> 3 fp(1e+06)      2.5s     2.5s     0.400    7.63MB     2.00
(ben_tam2$median[3] - ben_tam2$median[1]) / 1e6
#> [1] 1.56µs
(ben_tam2$median[3] - ben_tam2$median[2]) / 1e6
#> [1] 944ns
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
#> 1 f0()         78.6ms   79.1ms      12.6    1.44MB     2.10
#> 2 f01()          93ms   93.4ms      10.7   781.3KB     5.35
#> 3 fp()         95.6ms   97.7ms      10.2  783.26KB     2.55
(ben_pur$median[3] - ben_pur$median[1]) / 1e5
#> [1] 186ns
(ben_pur$median[3] - ben_pur$median[2]) / 1e5
#> [1] 43.4ns
```

``` r

ben_pur2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  899.22ms 899.22ms     1.11     7.63MB     2.22
#> 2 f01(1e+06)     1.1s     1.1s     0.912    7.63MB     1.82
#> 3 fp(1e+06)     1.14s    1.14s     0.881    7.63MB     1.76
(ben_pur2$median[3] - ben_pur2$median[1]) / 1e6
#> [1] 236ns
(ben_pur2$median[3] - ben_pur2$median[2]) / 1e6
#> [1] 38.4ns
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
#> 1 f0()        22.94ms  23.07ms    42.7      39.3KB     1.94
#> 2 fp()          4.11s    4.11s     0.243   100.8KB     1.95
(ben_tk$median[2] - ben_tk$median[1]) / 1e5
#> [1] 40.9µs
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
#> 1 f0()         21.8ms     22ms    42.4      18.7KB     1.93
#> 2 ff()         31.9ms   32.1ms    29.9      27.6KB     3.98
#> 3 fp()           2.3s     2.3s     0.435    25.1KB     1.74
(ben_api$median[3] - ben_api$median[1]) / 1e5
#> [1] 22.8µs
(ben_api$median[2] - ben_api$median[1]) / 1e5
#> [1] 101ns
```

``` r

ben_api2 <- bench::mark(f0(1e6), ff(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)   224.5ms  228.3ms    4.36          0B     2.91
#> 2 ff(1e+06)   332.1ms  333.7ms    3.00      1.91KB     3.00
#> 3 fp(1e+06)     23.4s    23.4s    0.0427    1.91KB     1.66
(ben_api2$median[3] - ben_api2$median[1]) / 1e6
#> [1] 23.2µs
(ben_api2$median[2] - ben_api2$median[1]) / 1e6
#> [1] 105ns
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
#> 1 test_baseline()   623.81ms 623.81ms     1.60     2.08KB        0
#> 2 test_modulo()        1.25s    1.25s     0.801    2.24KB        0
#> 3 test_cli()           1.25s    1.25s     0.801   24.11KB        0
#> 4 test_cli_unroll() 624.28ms 624.28ms     1.60     3.58KB        0
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
#> ■                                  0% | ETA: 46m
#> ■                                  0% | ETA: 41m
#> ■                                  0% | ETA: 37m
#> ■                                  0% | ETA: 34m
#> ■                                  0% | ETA: 32m
#> ■                                  0% | ETA: 30m
#> ■                                  0% | ETA: 28m
#> ■                                  0% | ETA: 27m
#> ■                                  0% | ETA: 26m
#> ■                                  0% | ETA: 25m
#> ■                                  0% | ETA: 25m
#> ■                                  0% | ETA: 24m
#> ■                                  0% | ETA: 23m
#> ■                                  0% | ETA: 23m
#> ■                                  0% | ETA: 22m
#> ■                                  0% | ETA: 22m
#> ■                                  0% | ETA: 21m
#> ■                                  0% | ETA: 21m
#> ■                                  0% | ETA: 20m
#> ■                                  0% | ETA: 20m
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
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 6.46ms 6.54ms      148.    1.41MB     2.03
cli_progress_done()
```

### Iterator without a bar

``` r

cli_progress_bar(total = NA)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ⠙ 1 done (511/s) | 3ms
#> ⠹ 2 done (66/s) | 31ms
#> ⠸ 3 done (78/s) | 39ms
#> ⠼ 4 done (87/s) | 47ms
#> ⠴ 5 done (93/s) | 54ms
#> ⠦ 6 done (98/s) | 62ms
#> ⠧ 7 done (102/s) | 69ms
#> ⠇ 8 done (105/s) | 77ms
#> ⠏ 9 done (107/s) | 85ms
#> ⠋ 10 done (109/s) | 92ms
#> ⠙ 11 done (111/s) | 100ms
#> ⠹ 12 done (112/s) | 108ms
#> ⠸ 13 done (113/s) | 115ms
#> ⠼ 14 done (115/s) | 123ms
#> ⠴ 15 done (116/s) | 130ms
#> ⠦ 16 done (116/s) | 138ms
#> ⠧ 17 done (117/s) | 146ms
#> ⠇ 18 done (118/s) | 153ms
#> ⠏ 19 done (119/s) | 161ms
#> ⠋ 20 done (119/s) | 169ms
#> ⠙ 21 done (119/s) | 176ms
#> ⠹ 22 done (120/s) | 184ms
#> ⠸ 23 done (120/s) | 192ms
#> ⠼ 24 done (121/s) | 199ms
#> ⠴ 25 done (121/s) | 207ms
#> ⠦ 26 done (122/s) | 214ms
#> ⠧ 27 done (122/s) | 222ms
#> ⠇ 28 done (122/s) | 230ms
#> ⠏ 29 done (123/s) | 237ms
#> ⠋ 30 done (123/s) | 245ms
#> ⠙ 31 done (123/s) | 253ms
#> ⠹ 32 done (123/s) | 260ms
#> ⠸ 33 done (124/s) | 268ms
#> ⠼ 34 done (122/s) | 280ms
#> ⠴ 35 done (122/s) | 288ms
#> ⠦ 36 done (122/s) | 296ms
#> ⠧ 37 done (122/s) | 304ms
#> ⠇ 38 done (122/s) | 313ms
#> ⠏ 39 done (122/s) | 321ms
#> ⠋ 40 done (122/s) | 329ms
#> ⠙ 41 done (122/s) | 338ms
#> ⠹ 42 done (122/s) | 346ms
#> ⠸ 43 done (122/s) | 354ms
#> ⠼ 44 done (122/s) | 362ms
#> ⠴ 45 done (122/s) | 370ms
#> ⠦ 46 done (122/s) | 378ms
#> ⠧ 47 done (122/s) | 385ms
#> ⠇ 48 done (122/s) | 393ms
#> ⠏ 49 done (123/s) | 401ms
#> ⠋ 50 done (123/s) | 408ms
#> ⠙ 51 done (123/s) | 416ms
#> ⠹ 52 done (123/s) | 423ms
#> ⠸ 53 done (123/s) | 431ms
#> ⠼ 54 done (123/s) | 438ms
#> ⠴ 55 done (123/s) | 446ms
#> ⠦ 56 done (124/s) | 454ms
#> ⠧ 57 done (124/s) | 461ms
#> ⠇ 58 done (124/s) | 469ms
#> ⠏ 59 done (124/s) | 476ms
#> ⠋ 60 done (124/s) | 484ms
#> ⠙ 61 done (124/s) | 492ms
#> ⠹ 62 done (124/s) | 499ms
#> ⠸ 63 done (124/s) | 507ms
#> ⠼ 64 done (125/s) | 514ms
#> ⠴ 65 done (125/s) | 522ms
#> ⠦ 66 done (125/s) | 530ms
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 7.51ms  7.6ms      130.     265KB     2.02
cli_progress_done()
```
