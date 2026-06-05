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
#> 1 __cli_update_due              0   9.89ns    1.37e8        0B        0
#> 2 fun()                  120.02ns 140.05ns    4.91e6        0B        0
#> 3 .Call(ccli_tick_reset)    100ns 111.06ns    8.19e6        0B        0
#> 4 interactive()            8.96ns  10.13ns    6.92e7        0B        0
```

``` r

ben_st2 <- bench::mark(
  if (`__cli_update_due`) foobar()
)
ben_st2
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 if (`__cli_update_due`) fo…  40ns   41ns 21197562.        0B        0
```

### `cli_progress_along()`

``` r

seq <- 1:100000
ta <- cli_progress_along(seq)
bench::mark(seq[[1]], ta[[1]])
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 seq[[1]]      121ns    141ns  6433842.        0B        0
#> 2 ta[[1]]       140ns    151ns  5840913.        0B        0
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
#> 1 f0()         22.1ms   22.1ms      45.3    21.6KB     407.
#> 2 fp()         24.5ms   24.9ms      40.2    82.5KB     342.
(ben_taf$median[2] - ben_taf$median[1]) / 1e5
#> [1] 27.8ns
```

``` r

ben_taf2 <- bench::mark(f0(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf2
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     240ms    242ms      4.14        0B     35.9
#> 2 fp(1e+06)     261ms    290ms      3.44    1.88KB     25.8
(ben_taf2$median[2] - ben_taf2$median[1]) / 1e6
#> [1] 48.6ns
```

``` r

ben_taf3 <- bench::mark(f0(1e7), fp(1e7))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf3
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+07)     2.41s    2.41s     0.415        0B     19.9
#> 2 fp(1e+07)     2.49s    2.49s     0.401    1.88KB     18.9
(ben_taf3$median[2] - ben_taf3$median[1]) / 1e7
#> [1] 8.43ns
```

``` r

ben_taf4 <- bench::mark(f0(1e8), fp(1e8))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf4
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+08)     23.5s    23.5s    0.0425        0B     22.4
#> 2 fp(1e+08)     25.1s    25.1s    0.0399    1.88KB     20.9
(ben_taf4$median[2] - ben_taf4$median[1]) / 1e8
#> [1] 15.2ns
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
#> 1 f0()         84.3ms   86.9ms      9.15     781KB    14.6 
#> 2 f01()       104.1ms  115.5ms      8.86     781KB    14.2 
#> 3 fp()        118.7ms  137.1ms      6.94     783KB     8.68
(ben_tam$median[3] - ben_tam$median[1]) / 1e5
#> [1] 502ns
```

``` r

ben_tam2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     1.78s    1.78s     0.560    7.63MB     4.48
#> 2 f01(1e+06)    1.05s    1.05s     0.951    7.63MB     1.90
#> 3 fp(1e+06)     1.13s    1.13s     0.884    7.63MB     3.53
(ben_tam2$median[3] - ben_tam2$median[1]) / 1e6
#> [1] 1ns
(ben_tam2$median[3] - ben_tam2$median[2]) / 1e6
#> [1] 80.2ns
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
#> 1 f0()         75.8ms     76ms      13.1    1.44MB     2.18
#> 2 f01()        90.7ms   91.1ms      10.9   781.3KB     2.18
#> 3 fp()         93.8ms   94.6ms      10.6  783.24KB     5.29
(ben_pur$median[3] - ben_pur$median[1]) / 1e5
#> [1] 186ns
(ben_pur$median[3] - ben_pur$median[2]) / 1e5
#> [1] 35.4ns
```

``` r

ben_pur2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)   917.3ms  917.3ms     1.09     7.63MB     2.18
#> 2 f01(1e+06)    1.06s    1.06s     0.946    7.63MB     1.89
#> 3 fp(1e+06)     1.17s    1.17s     0.852    7.63MB     2.56
(ben_pur2$median[3] - ben_pur2$median[1]) / 1e6
#> [1] 256ns
(ben_pur2$median[3] - ben_pur2$median[2]) / 1e6
#> [1] 117ns
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
#> 1 f0()        23.07ms  23.14ms    42.6      39.3KB     1.94
#> 2 fp()          4.04s    4.04s     0.248   100.8KB     1.98
(ben_tk$median[2] - ben_tk$median[1]) / 1e5
#> [1] 40.2µs
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
#> 1 f0()        21.63ms   21.8ms    39.1      18.7KB     3.91
#> 2 ff()        30.86ms  30.98ms    29.0      27.6KB     1.93
#> 3 fp()          2.24s    2.24s     0.447    25.1KB     1.79
(ben_api$median[3] - ben_api$median[1]) / 1e5
#> [1] 22.2µs
(ben_api$median[2] - ben_api$median[1]) / 1e5
#> [1] 91.9ns
```

``` r

