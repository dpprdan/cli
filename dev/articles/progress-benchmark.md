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
#> 1 __cli_update_due              0     10ns    1.03e8        0B        0
#> 2 fun()                  130.04ns  150.1ns    4.47e6        0B        0
#> 3 .Call(ccli_tick_reset)    100ns    120ns    8.13e6        0B        0
#> 4 interactive()            8.96ns   11.1ns    6.67e7        0B        0
```

``` r
ben_st2 <- bench::mark(
  if (`__cli_update_due`) foobar()
)
ben_st2
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 if (`__cli_update_due`) fo…  29ns 39.9ns 22901197.        0B        0
```

### `cli_progress_along()`

``` r
seq <- 1:100000
ta <- cli_progress_along(seq)
bench::mark(seq[[1]], ta[[1]])
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 seq[[1]]      120ns    140ns  6717048.        0B       0 
#> 2 ta[[1]]       130ns    150ns  5836235.        0B     584.
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
#> 1 f0()         22.3ms   22.3ms      44.7    21.6KB     253.
#> 2 fp()         25.2ms   25.5ms      39.1    82.3KB     195.
(ben_taf$median[2] - ben_taf$median[1]) / 1e5
#> [1] 31.9ns
```

``` r
ben_taf2 <- bench::mark(f0(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf2
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     247ms    248ms      4.03        0B     33.6
#> 2 fp(1e+06)     268ms    269ms      3.72    1.88KB     31.6
(ben_taf2$median[2] - ben_taf2$median[1]) / 1e6
#> [1] 20.8ns
```

``` r
ben_taf3 <- bench::mark(f0(1e7), fp(1e7))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf3
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+07)     2.52s    2.52s     0.396        0B     33.3
#> 2 fp(1e+07)     2.61s    2.61s     0.383    1.88KB     31.8
(ben_taf3$median[2] - ben_taf3$median[1]) / 1e7
#> [1] 8.54ns
```

``` r
ben_taf4 <- bench::mark(f0(1e8), fp(1e8))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf4
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+08)     23.8s    23.8s    0.0420        0B     20.5
#> 2 fp(1e+08)     25.7s    25.7s    0.0389    1.88KB     18.8
(ben_taf4$median[2] - ben_taf4$median[1]) / 1e8
#> [1] 19.1ns
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
#> 1 f0()           85ms   93.7ms     10.6      781KB     12.4
#> 2 f01()         116ms  122.1ms      7.55     781KB     13.2
#> 3 fp()          127ms  131.3ms      7.48     783KB     13.1
(ben_tam$median[3] - ben_tam$median[1]) / 1e5
#> [1] 376ns
```

``` r
ben_tam2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  880.57ms 880.57ms     1.14     7.63MB     4.54
#> 2 f01(1e+06)    1.11s    1.11s     0.900    7.63MB     5.40
#> 3 fp(1e+06)     1.37s    1.37s     0.731    7.63MB     3.65
(ben_tam2$median[3] - ben_tam2$median[1]) / 1e6
#> [1] 488ns
(ben_tam2$median[3] - ben_tam2$median[2]) / 1e6
#> [1] 257ns
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
#> 1 f0()         77.9ms   78.2ms      12.7    1.41MB     5.07
#> 2 f01()        89.5ms   89.5ms      11.2   781.3KB    16.8 
#> 3 fp()         92.6ms   94.3ms      10.6  783.24KB     7.07
(ben_pur$median[3] - ben_pur$median[1]) / 1e5
#> [1] 160ns
(ben_pur$median[3] - ben_pur$median[2]) / 1e5
#> [1] 47.4ns
```

``` r
ben_pur2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     2.12s    2.12s     0.473    7.63MB    0.945
#> 2 f01(1e+06)    1.12s    1.12s     0.892    7.63MB    3.57 
#> 3 fp(1e+06)     1.45s    1.45s     0.689    7.63MB    2.76
(ben_pur2$median[3] - ben_pur2$median[1]) / 1e6
#> [1] 1ns
(ben_pur2$median[3] - ben_pur2$median[2]) / 1e6
#> [1] 330ns
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
#> 1 f0()        26.57ms  32.18ms    30.7      39.3KB     3.84
#> 2 fp()          4.58s    4.58s     0.218   100.4KB     3.49
(ben_tk$median[2] - ben_tk$median[1]) / 1e5
#> [1] 45.5µs
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
#> 1 f0()        22.46ms  44.64ms    23.5      18.7KB     3.92
#> 2 ff()         31.7ms  51.56ms    21.5      27.6KB     3.90
#> 3 fp()          2.57s    2.57s     0.388    25.1KB     3.11
(ben_api$median[3] - ben_api$median[1]) / 1e5
#> [1] 25.3µs
(ben_api$median[2] - ben_api$median[1]) / 1e5
#> [1] 69.1ns
```

``` r
ben_api2 <- bench::mark(f0(1e6), ff(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)   222.8ms    223ms    4.47          0B     4.47
#> 2 ff(1e+06)   315.6ms  316.4ms    3.16       1.9KB     3.16
#> 3 fp(1e+06)     22.6s    22.6s    0.0442     1.9KB     2.39
(ben_api2$median[3] - ben_api2$median[1]) / 1e6
#> [1] 22.4µs
(ben_api2$median[2] - ben_api2$median[1]) / 1e6
#> [1] 93.5ns
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
#> 1 test_baseline()   623.29ms 623.29ms     1.60     2.08KB        0
#> 2 test_modulo()        1.25s    1.25s     0.802    2.24KB        0
#> 3 test_cli()           1.25s    1.25s     0.803    23.9KB        0
#> 4 test_cli_unroll() 623.99ms 623.99ms     1.60     3.56KB        0
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
#> ■                                  0% | ETA: 33m
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
#> ■                                  0% | ETA: 19m
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
#> ■                                  0% | ETA: 14m
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 6.26ms 6.45ms      151.     1.4MB     2.05
cli_progress_done()
```

### Iterator without a bar

``` r
cli_progress_bar(total = NA)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ⠙ 1 done (484/s) | 3ms
#> ⠹ 2 done (67/s) | 30ms
#> ⠸ 3 done (80/s) | 38ms
#> ⠼ 4 done (89/s) | 45ms
#> ⠴ 5 done (96/s) | 53ms
#> ⠦ 6 done (101/s) | 60ms
#> ⠧ 7 done (105/s) | 68ms
#> ⠇ 8 done (108/s) | 75ms
#> ⠏ 9 done (110/s) | 82ms
#> ⠋ 10 done (112/s) | 90ms
#> ⠙ 11 done (114/s) | 97ms
#> ⠹ 12 done (115/s) | 105ms
#> ⠸ 13 done (117/s) | 112ms
#> ⠼ 14 done (118/s) | 120ms
#> ⠴ 15 done (119/s) | 127ms
#> ⠦ 16 done (119/s) | 135ms
#> ⠧ 17 done (120/s) | 142ms
#> ⠇ 18 done (121/s) | 150ms
#> ⠏ 19 done (121/s) | 157ms
#> ⠋ 20 done (119/s) | 169ms
#> ⠙ 21 done (119/s) | 177ms
#> ⠹ 22 done (119/s) | 185ms
#> ⠸ 23 done (119/s) | 193ms
#> ⠼ 24 done (119/s) | 201ms
#> ⠴ 25 done (120/s) | 210ms
#> ⠦ 26 done (120/s) | 218ms
#> ⠧ 27 done (120/s) | 226ms
#> ⠇ 28 done (120/s) | 233ms
#> ⠏ 29 done (121/s) | 241ms
#> ⠋ 30 done (121/s) | 248ms
#> ⠙ 31 done (122/s) | 256ms
#> ⠹ 32 done (122/s) | 263ms
#> ⠸ 33 done (122/s) | 271ms
#> ⠼ 34 done (123/s) | 278ms
#> ⠴ 35 done (123/s) | 286ms
#> ⠦ 36 done (123/s) | 293ms
#> ⠧ 37 done (123/s) | 301ms
#> ⠇ 38 done (124/s) | 308ms
#> ⠏ 39 done (124/s) | 316ms
#> ⠋ 40 done (124/s) | 323ms
#> ⠙ 41 done (124/s) | 331ms
#> ⠹ 42 done (124/s) | 338ms
#> ⠸ 43 done (124/s) | 346ms
#> ⠼ 44 done (125/s) | 354ms
#> ⠴ 45 done (125/s) | 361ms
#> ⠦ 46 done (125/s) | 368ms
#> ⠧ 47 done (125/s) | 376ms
#> ⠇ 48 done (125/s) | 384ms
#> ⠏ 49 done (126/s) | 391ms
#> ⠋ 50 done (126/s) | 399ms
#> ⠙ 51 done (126/s) | 406ms
#> ⠹ 52 done (126/s) | 414ms
#> ⠸ 53 done (126/s) | 421ms
#> ⠼ 54 done (126/s) | 429ms
#> ⠴ 55 done (126/s) | 436ms
#> ⠦ 56 done (126/s) | 443ms
#> ⠧ 57 done (127/s) | 451ms
#> ⠇ 58 done (127/s) | 459ms
#> ⠏ 59 done (127/s) | 466ms
#> ⠋ 60 done (127/s) | 474ms
#> ⠙ 61 done (127/s) | 481ms
#> ⠹ 62 done (127/s) | 489ms
#> ⠸ 63 done (127/s) | 496ms
#> ⠼ 64 done (127/s) | 503ms
#> ⠴ 65 done (127/s) | 511ms
#> ⠦ 66 done (127/s) | 518ms
#> ⠧ 67 done (128/s) | 526ms
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 7.35ms 7.48ms      132.     265KB     2.04
cli_progress_done()
```
