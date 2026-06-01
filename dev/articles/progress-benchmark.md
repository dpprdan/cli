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
#> 1 __cli_update_due              0     10ns    1.31e8        0B        0
#> 2 fun()                  130.04ns  141.1ns    4.94e6        0B        0
#> 3 .Call(ccli_tick_reset)    100ns    120ns    8.02e6        0B        0
#> 4 interactive()            8.96ns   10.1ns    5.75e7        0B        0
```

``` r

ben_st2 <- bench::mark(
  if (`__cli_update_due`) foobar()
)
ben_st2
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 if (`__cli_update_due`) fo…  40ns 41.1ns 21666679.        0B        0
```

### `cli_progress_along()`

``` r

seq <- 1:100000
ta <- cli_progress_along(seq)
bench::mark(seq[[1]], ta[[1]])
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 seq[[1]]      120ns    140ns  6372990.        0B        0
#> 2 ta[[1]]       140ns    151ns  5930598.        0B        0
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
#> 1 f0()         21.6ms   21.7ms      46.1    21.6KB     438.
#> 2 fp()         24.3ms   24.3ms      41.1    82.5KB     219.
(ben_taf$median[2] - ben_taf$median[1]) / 1e5
#> [1] 26.4ns
```

``` r

ben_taf2 <- bench::mark(f0(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf2
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     239ms    240ms      4.17        0B     37.5
#> 2 fp(1e+06)     258ms    288ms      3.48    1.88KB     24.3
(ben_taf2$median[2] - ben_taf2$median[1]) / 1e6
#> [1] 48ns
```

``` r

ben_taf3 <- bench::mark(f0(1e7), fp(1e7))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf3
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+07)     2.39s    2.39s     0.419        0B     20.1
#> 2 fp(1e+07)     2.48s    2.48s     0.403    1.88KB     19.3
(ben_taf3$median[2] - ben_taf3$median[1]) / 1e7
#> [1] 9.29ns
```

``` r

ben_taf4 <- bench::mark(f0(1e8), fp(1e8))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf4
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+08)     23.6s    23.6s    0.0424        0B     22.4
#> 2 fp(1e+08)       25s      25s    0.0400    1.88KB     21.0
(ben_taf4$median[2] - ben_taf4$median[1]) / 1e8
#> [1] 14.4ns
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
#> 1 f0()         76.9ms   89.5ms      8.98     781KB    14.4 
#> 2 f01()       101.7ms  106.8ms      8.39     781KB    11.7 
#> 3 fp()          122ms  125.3ms      7.97     783KB     7.97
(ben_tam$median[3] - ben_tam$median[1]) / 1e5
#> [1] 358ns
```

``` r

ben_tam2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     1.03s    1.03s     0.967    7.63MB     6.77
#> 2 f01(1e+06)    1.83s    1.83s     0.547    7.63MB     4.38
#> 3 fp(1e+06)     1.99s    1.99s     0.502    7.63MB     4.02
(ben_tam2$median[3] - ben_tam2$median[1]) / 1e6
#> [1] 958ns
(ben_tam2$median[3] - ben_tam2$median[2]) / 1e6
#> [1] 165ns
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
#> 1 f0()         77.1ms   85.2ms     11.8     1.44MB     7.88
#> 2 f01()       104.6ms  110.8ms      7.98   781.3KB     7.98
#> 3 fp()        121.7ms  130.8ms      7.63  783.24KB     5.72
(ben_pur$median[3] - ben_pur$median[1]) / 1e5
#> [1] 456ns
(ben_pur$median[3] - ben_pur$median[2]) / 1e5
#> [1] 201ns
```

``` r

ben_pur2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  857.13ms 857.13ms     1.17     7.63MB     1.17
#> 2 f01(1e+06)    1.12s    1.12s     0.894    7.63MB     2.68
#> 3 fp(1e+06)     1.17s    1.17s     0.853    7.63MB     2.56
(ben_pur2$median[3] - ben_pur2$median[1]) / 1e6
#> [1] 315ns
(ben_pur2$median[3] - ben_pur2$median[2]) / 1e6
#> [1] 54.2ns
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
#> 1 f0()         22.8ms  22.94ms    42.9      39.3KB     1.95
#> 2 fp()          3.97s    3.97s     0.252   100.7KB     2.02
(ben_tk$median[2] - ben_tk$median[1]) / 1e5
#> [1] 39.4µs
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
#> 1 f0()         21.4ms  21.55ms    43.9      18.7KB     3.99
#> 2 ff()        30.61ms  30.81ms    31.2      27.6KB     1.95
#> 3 fp()          2.24s    2.24s     0.446    25.1KB     2.23
(ben_api$median[3] - ben_api$median[1]) / 1e5
#> [1] 22.2µs
(ben_api$median[2] - ben_api$median[1]) / 1e5
#> [1] 92.5ns
```

``` r

