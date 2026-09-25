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
#> 1 __cli_update_due         6.05ns   9.89ns 93291584.        0B        0
#> 2 fun()                   84.05ns  91.04ns  6390020.        0B        0
#> 3 .Call(ccli_tick_reset)  88.94ns  98.95ns  9590573.        0B        0
#> 4 interactive()           10.01ns  14.09ns 66945475.        0B        0
```

``` r

ben_st2 <- bench::mark(
  if (`__cli_update_due`) foobar()
)
ben_st2
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 if (`__cli_update_due`) fo…  29ns   35ns 25371926.        0B        0
```

### `cli_progress_along()`

``` r

seq <- 1:100000
ta <- cli_progress_along(seq)
bench::mark(seq[[1]], ta[[1]])
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 seq[[1]]       85ns     93ns  9693552.        0B        0
#> 2 ta[[1]]        93ns    100ns  8714072.        0B        0
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
#> 1 f0()         17.4ms   17.4ms      57.4    21.6KB     421.
#> 2 fp()           19ms   19.2ms      52.1    82.5KB     574.
(ben_taf$median[2] - ben_taf$median[1]) / 1e5
#> [1] 17.6ns
```

``` r

ben_taf2 <- bench::mark(f0(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf2
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     187ms    188ms      5.32        0B     46.1
#> 2 fp(1e+06)     193ms    195ms      4.47     1.9KB     22.4
(ben_taf2$median[2] - ben_taf2$median[1]) / 1e6
#> [1] 6.88ns
```

``` r

ben_taf3 <- bench::mark(f0(1e7), fp(1e7))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf3
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+07)     1.91s    1.91s     0.524        0B     24.6
#> 2 fp(1e+07)     1.96s    1.96s     0.509     1.9KB     24.4
(ben_taf3$median[2] - ben_taf3$median[1]) / 1e7
#> [1] 5.6ns
```

``` r

ben_taf4 <- bench::mark(f0(1e8), fp(1e8))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf4
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+08)     18.9s    18.9s    0.0530        0B     27.8
#> 2 fp(1e+08)     19.9s    19.9s    0.0502     1.9KB     26.1
(ben_taf4$median[2] - ben_taf4$median[1]) / 1e8
#> [1] 10.6ns
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
#> 1 f0()         73.5ms   79.8ms      9.05     781KB     18.1
#> 2 f01()        80.4ms   82.7ms     11.6      781KB     15.4
#> 3 fp()         90.7ms   97.1ms      9.33     783KB     13.1
(ben_tam$median[3] - ben_tam$median[1]) / 1e5
#> [1] 173ns
```

``` r

ben_tam2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  942.19ms 942.19ms     1.06     7.63MB     8.49
#> 2 f01(1e+06)    1.57s    1.57s     0.637    7.63MB     2.55
#> 3 fp(1e+06)     1.21s    1.21s     0.825    7.63MB     4.95
(ben_tam2$median[3] - ben_tam2$median[1]) / 1e6
#> [1] 270ns
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
#> 1 f0()         56.7ms   56.9ms      17.4    1.44MB    11.6 
#> 2 f01()          65ms   65.8ms      14.8   781.3KB     8.85
#> 3 fp()         67.5ms   67.7ms      14.6  783.26KB    11.0
(ben_pur$median[3] - ben_pur$median[1]) / 1e5
#> [1] 108ns
(ben_pur$median[3] - ben_pur$median[2]) / 1e5
#> [1] 19.1ns
```

``` r

ben_pur2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  733.83ms 733.83ms     1.36     7.63MB     4.09
#> 2 f01(1e+06) 903.24ms 903.24ms     1.11     7.63MB     3.32
#> 3 fp(1e+06)     1.26s    1.26s     0.796    7.63MB     3.18
(ben_pur2$median[3] - ben_pur2$median[1]) / 1e6
#> [1] 523ns
(ben_pur2$median[3] - ben_pur2$median[2]) / 1e6
#> [1] 353ns
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
#> 1 f0()        17.65ms  24.35ms    40.8      39.3KB     3.89
#> 2 fp()          3.57s    3.57s     0.280   100.8KB     3.64
(ben_tk$median[2] - ben_tk$median[1]) / 1e5
#> [1] 35.5µs
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
#> 1 f0()        18.77ms  32.33ms    29.5      18.7KB     3.93
#> 2 ff()        25.88ms  39.04ms    24.7      27.6KB     3.80
#> 3 fp()          3.28s    3.28s     0.305    25.1KB     1.83
(ben_api$median[3] - ben_api$median[1]) / 1e5
#> [1] 32.4µs
(ben_api$median[2] - ben_api$median[1]) / 1e5
#> [1] 67ns
```

``` r

