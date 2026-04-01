# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x55af13f2bfb0\>
\<environment: 0x55af14a7c9b0\>

## Introduction

Often we can use the corresponding base R function as a baseline. We
also compare to the fansi package, where it is possible.

## Data

In cli the typical use case is short string scalars, but we run some
benchmarks longer strings and string vectors as well.

``` r
library(cli)
library(fansi)
options(cli.unicode = TRUE)
options(cli.num_colors = 256)
```

``` r
ansi <- format_inline(
  "{col_green(symbol$tick)} {.code print(x)} {.emph emphasised}"
)
```

``` r
plain <- ansi_strip(ansi)
```

``` r
vec_plain <- rep(plain, 100)
vec_ansi <- rep(ansi, 100)
vec_plain6 <- rep(plain, 6)
vec_ansi6 <- rep(plain, 6)
```

``` r
txt_plain <- paste(vec_plain, collapse = " ")
txt_ansi <- paste(vec_ansi, collapse = " ")
```

``` r
uni <- paste(
  "\U0001f477\u200d\u2640\ufe0f",
  "\U0001f477\U0001f3fb",
  "\U0001f477\u200d\u2640\ufe0f",
  "\U0001f477\U0001f3fb",
  "\U0001f477\U0001f3ff\u200d\u2640\ufe0f"
)
vec_uni <- rep(uni, 100)
txt_uni <- paste(vec_uni, collapse = " ")
```

## ANSI functions

### `ansi_align()`

``` r
bench::mark(
  ansi  = ansi_align(ansi, width = 20),
  plain = ansi_align(plain, width = 20), 
  base  = format(plain, width = 20),
  check = FALSE
)
```

``` fansi
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 ansi         45.6µs     49µs    19714.    99.3KB     18.9
#> 2 plain        45.6µs   49.1µs    19699.        0B     19.6
#> 3 base         11.1µs   12.2µs    79047.    48.4KB     15.8
```

``` r
bench::mark(
  ansi  = ansi_align(ansi, width = 20, align = "right"),
  plain = ansi_align(plain, width = 20, align = "right"), 
  base  = format(plain, width = 20, justify = "right"),
  check = FALSE
)
```

``` fansi
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 ansi           48µs   51.4µs    18804.        0B     21.2
#> 2 plain          48µs   51.4µs    18755.        0B     21.4
#> 3 base         13.2µs   14.4µs    67114.        0B     20.1
```

### `ansi_chartr()`

``` r
bench::mark(
  ansi  = ansi_chartr("abc", "XYZ", ansi),
  plain = ansi_chartr("abc", "XYZ", plain),
  base  = chartr("abc", "XYZ", plain),
  check = FALSE
)
```

``` fansi
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 ansi        110.6µs  117.2µs     8253.   75.07KB     16.8
#> 2 plain        87.2µs  92.71µs    10437.    8.73KB     14.6
#> 3 base          1.8µs   1.92µs   499013.        0B      0
```

### `ansi_columns()`

``` r
bench::mark(
  ansi  = ansi_columns(vec_ansi6, width = 120),
  plain = ansi_columns(vec_plain6, width = 120),
  check = FALSE
)
```

``` fansi
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 ansi          342µs    363µs     2707.   33.17KB     19.1
#> 2 plain         339µs    362µs     2721.    1.09KB     19.2
```

### `ansi_has_any()`

``` r
bench::mark(
  cli_ansi        = ansi_has_any(ansi),
  fansi_ansi      = has_sgr(ansi),
  cli_plain       = ansi_has_any(plain),
  fansi_plain     = has_sgr(plain),
  cli_vec_ansi    = ansi_has_any(vec_ansi),
  fansi_vec_ansi  = has_sgr(vec_ansi),
  cli_vec_plain   = ansi_has_any(vec_plain),
  fansi_vec_plain = has_sgr(vec_plain),
  cli_txt_ansi    = ansi_has_any(txt_ansi),
  fansi_txt_ansi  = has_sgr(txt_ansi),
  cli_txt_plain   = ansi_has_any(txt_plain),
  fansi_txt_plain = has_sgr(vec_plain),
  check = FALSE
)
```

``` fansi
#> # A tibble: 12 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi          5.76µs   6.32µs   151885.     9.2KB     30.4
#>  2 fansi_ansi       30.46µs  33.19µs    29212.    4.18KB     26.3
#>  3 cli_plain         5.79µs   6.31µs   153172.        0B     15.3
#>  4 fansi_plain      29.78µs  32.68µs    29568.      688B     26.6
#>  5 cli_vec_ansi      7.17µs   7.66µs   126803.      448B     12.7
#>  6 fansi_vec_ansi   39.28µs  41.47µs    23428.    5.02KB     21.1
#>  7 cli_vec_plain     7.74µs   8.23µs   118314.      448B     11.8
#>  8 fansi_vec_plain   37.1µs  39.21µs    24650.    5.02KB     22.2
#>  9 cli_txt_ansi      5.73µs    6.1µs   159107.        0B     15.9
#> 10 fansi_txt_ansi   29.73µs  31.42µs    30577.      688B     27.5
#> 11 cli_txt_plain     6.58µs   6.95µs   140286.        0B     14.0
#> 12 fansi_txt_plain  37.64µs  39.63µs    24399.    5.02KB     22.0
```

