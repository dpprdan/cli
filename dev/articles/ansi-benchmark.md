# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x55eabfa16790\>
\<environment: 0x55eac04bee68\>

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
#> 1 ansi         48.1µs   51.5µs    18768.    99.6KB     19.0
#> 2 plain        47.5µs   51.2µs    18862.        0B     19.8
#> 3 base         11.7µs   12.9µs    75077.    48.6KB     15.0
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
#> 1 ansi         49.8µs   53.3µs    18137.        0B     21.3
#> 2 plain        48.8µs   52.4µs    18496.        0B     21.3
#> 3 base         13.6µs     15µs    64383.        0B     25.8
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
#> 1 ansi       113.41µs  120.1µs     8040.   76.15KB     16.8
#> 2 plain       89.54µs   94.7µs    10187.    8.73KB     14.6
#> 3 base         1.85µs      2µs   480739.        0B      0
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
#> 1 ansi          355µs    378µs     2605.   33.23KB     19.0
#> 2 plain         352µs    378µs     2618.    1.09KB     16.9
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
#>  1 cli_ansi          5.84µs   6.39µs   151274.    9.27KB    30.3 
#>  2 fansi_ansi       31.44µs  34.77µs    27824.    4.18KB    22.3 
#>  3 cli_plain         5.84µs   6.38µs   150804.        0B    30.2 
#>  4 fansi_plain      31.18µs  33.89µs    28020.      688B    16.8 
#>  5 cli_vec_ansi      7.23µs   7.71µs   125722.      448B    12.6 
#>  6 fansi_vec_ansi   41.46µs  43.86µs    21906.    5.02KB    11.0 
#>  7 cli_vec_plain     7.79µs   8.28µs   114437.      448B    11.4 
#>  8 fansi_vec_plain  38.94µs  41.42µs    23429.    5.02KB     9.38
#>  9 cli_txt_ansi      5.78µs   6.19µs   156689.        0B    15.7 
#> 10 fansi_txt_ansi   31.33µs  33.33µs    29155.      688B    11.7 
#> 11 cli_txt_plain     6.57µs   6.97µs   139699.        0B    14.0 
#> 12 fansi_txt_plain  39.13µs  41.71µs    23255.    5.02KB    11.6
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
#> 1 cli          57.4µs   59.5µs    16385.    22.7KB     4.05
#> 2 fansi       119.8µs  126.7µs     7763.    55.3KB     6.12
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
#>  1 cli_ansi          7.23µs   7.87µs   123553.        0B    12.4 
#>  2 fansi_ansi       91.73µs  97.58µs     9950.   38.84KB     8.20
#>  3 base_ansi       910.95ns 961.94ns   971397.        0B     0   
#>  4 cli_plain         7.17µs   7.86µs   123190.        0B    12.3 
#>  5 fansi_plain      92.24µs  97.43µs     9914.      688B     8.19
#>  6 base_plain      831.09ns 882.08ns  1065778.        0B   107.  
#>  7 cli_vec_ansi     29.66µs  30.54µs    32100.      448B     3.21
#>  8 fansi_vec_ansi  112.91µs 118.75µs     8153.    5.02KB     6.16
#>  9 base_vec_ansi     17.2µs  17.28µs    56911.      448B     0   
#> 10 cli_vec_plain    27.87µs  28.69µs    34120.      448B     3.41
#> 11 fansi_vec_plain 103.78µs 108.95µs     8870.    5.02KB     8.27
#> 12 base_vec_plain   10.14µs  10.22µs    95799.      448B     0   
#> 13 cli_txt_ansi     29.09µs  29.85µs    32817.        0B     3.28
#> 14 fansi_txt_ansi  104.61µs 109.85µs     8831.      688B     8.20
#> 15 base_txt_ansi     16.9µs  16.95µs    58032.        0B     0   
#> 16 cli_txt_plain    28.36µs  29.29µs    33500.        0B     3.35
#> 17 fansi_txt_plain  94.48µs  99.52µs     9730.      688B     8.20
#> 18 base_txt_plain    9.89µs  10.39µs    92984.        0B     0
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
#>  1 cli_ansi           8.7µs   9.43µs   102633.        0B    10.3 
#>  2 fansi_ansi       92.51µs   98.2µs     9852.      688B     8.29
#>  3 base_ansi         1.23µs   1.28µs   733457.        0B     0   
#>  4 cli_plain          8.7µs   9.43µs   102956.        0B    20.6 
#>  5 fansi_plain      91.63µs  97.51µs     9927.      688B     8.21
#>  6 base_plain        1.01µs   1.06µs   889912.        0B     0   
#>  7 cli_vec_ansi     34.76µs  35.77µs    27342.      448B     2.73
#>  8 fansi_vec_ansi  115.51µs 121.12µs     8003.    5.02KB     8.27
#>  9 base_vec_ansi    40.98µs  41.41µs    23834.      448B     0   
#> 10 cli_vec_plain    33.26µs   34.2µs    28633.      448B     2.86
#> 11 fansi_vec_plain    105µs 111.69µs     8675.    5.02KB     8.26
#> 12 base_vec_plain   21.62µs  21.96µs    44946.      448B     0   
#> 13 cli_txt_ansi     34.58µs   35.4µs    27690.        0B     2.77
#> 14 fansi_txt_ansi  107.47µs  112.9µs     8585.      688B     8.21
#> 15 base_txt_ansi    43.25µs  44.17µs    22382.        0B     0   
#> 16 cli_txt_plain    33.98µs  35.04µs    27912.        0B     2.79
#> 17 fansi_txt_plain  96.76µs 102.78µs     9417.      688B     8.20
#> 18 base_txt_plain   23.58µs  23.84µs    41402.        0B     0
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
#> 1 cli_ansi        7.02µs   7.66µs   126956.        0B     0   
#> 2 cli_plain       6.66µs   7.24µs   134324.        0B    13.4 
#> 3 cli_vec_ansi   32.47µs  33.58µs    29197.      848B     2.92
#> 4 cli_vec_plain  10.69µs  11.37µs    85709.      848B     8.57
#> 5 cli_txt_ansi   31.44µs  32.49µs    30190.        0B     3.02
#> 6 cli_txt_plain   7.53µs   8.15µs   119257.        0B    11.9
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
#>  1 cli_ansi          26.2µs   27.8µs    34810.        0B    17.4 
#>  2 fansi_ansi        29.3µs   31.5µs    30744.    7.24KB    12.3 
#>  3 cli_plain         26.1µs   27.6µs    35166.        0B    14.1 
#>  4 fansi_plain         29µs   31.1µs    31169.      688B    12.5 
#>  5 cli_vec_ansi      35.7µs   37.5µs    25853.      848B    12.9 
#>  6 fansi_vec_ansi    56.3µs   58.8µs    16542.    5.41KB     6.19
#>  7 cli_vec_plain     28.2µs   30.4µs    31985.      848B    12.8 
#>  8 fansi_vec_plain   37.8µs   39.7µs    24452.    4.59KB     9.78
#>  9 cli_txt_ansi      34.9µs   36.1µs    26968.        0B    13.5 
#> 10 fansi_txt_ansi    44.9µs   46.6µs    20817.    5.12KB     8.33
#> 11 cli_txt_plain     26.6µs   27.8µs    34943.        0B    14.0 
#> 12 fansi_txt_plain   29.8µs   31.2µs    30913.      688B    12.4
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
#>  1 cli_ansi        165.47µs 173.18µs     5612.  104.86KB    10.3 
#>  2 fansi_ansi      131.88µs 140.03µs     6960.  106.35KB    10.4 
#>  3 base_ansi         4.04µs   4.38µs   221859.      224B    22.2 
#>  4 cli_plain       163.65µs 171.06µs     5671.    8.09KB    10.3 
#>  5 fansi_plain     130.02µs 138.69µs     7031.    9.62KB    10.4 
#>  6 base_plain        3.61µs   3.93µs   248046.        0B     0   
#>  7 cli_vec_ansi      7.71ms   7.89ms      126.  823.77KB    11.3 
#>  8 fansi_vec_ansi    1.06ms    1.1ms      889.  846.81KB    17.4 
#>  9 base_vec_ansi   158.62µs 163.86µs     5968.    22.7KB     4.13
#> 10 cli_vec_plain     7.67ms   7.86ms      127.  823.77KB    11.3 
#> 11 fansi_vec_plain   1.01ms   1.04ms      955.  845.98KB    17.3 
#> 12 base_vec_plain  108.07µs 113.45µs     8713.      848B     4.06
#> 13 cli_txt_ansi      3.41ms   3.45ms      289.    63.6KB     0   
#> 14 fansi_txt_ansi    1.57ms   1.59ms      626.   35.05KB     0   
#> 15 base_txt_ansi   137.59µs 143.89µs     6916.   18.47KB     4.06
#> 16 cli_txt_plain     2.44ms   2.46ms      404.    63.6KB     0   
#> 17 fansi_txt_plain 521.46µs 539.91µs     1836.    30.6KB     2.02
#> 18 base_txt_plain   88.49µs  91.22µs    10806.   11.05KB     2.02
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
#>  1 cli_ansi        150.69µs 157.76µs     6161.   33.84KB    12.4 
#>  2 fansi_ansi       56.08µs  59.84µs    16194.   31.42KB    12.5 
#>  3 base_ansi         1.05µs   1.12µs   844070.     4.2KB     0   
#>  4 cli_plain       147.12µs 154.88µs     6269.        0B    12.4 
#>  5 fansi_plain      55.42µs  59.48µs    16297.      872B    10.3 
#>  6 base_plain      981.96ns   1.04µs   895842.        0B    89.6 
#>  7 cli_vec_ansi    276.99µs 287.27µs     3413.   16.73KB     6.16
#>  8 fansi_vec_ansi  116.79µs 121.32µs     8031.    5.59KB     6.30
#>  9 base_vec_ansi    35.46µs  36.08µs    27392.      848B     0   
#> 10 cli_vec_plain   235.16µs 244.46µs     4001.   16.73KB     8.29
#> 11 fansi_vec_plain 109.83µs  114.1µs     8531.    5.59KB     6.16
#> 12 base_vec_plain   29.96µs  30.46µs    32245.      848B     0   
#> 13 cli_txt_ansi    158.97µs 167.17µs     5817.        0B    12.4 
#> 14 fansi_txt_ansi   55.59µs  59.61µs    16273.      872B    12.9 
#> 15 base_txt_ansi     1.09µs   1.15µs   837842.        0B     0   
#> 16 cli_txt_plain   148.31µs 154.08µs     6315.        0B    12.4 
#> 17 fansi_txt_plain  54.81µs  57.22µs    16917.      872B    12.4 
#> 18 base_txt_plain    1.02µs   1.07µs   897119.        0B     0
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
#>  1 cli_ansi        421.83µs 449.25µs    2219.     6.18KB    10.3 
#>  2 fansi_ansi       101.1µs 107.87µs    9004.    97.33KB    10.5 
#>  3 base_ansi        39.62µs  41.63µs   23179.         0B    11.6 
#>  4 cli_plain       278.07µs 290.52µs    3362.         0B    10.3 
#>  5 fansi_plain      99.28µs 106.18µs    9152.       872B    10.3 
#>  6 base_plain       32.34µs  34.32µs   28030.         0B    11.2 
#>  7 cli_vec_ansi     44.87ms  45.52ms      21.9   94.67KB    18.3 
#>  8 fansi_vec_ansi  240.65µs 250.54µs    3910.     7.25KB     6.14
#>  9 base_vec_ansi      2.3ms   2.36ms     422.    48.18KB    12.9 
#> 10 cli_vec_plain    29.11ms  29.49ms      33.6    2.48KB    14.0 
#> 11 fansi_vec_plain 194.46µs 202.28µs    4836.     6.42KB     8.25
#> 12 base_vec_plain    1.67ms   1.73ms     574.     47.4KB    12.8 
#> 13 cli_txt_ansi     26.83ms  27.16ms      36.7    4.27MB     4.31
#> 14 fansi_txt_ansi  228.74µs 237.53µs    4135.     6.77KB     6.13
#> 15 base_txt_ansi     1.26ms    1.3ms     762.   582.06KB    11.1 
#> 16 cli_txt_plain     1.29ms   1.33ms     743.   369.84KB     8.64
#> 17 fansi_txt_plain 188.81µs 197.15µs    4962.     2.51KB     6.14
#> 18 base_txt_plain  855.65µs  892.4µs    1106.   367.31KB     8.64
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
#>  1 cli_ansi          6.89µs   7.49µs   129001.   25.09KB    12.9 
#>  2 fansi_ansi       81.98µs  87.09µs    11117.   28.48KB    10.4 
#>  3 base_ansi         1.04µs   1.09µs   863538.        0B     0   
#>  4 cli_plain         6.72µs   7.38µs   129595.        0B    25.9 
#>  5 fansi_plain      82.24µs  86.98µs    11131.    1.98KB    10.5 
#>  6 base_plain        1.01µs   1.07µs   879809.        0B     0   
#>  7 cli_vec_ansi     27.53µs  28.57µs    34219.     1.7KB     3.42
#>  8 fansi_vec_ansi  118.91µs 124.54µs     7775.    8.86KB     8.34
#>  9 base_vec_ansi      6.1µs   6.38µs   153856.      848B     0   
#> 10 cli_vec_plain    23.82µs  24.76µs    39158.     1.7KB     3.92
#> 11 fansi_vec_plain 114.44µs 119.75µs     8102.    8.86KB     8.34
#> 12 base_vec_plain    5.84µs   5.97µs   164150.      848B     0   
#> 13 cli_txt_ansi      6.85µs   7.54µs   128269.        0B    12.8 
#> 14 fansi_txt_ansi   81.76µs  87.14µs    11114.    1.98KB    10.4 
#> 15 base_txt_ansi     6.46µs   6.53µs   148802.        0B    14.9 
#> 16 cli_txt_plain     7.47µs   8.14µs   119337.        0B    11.9 
#> 17 fansi_txt_plain  80.25µs  83.48µs    11623.    1.98KB    10.3 
#> 18 base_txt_plain    4.12µs   4.17µs   234260.        0B     0
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
#>  1 cli_ansi        106.4µs 110.81µs    8728.    11.88KB     8.20
#>  2 base_ansi        1.33µs   1.37µs  713077.         0B     0   
#>  3 cli_plain       85.07µs  88.38µs   10919.     8.73KB     8.21
#>  4 base_plain       1.03µs   1.07µs  897066.         0B     0   
#>  5 cli_vec_ansi     4.15ms   4.25ms     235.   838.77KB    15.7 
#>  6 base_vec_ansi   71.91µs  72.14µs   13685.       848B     0   
#>  7 cli_vec_plain    2.37ms   2.42ms     411.    816.9KB    12.8 
#>  8 base_vec_plain  42.55µs  43.15µs   22906.       848B     2.29
#>  9 cli_txt_ansi    14.37ms  14.49ms      69.0  114.42KB     2.03
#> 10 base_txt_ansi   72.72µs  73.79µs   13377.         0B     0   
#> 11 cli_txt_plain  272.42µs 280.04µs    3502.    18.16KB     4.03
#> 12 base_txt_plain  40.93µs  42.45µs   23420.         0B     0
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
#>  1 cli_ansi        109.9µs  115.9µs     8364.        0B    12.4 
#>  2 base_ansi        16.9µs   18.1µs    53503.        0B    10.7 
#>  3 cli_plain       110.9µs  116.8µs     8296.        0B    10.3 
#>  4 base_plain       17.2µs   18.2µs    52980.        0B    10.6 
#>  5 cli_vec_ansi    208.4µs  218.3µs     4459.     7.2KB     6.13
#>  6 base_vec_ansi    59.2µs     65µs    14978.    1.66KB     4.06
#>  7 cli_vec_plain   193.6µs  203.8µs     4779.     7.2KB     6.15
#>  8 base_vec_plain   52.2µs     58µs    16916.    1.66KB     4.06
#>  9 cli_txt_ansi    184.6µs  190.1µs     5120.        0B     6.11
#> 10 base_txt_ansi    41.6µs   42.9µs    22691.        0B     6.81
#> 11 cli_txt_plain   167.4µs  174.5µs     5582.        0B     6.16
#> 12 base_txt_plain   35.8µs   37.2µs    26171.        0B     5.24
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
#> 1 cli          8.37µs   9.06µs   106923.        0B    10.7 
#> 2 base       881.03ns 922.01ns  1008414.        0B     0   
#> 3 cli_vec     24.02µs  24.82µs    39344.      448B     3.93
#> 4 base_vec    11.62µs  11.82µs    83230.      448B     0   
#> 5 cli_txt     24.15µs  24.86µs    39258.        0B     7.85
#> 6 base_txt    12.62µs  12.69µs    77471.        0B     0
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
#> 1 cli          8.38µs   9.03µs   107489.        0B    10.7 
#> 2 base         1.29µs   1.35µs   701585.        0B     0   
#> 3 cli_vec     29.23µs  30.15µs    32453.      448B     3.25
#> 4 base_vec    50.48µs  51.22µs    19261.      448B     2.02
#> 5 cli_txt     29.71µs  30.56µs    32061.        0B     3.21
#> 6 base_txt    86.51µs  87.45µs    10912.        0B     0
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
#> 1 cli          8.97µs   9.68µs    99692.        0B     9.97
#> 2 base       871.02ns 912.11ns  1011448.        0B     0   
#> 3 cli_vec     20.02µs  20.89µs    46717.      448B     4.67
#> 4 base_vec    11.62µs  11.83µs    83177.      448B     0   
#> 5 cli_txt     20.71µs   21.5µs    45478.        0B     4.55
#> 6 base_txt    12.63µs   12.7µs    77439.        0B     0
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
#> 1 cli          6.43µs      7µs   136837.    22.2KB    13.7 
#> 2 base         1.05µs    1.1µs   856075.        0B     0   
#> 3 cli_vec     30.57µs  31.48µs    31169.     1.7KB     3.12
#> 4 base_vec     8.31µs   8.59µs   113797.      848B    11.4 
#> 5 cli_txt      6.31µs   6.91µs   139285.        0B    13.9 
#> 6 base_txt      5.7µs   5.78µs   168978.        0B     0
```

## Session info

``` r