ben_api2 <- bench::mark(f0(1e6), ff(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     232ms    242ms    4.05          0B     2.70
#> 2 ff(1e+06)     329ms    341ms    2.93       1.9KB     2.93
#> 3 fp(1e+06)       23s      23s    0.0436     1.9KB     1.87
(ben_api2$median[3] - ben_api2$median[1]) / 1e6
#> [1] 22.7µs
(ben_api2$median[2] - ben_api2$median[1]) / 1e6
#> [1] 99.2ns
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
#> 1 test_baseline()   627.17ms 627.17ms     1.59     2.08KB        0
#> 2 test_modulo()        1.25s    1.25s     0.800    2.24KB        0
#> 3 test_cli()           1.25s    1.25s     0.803   24.09KB        0
#> 4 test_cli_unroll() 626.83ms 626.83ms     1.60     3.56KB        0
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
#> ■                                  0% | ETA: 24m
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
#> 1 cli_progress_update(force… 6.07ms 6.28ms      157.    1.41MB     2.03
cli_progress_done()
```

### Iterator without a bar

``` r

cli_progress_bar(total = NA)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ⠙ 1 done (497/s) | 3ms
#> ⠹ 2 done (70/s) | 29ms
#> ⠸ 3 done (83/s) | 37ms
#> ⠼ 4 done (92/s) | 44ms
#> ⠴ 5 done (98/s) | 52ms
#> ⠦ 6 done (103/s) | 59ms
#> ⠧ 7 done (106/s) | 66ms
#> ⠇ 8 done (109/s) | 74ms
#> ⠏ 9 done (112/s) | 81ms
#> ⠋ 10 done (114/s) | 88ms
#> ⠙ 11 done (116/s) | 96ms
#> ⠹ 12 done (117/s) | 103ms
#> ⠸ 13 done (118/s) | 110ms
#> ⠼ 14 done (119/s) | 118ms
#> ⠴ 15 done (120/s) | 125ms
#> ⠦ 16 done (121/s) | 133ms
#> ⠧ 17 done (122/s) | 140ms
#> ⠇ 18 done (123/s) | 147ms
#> ⠏ 19 done (123/s) | 155ms
#> ⠋ 20 done (124/s) | 162ms
#> ⠙ 21 done (124/s) | 170ms
#> ⠹ 22 done (125/s) | 177ms
#> ⠸ 23 done (125/s) | 185ms
#> ⠼ 24 done (125/s) | 192ms
#> ⠴ 25 done (126/s) | 200ms
#> ⠦ 26 done (126/s) | 207ms
#> ⠧ 27 done (126/s) | 215ms
#> ⠇ 28 done (126/s) | 222ms
#> ⠏ 29 done (127/s) | 229ms
#> ⠋ 30 done (127/s) | 237ms
#> ⠙ 31 done (127/s) | 244ms
#> ⠹ 32 done (128/s) | 251ms
#> ⠸ 33 done (128/s) | 259ms
#> ⠼ 34 done (128/s) | 266ms
#> ⠴ 35 done (128/s) | 274ms
#> ⠦ 36 done (128/s) | 281ms
#> ⠧ 37 done (128/s) | 289ms
#> ⠇ 38 done (129/s) | 296ms
#> ⠏ 39 done (129/s) | 304ms
#> ⠋ 40 done (129/s) | 311ms
#> ⠙ 41 done (129/s) | 318ms
#> ⠹ 42 done (129/s) | 326ms
#> ⠸ 43 done (129/s) | 333ms
#> ⠼ 44 done (129/s) | 340ms
#> ⠴ 45 done (130/s) | 348ms
#> ⠦ 46 done (130/s) | 355ms
#> ⠧ 47 done (130/s) | 363ms
#> ⠇ 48 done (130/s) | 370ms
#> ⠏ 49 done (130/s) | 377ms
#> ⠋ 50 done (130/s) | 385ms
#> ⠙ 51 done (130/s) | 393ms
#> ⠹ 52 done (130/s) | 400ms
#> ⠸ 53 done (130/s) | 407ms
#> ⠼ 54 done (130/s) | 415ms
#> ⠴ 55 done (130/s) | 423ms
#> ⠦ 56 done (130/s) | 430ms
#> ⠧ 57 done (130/s) | 438ms
#> ⠇ 58 done (131/s) | 445ms
#> ⠏ 59 done (131/s) | 452ms
#> ⠋ 60 done (131/s) | 460ms
#> ⠙ 61 done (131/s) | 467ms
#> ⠹ 62 done (131/s) | 475ms
#> ⠸ 63 done (131/s) | 482ms
#> ⠼ 64 done (131/s) | 490ms
#> ⠴ 65 done (131/s) | 497ms
#> ⠦ 66 done (131/s) | 504ms
#> ⠧ 67 done (131/s) | 512ms
#> ⠇ 68 done (131/s) | 519ms
#> ⠏ 69 done (131/s) | 526ms
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 7.21ms 7.39ms      135.     265KB     2.01
cli_progress_done()
```