### `ansi_html()`

This is typically used with longer text.

``` r
bench::mark(
  cli   = ansi_html(txt_ansi),
  fansi = sgr_to_html(txt_ansi, classes = TRUE),
  check = FALSE
)
```

``` fansi
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 cli          56.4µs   58.1µs    16823.    22.7KB     8.18
#> 2 fansi       118.6µs  121.5µs     8031.    55.3KB     8.20
```

### `ansi_nchar()`

``` r
bench::mark(
  cli_ansi        = ansi_nchar(ansi),
  fansi_ansi      = nchar_sgr(ansi),
  base_ansi       = nchar(ansi),
  cli_plain       = ansi_nchar(plain),
  fansi_plain     = nchar_sgr(plain),
  base_plain      = nchar(plain),
  cli_vec_ansi    = ansi_nchar(vec_ansi),
  fansi_vec_ansi  = nchar_sgr(vec_ansi),
  base_vec_ansi   = nchar(vec_ansi),
  cli_vec_plain   = ansi_nchar(vec_plain),
  fansi_vec_plain = nchar_sgr(vec_plain),
  base_vec_plain  = nchar(vec_plain),
  cli_txt_ansi    = ansi_nchar(txt_ansi),
  fansi_txt_ansi  = nchar_sgr(txt_ansi),
  base_txt_ansi   = nchar(txt_ansi),
  cli_txt_plain   = ansi_nchar(txt_plain),
  fansi_txt_plain = nchar_sgr(txt_plain),
  base_txt_plain  = nchar(txt_plain),
  check = FALSE
)
```

``` fansi
#> # A tibble: 18 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi          6.69µs   7.25µs   133241.        0B    26.7 
#>  2 fansi_ansi       91.18µs  95.35µs    10143.   38.83KB    16.7 
#>  3 base_ansi       830.97ns 872.07ns  1076914.        0B     0   
#>  4 cli_plain         6.59µs   7.23µs   133804.        0B    26.8 
#>  5 fansi_plain      90.84µs  95.06µs    10164.      688B    16.8 
#>  6 base_plain      771.02ns    812ns  1158755.        0B     0   
#>  7 cli_vec_ansi     28.49µs  29.31µs    33359.      448B     6.67
#>  8 fansi_vec_ansi   111.2µs 115.92µs     8351.    5.02KB    12.5 
#>  9 base_vec_ansi    14.67µs  14.77µs    66529.      448B     6.65
#> 10 cli_vec_plain    26.61µs  27.35µs    35745.      448B     3.57
#> 11 fansi_vec_plain 101.62µs 105.84µs     9124.    5.02KB    16.9 
#> 12 base_vec_plain    8.75µs   8.85µs   111048.      448B     0   
#> 13 cli_txt_ansi     27.97µs  28.69µs    34067.        0B     6.81
#> 14 fansi_txt_ansi  102.84µs 107.54µs     8950.      688B    14.5 
#> 15 base_txt_ansi    14.24µs  14.31µs    68756.        0B     0   
#> 16 cli_txt_plain    26.04µs  26.75µs    36574.        0B     7.32
#> 17 fansi_txt_plain  93.03µs  97.56µs     9901.      688B    16.7 
#> 18 base_txt_plain    8.46µs   8.95µs   109609.        0B     0
```

``` r
bench::mark(
  cli_ansi        = ansi_nchar(ansi, type = "width"),
  fansi_ansi      = nchar_sgr(ansi, type = "width"),
  base_ansi       = nchar(ansi, "width"),
  cli_plain       = ansi_nchar(plain, type = "width"),
  fansi_plain     = nchar_sgr(plain, type = "width"),
  base_plain      = nchar(plain, "width"),
  cli_vec_ansi    = ansi_nchar(vec_ansi, type = "width"),
  fansi_vec_ansi  = nchar_sgr(vec_ansi, type = "width"),
  base_vec_ansi   = nchar(vec_ansi, "width"),
  cli_vec_plain   = ansi_nchar(vec_plain, type = "width"),
  fansi_vec_plain = nchar_sgr(vec_plain, type = "width"),
  base_vec_plain  = nchar(vec_plain, "width"),
  cli_txt_ansi    = ansi_nchar(txt_ansi, type = "width"),
  fansi_txt_ansi  = nchar_sgr(txt_ansi, type = "width"),
  base_txt_ansi   = nchar(txt_ansi, "width"),
  cli_txt_plain   = ansi_nchar(txt_plain, type = "width"),
  fansi_txt_plain = nchar_sgr(txt_plain, type = "width"),
  base_txt_plain  = nchar(txt_plain, type = "width"),
  check = FALSE
)
```

