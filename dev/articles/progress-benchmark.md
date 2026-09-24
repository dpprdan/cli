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
#> 1 __cli_update_due              0     10ns 99841327.        0B        0
#> 2 fun()                  130.04ns  150.1ns  4572174.        0B        0
#> 3 .Call(ccli_tick_reset)    100ns  120.1ns  7955247.        0B        0
#> 4 interactive()            8.96ns   10.1ns 72694653.        0B        0
```

``` r

ben_st2 <- bench::mark(
  if (`__cli_update_due`) foobar()
)
ben_st2
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 if (`__cli_update_due`) fo…  40ns 40.2ns 22081367.        0B        0
```

### `cli_progress_along()`

``` r

seq <- 1:100000
ta <- cli_progress_along(seq)
bench::mark(seq[[1]], ta[[1]])
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 seq[[1]]      120ns    141ns  6494385.        0B        0
#> 2 ta[[1]]       130ns    151ns  5898067.        0B        0
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
#> 1 f0()         22.5ms   22.5ms      44.5    21.6KB     378.
#> 2 fp()         25.5ms   25.8ms      38.8    82.5KB     310.
(ben_taf$median[2] - ben_taf$median[1]) / 1e5
#> [1] 32.9ns
```

``` r

ben_taf2 <- bench::mark(f0(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf2
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     255ms    255ms      3.92        0B     35.3
#> 2 fp(1e+06)     271ms    273ms      3.66     1.9KB     31.1
(ben_taf2$median[2] - ben_taf2$median[1]) / 1e6
#> [1] 17.9ns
```

``` r

ben_taf3 <- bench::mark(f0(1e7), fp(1e7))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf3
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+07)     2.49s    2.49s     0.402        0B     18.9
#> 2 fp(1e+07)     2.56s    2.56s     0.391     1.9KB     18.8
(ben_taf3$median[2] - ben_taf3$median[1]) / 1e7
#> [1] 6.74ns
```

``` r

ben_taf4 <- bench::mark(f0(1e8), fp(1e8))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf4
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+08)     24.2s    24.2s    0.0413        0B     21.7
#> 2 fp(1e+08)     25.9s    25.9s    0.0386     1.9KB     20.0
(ben_taf4$median[2] - ben_taf4$median[1]) / 1e8
#> [1] 17ns
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
#> 1 f0()         94.6ms    117ms      7.22     781KB     15.9
#> 2 f01()       103.7ms    107ms      9.17     781KB     11.0
#> 3 fp()        116.2ms    130ms      6.80     783KB     10.2
(ben_tam$median[3] - ben_tam$median[1]) / 1e5
#> [1] 138ns
```

``` r

ben_tam2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  936.36ms 936.36ms     1.07     7.63MB     7.48
#> 2 f01(1e+06)    1.42s    1.42s     0.704    7.63MB     4.93
#> 3 fp(1e+06)     2.08s    2.08s     0.481    7.63MB     3.85
(ben_tam2$median[3] - ben_tam2$median[1]) / 1e6
#> [1] 1.14µs
(ben_tam2$median[3] - ben_tam2$median[2]) / 1e6
#> [1] 659ns
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
#> 1 f0()         78.6ms   81.5ms     12.3     1.44MB     24.5
#> 2 f01()        99.3ms   99.3ms     10.1    781.3KB     40.3
#> 3 fp()        130.1ms  130.1ms      7.69  783.26KB     23.1
(ben_pur$median[3] - ben_pur$median[1]) / 1e5
#> [1] 487ns
(ben_pur$median[3] - ben_pur$median[2]) / 1e5
#> [1] 309ns
```

``` r

ben_pur2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  869.22ms 869.22ms     1.15     7.63MB     2.30
#> 2 f01(1e+06)    1.13s    1.13s     0.884    7.63MB     2.65
#> 3 fp(1e+06)     1.17s    1.17s     0.854    7.63MB     2.56
(ben_pur2$median[3] - ben_pur2$median[1]) / 1e6
#> [1] 302ns
(ben_pur2$median[3] - ben_pur2$median[2]) / 1e6
#> [1] 40.6ns
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
#> 1 f0()        22.64ms  22.79ms    43.1      39.3KB     1.96
#> 2 fp()          3.91s    3.91s     0.255   100.8KB     2.04
(ben_tk$median[2] - ben_tk$median[1]) / 1e5
#> [1] 38.9µs
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
#> 1 f0()        21.59ms  21.76ms    43.2      18.7KB     3.93
#> 2 ff()        31.96ms  32.23ms    29.6      27.6KB     1.97
#> 3 fp()          2.21s    2.21s     0.453    25.1KB     1.81
(ben_api$median[3] - ben_api$median[1]) / 1e5
#> [1] 21.9µs
(ben_api$median[2] - ben_api$median[1]) / 1e5
#> [1] 105ns
```

``` r