ben_api2 <- bench::mark(f0(1e6), ff(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     179ms    197ms    4.92          0B     4.92
#> 2 ff(1e+06)     254ms    254ms    3.94      1.91KB     3.94
#> 3 fp(1e+06)       17s      17s    0.0590    1.91KB     3.24
(ben_api2$median[3] - ben_api2$median[1]) / 1e6
#> [1] 16.8µs
(ben_api2$median[2] - ben_api2$median[1]) / 1e6
#> [1] 57.2ns
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
#> 1 test_baseline()   785.38ms 785.38ms     1.27     2.08KB        0
#> 2 test_modulo()        1.12s    1.12s     0.896    2.24KB        0
#> 3 test_cli()        817.23ms 817.23ms     1.22    24.11KB        0
#> 4 test_cli_unroll() 787.74ms 787.74ms     1.27     3.58KB        0
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
#> ■                                  0% | ETA: 49m
#> ■                                  0% | ETA: 42m
#> ■                                  0% | ETA: 38m
#> ■                                  0% | ETA: 34m
#> ■                                  0% | ETA: 31m
#> ■                                  0% | ETA: 29m
#> ■                                  0% | ETA: 27m
#> ■                                  0% | ETA: 26m
#> ■                                  0% | ETA: 25m
#> ■                                  0% | ETA: 23m
#> ■                                  0% | ETA: 22m
#> ■                                  0% | ETA: 22m
#> ■                                  0% | ETA: 21m
#> ■                                  0% | ETA: 20m
#> ■                                  0% | ETA: 20m
#> ■                                  0% | ETA: 19m
#> ■                                  0% | ETA: 19m
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
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 12m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> ■                                  0% | ETA: 11m
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 5.29ms 5.39ms      179.    1.42MB     2.04
cli_progress_done()
```

### Iterator without a bar

``` r

cli_progress_bar(total = NA)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ⠙ 1 done (524/s) | 3ms
#> ⠹ 2 done (82/s) | 25ms
#> ⠸ 3 done (97/s) | 32ms
#> ⠼ 4 done (107/s) | 38ms
#> ⠴ 5 done (115/s) | 44ms
#> ⠦ 6 done (121/s) | 50ms
#> ⠧ 7 done (125/s) | 57ms
#> ⠇ 8 done (129/s) | 63ms
#> ⠏ 9 done (132/s) | 69ms
#> ⠋ 10 done (134/s) | 75ms
#> ⠙ 11 done (137/s) | 81ms
#> ⠹ 12 done (138/s) | 87ms
#> ⠸ 13 done (140/s) | 93ms
#> ⠼ 14 done (142/s) | 100ms
#> ⠴ 15 done (143/s) | 106ms
#> ⠦ 16 done (144/s) | 112ms
#> ⠧ 17 done (145/s) | 118ms
#> ⠇ 18 done (146/s) | 124ms
#> ⠏ 19 done (147/s) | 130ms
#> ⠋ 20 done (147/s) | 136ms
#> ⠙ 21 done (148/s) | 142ms
#> ⠹ 22 done (149/s) | 149ms
#> ⠸ 23 done (149/s) | 155ms
#> ⠼ 24 done (150/s) | 161ms
#> ⠴ 25 done (150/s) | 167ms
#> ⠦ 26 done (151/s) | 173ms
#> ⠧ 27 done (151/s) | 179ms
#> ⠇ 28 done (152/s) | 185ms
#> ⠏ 29 done (152/s) | 192ms
#> ⠋ 30 done (152/s) | 198ms
#> ⠙ 31 done (153/s) | 204ms
#> ⠹ 32 done (153/s) | 210ms
#> ⠸ 33 done (153/s) | 216ms
#> ⠼ 34 done (153/s) | 222ms
#> ⠴ 35 done (153/s) | 229ms
#> ⠦ 36 done (154/s) | 235ms
#> ⠧ 37 done (154/s) | 241ms
#> ⠇ 38 done (154/s) | 247ms
#> ⠏ 39 done (154/s) | 253ms
#> ⠋ 40 done (155/s) | 259ms
#> ⠙ 41 done (155/s) | 265ms
#> ⠹ 42 done (155/s) | 272ms
#> ⠸ 43 done (155/s) | 278ms
#> ⠼ 44 done (153/s) | 289ms
#> ⠴ 45 done (153/s) | 296ms
#> ⠦ 46 done (152/s) | 303ms
#> ⠧ 47 done (152/s) | 310ms
#> ⠇ 48 done (152/s) | 317ms
#> ⠏ 49 done (152/s) | 324ms
#> ⠋ 50 done (151/s) | 331ms
#> ⠙ 51 done (151/s) | 337ms
#> ⠹ 52 done (152/s) | 343ms
#> ⠸ 53 done (152/s) | 350ms
#> ⠼ 54 done (152/s) | 356ms
#> ⠴ 55 done (152/s) | 362ms
#> ⠦ 56 done (152/s) | 368ms
#> ⠧ 57 done (152/s) | 375ms
#> ⠇ 58 done (153/s) | 381ms
#> ⠏ 59 done (153/s) | 387ms
#> ⠋ 60 done (153/s) | 393ms
#> ⠙ 61 done (153/s) | 400ms
#> ⠹ 62 done (153/s) | 406ms
#> ⠸ 63 done (153/s) | 412ms
#> ⠼ 64 done (153/s) | 418ms
#> ⠴ 65 done (153/s) | 424ms
#> ⠦ 66 done (154/s) | 430ms
#> ⠧ 67 done (154/s) | 436ms
#> ⠇ 68 done (154/s) | 443ms
#> ⠏ 69 done (154/s) | 449ms
#> ⠋ 70 done (154/s) | 455ms
#> ⠙ 71 done (154/s) | 461ms
#> ⠹ 72 done (154/s) | 467ms
#> ⠸ 73 done (154/s) | 473ms
#> ⠼ 74 done (155/s) | 479ms
#> ⠴ 75 done (155/s) | 486ms
#> ⠦ 76 done (155/s) | 492ms
#> ⠧ 77 done (155/s) | 498ms
#> ⠇ 78 done (155/s) | 504ms
#> ⠏ 79 done (155/s) | 511ms
#> ⠋ 80 done (155/s) | 517ms
#> ⠙ 81 done (155/s) | 523ms
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 6.03ms 6.15ms      160.     265KB     2.03
cli_progress_done()
```