``` fansi
#> # A tibble: 18 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi          8.34µs   9.06µs   106920.        0B    32.1 
#>  2 fansi_ansi       90.66µs  95.59µs    10104.      688B    16.7 
#>  3 base_ansi         1.17µs   1.21µs   779711.        0B     0   
#>  4 cli_plain         8.35µs   8.96µs   107951.        0B    21.6 
#>  5 fansi_plain       90.3µs   94.3µs    10196.      688B    16.8 
#>  6 base_plain      952.04ns      1µs   928891.        0B     0   
#>  7 cli_vec_ansi     34.72µs  35.51µs    27580.      448B     8.28
#>  8 fansi_vec_ansi  112.89µs 117.29µs     8267.    5.02KB    12.5 
#>  9 base_vec_ansi    42.54µs  42.76µs    23054.      448B     2.31
#> 10 cli_vec_plain    33.19µs  33.98µs    28856.      448B     5.77
#> 11 fansi_vec_plain  102.9µs  107.5µs     8990.    5.02KB    14.7 
#> 12 base_vec_plain   22.23µs  22.55µs    43719.      448B     0   
#> 13 cli_txt_ansi     34.68µs  35.51µs    27591.        0B     5.52
#> 14 fansi_txt_ansi   105.5µs 110.33µs     8728.      688B    14.5 
#> 15 base_txt_ansi    45.16µs  45.73µs    21582.        0B     2.16
#> 16 cli_txt_plain    32.69µs  33.46µs    29198.        0B     5.84
#> 17 fansi_txt_plain  95.59µs 100.26µs     9672.      688B    14.5 
#> 18 base_txt_plain   24.07µs  24.58µs    40084.        0B     4.01
```

### `ansi_simplify()`

Nothing to compare here.

``` r
bench::mark(
  cli_ansi      = ansi_simplify(ansi),
  cli_plain     = ansi_simplify(plain),
  cli_vec_ansi  = ansi_simplify(vec_ansi),
  cli_vec_plain = ansi_simplify(vec_plain),
  cli_txt_ansi  = ansi_simplify(txt_ansi),
  cli_txt_plain = ansi_simplify(txt_plain),
  check = FALSE
)
```

``` fansi
#> # A tibble: 6 × 6
#>   expression         min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>    <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 cli_ansi        6.77µs   7.26µs   133563.        0B    26.7 
#> 2 cli_plain       6.25µs   6.73µs   143207.        0B    14.3 
#> 3 cli_vec_ansi    31.2µs  32.19µs    30425.      848B     6.09
#> 4 cli_vec_plain   10.1µs  10.71µs    89709.      848B    17.9 
#> 5 cli_txt_ansi   30.56µs  31.79µs    30771.        0B     3.08
#> 6 cli_txt_plain    7.1µs   7.56µs   128297.        0B    25.7
```

### `ansi_strip()`

``` r
bench::mark(
  cli_ansi        = ansi_strip(ansi),
  fansi_ansi      = strip_sgr(ansi),
  cli_plain       = ansi_strip(plain),
  fansi_plain     = strip_sgr(plain),
  cli_vec_ansi    = ansi_strip(vec_ansi),
  fansi_vec_ansi  = strip_sgr(vec_ansi),
  cli_vec_plain   = ansi_strip(vec_plain),
  fansi_vec_plain = strip_sgr(vec_plain),
  cli_txt_ansi    = ansi_strip(txt_ansi),
  fansi_txt_ansi  = strip_sgr(txt_ansi),
  cli_txt_plain   = ansi_strip(txt_plain),
  fansi_txt_plain = strip_sgr(txt_plain),
  check = FALSE
)
```

``` fansi
#> # A tibble: 12 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi          25.3µs   27.1µs    35766.        0B     28.6
#>  2 fansi_ansi        28.2µs   29.8µs    32440.    7.24KB     26.0
#>  3 cli_plain         25.1µs   26.8µs    36146.        0B     28.9
#>  4 fansi_plain       27.6µs   29.3µs    33024.      688B     26.4
#>  5 cli_vec_ansi      34.4µs   36.1µs    26884.      848B     21.5
#>  6 fansi_vec_ansi    52.9µs   55.8µs    17403.    5.41KB     12.6
#>  7 cli_vec_plain       28µs   29.8µs    32439.      848B     26.0
#>  8 fansi_vec_plain   36.2µs   38.5µs    25012.    4.59KB     20.0
#>  9 cli_txt_ansi      33.8µs   35.3µs    27439.        0B     22.0
#> 10 fansi_txt_ansi    43.5µs   45.4µs    21250.    5.12KB     16.9
#> 11 cli_txt_plain     25.9µs   27.3µs    35479.        0B     28.4
#> 12 fansi_txt_plain   28.9µs   30.2µs    31998.      688B     22.4
```