ben_api2 <- bench::mark(f0(1e6), ff(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)   229.6ms    246ms    4.15          0B     4.15
#> 2 ff(1e+06)   316.3ms    324ms    3.09      1.91KB     1.54
#> 3 fp(1e+06)     23.5s    23.5s    0.0426    1.91KB     1.92
(ben_api2$median[3] - ben_api2$median[1]) / 1e6
#> [1] 23.2µs
(ben_api2$median[2] - ben_api2$median[1]) / 1e6
#> [1] 78.1ns
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
#> 1 test_baseline()   623.69ms 623.69ms     1.60     2.08KB        0
#> 2 test_modulo()        1.25s    1.25s     0.801    2.24KB        0
#> 3 test_cli()           1.25s    1.25s     0.801   24.11KB        0
#> 4 test_cli_unroll()  624.8ms  624.8ms     1.60     3.58KB        0
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
#> ■                                  0% | ETA: 38m
#> ■                                  0% | ETA: 35m
#> ■                                  0% | ETA: 32m
#> ■                                  0% | ETA: 30m
#> ■                                  0% | ETA: 29m
#> ■                                  0% | ETA: 27m
#> ■                                  0% | ETA: 26m
#> ■                                  0% | ETA: 25m
#> ■                                  0% | ETA: 24m
#> ■                                  0% | ETA: 24m
#> ■                                  0% | ETA: 23m
#> ■                                  0% | ETA: 22m
#> ■                                  0% | ETA: 22m
#> ■                                  0% | ETA: 21m
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
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 6.38ms 6.66ms      147.    1.41MB     2.05
cli_progress_done()
```

### Iterator without a bar

``` r

cli_progress_bar(total = NA)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ⠙ 1 done (470/s) | 3ms
#> ⠹ 2 done (66/s) | 31ms
#> ⠸ 3 done (78/s) | 39ms
#> ⠼ 4 done (87/s) | 47ms
#> ⠴ 5 done (93/s) | 54ms
#> ⠦ 6 done (98/s) | 62ms
#> ⠧ 7 done (101/s) | 70ms
#> ⠇ 8 done (104/s) | 78ms
#> ⠏ 9 done (103/s) | 88ms
#> ⠋ 10 done (105/s) | 96ms
#> ⠙ 11 done (107/s) | 104ms
#> ⠹ 12 done (108/s) | 111ms
#> ⠸ 13 done (110/s) | 119ms
#> ⠼ 14 done (111/s) | 127ms
#> ⠴ 15 done (112/s) | 135ms
#> ⠦ 16 done (113/s) | 143ms
#> ⠧ 17 done (113/s) | 151ms
#> ⠇ 18 done (114/s) | 159ms
#> ⠏ 19 done (114/s) | 167ms
#> ⠋ 20 done (115/s) | 175ms
#> ⠙ 21 done (116/s) | 182ms
#> ⠹ 22 done (116/s) | 190ms
#> ⠸ 23 done (116/s) | 198ms
#> ⠼ 24 done (117/s) | 206ms
#> ⠴ 25 done (117/s) | 214ms
#> ⠦ 26 done (117/s) | 222ms
#> ⠧ 27 done (118/s) | 230ms
#> ⠇ 28 done (118/s) | 237ms
#> ⠏ 29 done (119/s) | 245ms
#> ⠋ 30 done (119/s) | 253ms
#> ⠙ 31 done (119/s) | 261ms
#> ⠹ 32 done (119/s) | 269ms
#> ⠸ 33 done (117/s) | 282ms
#> ⠼ 34 done (117/s) | 290ms
#> ⠴ 35 done (118/s) | 298ms
#> ⠦ 36 done (118/s) | 306ms
#> ⠧ 37 done (118/s) | 314ms
#> ⠇ 38 done (118/s) | 322ms
#> ⠏ 39 done (118/s) | 331ms
#> ⠋ 40 done (118/s) | 338ms
#> ⠙ 41 done (119/s) | 346ms
#> ⠹ 42 done (119/s) | 354ms
#> ⠸ 43 done (119/s) | 362ms
#> ⠼ 44 done (119/s) | 370ms
#> ⠴ 45 done (119/s) | 378ms
#> ⠦ 46 done (119/s) | 386ms
#> ⠧ 47 done (119/s) | 394ms
#> ⠇ 48 done (120/s) | 402ms
#> ⠏ 49 done (120/s) | 410ms
#> ⠋ 50 done (120/s) | 418ms
#> ⠙ 51 done (120/s) | 426ms
#> ⠹ 52 done (120/s) | 434ms
#> ⠸ 53 done (120/s) | 442ms
#> ⠼ 54 done (120/s) | 451ms
#> ⠴ 55 done (120/s) | 459ms
#> ⠦ 56 done (120/s) | 467ms
#> ⠧ 57 done (120/s) | 475ms
#> ⠇ 58 done (120/s) | 484ms
#> ⠏ 59 done (120/s) | 492ms
#> ⠋ 60 done (120/s) | 500ms
#> ⠙ 61 done (120/s) | 508ms
#> ⠹ 62 done (120/s) | 517ms
#> ⠸ 63 done (120/s) | 525ms
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 7.62ms 7.94ms      125.     265KB     2.05
cli_progress_done()
```
