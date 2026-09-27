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
#> 1 __cli_update_due              0   10.1ns 92721259.        0B        0
#> 2 fun()                    80.1ns    110ns  5905303.        0B        0
#> 3 .Call(ccli_tick_reset)     80ns   90.1ns 10184143.        0B        0
#> 4 interactive()              10ns   10.1ns 63873663.        0B        0
```

``` r

ben_st2 <- bench::mark(
  if (`__cli_update_due`) foobar()
)
ben_st2
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 if (`__cli_update_due`) fo…  30ns   40ns 25032820.        0B        0
```

### `cli_progress_along()`

``` r

seq <- 1:100000
ta <- cli_progress_along(seq)
bench::mark(seq[[1]], ta[[1]])
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 seq[[1]]     89.9ns    110ns  7547461.        0B        0
#> 2 ta[[1]]      90.1ns    111ns  7259667.        0B        0
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
#> 1 f0()         18.9ms   19.1ms      52.2    21.6KB     331.
#> 2 fp()         21.5ms   21.9ms      45.6    82.5KB     433.
(ben_taf$median[2] - ben_taf$median[1]) / 1e5
#> [1] 28.6ns
```

``` r

ben_taf2 <- bench::mark(f0(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf2
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     220ms    221ms      4.52        0B     40.7
#> 2 fp(1e+06)     217ms    265ms      3.77     1.9KB     24.5
(ben_taf2$median[2] - ben_taf2$median[1]) / 1e6
#> [1] 44.3ns
```

``` r

ben_taf3 <- bench::mark(f0(1e7), fp(1e7))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf3
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+07)     2.13s    2.13s     0.469        0B     22.1
#> 2 fp(1e+07)     2.18s    2.18s     0.458     1.9KB     21.5
(ben_taf3$median[2] - ben_taf3$median[1]) / 1e7
#> [1] 4.99ns
```

``` r

ben_taf4 <- bench::mark(f0(1e8), fp(1e8))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf4
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+08)     20.8s    20.8s    0.0481        0B     25.2
#> 2 fp(1e+08)     22.2s    22.2s    0.0451     1.9KB     23.4
(ben_taf4$median[2] - ben_taf4$median[1]) / 1e8
#> [1] 13.7ns
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
#> 1 f0()         79.8ms    102ms      7.42     781KB    16.3 
#> 2 f01()        87.7ms   92.7ms      9.40     781KB     9.40
#> 3 fp()         93.9ms  109.8ms      8.91     783KB    12.5
(ben_tam$median[3] - ben_tam$median[1]) / 1e5
#> [1] 78ns
```

``` r

ben_tam2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     1.01s    1.01s     0.990    7.63MB     6.93
#> 2 f01(1e+06)    3.05s    3.05s     0.328    7.63MB     2.62
#> 3 fp(1e+06)  913.03ms 913.03ms     1.10     7.63MB     2.19
(ben_tam2$median[3] - ben_tam2$median[1]) / 1e6
#> [1] 1ns
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
#> 1 f0()         57.8ms   57.9ms      17.2    1.44MB     4.91
#> 2 f01()        70.5ms   71.5ms      13.2   781.3KB     5.28
#> 3 fp()           72ms   75.6ms      13.0  783.26KB     5.19
(ben_pur$median[3] - ben_pur$median[1]) / 1e5
#> [1] 176ns
(ben_pur$median[3] - ben_pur$median[2]) / 1e5
#> [1] 40.1ns
```

``` r