### `ansi_strsplit()`

``` r
bench::mark(
  cli_ansi        = ansi_strsplit(ansi, "i"),
  fansi_ansi      = strsplit_sgr(ansi, "i"),
  base_ansi       = strsplit(ansi, "i"),
  cli_plain       = ansi_strsplit(plain, "i"),
  fansi_plain     = strsplit_sgr(plain, "i"),
  base_plain      = strsplit(plain, "i"),
  cli_vec_ansi    = ansi_strsplit(vec_ansi, "i"),
  fansi_vec_ansi  = strsplit_sgr(vec_ansi, "i"),
  base_vec_ansi   = strsplit(vec_ansi, "i"),
  cli_vec_plain   = ansi_strsplit(vec_plain, "i"),
  fansi_vec_plain = strsplit_sgr(vec_plain, "i"),
  base_vec_plain  = strsplit(vec_plain, "i"),
  cli_txt_ansi    = ansi_strsplit(txt_ansi, "i"),
  fansi_txt_ansi  = strsplit_sgr(txt_ansi, "i"),
  base_txt_ansi   = strsplit(txt_ansi, "i"),
  cli_txt_plain   = ansi_strsplit(txt_plain, "i"),
  fansi_txt_plain = strsplit_sgr(txt_plain, "i"),
  base_txt_plain  = strsplit(txt_plain, "i"),
  check = FALSE
)
```

``` fansi
#> # A tibble: 18 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi        164.22µs 171.64µs     5664.  104.34KB    18.9 
#>  2 fansi_ansi      127.72µs  134.3µs     7225.  106.35KB    19.0 
#>  3 base_ansi         4.03µs   4.36µs   223621.      224B    22.4 
#>  4 cli_plain       162.46µs 170.51µs     5690.    8.09KB    18.9 
#>  5 fansi_plain     125.22µs  131.8µs     7368.    9.62KB    19.0 
#>  6 base_plain        3.52µs   3.81µs   253958.        0B    25.4 
#>  7 cli_vec_ansi      7.55ms   7.72ms      129.  823.77KB    25.3 
#>  8 fansi_vec_ansi    1.05ms   1.09ms      892.  846.81KB    19.6 
#>  9 base_vec_ansi   154.57µs  160.4µs     6073.    22.7KB     2.04
#> 10 cli_vec_plain     7.49ms   7.75ms      127.  823.77KB    25.9 
#> 11 fansi_vec_plain   1.01ms   1.04ms      939.  845.98KB    19.8 
#> 12 base_vec_plain  105.34µs 110.51µs     8925.      848B     4.05
#> 13 cli_txt_ansi      3.42ms   3.45ms      289.    63.6KB     0   
#> 14 fansi_txt_ansi    1.56ms   1.58ms      628.   35.05KB     2.02
#> 15 base_txt_ansi   135.85µs 146.92µs     6691.   18.47KB     2.02
#> 16 cli_txt_plain     2.39ms   2.42ms      413.    63.6KB     0   
#> 17 fansi_txt_plain 515.88µs 536.21µs     1846.    30.6KB     6.27
#> 18 base_txt_plain      88µs  89.17µs    11006.   11.05KB     2.02
```

### `ansi_strtrim()`

``` r
bench::mark(
  cli_ansi        = ansi_strtrim(ansi, 10),
  fansi_ansi      = strtrim_sgr(ansi, 10),
  base_ansi       = strtrim(ansi, 10),
  cli_plain       = ansi_strtrim(plain, 10),
  fansi_plain     = strtrim_sgr(plain, 10),
  base_plain      = strtrim(plain, 10),
  cli_vec_ansi    = ansi_strtrim(vec_ansi, 10),
  fansi_vec_ansi  = strtrim_sgr(vec_ansi, 10),
  base_vec_ansi   = strtrim(vec_ansi, 10),
  cli_vec_plain   = ansi_strtrim(vec_plain, 10),
  fansi_vec_plain = strtrim_sgr(vec_plain, 10),
  base_vec_plain  = strtrim(vec_plain, 10),
  cli_txt_ansi    = ansi_strtrim(txt_ansi, 10),
  fansi_txt_ansi  = strtrim_sgr(txt_ansi, 10),
  base_txt_ansi   = strtrim(txt_ansi, 10),
  cli_txt_plain   = ansi_strtrim(txt_plain, 10),
  fansi_txt_plain = strtrim_sgr(txt_plain, 10),
  base_txt_plain  = strtrim(txt_plain, 10),
  check = FALSE
)
```

