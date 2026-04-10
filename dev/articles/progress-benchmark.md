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
#> 1 __cli_update_due        10.01ns   10.1ns 89602622.        0B        0
#> 2 fun()                  119.91ns  150.9ns  4678977.        0B        0
#> 3 .Call(ccli_tick_reset)  99.88ns  119.9ns  7969089.        0B        0
#> 4 interactive()            9.89ns   19.9ns 53383174.        0B        0
```

``` r
ben_st2 <- bench::mark(
  if (`__cli_update_due`) foobar()
)
ben_st2
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 if (`__cli_update_due`) fo…  30ns 50.1ns 21437460.        0B        0
```

### `cli_progress_along()`

``` r
seq <- 1:100000
ta <- cli_progress_along(seq)
bench::mark(seq[[1]], ta[[1]])
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 seq[[1]]     99.9ns    120ns  7376325.        0B       0 
#> 2 ta[[1]]       110ns    131ns  6149379.        0B     615.
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
#> 1 f0()         24.2ms   24.3ms      41.2    21.6KB     206.
#> 2 fp()         26.6ms   27.2ms      36.7    82.5KB     171.
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
#> 1 f0(1e+06)     269ms    271ms      3.69        0B     29.5
#> 2 fp(1e+06)     291ms    291ms      3.43    1.88KB     29.2
(ben_taf2$median[2] - ben_taf2$median[1]) / 1e6
#> [1] 20.4ns
```

``` r
ben_taf3 <- bench::mark(f0(1e7), fp(1e7))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf3
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+07)     2.73s    2.73s     0.366        0B     30.7
#> 2 fp(1e+07)     2.91s    2.91s     0.344    1.88KB     28.9
(ben_taf3$median[2] - ben_taf3$median[1]) / 1e7
#> [1] 17.5ns
```

``` r
ben_taf4 <- bench::mark(f0(1e8), fp(1e8))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf4
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+08)     25.6s    25.6s    0.0390        0B     18.9
#> 2 fp(1e+08)       28s      28s    0.0357    1.88KB     17.2
(ben_taf4$median[2] - ben_taf4$median[1]) / 1e8
#> [1] 23.8ns
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
#> 1 f0()           90ms     93ms     10.2      781KB    13.6 
#> 2 f01()         125ms    160ms      6.42     781KB     8.03
#> 3 fp()          182ms    191ms      5.14     783KB    10.3
(ben_tam$median[3] - ben_tam$median[1]) / 1e5
#> [1] 983ns
```

``` r
ben_tam2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  966.79ms 966.79ms     1.03     7.63MB     7.24
#> 2 f01(1e+06)    1.49s    1.49s     0.671    7.63MB     4.70
#> 3 fp(1e+06)     2.03s    2.03s     0.492    7.63MB     3.94
(ben_tam2$median[3] - ben_tam2$median[1]) / 1e6
#> [1] 1.06µs
(ben_tam2$median[3] - ben_tam2$median[2]) / 1e6
#> [1] 542ns
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
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0()         77.1ms   87.3ms     11.6     1.41MB     7.70
#> 2 f01()       120.8ms  124.3ms      7.05   781.3KB     7.05
#> 3 fp()        127.9ms  134.7ms      7.30  783.24KB     3.65
(ben_pur$median[3] - ben_pur$median[1]) / 1e5
#> [1] 474ns
(ben_pur$median[3] - ben_pur$median[2]) / 1e5
#> [1] 104ns
```

``` r
ben_pur2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  933.35ms 933.35ms     1.07     7.63MB     2.14
#> 2 f01(1e+06)    1.13s    1.13s     0.888    7.63MB     1.78
#> 3 fp(1e+06)     1.47s    1.47s     0.681    7.63MB     1.36
(ben_pur2$median[3] - ben_pur2$median[1]) / 1e6
#> [1] 536ns
(ben_pur2$median[3] - ben_pur2$median[2]) / 1e6
#> [1] 343ns
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
#> 1 f0()        24.03ms  24.21ms    41.0      39.3KB     1.95
#> 2 fp()          3.94s    3.94s     0.254   100.7KB     2.03
(ben_tk$median[2] - ben_tk$median[1]) / 1e5
#> [1] 39.2µs
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
#> 1 f0()           23ms  23.24ms    37.2      18.7KB     3.91
#> 2 ff()        31.83ms  32.08ms    28.6      27.6KB     1.91
#> 3 fp()          2.21s    2.21s     0.452    25.1KB     1.81
(ben_api$median[3] - ben_api$median[1]) / 1e5
#> [1] 21.9µs
(ben_api$median[2] - ben_api$median[1]) / 1e5
#> [1] 88.4ns
```

``` r
ben_api2 <- bench::mark(f0(1e6), ff(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)   250.7ms  263.5ms    3.79          0B     3.79
#> 2 ff(1e+06)   338.6ms    382ms    2.62       1.9KB     1.31
#> 3 fp(1e+06)     22.9s    22.9s    0.0437     1.9KB     1.88
(ben_api2$median[3] - ben_api2$median[1]) / 1e6
#> [1] 22.6µs
(ben_api2$median[2] - ben_api2$median[1]) / 1e6
#> [1] 118ns
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
#> 1 test_baseline()   703.34ms 703.34ms     1.42     2.08KB        0
#> 2 test_modulo()        1.41s    1.41s     0.710    2.24KB        0
#> 3 test_cli()           1.02s    1.02s     0.984   24.09KB        0
#> 4 test_cli_unroll() 704.53ms 704.53ms     1.42     3.56KB        0
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
#> ■                                  0% | ETA: 27m
#> ■                                  0% | ETA: 26m
#> ■                                  0% | ETA: 25m
#> ■                                  0% | ETA: 24m
#> ■                                  0% | ETA: 23m
#> ■                                  0% | ETA: 22m
#> ■                                  0% | ETA: 22m
#> ■                                  0% | ETA: 21m
#> ■                                  0% | ETA: 21m
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
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
#> ■                                  0% | ETA: 13m
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force …   6ms 6.26ms      157.     1.4MB        0
cli_progress_done()
```

### Iterator without a bar

``` r
cli_progress_bar(total = NA)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ⠙ 1 done (446/s) | 3ms
#> ⠹ 2 done (68/s) | 30ms
#> ⠸ 3 done (81/s) | 38ms
#> ⠼ 4 done (90/s) | 45ms
#> ⠴ 5 done (96/s) | 53ms
#> ⠦ 6 done (101/s) | 60ms
#> ⠧ 7 done (105/s) | 67ms
#> ⠇ 8 done (107/s) | 75ms
#> ⠏ 9 done (109/s) | 83ms
#> ⠋ 10 done (111/s) | 90ms
#> ⠙ 11 done (113/s) | 98ms
#> ⠹ 12 done (115/s) | 105ms
#> ⠸ 13 done (116/s) | 113ms
#> ⠼ 14 done (117/s) | 120ms
#> ⠴ 15 done (118/s) | 128ms
#> ⠦ 16 done (119/s) | 136ms
#> ⠧ 17 done (119/s) | 143ms
#> ⠇ 18 done (120/s) | 151ms
#> ⠏ 19 done (120/s) | 158ms
#> ⠋ 20 done (121/s) | 166ms
#> ⠙ 21 done (120/s) | 176ms
#> ⠹ 22 done (120/s) | 184ms
#> ⠸ 23 done (121/s) | 191ms
#> ⠼ 24 done (121/s) | 199ms
#> ⠴ 25 done (122/s) | 206ms
#> ⠦ 26 done (122/s) | 213ms
#> ⠧ 27 done (123/s) | 220ms
#> ⠇ 28 done (123/s) | 228ms
#> ⠏ 29 done (123/s) | 236ms
#> ⠋ 30 done (124/s) | 243ms
#> ⠙ 31 done (124/s) | 250ms
#> ⠹ 32 done (124/s) | 258ms
#> ⠸ 33 done (124/s) | 266ms
#> ⠼ 34 done (125/s) | 273ms
#> ⠴ 35 done (125/s) | 281ms
#> ⠦ 36 done (125/s) | 288ms
#> ⠧ 37 done (125/s) | 296ms
#> ⠇ 38 done (126/s) | 303ms
#> ⠏ 39 done (126/s) | 311ms
#> ⠋ 40 done (126/s) | 318ms
#> ⠙ 41 done (126/s) | 326ms
#> ⠹ 42 done (126/s) | 333ms
#> ⠸ 43 done (126/s) | 341ms
#> ⠼ 44 done (126/s) | 349ms
#> ⠴ 45 done (127/s) | 356ms
#> ⠦ 46 done (127/s) | 364ms
#> ⠧ 47 done (127/s) | 372ms
#> ⠇ 48 done (126/s) | 381ms
#> ⠏ 49 done (126/s) | 389ms
#> ⠋ 50 done (126/s) | 396ms
#> ⠙ 51 done (126/s) | 404ms
#> ⠹ 52 done (126/s) | 412ms
#> ⠸ 53 done (127/s) | 420ms
#> ⠼ 54 done (127/s) | 427ms
#> ⠴ 55 done (127/s) | 435ms
#> ⠦ 56 done (127/s) | 443ms
#> ⠧ 57 done (127/s) | 450ms
#> ⠇ 58 done (127/s) | 458ms
#> ⠏ 59 done (127/s) | 466ms
#> ⠋ 60 done (127/s) | 473ms
#> ⠙ 61 done (127/s) | 481ms
#> ⠹ 62 done (127/s) | 489ms
#> ⠸ 63 done (127/s) | 497ms
#> ⠼ 64 done (127/s) | 505ms
#> ⠴ 65 done (127/s) | 512ms
#> ⠦ 66 done (127/s) | 520ms
#> ⠧ 67 done (127/s) | 528ms
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 7.28ms 7.59ms      131.     265KB        0
cli_progress_done()
```