ben_api2 <- bench::mark(f0(1e6), ff(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)   219.4ms  223.7ms    4.42          0B     2.95
#> 2 ff(1e+06)     324ms  324.5ms    3.08       1.9KB     3.08
#> 3 fp(1e+06)     23.2s    23.2s    0.0430     1.9KB     1.94
(ben_api2$median[3] - ben_api2$median[1]) / 1e6
#> [1] 23µs
(ben_api2$median[2] - ben_api2$median[1]) / 1e6
#> [1] 101ns
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
#> 1 test_baseline()   622.87ms 622.87ms     1.61     2.08KB        0
#> 2 test_modulo()        1.25s    1.25s     0.802    2.24KB        0
#> 3 test_cli()           1.25s    1.25s     0.798   24.09KB        0
#> 4 test_cli_unroll() 624.22ms 624.22ms     1.60     3.56KB        0
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
#> ■                                  0% | ETA: 19m
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
#> ■                                  0% | ETA: 15m
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
#> 1 cli_progress_update(force… 6.07ms 6.21ms      157.    1.41MB     2.04
cli_progress_done()
```

### Iterator without a bar

``` r

cli_progress_bar(total = NA)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ⠙ 1 done (522/s) | 3ms
#> ⠹ 2 done (70/s) | 29ms
#> ⠸ 3 done (84/s) | 36ms
#> ⠼ 4 done (93/s) | 44ms
#> ⠴ 5 done (99/s) | 51ms
#> ⠦ 6 done (104/s) | 58ms
#> ⠧ 7 done (108/s) | 65ms
#> ⠇ 8 done (111/s) | 73ms
#> ⠏ 9 done (114/s) | 80ms
#> ⠋ 10 done (116/s) | 87ms
#> ⠙ 11 done (118/s) | 94ms
#> ⠹ 12 done (119/s) | 101ms
#> ⠸ 13 done (120/s) | 109ms
#> ⠼ 14 done (121/s) | 116ms
#> ⠴ 15 done (122/s) | 123ms
#> ⠦ 16 done (123/s) | 131ms
#> ⠧ 17 done (124/s) | 138ms
#> ⠇ 18 done (125/s) | 145ms
#> ⠏ 19 done (125/s) | 152ms
#> ⠋ 20 done (126/s) | 160ms
#> ⠙ 21 done (126/s) | 167ms
#> ⠹ 22 done (127/s) | 174ms
#> ⠸ 23 done (127/s) | 181ms
#> ⠼ 24 done (128/s) | 189ms
#> ⠴ 25 done (128/s) | 196ms
#> ⠦ 26 done (129/s) | 203ms
#> ⠧ 27 done (129/s) | 211ms
#> ⠇ 28 done (129/s) | 218ms
#> ⠏ 29 done (129/s) | 225ms
#> ⠋ 30 done (129/s) | 232ms
#> ⠙ 31 done (130/s) | 240ms
#> ⠹ 32 done (130/s) | 247ms
#> ⠸ 33 done (130/s) | 254ms
#> ⠼ 34 done (131/s) | 261ms
#> ⠴ 35 done (131/s) | 268ms
#> ⠦ 36 done (131/s) | 276ms
#> ⠧ 37 done (131/s) | 283ms
#> ⠇ 38 done (131/s) | 290ms
#> ⠏ 39 done (132/s) | 297ms
#> ⠋ 40 done (132/s) | 304ms
#> ⠙ 41 done (132/s) | 312ms
#> ⠹ 42 done (132/s) | 319ms
#> ⠸ 43 done (132/s) | 326ms
#> ⠼ 44 done (131/s) | 337ms
#> ⠴ 45 done (131/s) | 344ms
#> ⠦ 46 done (131/s) | 351ms
#> ⠧ 47 done (131/s) | 359ms
#> ⠇ 48 done (131/s) | 366ms
#> ⠏ 49 done (132/s) | 373ms
#> ⠋ 50 done (132/s) | 380ms
#> ⠙ 51 done (132/s) | 388ms
#> ⠹ 52 done (132/s) | 395ms
#> ⠸ 53 done (132/s) | 402ms
#> ⠼ 54 done (132/s) | 409ms
#> ⠴ 55 done (132/s) | 417ms
#> ⠦ 56 done (132/s) | 424ms
#> ⠧ 57 done (132/s) | 431ms
#> ⠇ 58 done (133/s) | 438ms
#> ⠏ 59 done (133/s) | 445ms
#> ⠋ 60 done (133/s) | 453ms
#> ⠙ 61 done (133/s) | 460ms
#> ⠹ 62 done (133/s) | 467ms
#> ⠸ 63 done (133/s) | 475ms
#> ⠼ 64 done (133/s) | 482ms
#> ⠴ 65 done (133/s) | 489ms
#> ⠦ 66 done (133/s) | 496ms
#> ⠧ 67 done (133/s) | 504ms
#> ⠇ 68 done (133/s) | 511ms
#> ⠏ 69 done (133/s) | 519ms
#> ⠋ 70 done (133/s) | 526ms
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 7.12ms 7.22ms      138.     265KB     2.03
cli_progress_done()
```