``` fansi
#> # A tibble: 18 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi        146.08µs 155.09µs     6219.   33.84KB    23.4 
#>  2 fansi_ansi       53.41µs  56.97µs    16901.   31.42KB    22.1 
#>  3 base_ansi         1.04µs   1.09µs   878475.     4.2KB    87.9 
#>  4 cli_plain       143.31µs 149.74µs     6508.        0B    23.2 
#>  5 fansi_plain      52.09µs  54.99µs    17557.      872B    23.4 
#>  6 base_plain      962.06ns   1.01µs   922798.        0B     0   
#>  7 cli_vec_ansi    273.91µs 284.96µs     3445.   16.73KB    12.5 
#>  8 fansi_vec_ansi  115.53µs 119.58µs     8173.    5.59KB    12.5 
#>  9 base_vec_ansi     36.3µs  37.56µs    25950.      848B     2.60
#> 10 cli_vec_plain   229.65µs 238.04µs     4113.   16.73KB    14.7 
#> 11 fansi_vec_plain 108.68µs 112.62µs     8666.    5.59KB    12.5 
#> 12 base_vec_plain   30.45µs  31.21µs    31658.      848B     0   
#> 13 cli_txt_ansi     155.5µs 162.68µs     5987.        0B    23.4 
#> 14 fansi_txt_ansi   53.21µs  56.51µs    17197.      872B    23.4 
#> 15 base_txt_ansi     1.07µs   1.12µs   854116.        0B     0   
#> 16 cli_txt_plain   146.24µs  152.5µs     6368.        0B    23.3 
#> 17 fansi_txt_plain  53.04µs  56.38µs    17106.      872B    23.4 
#> 18 base_txt_plain  982.08ns   1.03µs   919126.        0B     0
```

### `ansi_strwrap()`

This function is most useful for longer text, but it is often called for
short text in cli, so it makes sense to benchmark that as well.

``` r
bench::mark(
  cli_ansi        = ansi_strwrap(ansi, 30),
  fansi_ansi      = strwrap_sgr(ansi, 30),
  base_ansi       = strwrap(ansi, 30),
  cli_plain       = ansi_strwrap(plain, 30),
  fansi_plain     = strwrap_sgr(plain, 30),
  base_plain      = strwrap(plain, 30),
  cli_vec_ansi    = ansi_strwrap(vec_ansi, 30),
  fansi_vec_ansi  = strwrap_sgr(vec_ansi, 30),
  base_vec_ansi   = strwrap(vec_ansi, 30),
  cli_vec_plain   = ansi_strwrap(vec_plain, 30),
  fansi_vec_plain = strwrap_sgr(vec_plain, 30),
  base_vec_plain  = strwrap(vec_plain, 30),
  cli_txt_ansi    = ansi_strwrap(txt_ansi, 30),
  fansi_txt_ansi  = strwrap_sgr(txt_ansi, 30),
  base_txt_ansi   = strwrap(txt_ansi, 30),
  cli_txt_plain   = ansi_strwrap(txt_plain, 30),
  fansi_txt_plain = strwrap_sgr(txt_plain, 30),
  base_txt_plain  = strwrap(txt_plain, 30),
  check = FALSE
)
```

``` fansi
#> # A tibble: 18 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi        397.54µs 423.83µs    2333.         0B    21.4 
#>  2 fansi_ansi       98.23µs 104.85µs    9174.    97.32KB    21.2 
#>  3 base_ansi        37.63µs  40.35µs   23777.         0B    19.4 
#>  4 cli_plain       272.89µs 287.45µs    3408.         0B    10.3 
#>  5 fansi_plain      97.63µs 103.24µs    9469.       872B    12.4 
#>  6 base_plain       31.08µs   33.2µs   29005.         0B    11.6 
#>  7 cli_vec_ansi     41.77ms  42.03ms      23.8    2.48KB    17.0 
#>  8 fansi_vec_ansi  237.02µs 245.27µs    4004.     7.25KB     6.18
#>  9 base_vec_ansi     2.21ms   2.29ms     436.    48.18KB    12.8 
#> 10 cli_vec_plain    28.64ms  28.92ms      34.6    2.48KB    18.8 
#> 11 fansi_vec_plain 191.41µs 199.29µs    4898.     6.42KB     6.13
#> 12 base_vec_plain    1.61ms   1.67ms     596.     47.4KB    12.7 
#> 13 cli_txt_ansi     23.75ms  23.99ms      41.4  507.59KB     6.90
#> 14 fansi_txt_ansi  226.12µs 234.77µs    4176.     6.77KB     6.12
#> 15 base_txt_ansi     1.23ms   1.26ms     782.   582.06KB    11.1 
#> 16 cli_txt_plain     1.25ms   1.29ms     765.   369.84KB     8.59
#> 17 fansi_txt_plain 179.62µs 186.61µs    5239.     2.51KB     6.14
#> 18 base_txt_plain  844.15µs 877.73µs    1126.   367.31KB    11.0
```

