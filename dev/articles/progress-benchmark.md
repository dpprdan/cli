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
#> 1 __cli_update_due              0     10ns    1.12e8        0B        0
#> 2 fun()                  130.04ns  150.1ns    4.68e6        0B        0
#> 3 .Call(ccli_tick_reset) 101.05ns    120ns    7.99e6        0B        0
#> 4 interactive()            8.96ns   10.1ns    5.82e7        0B        0
```

``` r
ben_st2 <- bench::mark(
  if (`__cli_update_due`) foobar()
)
ben_st2
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                  <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 if (`__cli_update_due`) fo…  40ns 50.1ns 21831881.        0B        0
```

### `cli_progress_along()`

``` r
seq <- 1:100000
ta <- cli_progress_along(seq)
bench::mark(seq[[1]], ta[[1]])
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 seq[[1]]      120ns    140ns  6574423.        0B       0 
#> 2 ta[[1]]       140ns    161ns  5427619.        0B     543.
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
#> 1 f0()         22.1ms   22.2ms      44.9    21.6KB     255.
#> 2 fp()         24.9ms   25.2ms      39.4    82.3KB     210.
(ben_taf$median[2] - ben_taf$median[1]) / 1e5
#> [1] 30.1ns
```

``` r
ben_taf2 <- bench::mark(f0(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf2
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     240ms    240ms      4.14        0B     34.5
#> 2 fp(1e+06)     260ms    260ms      3.84    1.88KB     30.7
(ben_taf2$median[2] - ben_taf2$median[1]) / 1e6
#> [1] 20ns
```

``` r
ben_taf3 <- bench::mark(f0(1e7), fp(1e7))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf3
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+07)     2.49s    2.49s     0.401        0B     33.7
#> 2 fp(1e+07)     2.62s    2.62s     0.382    1.88KB     32.1
(ben_taf3$median[2] - ben_taf3$median[1]) / 1e7
#> [1] 12.8ns
```

``` r
ben_taf4 <- bench::mark(f0(1e8), fp(1e8))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_taf4
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+08)     23.9s    23.9s    0.0419        0B     20.4
#> 2 fp(1e+08)     25.6s    25.6s    0.0390    1.88KB     18.9
(ben_taf4$median[2] - ben_taf4$median[1]) / 1e8
#> [1] 17.5ns
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
#> 1 f0()           88ms   94.2ms     10.4      781KB     12.1
#> 2 f01()         121ms  124.7ms      7.38     781KB     12.9
#> 3 fp()          128ms  135.1ms      7.31     783KB     12.8
(ben_tam$median[3] - ben_tam$median[1]) / 1e5
#> [1] 408ns
```

``` r
ben_tam2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_tam2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)  903.26ms 903.26ms     1.11     7.63MB     4.43
#> 2 f01(1e+06)    1.15s    1.15s     0.873    7.63MB     5.24
#> 3 fp(1e+06)     1.43s    1.43s     0.701    7.63MB     3.51
(ben_tam2$median[3] - ben_tam2$median[1]) / 1e6
#> [1] 522ns
(ben_tam2$median[3] - ben_tam2$median[2]) / 1e6
#> [1] 280ns
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
#> 1 f0()         81.8ms   82.2ms     12.1     1.41MB     6.04
#> 2 f01()        93.8ms   94.2ms     10.5    781.3KB    10.5 
#> 3 fp()         98.8ms   99.6ms      9.93  783.24KB     6.62
(ben_pur$median[3] - ben_pur$median[1]) / 1e5
#> [1] 174ns
(ben_pur$median[3] - ben_pur$median[2]) / 1e5
#> [1] 54.5ns
```

``` r
ben_pur2 <- bench::mark(f0(1e6), f01(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_pur2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)     2.15s    2.15s     0.464    7.63MB    0.928
#> 2 f01(1e+06)    1.15s    1.15s     0.866    7.63MB    3.47 
#> 3 fp(1e+06)     1.51s    1.51s     0.663    7.63MB    2.65
(ben_pur2$median[3] - ben_pur2$median[1]) / 1e6
#> [1] 1ns
(ben_pur2$median[3] - ben_pur2$median[2]) / 1e6
#> [1] 355ns
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
#> 1 f0()        28.13ms  32.89ms    30.2      39.3KB     3.77
#> 2 fp()          4.64s    4.64s     0.216   100.4KB     3.45
(ben_tk$median[2] - ben_tk$median[1]) / 1e5
#> [1] 46.1µs
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
#> 1 f0()         22.7ms   44.6ms    23.4      18.7KB     3.89
#> 2 ff()         31.5ms   52.4ms    21.4      27.6KB     3.88
#> 3 fp()           2.6s     2.6s     0.384    25.1KB     3.46
(ben_api$median[3] - ben_api$median[1]) / 1e5
#> [1] 25.6µs
(ben_api$median[2] - ben_api$median[1]) / 1e5
#> [1] 77.9ns
```

``` r
ben_api2 <- bench::mark(f0(1e6), ff(1e6), fp(1e6))
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
ben_api2
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 f0(1e+06)   222.3ms  222.3ms    4.47          0B     4.47
#> 2 ff(1e+06)   313.7ms  314.1ms    3.18       1.9KB     3.18
#> 3 fp(1e+06)     22.6s    22.6s    0.0442     1.9KB     2.39
(ben_api2$median[3] - ben_api2$median[1]) / 1e6
#> [1] 22.4µs
(ben_api2$median[2] - ben_api2$median[1]) / 1e6
#> [1] 91.8ns
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
#> 1 test_baseline()   622.92ms 622.92ms     1.61     2.08KB        0
#> 2 test_modulo()        1.25s    1.25s     0.802    2.24KB        0
#> 3 test_cli()           1.25s    1.25s     0.803    23.9KB        0
#> 4 test_cli_unroll() 623.77ms 623.77ms     1.60     3.56KB        0
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
#> ■                                  0% | ETA: 37m
#> ■                                  0% | ETA: 34m
#> ■                                  0% | ETA: 31m
#> ■                                  0% | ETA: 30m
#> ■                                  0% | ETA: 28m
#> ■                                  0% | ETA: 27m
#> ■                                  0% | ETA: 26m
#> ■                                  0% | ETA: 25m
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
#> ■                                  0% | ETA: 14m
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 6.47ms 6.56ms      148.     1.4MB     2.03
cli_progress_done()
```

### Iterator without a bar

``` r
cli_progress_bar(total = NA)
bench::mark(cli_progress_update(force = TRUE), max_iterations = 10000)
#> ⠙ 1 done (490/s) | 3ms
#> ⠹ 2 done (65/s) | 31ms
#> ⠸ 3 done (78/s) | 39ms
#> ⠼ 4 done (87/s) | 47ms
#> ⠴ 5 done (93/s) | 54ms
#> ⠦ 6 done (98/s) | 62ms
#> ⠧ 7 done (102/s) | 69ms
#> ⠇ 8 done (105/s) | 77ms
#> ⠏ 9 done (107/s) | 84ms
#> ⠋ 10 done (109/s) | 92ms
#> ⠙ 11 done (111/s) | 100ms
#> ⠹ 12 done (113/s) | 107ms
#> ⠸ 13 done (114/s) | 115ms
#> ⠼ 14 done (115/s) | 122ms
#> ⠴ 15 done (112/s) | 134ms
#> ⠦ 16 done (113/s) | 142ms
#> ⠧ 17 done (113/s) | 151ms
#> ⠇ 18 done (114/s) | 159ms
#> ⠏ 19 done (114/s) | 167ms
#> ⠋ 20 done (114/s) | 176ms
#> ⠙ 21 done (114/s) | 184ms
#> ⠹ 22 done (115/s) | 192ms
#> ⠸ 23 done (116/s) | 200ms
#> ⠼ 24 done (116/s) | 207ms
#> ⠴ 25 done (117/s) | 215ms
#> ⠦ 26 done (117/s) | 222ms
#> ⠧ 27 done (118/s) | 230ms
#> ⠇ 28 done (118/s) | 238ms
#> ⠏ 29 done (118/s) | 245ms
#> ⠋ 30 done (119/s) | 253ms
#> ⠙ 31 done (119/s) | 261ms
#> ⠹ 32 done (119/s) | 269ms
#> ⠸ 33 done (120/s) | 276ms
#> ⠼ 34 done (120/s) | 284ms
#> ⠴ 35 done (120/s) | 292ms
#> ⠦ 36 done (120/s) | 299ms
#> ⠧ 37 done (121/s) | 307ms
#> ⠇ 38 done (121/s) | 315ms
#> ⠏ 39 done (121/s) | 322ms
#> ⠋ 40 done (121/s) | 330ms
#> ⠙ 41 done (122/s) | 338ms
#> ⠹ 42 done (122/s) | 345ms
#> ⠸ 43 done (122/s) | 353ms
#> ⠼ 44 done (122/s) | 361ms
#> ⠴ 45 done (122/s) | 368ms
#> ⠦ 46 done (123/s) | 376ms
#> ⠧ 47 done (123/s) | 384ms
#> ⠇ 48 done (123/s) | 391ms
#> ⠏ 49 done (123/s) | 399ms
#> ⠋ 50 done (123/s) | 407ms
#> ⠙ 51 done (123/s) | 414ms
#> ⠹ 52 done (123/s) | 422ms
#> ⠸ 53 done (124/s) | 429ms
#> ⠼ 54 done (124/s) | 437ms
#> ⠴ 55 done (124/s) | 445ms
#> ⠦ 56 done (124/s) | 452ms
#> ⠧ 57 done (124/s) | 460ms
#> ⠇ 58 done (124/s) | 468ms
#> ⠏ 59 done (124/s) | 475ms
#> ⠋ 60 done (124/s) | 483ms
#> ⠙ 61 done (124/s) | 491ms
#> ⠹ 62 done (125/s) | 498ms
#> ⠸ 63 done (125/s) | 506ms
#> ⠼ 64 done (125/s) | 513ms
#> ⠴ 65 done (125/s) | 521ms
#> ⠦ 66 done (125/s) | 528ms
#> # A tibble: 1 × 6
#>   expression                    min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                 <bch:> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 cli_progress_update(force… 7.47ms 7.62ms      130.     265KB     2.03
cli_progress_done()
```