ben_pur2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  717.85ms 717.85ms     1.39     7.63MB     2.79
#> 2 f01(1e+06)  889.8ms  889.8ms     1.12     7.63MB     2.25
#> 3 fp(1e+06)     1.35s    1.35s     0.743    7.63MB     2.23
(ben_pur2$median[3] - ben_pur2$median[1]) / 1e6
#> [1] 628ns
(ben_pur2$median[3] - ben_pur2$median[2]) / 1e6
#> [1] 456ns
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
#> 1 f0()        19.93ms  24.34ms    38.9      39.3KB     1.94
#> 2 fp()          3.38s    3.38s     0.296   100.8KB     2.66
(ben_tk$median[2] - ben_tk$median[1]) / 1e5
#> [1] 33.6µs
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
#> 1 f0()        18.16ms  37.59ms    27.9      18.7KB     3.98
#> 2 ff()        25.28ms  45.41ms    23.8      27.6KB     1.98
#> 3 fp()          1.91s    1.91s     0.523    25.1KB     2.61
(ben_api$median[3] - ben_api$median[1]) / 1e5
#> [1] 18.8µs
(ben_api$median[2] - ben_api$median[1]) / 1e5
#> [1] 78.2ns
```

``` r

ben_api2 <- bench::mark(f0(1e6), ff(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     181ms    181ms    5.39          0B     5.39
#> 2 ff(1e+06)     246ms    248ms    4.04      1.91KB     2.69
#> 3 fp(1e+06)       17s      17s    0.0589    1.91KB     2.47
(ben_api2$median[3] - ben_api2$median[1]) / 1e6
#> [1] 16.8µs
(ben_api2$median[2] - ben_api2$median[1]) / 1e6
#> [1] 66.1ns
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
#> 1 test_baseline()   546.29ms 546.29ms     1.83     2.08KB        0
#> 2 test_modulo()        1.09s    1.09s     0.915    2.24KB        0
#> 3 test_cli()        789.28ms 789.28ms     1.27    24.11KB        0
#> 4 test_cli_unroll() 546.66ms 546.66ms     1.83     3.58KB        0
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
#> ■                                  0% | ETA:  3m
#> ■                                  0% | ETA:  1h
#> ■                                  0% | ETA:  1h
#> ■                                  0% | ETA: 49m
#> ■                                  0% | ETA: 41m
#> ■                                  0% | ETA: 35m
#> ■                                  0% | ETA: 32m
#> ■                                  0% | ETA: 29m
#> ■                                  0% | ETA: 26m
#> ■                                  0% | ETA: 24m
#> ■                                  0% | ETA: 23m
#> ■                                  0% | ETA: 22m
#> ■                                  0% | ETA: 21m
#> ■                                  0% | ETA: 20m
#> ■                                  0% | ETA: 19m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 18m
#> ■                                  0% | ETA: 17m
#> ■                                  0% | ETA: 17m
#> ■                                  0% | ETA: 17m
#> ■                                  0% | ETA: 16m
#> ■                                  0% | ETA: 16m
#> ■                                  0% | ETA: 16m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
#> ■                                  0% | ETA: 15m
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
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> ■                                  0% | ETA: 10m
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 4.74ms 4.86ms      202.    1.42MB     2.04
cli_progress_done()
```

### Iterator without a bar

``` r

cli_progress_bar(total = NA)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ⠙ 1 done (562/s) | 2ms
#> ⠹ 2 done (83/s) | 25ms
#> ⠸ 3 done (99/s) | 31ms
#> ⠼ 4 done (111/s) | 36ms
#> ⠴ 5 done (120/s) | 42ms
#> ⠦ 6 done (127/s) | 48ms
#> ⠧ 7 done (133/s) | 53ms
#> ⠇ 8 done (137/s) | 59ms
#> ⠏ 9 done (141/s) | 65ms
#> ⠋ 10 done (144/s) | 70ms
#> ⠙ 11 done (137/s) | 81ms
#> ⠹ 12 done (140/s) | 87ms
#> ⠸ 13 done (142/s) | 92ms
#> ⠼ 14 done (144/s) | 98ms
#> ⠴ 15 done (146/s) | 103ms
#> ⠦ 16 done (148/s) | 109ms
#> ⠧ 17 done (149/s) | 115ms
#> ⠇ 18 done (150/s) | 120ms
#> ⠏ 19 done (151/s) | 126ms
#> ⠋ 20 done (153/s) | 132ms
#> ⠙ 21 done (154/s) | 137ms
#> ⠹ 22 done (154/s) | 143ms
#> ⠸ 23 done (155/s) | 149ms
#> ⠼ 24 done (156/s) | 154ms
#> ⠴ 25 done (157/s) | 160ms
#> ⠦ 26 done (157/s) | 166ms
#> ⠧ 27 done (158/s) | 172ms
#> ⠇ 28 done (158/s) | 177ms
#> ⠏ 29 done (159/s) | 183ms
#> ⠋ 30 done (159/s) | 189ms
#> ⠙ 31 done (160/s) | 195ms
#> ⠹ 32 done (160/s) | 200ms
#> ⠸ 33 done (161/s) | 206ms
#> ⠼ 34 done (161/s) | 212ms
#> ⠴ 35 done (161/s) | 218ms
#> ⠦ 36 done (162/s) | 223ms
#> ⠧ 37 done (162/s) | 229ms
#> ⠇ 38 done (162/s) | 235ms
#> ⠏ 39 done (162/s) | 241ms
#> ⠋ 40 done (162/s) | 247ms
#> ⠙ 41 done (162/s) | 253ms
#> ⠹ 42 done (163/s) | 259ms
#> ⠸ 43 done (163/s) | 265ms
#> ⠼ 44 done (163/s) | 270ms
#> ⠴ 45 done (163/s) | 276ms
#> ⠦ 46 done (163/s) | 282ms
#> ⠧ 47 done (164/s) | 288ms
#> ⠇ 48 done (164/s) | 293ms
#> ⠏ 49 done (164/s) | 299ms
#> ⠋ 50 done (164/s) | 305ms
#> ⠙ 51 done (164/s) | 311ms
#> ⠹ 52 done (165/s) | 316ms
#> ⠸ 53 done (165/s) | 322ms
#> ⠼ 54 done (165/s) | 328ms
#> ⠴ 55 done (165/s) | 334ms
#> ⠦ 56 done (165/s) | 339ms
#> ⠧ 57 done (165/s) | 345ms
#> ⠇ 58 done (166/s) | 351ms
#> ⠏ 59 done (166/s) | 356ms
#> ⠋ 60 done (166/s) | 362ms
#> ⠙ 61 done (166/s) | 368ms
#> ⠹ 62 done (166/s) | 374ms
#> ⠸ 63 done (166/s) | 379ms
#> ⠼ 64 done (166/s) | 385ms
#> ⠴ 65 done (167/s) | 391ms
#> ⠦ 66 done (167/s) | 396ms
#> ⠧ 67 done (167/s) | 402ms
#> ⠇ 68 done (167/s) | 408ms
#> ⠏ 69 done (167/s) | 414ms
#> ⠋ 70 done (167/s) | 419ms
#> ⠙ 71 done (167/s) | 425ms
#> ⠹ 72 done (167/s) | 431ms
#> ⠸ 73 done (167/s) | 437ms
#> ⠼ 74 done (168/s) | 442ms
#> ⠴ 75 done (168/s) | 448ms
#> ⠦ 76 done (168/s) | 454ms
#> ⠧ 77 done (168/s) | 459ms
#> ⠇ 78 done (168/s) | 465ms
#> ⠏ 79 done (168/s) | 471ms
#> ⠋ 80 done (168/s) | 477ms
#> ⠙ 81 done (168/s) | 482ms
#> ⠹ 82 done (168/s) | 488ms
#> ⠸ 83 done (168/s) | 494ms
#> ⠼ 84 done (168/s) | 500ms
#> ⠴ 85 done (168/s) | 506ms
#> ⠦ 86 done (168/s) | 511ms
#> ⠧ 87 done (168/s) | 517ms
#> ⠇ 88 done (169/s) | 523ms
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 5.52ms 5.72ms      175.     266KB     2.03
cli_progress_done()
```