### `ansi_substr()`

``` r
bench::mark(
  cli_ansi        = ansi_substr(ansi, 2, 10),
  fansi_ansi      = substr_sgr(ansi, 2, 10),
  base_ansi       = substr(ansi, 2, 10),
  cli_plain       = ansi_substr(plain, 2, 10),
  fansi_plain     = substr_sgr(plain, 2, 10),
  base_plain      = substr(plain, 2, 10),
  cli_vec_ansi    = ansi_substr(vec_ansi, 2, 10),
  fansi_vec_ansi  = substr_sgr(vec_ansi, 2, 10),
  base_vec_ansi   = substr(vec_ansi, 2, 10),
  cli_vec_plain   = ansi_substr(vec_plain, 2, 10),
  fansi_vec_plain = substr_sgr(vec_plain, 2, 10),
  base_vec_plain  = substr(vec_plain, 2, 10),
  cli_txt_ansi    = ansi_substr(txt_ansi, 2, 10),
  fansi_txt_ansi  = substr_sgr(txt_ansi, 2, 10),
  base_txt_ansi   = substr(txt_ansi, 2, 10),
  cli_txt_plain   = ansi_substr(txt_plain, 2, 10),
  fansi_txt_plain = substr_sgr(txt_plain, 2, 10),
  base_txt_plain  = substr(txt_plain, 2, 10),
  check = FALSE
)
```

``` fansi
#> # A tibble: 18 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi          6.74µs   7.39µs   129195.   24.83KB    25.8 
#>  2 fansi_ansi       78.26µs  82.94µs    11694.   28.48KB    10.4 
#>  3 base_ansi       991.04ns   1.04µs   887276.        0B     0   
#>  4 cli_plain          6.6µs   7.27µs   132866.        0B    26.6 
#>  5 fansi_plain      78.18µs  82.52µs    11786.    1.98KB    10.4 
#>  6 base_plain      961.01ns   1.01µs   926123.        0B     0   
#>  7 cli_vec_ansi     28.12µs  29.08µs    33651.     1.7KB     6.73
#>  8 fansi_vec_ansi  114.83µs 119.42µs     8143.    8.86KB     6.19
#>  9 base_vec_ansi     6.19µs   6.49µs   149524.      848B    15.0 
#> 10 cli_vec_plain    23.42µs  24.79µs    39439.     1.7KB     3.94
#> 11 fansi_vec_plain 108.11µs 113.69µs     8502.    8.86KB     8.35
#> 12 base_vec_plain    5.67µs   5.99µs   163317.      848B     0   
#> 13 cli_txt_ansi      6.78µs   7.39µs   130588.        0B    13.1 
#> 14 fansi_txt_ansi   77.75µs  82.75µs    11672.    1.98KB    12.5 
#> 15 base_txt_ansi     5.13µs    5.2µs   187613.        0B     0   
#> 16 cli_txt_plain     7.61µs   8.25µs   117841.        0B    11.8 
#> 17 fansi_txt_plain  78.23µs  83.06µs    11673.    1.98KB    12.7 
#> 18 base_txt_plain    3.37µs   3.43µs   283328.        0B     0
```

### `ansi_tolower()` , `ansi_toupper()`

``` r
bench::mark(
  cli_ansi        = ansi_tolower(ansi),
  base_ansi       = tolower(ansi),
  cli_plain       = ansi_tolower(plain),
  base_plain      = tolower(plain),
  cli_vec_ansi    = ansi_tolower(vec_ansi),
  base_vec_ansi   = tolower(vec_ansi),
  cli_vec_plain   = ansi_tolower(vec_plain),
  base_vec_plain  = tolower(vec_plain),
  cli_txt_ansi    = ansi_tolower(txt_ansi),
  base_txt_ansi   = tolower(txt_ansi),
  cli_txt_plain   = ansi_tolower(txt_plain),
  base_txt_plain  = tolower(txt_plain),
  check = FALSE
)
```

``` fansi
#> # A tibble: 12 × 6
#>    expression          min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>     <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi       104.39µs 109.89µs    8832.    11.88KB    10.3 
#>  2 base_ansi        1.27µs   1.32µs  732632.         0B     0   
#>  3 cli_plain       83.64µs  88.33µs   10955.     8.73KB     8.20
#>  4 base_plain     962.06ns   1.01µs  937655.         0B     0   
#>  5 cli_vec_ansi     4.07ms    4.2ms     239.   838.77KB    15.6 
#>  6 base_vec_ansi   71.86µs  72.23µs   13659.       848B     0   
#>  7 cli_vec_plain    2.25ms   2.32ms     429.    816.9KB    15.1 
#>  8 base_vec_plain  42.98µs  43.15µs   22866.       848B     0   
#>  9 cli_txt_ansi    13.43ms  13.56ms      73.6  114.42KB     4.20
#> 10 base_txt_ansi   73.69µs  74.05µs   13311.         0B     0   
#> 11 cli_txt_plain  258.57µs 267.43µs    3657.    18.16KB     2.01
#> 12 base_txt_plain  40.89µs   41.5µs   23800.         0B     0
```