sessioninfo::session_info()
```

``` fansi
#> ─ Session info ──────────────────────────────────────────────────────
#>  setting  value
#>  version  R version 4.6.0 (2026-04-24)
#>  os       Ubuntu 24.04.4 LTS
#>  system   x86_64, linux-gnu
#>  ui       X11
#>  language en
#>  collate  C.UTF-8
#>  ctype    C.UTF-8
#>  tz       UTC
#>  date     2026-05-27
#>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.11.0     2026-05-16 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.6.9000 2026-05-27 [1] local
#>  codetools     0.2-20     2024-03-31 [3] CRAN (R 4.6.0)
#>  desc          1.4.3      2023-12-10 [1] RSPM
#>  digest        0.6.39     2025-11-19 [1] RSPM
#>  evaluate      1.0.5      2025-08-27 [1] RSPM
#>  fansi       * 1.0.7      2025-11-19 [1] RSPM
#>  fastmap       1.2.0      2024-05-15 [1] RSPM
#>  fs            2.1.0      2026-04-18 [1] RSPM
#>  glue          1.8.1      2026-04-17 [1] RSPM
#>  htmltools     0.5.9      2025-12-04 [1] RSPM
#>  htmlwidgets   1.6.4      2023-12-06 [1] RSPM
#>  jquerylib     0.1.4      2021-04-26 [1] RSPM
#>  jsonlite      2.0.0      2025-03-27 [1] RSPM
#>  knitr         1.51       2025-12-20 [1] RSPM
#>  lifecycle     1.0.5      2026-01-08 [1] RSPM
#>  magrittr      2.0.5      2026-04-04 [1] RSPM
#>  pillar        1.11.1     2025-09-17 [1] RSPM
#>  pkgconfig     2.0.3      2019-09-22 [1] RSPM
#>  pkgdown       2.2.0      2025-11-06 [1] any (@2.2.0)
#>  profmem       0.7.0      2025-05-02 [1] RSPM
#>  R6            2.6.1      2025-02-15 [1] RSPM
#>  ragg          1.5.2      2026-03-23 [1] RSPM
#>  rlang         1.2.0      2026-04-06 [1] RSPM
#>  rmarkdown     2.31       2026-03-26 [1] RSPM
#>  sass          0.4.10     2025-04-11 [1] RSPM
#>  sessioninfo   1.2.3      2025-02-05 [1] RSPM
#>  systemfonts   1.3.2      2026-03-05 [1] RSPM
#>  textshaping   1.0.5      2026-03-06 [1] RSPM
#>  tibble        3.3.1      2026-01-11 [1] RSPM
#>  utf8          1.2.6      2025-06-08 [1] RSPM
#>  vctrs         0.7.3      2026-04-11 [1] RSPM
#>  xfun          0.57       2026-03-20 [1] RSPM
#>  yaml          2.3.12     2025-12-10 [1] RSPM
#> 
#>  [1] /home/runner/work/_temp/Library
#>  [2] /opt/R/4.6.0/lib/R/site-library
#>  [3] /opt/R/4.6.0/lib/R/library
#>  * ── Packages attached to the search path.
#> 
#> ─────────────────────────────────────────────────────────────────────
```
