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
#> 1 __cli_update_due              0     10ns    1.14e8        0B        0
#> 2 fun()                  130.04ns  150.1ns    4.56e6        0B        0
#> 3 .Call(ccli_tick_reset)    100ns    120ns    8.31e6        0B        0
#> 4 interactive()            8.96ns   10.1ns    7.52e7        0B        0
```

``` r

ben_st2 <- bench::mark(
  if (`__cli_update_due`) foobar()
)
ben_st2
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 if (`__cli_update_due`) fo…  40ns 50.1ns 20822756.        0B        0
```

### `cli_progress_along()`

``` r

seq <- 1:100000
ta <- cli_progress_along(seq)
bench::mark(seq[[1]], ta[[1]])
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 seq[[1]]      150ns    170ns  5624641.        0B        0
#> 2 ta[[1]]       150ns    171ns  5357018.        0B        0
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
#> 1 f0()         22.2ms   22.2ms      45.0    21.6KB     405.
#> 2 fp()         24.7ms   24.7ms      40.4    82.5KB     215.
(ben_taf$median[2] - ben_taf$median[1]) / 1e5
#> [1] 24.1ns
```

``` r

ben_taf2 <- bench::mark(f0(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf2
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     246ms    246ms      4.04        0B     35.0
#> 2 fp(1e+06)     268ms    299ms      3.34    1.88KB     26.7
(ben_taf2$median[2] - ben_taf2$median[1]) / 1e6
#> [1] 52.8ns
```

``` r

ben_taf3 <- bench::mark(f0(1e7), fp(1e7))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf3
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+07)     2.44s    2.44s     0.409        0B     19.6
#> 2 fp(1e+07)      2.5s     2.5s     0.400    1.88KB     19.2
(ben_taf3$median[2] - ben_taf3$median[1]) / 1e7
#> [1] 5.29ns
```

``` r

ben_taf4 <- bench::mark(f0(1e8), fp(1e8))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf4
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+08)     23.9s    23.9s    0.0419        0B     22.2
#> 2 fp(1e+08)     25.4s    25.4s    0.0394    1.88KB     20.7
(ben_taf4$median[2] - ben_taf4$median[1]) / 1e8
#> [1] 14.8ns
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
#> 1 f0()           93ms   95.7ms      7.52     781KB    15.0 
#> 2 f01()         111ms    118ms      8.43     781KB     8.43
#> 3 fp()          120ms  134.2ms      7.57     783KB    13.2
(ben_tam$median[3] - ben_tam$median[1]) / 1e5
#> [1] 386ns
```

``` r

ben_tam2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     1.12s    1.12s     0.894    7.63MB     6.26
#> 2 f01(1e+06)    2.75s    2.75s     0.364    7.63MB     2.91
#> 3 fp(1e+06)     1.16s    1.16s     0.862    7.63MB     1.72
(ben_tam2$median[3] - ben_tam2$median[1]) / 1e6
#> [1] 42ns
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
#> 1 f0()         79.1ms   79.5ms     12.4     1.44MB     4.96
#> 2 f01()        96.1ms   98.5ms     10.1    781.3KB     2.53
#> 3 fp()         99.9ms  101.7ms      9.79  783.24KB     2.45
(ben_pur$median[3] - ben_pur$median[1]) / 1e5
#> [1] 222ns
(ben_pur$median[3] - ben_pur$median[2]) / 1e5
#> [1] 31.9ns
```

``` r

ben_pur2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  929.45ms 929.45ms     1.08     7.63MB     2.15
#> 2 f01(1e+06)     1.1s     1.1s     0.911    7.63MB     1.82
#> 3 fp(1e+06)     1.23s    1.23s     0.814    7.63MB     2.44
(ben_pur2$median[3] - ben_pur2$median[1]) / 1e6
#> [1] 299ns
(ben_pur2$median[3] - ben_pur2$median[2]) / 1e6
#> [1] 130ns
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
#> 1 f0()         23.1ms   23.2ms    42.8      39.3KB     1.94
#> 2 fp()             4s       4s     0.250   100.7KB     1.75
(ben_tk$median[2] - ben_tk$median[1]) / 1e5
#> [1] 39.7µs
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
#> 1 f0()        21.34ms  21.67ms    43.3      18.7KB     3.94
#> 2 ff()        30.75ms  30.96ms    30.7      27.6KB     1.92
#> 3 fp()          2.23s    2.23s     0.448    25.1KB     1.79
(ben_api$median[3] - ben_api$median[1]) / 1e5
#> [1] 22.1µs
(ben_api$median[2] - ben_api$median[1]) / 1e5
#> [1] 92.8ns
```

``` r