### `ansi_trimws()`

``` r
bench::mark(
  cli_ansi        = ansi_trimws(ansi),
  base_ansi       = trimws(ansi),
  cli_plain       = ansi_trimws(plain),
  base_plain      = trimws(plain),
  cli_vec_ansi    = ansi_trimws(vec_ansi),
  base_vec_ansi   = trimws(vec_ansi),
  cli_vec_plain   = ansi_trimws(vec_plain),
  base_vec_plain  = trimws(vec_plain),
  cli_txt_ansi    = ansi_trimws(txt_ansi),
  base_txt_ansi   = trimws(txt_ansi),
  cli_txt_plain   = ansi_trimws(txt_plain),
  base_txt_plain  = trimws(txt_plain),
  check = FALSE
)
```

``` fansi
#> # A tibble: 12 × 6
#>    expression          min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>     <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi        107.6µs    112µs     8662.        0B    12.4 
#>  2 base_ansi        16.1µs     17µs    57168.        0B    11.4 
#>  3 cli_plain       106.2µs  111.2µs     8733.        0B    14.5 
#>  4 base_plain       16.1µs   17.2µs    56459.        0B    11.3 
#>  5 cli_vec_ansi      196µs  207.2µs     4722.     7.2KB     6.12
#>  6 base_vec_ansi      54µs   60.1µs    16657.    1.66KB     4.05
#>  7 cli_vec_plain     183µs  194.3µs     5031.     7.2KB     6.13
#>  8 base_vec_plain   48.9µs   55.5µs    18065.    1.66KB     4.06
#>  9 cli_txt_ansi    173.5µs  180.2µs     5371.        0B     8.18
#> 10 base_txt_ansi    37.9µs     48µs    21663.        0B     4.33
#> 11 cli_txt_plain   158.6µs  174.1µs     5652.        0B     8.18
#> 12 base_txt_plain   33.2µs   34.4µs    28137.        0B     5.63
```

## UTF-8 functions

### `utf8_nchar()`

``` r
bench::mark(
  cli        = utf8_nchar(uni, type = "chars"),
  base       = nchar(uni, "chars"),
  cli_vec    = utf8_nchar(vec_uni, type = "chars"),
  base_vec   = nchar(vec_uni, "chars"),
  cli_txt    = utf8_nchar(txt_uni, type = "chars"),
  base_txt   = nchar(txt_uni, "chars"),
  check = FALSE
)
```

``` fansi
#> # A tibble: 6 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 cli          8.01µs    8.6µs   113298.        0B    11.3 
#> 2 base       821.08ns  862.2ns  1072666.        0B     0   
#> 3 cli_vec     22.91µs   23.7µs    41093.      448B     8.22
#> 4 base_vec    11.66µs     12µs    82296.      448B     0   
#> 5 cli_txt     23.21µs   23.9µs    40945.        0B     4.09
#> 6 base_txt     12.3µs   12.4µs    79465.        0B     0
```

``` r
bench::mark(
  cli        = utf8_nchar(uni, type = "width"),
  base       = nchar(uni, "width"),
  cli_vec    = utf8_nchar(vec_uni, type = "width"),
  base_vec   = nchar(vec_uni, "width"),
  cli_txt    = utf8_nchar(txt_uni, type = "width"),
  base_txt   = nchar(txt_uni, "width"),
  check = FALSE
)
```

``` fansi
#> # A tibble: 6 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 cli             8µs   8.66µs   112081.        0B    22.4 
#> 2 base         1.25µs    1.3µs   724474.        0B     0   
#> 3 cli_vec     28.37µs  29.43µs    33275.      448B     3.33
#> 4 base_vec    51.44µs  52.08µs    18936.      448B     0   
#> 5 cli_txt     28.84µs  29.73µs    32895.        0B     3.29
#> 6 base_txt     87.8µs  88.51µs    11162.        0B     0
```

``` r
bench::mark(
  cli        = utf8_nchar(uni, type = "codepoints"),
  base       = nchar(uni, "chars"),
  cli_vec    = utf8_nchar(vec_uni, type = "codepoints"),
  base_vec   = nchar(vec_uni, "chars"),
  cli_txt    = utf8_nchar(txt_uni, type = "codepoints"),
  base_txt   = nchar(txt_uni, "chars"),
  check = FALSE
)
```

