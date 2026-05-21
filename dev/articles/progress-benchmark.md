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
#> 1 __cli_update_due              0   10.1ns 85009659.        0B        0
#> 2 fun()                  120.02ns  150.2ns  4629008.        0B        0
#> 3 .Call(ccli_tick_reset)    100ns  120.1ns  7940182.        0B        0
#> 4 interactive()            8.96ns   10.1ns 71386950.        0B        0
```

``` r

ben_st2 <- bench::mark(
  if (`__cli_update_due`) foobar()
)
ben_st2
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 if (`__cli_update_due`) f… 39.9ns 49.9ns 20535722.        0B        0
```

### `cli_progress_along()`

``` r

seq <- 1:100000
ta <- cli_progress_along(seq)
bench::mark(seq[[1]], ta[[1]])
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 seq[[1]]      130ns    160ns  5983176.        0B        0
#> 2 ta[[1]]       150ns    170ns  5206147.        0B        0
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
#> 1 f0()         22.1ms   22.2ms      45.0    21.6KB     405.
#> 2 fp()         24.3ms   24.8ms      40.3    82.5KB     215.
(ben_taf$median[2] - ben_taf$median[1]) / 1e5
#> [1] 26.1ns
```

``` r

ben_taf2 <- bench::mark(f0(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf2
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     238ms    240ms      4.18        0B     36.2
#> 2 fp(1e+06)     260ms    292ms      3.42    1.88KB     27.4
(ben_taf2$median[2] - ben_taf2$median[1]) / 1e6
#> [1] 52.6ns
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
#> 2 fp(1e+07)      2.5s     2.5s     0.400    1.88KB     19.2
(ben_taf3$median[2] - ben_taf3$median[1]) / 1e7
#> [1] 7.57ns
```

``` r

ben_taf4 <- bench::mark(f0(1e8), fp(1e8))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf4
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+08)     23.7s    23.7s    0.0423        0B     22.4
#> 2 fp(1e+08)       25s      25s    0.0400    1.88KB     21.0
(ben_taf4$median[2] - ben_taf4$median[1]) / 1e8
#> [1] 13.5ns
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
#> 1 f0()         88.4ms   93.6ms      8.40     781KB     15.1
#> 2 f01()       112.1ms  113.6ms      8.58     781KB     10.3
#> 3 fp()        126.8ms  132.5ms      7.02     783KB     10.5
(ben_tam$median[3] - ben_tam$median[1]) / 1e5
#> [1] 389ns
```

``` r

ben_tam2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  973.16ms 973.16ms     1.03     7.63MB     7.19
#> 2 f01(1e+06)    1.92s    1.92s     0.521    7.63MB     2.60
#> 3 fp(1e+06)     1.22s    1.22s     0.818    7.63MB     4.91
(ben_tam2$median[3] - ben_tam2$median[1]) / 1e6
#> [1] 249ns
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
#> 1 f0()         78.8ms   79.1ms      12.5    1.44MB     5.01
#> 2 f01()        95.4ms   96.2ms      10.4   781.3KB     6.95
#> 3 fp()         98.4ms   98.9ms      10.1  783.24KB    15.2
(ben_pur$median[3] - ben_pur$median[1]) / 1e5
#> [1] 197ns
(ben_pur$median[3] - ben_pur$median[2]) / 1e5
#> [1] 26.2ns
```

``` r

ben_pur2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  879.24ms 879.24ms     1.14     7.63MB     2.27
#> 2 f01(1e+06)    1.19s    1.19s     0.840    7.63MB     3.36
#> 3 fp(1e+06)     1.58s    1.58s     0.634    7.63MB     2.54
(ben_pur2$median[3] - ben_pur2$median[1]) / 1e6
#> [1] 697ns
(ben_pur2$median[3] - ben_pur2$median[2]) / 1e6
#> [1] 386ns
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
#> 1 f0()        22.94ms  22.99ms    43.1      39.3KB     1.96
#> 2 fp()          4.03s    4.03s     0.248   100.7KB     2.73
(ben_tk$median[2] - ben_tk$median[1]) / 1e5
#> [1] 40µs
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
#> 1 f0()        21.55ms  21.74ms    43.2      18.7KB     3.93
#> 2 ff()        31.15ms  31.43ms    30.0      27.6KB     4.00
#> 3 fp()          2.31s    2.31s     0.434    25.1KB     2.60
(ben_api$median[3] - ben_api$median[1]) / 1e5
#> [1] 22.8µs
(ben_api$median[2] - ben_api$median[1]) / 1e5
#> [1] 96.9ns
```

``` r

ben_api2 <- bench::mark(f0(1e6), ff(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     220ms    220ms    4.54          0B     4.54
#> 2 ff(1e+06)     310ms    311ms    3.21       1.9KB     3.21
#> 3 fp(1e+06)       23s      23s    0.0434     1.9KB     2.47
(ben_api2$median[3] - ben_api2$median[1]) / 1e6
#> [1] 22.8µs
(ben_api2$median[2] - ben_api2$median[1]) / 1e6
#> [1] 91ns
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
#> 1 test_baseline()   623.51ms 623.51ms     1.60     2.08KB        0
#> 2 test_modulo()        1.25s    1.25s     0.802    2.24KB        0
#> 3 test_cli()           1.25s    1.25s     0.802   24.09KB        0
#> 4 test_cli_unroll() 623.52ms 623.52ms     1.60     3.56KB        0
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
#> ■                                  0% | ETA: 47m
#> ■                                  0% | ETA: 42m
#> ■                                  0% | ETA: 38m
#> ■                                  0% | ETA: 35m
#> ■                                  0% | ETA: 33m
#> ■                                  0% | ETA: 31m
#> ■                                  0% | ETA: 29m
#> ■                                  0% | ETA: 27m
#> ■                                  0% | ETA: 26m
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
#> ■                                  0% | ETA: 14m
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 6.24ms 6.33ms      152.    1.41MB     2.03
cli_progress_done()
```

### Iterator without a bar

``` r

cli_progress_bar(total = NA)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ⠙ 1 done (496/s) | 3ms
#> ⠹ 2 done (70/s) | 29ms
#> ⠸ 3 done (83/s) | 37ms
#> ⠼ 4 done (92/s) | 44ms
#> ⠴ 5 done (98/s) | 52ms
#> ⠦ 6 done (103/s) | 59ms
#> ⠧ 7 done (107/s) | 66ms
#> ⠇ 8 done (110/s) | 74ms
#> ⠏ 9 done (112/s) | 81ms
#> ⠋ 10 done (114/s) | 88ms
#> ⠙ 11 done (116/s) | 96ms
#> ⠹ 12 done (117/s) | 103ms
#> ⠸ 13 done (118/s) | 111ms
#> ⠼ 14 done (119/s) | 118ms
#> ⠴ 15 done (120/s) | 126ms
#> ⠦ 16 done (121/s) | 133ms
#> ⠧ 17 done (121/s) | 141ms
#> ⠇ 18 done (122/s) | 148ms
#> ⠏ 19 done (123/s) | 155ms
#> ⠋ 20 done (123/s) | 163ms
#> ⠙ 21 done (124/s) | 170ms
#> ⠹ 22 done (124/s) | 177ms
#> ⠸ 23 done (125/s) | 185ms
#> ⠼ 24 done (125/s) | 192ms
#> ⠴ 25 done (126/s) | 200ms
#> ⠦ 26 done (126/s) | 207ms
#> ⠧ 27 done (126/s) | 214ms
#> ⠇ 28 done (127/s) | 222ms
#> ⠏ 29 done (127/s) | 229ms
#> ⠋ 30 done (127/s) | 236ms
#> ⠙ 31 done (127/s) | 244ms
#> ⠹ 32 done (128/s) | 251ms
#> ⠸ 33 done (128/s) | 259ms
#> ⠼ 34 done (128/s) | 266ms
#> ⠴ 35 done (128/s) | 274ms
#> ⠦ 36 done (128/s) | 281ms
#> ⠧ 37 done (129/s) | 288ms
#> ⠇ 38 done (129/s) | 296ms
#> ⠏ 39 done (129/s) | 303ms
#> ⠋ 40 done (129/s) | 310ms
#> ⠙ 41 done (129/s) | 318ms
#> ⠹ 42 done (128/s) | 330ms
#> ⠸ 43 done (128/s) | 338ms
#> ⠼ 44 done (127/s) | 346ms
#> ⠴ 45 done (127/s) | 354ms
#> ⠦ 46 done (127/s) | 362ms
#> ⠧ 47 done (127/s) | 370ms
#> ⠇ 48 done (127/s) | 378ms
#> ⠏ 49 done (127/s) | 386ms
#> ⠋ 50 done (127/s) | 394ms
#> ⠙ 51 done (127/s) | 402ms
#> ⠹ 52 done (127/s) | 411ms
#> ⠸ 53 done (127/s) | 419ms
#> ⠼ 54 done (127/s) | 427ms
#> ⠴ 55 done (127/s) | 434ms
#> ⠦ 56 done (127/s) | 441ms
#> ⠧ 57 done (127/s) | 449ms
#> ⠇ 58 done (127/s) | 456ms
#> ⠏ 59 done (128/s) | 463ms
#> ⠋ 60 done (128/s) | 471ms
#> ⠙ 61 done (128/s) | 479ms
#> ⠹ 62 done (128/s) | 486ms
#> ⠸ 63 done (128/s) | 493ms
#> ⠼ 64 done (128/s) | 501ms
#> ⠴ 65 done (128/s) | 508ms
#> ⠦ 66 done (128/s) | 515ms
#> ⠧ 67 done (128/s) | 523ms
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force … 7.3ms 7.38ms      133.     265KB     2.05
cli_progress_done()
```