ben_api2 <- bench::mark(f0(1e6), ff(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)   225.3ms  235.9ms    4.23          0B     2.82
#> 2 ff(1e+06)   309.8ms  320.2ms    3.12       1.9KB     3.12
#> 3 fp(1e+06)     23.4s    23.4s    0.0428     1.9KB     1.80
(ben_api2$median[3] - ben_api2$median[1]) / 1e6
#> [1] 23.1µs
(ben_api2$median[2] - ben_api2$median[1]) / 1e6
#> [1] 84.3ns
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
#> 1 test_baseline()   623.74ms 623.74ms     1.60     2.08KB        0
#> 2 test_modulo()        1.25s    1.25s     0.801    2.24KB        0
#> 3 test_cli()           1.25s    1.25s     0.803   24.09KB        0
#> 4 test_cli_unroll()  624.1ms  624.1ms     1.60     3.56KB        0
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
#> ■                                  0% | ETA: 42m
#> ■                                  0% | ETA: 38m
#> ■                                  0% | ETA: 35m
#> ■                                  0% | ETA: 32m
#> ■                                  0% | ETA: 30m
#> ■                                  0% | ETA: 29m
#> ■                                  0% | ETA: 27m
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
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 6.18ms 6.33ms      155.    1.41MB     2.04
cli_progress_done()
```

### Iterator without a bar

``` r

cli_progress_bar(total = NA)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ⠙ 1 done (483/s) | 3ms
#> ⠹ 2 done (64/s) | 32ms
#> ⠸ 3 done (77/s) | 39ms
#> ⠼ 4 done (87/s) | 47ms
#> ⠴ 5 done (93/s) | 54ms
#> ⠦ 6 done (98/s) | 62ms
#> ⠧ 7 done (102/s) | 69ms
#> ⠇ 8 done (105/s) | 77ms
#> ⠏ 9 done (108/s) | 84ms
#> ⠋ 10 done (110/s) | 92ms
#> ⠙ 11 done (112/s) | 99ms
#> ⠹ 12 done (114/s) | 106ms
#> ⠸ 13 done (115/s) | 114ms
#> ⠼ 14 done (116/s) | 121ms
#> ⠴ 15 done (117/s) | 129ms
#> ⠦ 16 done (118/s) | 136ms
#> ⠧ 17 done (119/s) | 144ms
#> ⠇ 18 done (120/s) | 151ms
#> ⠏ 19 done (120/s) | 159ms
#> ⠋ 20 done (118/s) | 170ms
#> ⠙ 21 done (119/s) | 177ms
#> ⠹ 22 done (120/s) | 184ms
#> ⠸ 23 done (121/s) | 191ms
#> ⠼ 24 done (121/s) | 199ms
#> ⠴ 25 done (122/s) | 206ms
#> ⠦ 26 done (122/s) | 214ms
#> ⠧ 27 done (123/s) | 221ms
#> ⠇ 28 done (123/s) | 228ms
#> ⠏ 29 done (123/s) | 236ms
#> ⠋ 30 done (124/s) | 243ms
#> ⠙ 31 done (124/s) | 250ms
#> ⠹ 32 done (125/s) | 257ms
#> ⠸ 33 done (125/s) | 265ms
#> ⠼ 34 done (125/s) | 272ms
#> ⠴ 35 done (126/s) | 279ms
#> ⠦ 36 done (126/s) | 287ms
#> ⠧ 37 done (126/s) | 294ms
#> ⠇ 38 done (126/s) | 302ms
#> ⠏ 39 done (126/s) | 309ms
#> ⠋ 40 done (127/s) | 316ms
#> ⠙ 41 done (127/s) | 324ms
#> ⠹ 42 done (127/s) | 331ms
#> ⠸ 43 done (127/s) | 338ms
#> ⠼ 44 done (128/s) | 346ms
#> ⠴ 45 done (128/s) | 353ms
#> ⠦ 46 done (128/s) | 360ms
#> ⠧ 47 done (128/s) | 368ms
#> ⠇ 48 done (128/s) | 375ms
#> ⠏ 49 done (128/s) | 383ms
#> ⠋ 50 done (128/s) | 390ms
#> ⠙ 51 done (128/s) | 398ms
#> ⠹ 52 done (129/s) | 405ms
#> ⠸ 53 done (129/s) | 413ms
#> ⠼ 54 done (129/s) | 420ms
#> ⠴ 55 done (129/s) | 427ms
#> ⠦ 56 done (129/s) | 435ms
#> ⠧ 57 done (129/s) | 442ms
#> ⠇ 58 done (129/s) | 450ms
#> ⠏ 59 done (129/s) | 458ms
#> ⠋ 60 done (129/s) | 465ms
#> ⠙ 61 done (129/s) | 473ms
#> ⠹ 62 done (129/s) | 480ms
#> ⠸ 63 done (129/s) | 488ms
#> ⠼ 64 done (129/s) | 495ms
#> ⠴ 65 done (129/s) | 503ms
#> ⠦ 66 done (130/s) | 510ms
#> ⠧ 67 done (130/s) | 517ms
#> ⠇ 68 done (130/s) | 525ms
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 7.25ms 7.39ms      135.     265KB     2.04
cli_progress_done()
```