``` fansi
#> # A tibble: 6 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 cli          8.63µs   9.28µs   104663.        0B    10.5 
#> 2 base       820.96ns 862.05ns  1073871.        0B     0   
#> 3 cli_vec     19.73µs  20.69µs    46512.      448B     9.30
#> 4 base_vec    11.66µs  11.96µs    82292.      448B     0   
#> 5 cli_txt     20.09µs  22.95µs    43645.        0B     4.36
#> 6 base_txt     12.3µs  12.38µs    79514.        0B     0
```

### `utf8_substr()`

``` r
bench::mark(
  cli        = utf8_substr(uni, 2, 10),
  base       = substr(uni, 2, 10),
  cli_vec    = utf8_substr(vec_uni, 2, 10),
  base_vec   = substr(vec_uni, 2, 10),
  cli_txt    = utf8_substr(txt_uni, 2, 10),
  base_txt   = substr(txt_uni, 2, 10),
  check = FALSE
)
```

``` fansi
#> # A tibble: 6 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 cli          6.28µs   6.84µs   141502.    22.1KB    28.3 
#> 2 base            1µs   1.07µs   876596.        0B     0   
#> 3 cli_vec     29.75µs   30.7µs    31886.     1.7KB     3.19
#> 4 base_vec     8.39µs   8.59µs   114286.      848B     0   
#> 5 cli_txt      6.29µs   6.87µs   140517.        0B    28.1 
#> 6 base_txt     5.42µs   5.49µs   175472.        0B     0
```

## Session info

``` r
sessioninfo::session_info()
```

``` fansi
#> ─ Session info ──────────────────────────────────────────────────────
#>  setting  value
#>  version  R version 4.5.3 (2026-03-11)
#>  os       Ubuntu 24.04.4 LTS
#>  system   x86_64, linux-gnu
#>  ui       X11
#>  language en
#>  collate  C.UTF-8
#>  ctype    C.UTF-8
#>  tz       UTC
#>  date     2026-03-31
#>  pandoc   3.1.11 @ /opt/hostedtoolcache/pandoc/3.1.11/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.10.0     2026-01-26 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.5.9000 2026-03-31 [1] local
#>  codetools     0.2-20     2024-03-31 [3] CRAN (R 4.5.3)
#>  desc          1.4.3      2023-12-10 [1] RSPM
#>  digest        0.6.39     2025-11-19 [1] RSPM
#>  evaluate      1.0.5      2025-08-27 [1] RSPM
#>  fansi       * 1.0.7      2025-11-19 [1] RSPM
#>  fastmap       1.2.0      2024-05-15 [1] RSPM
#>  fs            2.0.1      2026-03-24 [1] RSPM
#>  glue          1.8.0      2024-09-30 [1] RSPM
#>  htmltools     0.5.9      2025-12-04 [1] RSPM
#>  htmlwidgets   1.6.4      2023-12-06 [1] RSPM
#>  jquerylib     0.1.4      2021-04-26 [1] RSPM
#>  jsonlite      2.0.0      2025-03-27 [1] RSPM
#>  knitr         1.51       2025-12-20 [1] RSPM
#>  lifecycle     1.0.5      2026-01-08 [1] RSPM
#>  magrittr      2.0.4      2025-09-12 [1] RSPM
#>  pillar        1.11.1     2025-09-17 [1] RSPM
#>  pkgconfig     2.0.3      2019-09-22 [1] RSPM
#>  pkgdown       2.2.0      2025-11-06 [1] any (@2.2.0)
#>  profmem       0.7.0      2025-05-02 [1] RSPM
#>  R6            2.6.1      2025-02-15 [1] RSPM
#>  ragg          1.5.2      2026-03-23 [1] RSPM
#>  rlang         1.1.7      2026-01-09 [1] RSPM
#>  rmarkdown     2.31       2026-03-26 [1] RSPM
#>  sass          0.4.10     2025-04-11 [1] RSPM
#>  sessioninfo   1.2.3      2025-02-05 [1] RSPM
#>  systemfonts   1.3.2      2026-03-05 [1] RSPM
#>  textshaping   1.0.5      2026-03-06 [1] RSPM
#>  tibble        3.3.1      2026-01-11 [1] RSPM
#>  utf8          1.2.6      2025-06-08 [1] RSPM
#>  vctrs         0.7.2      2026-03-21 [1] RSPM
#>  xfun          0.57       2026-03-20 [1] RSPM
#>  yaml          2.3.12     2025-12-10 [1] RSPM
#> 
#>  [1] /home/runner/work/_temp/Library
#>  [2] /opt/R/4.5.3/lib/R/site-library
#>  [3] /opt/R/4.5.3/lib/R/library
#>  * ── Packages attached to the search path.
#> 
#> ─────────────────────────────────────────────────────────────────────
```
