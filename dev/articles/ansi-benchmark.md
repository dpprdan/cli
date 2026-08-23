# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x563b3549e1d8\>
\<environment: 0x563b35f3d610\>

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
#> 1 ansi         45.5µs   48.9µs    19673.    99.6KB     21.0
#> 2 plain        45.3µs   48.5µs    19875.        0B     21.9
#> 3 base         11.3µs   12.5µs    77185.    48.6KB     23.2
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
#> 1 ansi           47µs   51.5µs    18639.        0B     23.7
#> 2 plain        47.5µs   51.5µs    18631.        0B     21.2
#> 3 base         13.4µs   14.8µs    64980.        0B     26.0
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
#> 1 ansi       118.07µs 126.24µs     7657.   77.03KB     16.9
#> 2 plain       94.96µs  100.1µs     9626.    8.91KB     14.6
#> 3 base         1.88µs   2.01µs   476649.        0B      0
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
#> 1 ansi          344µs    367µs     2682.   33.24KB     21.2
#> 2 plain         338µs    368µs     2684.    1.09KB     19.0
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
#>  1 cli_ansi          5.82µs   6.42µs   149233.    9.27KB    29.9 
#>  2 fansi_ansi       30.88µs  33.63µs    28669.    4.18KB    25.8 
#>  3 cli_plain         5.85µs   6.38µs   149965.        0B    30.0 
#>  4 fansi_plain       30.4µs  32.76µs    28863.      688B    14.4 
#>  5 cli_vec_ansi      7.32µs   7.77µs   122730.      448B    12.3 
#>  6 fansi_vec_ansi   40.61µs  43.22µs    22114.    5.02KB     8.85
#>  7 cli_vec_plain     7.88µs    8.4µs   115658.      448B    11.6 
#>  8 fansi_vec_plain  38.34µs  40.83µs    23705.    5.02KB     9.49
#>  9 cli_txt_ansi      5.81µs   6.22µs   154749.        0B    15.5 
#> 10 fansi_txt_ansi   30.79µs  32.85µs    29383.      688B    14.7 
#> 11 cli_txt_plain     6.64µs   7.07µs   136814.        0B    13.7 
#> 12 fansi_txt_plain   38.7µs  41.43µs    23358.    5.02KB     9.35
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
#> 1 cli            60µs   61.5µs    15845.    22.7KB     4.05
#> 2 fansi         119µs  125.5µs     7838.    55.3KB     4.05
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
#>  1 cli_ansi          6.97µs    7.6µs   126760.        0B    12.7 
#>  2 fansi_ansi       93.01µs  97.97µs     9864.   38.84KB     8.20
#>  3 base_ansi       912.11ns 962.06ns   952413.        0B     0   
#>  4 cli_plain         6.77µs   7.41µs   130120.        0B    13.0 
#>  5 fansi_plain      92.84µs  97.54µs     9900.      688B     8.18
#>  6 base_plain      831.09ns 881.96ns  1009243.        0B     0   
#>  7 cli_vec_ansi     27.99µs  28.91µs    33762.      448B     3.38
#>  8 fansi_vec_ansi  114.23µs 119.42µs     8061.    5.02KB     8.26
#>  9 base_vec_ansi    18.47µs  18.58µs    52909.      448B     0   
#> 10 cli_vec_plain    26.72µs  27.53µs    35411.      448B     3.54
#> 11 fansi_vec_plain 104.17µs 109.81µs     8736.    5.02KB     8.23
#> 12 base_vec_plain   10.78µs   10.9µs    90349.      448B     0   
#> 13 cli_txt_ansi     27.94µs   28.7µs    33835.        0B     3.38
#> 14 fansi_txt_ansi  105.01µs  110.4µs     8751.      688B     6.12
#> 15 base_txt_ansi    18.21µs  18.29µs    53757.        0B     0   
#> 16 cli_txt_plain    26.37µs  27.08µs    36155.        0B     3.62
#> 17 fansi_txt_plain  94.96µs 100.39µs     9588.      688B    10.3 
#> 18 base_txt_plain    10.6µs  11.12µs    88649.        0B     0
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
#>  1 cli_ansi          8.54µs   9.39µs   102900.        0B    10.3 
#>  2 fansi_ansi       93.62µs  99.04µs     9738.      688B     8.28
#>  3 base_ansi         1.26µs   1.31µs   707835.        0B     0   
#>  4 cli_plain         8.45µs   9.26µs   104422.        0B    20.9 
#>  5 fansi_plain      93.24µs  98.23µs     9838.      688B     8.19
#>  6 base_plain        1.02µs   1.07µs   863030.        0B     0   
#>  7 cli_vec_ansi     34.65µs  35.55µs    27475.      448B     2.75
#>  8 fansi_vec_ansi  116.77µs 121.79µs     7924.    5.02KB     8.25
#>  9 base_vec_ansi    44.02µs  44.85µs    22015.      448B     0   
#> 10 cli_vec_plain    33.33µs  34.27µs    28508.      448B     2.85
#> 11 fansi_vec_plain 107.11µs  111.6µs     8630.    5.02KB     8.25
#> 12 base_vec_plain   22.98µs  23.28µs    42362.      448B     0   
#> 13 cli_txt_ansi     34.91µs  35.76µs    27353.        0B     2.74
#> 14 fansi_txt_ansi  108.33µs 113.76µs     8465.      688B     8.21
#> 15 base_txt_ansi    46.99µs  47.72µs    20698.        0B     0   
#> 16 cli_txt_plain    32.94µs   33.9µs    28806.        0B     2.88
#> 17 fansi_txt_plain   98.2µs 103.44µs     9340.      688B     8.20
#> 18 base_txt_plain   24.76µs  25.38µs    38865.        0B     0
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
#> 1 cli_ansi        6.86µs   7.44µs   129431.        0B    12.9 
#> 2 cli_plain        6.4µs   6.89µs   139959.        0B    14.0 
#> 3 cli_vec_ansi   32.85µs  33.85µs    28917.      848B     2.89
#> 4 cli_vec_plain  10.39µs   11.1µs    87422.      848B     8.74
#> 5 cli_txt_ansi   32.77µs  33.54µs    29164.        0B     2.92
#> 6 cli_txt_plain    7.3µs   7.93µs   121972.        0B    12.2
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
#>  1 cli_ansi          25.7µs   27.4µs    35321.        0B    14.1 
#>  2 fansi_ansi        28.3µs   30.6µs    31563.    7.24KB    12.6 
#>  3 cli_plain         25.7µs   27.4µs    35317.        0B    14.1 
#>  4 fansi_plain       27.9µs   29.9µs    32379.      688B    16.2 
#>  5 cli_vec_ansi      35.1µs   37.2µs    26047.      848B    10.4 
#>  6 fansi_vec_ansi    56.6µs   59.8µs    16277.    5.41KB     6.18
#>  7 cli_vec_plain     28.6µs   30.4µs    31852.      848B    12.7 
#>  8 fansi_vec_plain   36.9µs   39.2µs    24522.    4.59KB     9.81
#>  9 cli_txt_ansi      34.4µs   35.7µs    27208.        0B    13.6 
#> 10 fansi_txt_ansi    44.1µs   45.7µs    21216.    5.12KB     8.49
#> 11 cli_txt_plain     26.3µs   27.5µs    35161.        0B    14.1 
#> 12 fansi_txt_plain   28.7µs   30.2µs    31963.      688B    12.8
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
#>  1 cli_ansi        163.86µs 171.51µs     5639.  104.86KB    10.3 
#>  2 fansi_ansi      129.77µs 137.05µs     7088.  106.35KB    10.3 
#>  3 base_ansi         4.14µs   4.49µs   216267.      224B     0   
#>  4 cli_plain       163.88µs 170.83µs     5669.    8.09KB    10.3 
#>  5 fansi_plain     126.85µs 135.12µs     7179.    9.62KB    10.3 
#>  6 base_plain        3.62µs   3.92µs   246170.        0B    24.6 
#>  7 cli_vec_ansi      7.68ms   7.87ms      127.  823.77KB    11.1 
#>  8 fansi_vec_ansi    1.07ms    1.1ms      876.  846.81KB    17.3 
#>  9 base_vec_ansi   156.64µs 162.64µs     6023.    22.7KB     2.04
#> 10 cli_vec_plain     7.63ms    7.8ms      128.  823.77KB    11.2 
#> 11 fansi_vec_plain   1.01ms   1.05ms      944.  845.98KB    20.0 
#> 12 base_vec_plain  106.92µs 110.73µs     8883.      848B     2.01
#> 13 cli_txt_ansi      3.18ms   3.29ms      305.    63.6KB     0   
#> 14 fansi_txt_ansi    1.55ms   1.57ms      632.   35.05KB     2.02
#> 15 base_txt_ansi   135.42µs 145.72µs     6840.   18.47KB     2.02
#> 16 cli_txt_plain      2.4ms   2.52ms      396.    63.6KB     0   
#> 17 fansi_txt_plain 517.76µs 541.81µs     1818.    30.6KB     2.02
#> 18 base_txt_plain    88.5µs  90.53µs    10876.   11.05KB     2.02
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
#>  1 cli_ansi        150.74µs 158.63µs     6064.   33.84KB    12.5 
#>  2 fansi_ansi       55.31µs  59.32µs    16293.   31.42KB    10.3 
#>  3 base_ansi         1.07µs   1.12µs   835996.     4.2KB     0   
#>  4 cli_plain       146.83µs 154.46µs     6261.        0B    12.4 
#>  5 fansi_plain      55.28µs  58.94µs    16409.      872B    12.5 
#>  6 base_plain           1µs   1.04µs   896289.        0B     0   
#>  7 cli_vec_ansi    276.61µs 288.54µs     3392.   16.73KB     6.15
#>  8 fansi_vec_ansi   116.7µs 121.34µs     8028.    5.59KB     8.30
#>  9 base_vec_ansi    35.93µs  37.15µs    26564.      848B     0   
#> 10 cli_vec_plain   233.74µs 246.09µs     3964.   16.73KB     6.20
#> 11 fansi_vec_plain 110.38µs 114.76µs     8461.    5.59KB     8.30
#> 12 base_vec_plain   30.29µs   31.3µs    31601.      848B     0   
#> 13 cli_txt_ansi    158.22µs 165.82µs     5840.        0B    10.3 
#> 14 fansi_txt_ansi   55.24µs  58.91µs    16434.      872B    12.4 
#> 15 base_txt_ansi      1.1µs   1.16µs   810630.        0B     0   
#> 16 cli_txt_plain   146.26µs 153.97µs     6307.        0B    12.1 
#> 17 fansi_txt_plain   54.1µs  56.42µs    17147.      872B    12.4 
#> 18 base_txt_plain    1.01µs   1.06µs   893054.        0B     0
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
#>  1 cli_ansi        427.19µs 455.57µs    2194.     6.18KB    10.3 
#>  2 fansi_ansi       98.03µs 104.53µs    9289.    97.33KB    10.4 
#>  3 base_ansi        38.18µs  40.43µs   23110.         0B    11.6 
#>  4 cli_plain       277.75µs 290.01µs    3349.         0B    10.3 
#>  5 fansi_plain      96.23µs 102.83µs    9432.       872B    10.3 
#>  6 base_plain       31.42µs  33.18µs   28934.         0B    11.6 
#>  7 cli_vec_ansi     45.35ms  45.75ms      21.9   94.67KB    18.2 
#>  8 fansi_vec_ansi  238.65µs 249.11µs    3941.     7.25KB     6.14
#>  9 base_vec_ansi     2.28ms   2.35ms     424.    48.18KB    12.8 
#> 10 cli_vec_plain    29.09ms  29.52ms      33.8    2.48KB    14.1 
#> 11 fansi_vec_plain 191.42µs 200.51µs    4864.     6.42KB     6.19
#> 12 base_vec_plain    1.65ms   1.71ms     579.     47.4KB    12.7 
#> 13 cli_txt_ansi     27.59ms  27.91ms      35.7    4.27MB     7.15
#> 14 fansi_txt_ansi  225.33µs 235.87µs    4157.     6.77KB     4.05
#> 15 base_txt_ansi     1.28ms   1.31ms     756.   582.06KB    11.1 
#> 16 cli_txt_plain      1.3ms   1.34ms     736.   369.84KB     8.61
#> 17 fansi_txt_plain 177.52µs 186.12µs    5246.     2.51KB     6.13
#> 18 base_txt_plain  865.24µs 901.79µs    1093.   367.31KB    10.9
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
#>  1 cli_ansi          6.73µs   7.34µs   131030.   25.09KB    13.1 
#>  2 fansi_ansi       79.78µs  84.69µs    11384.   28.48KB    10.3 
#>  3 base_ansi         1.07µs   1.16µs   795303.        0B     0   
#>  4 cli_plain         6.82µs   7.39µs   129210.        0B    25.8 
#>  5 fansi_plain      79.72µs  84.52µs    11438.    1.98KB    10.3 
#>  6 base_plain        1.03µs    1.1µs   826977.        0B     0   
#>  7 cli_vec_ansi     26.32µs  27.58µs    35369.     1.7KB     3.54
#>  8 fansi_vec_ansi  116.81µs 123.25µs     7865.    8.86KB     8.34
#>  9 base_vec_ansi     6.32µs   6.64µs   147411.      848B     0   
#> 10 cli_vec_plain    23.03µs  23.93µs    40789.     1.7KB     4.08
#> 11 fansi_vec_plain 112.04µs 117.61µs     8233.    8.86KB     8.34
#> 12 base_vec_plain    6.07µs   6.42µs   151914.      848B     0   
#> 13 cli_txt_ansi      6.89µs   7.45µs   128717.        0B    12.9 
#> 14 fansi_txt_ansi   79.56µs  84.81µs    11350.    1.98KB    12.5 
#> 15 base_txt_ansi     6.49µs   6.58µs   148508.        0B     0   
#> 16 cli_txt_plain     7.54µs   8.22µs   116794.        0B    11.7 
#> 17 fansi_txt_plain  78.14µs  84.03µs    11548.    1.98KB    12.1 
#> 18 base_txt_plain    4.14µs    4.2µs   231165.        0B     0
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
#>  1 cli_ansi       111.51µs 116.03µs    8308.     12.1KB     8.19
#>  2 base_ansi        1.34µs   1.38µs  695860.         0B     0   
#>  3 cli_plain       89.35µs  93.74µs   10253.     8.91KB     8.19
#>  4 base_plain       1.03µs   1.07µs  904118.         0B     0   
#>  5 cli_vec_ansi     4.19ms   4.31ms     232.   838.95KB    13.1 
#>  6 base_vec_ansi    75.6µs  76.31µs   12877.       848B     2.01
#>  7 cli_vec_plain    2.35ms   2.42ms     410.   817.08KB    13.0 
#>  8 base_vec_plain  45.48µs  46.28µs   21269.       848B     0   
#>  9 cli_txt_ansi    14.95ms  15.09ms      66.2   114.6KB     4.27
#> 10 base_txt_ansi    76.3µs  76.55µs   12878.         0B     0   
#> 11 cli_txt_plain  295.02µs 309.44µs    3174.    18.34KB     2.01
#> 12 base_txt_plain  42.47µs   43.9µs   22590.         0B     0
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
#>  1 cli_ansi        108.5µs  113.9µs     8482.        0B    12.4 
#>  2 base_ansi        16.9µs     18µs    53472.        0B    10.7 
#>  3 cli_plain       107.7µs  114.1µs     8464.        0B    12.4 
#>  4 base_plain       17.2µs   18.3µs    52991.        0B    10.6 
#>  5 cli_vec_ansi    210.7µs  220.7µs     4416.     7.2KB     6.14
#>  6 base_vec_ansi    60.9µs     67µs    14589.    1.66KB     2.02
#>  7 cli_vec_plain   197.2µs  206.2µs     4723.     7.2KB     6.14
#>  8 base_vec_plain   53.7µs   60.1µs    16253.    1.66KB     4.06
#>  9 cli_txt_ansi    184.4µs  190.4µs     5093.        0B     6.11
#> 10 base_txt_ansi    41.2µs   42.4µs    22967.        0B     4.59
#> 11 cli_txt_plain   168.9µs  174.3µs     5556.        0B     8.18
#> 12 base_txt_plain   35.6µs     37µs    26190.        0B     5.24
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
#> 1 cli          8.22µs   8.86µs   108055.        0B    21.6 
#> 2 base       881.03ns 932.14ns   977853.        0B     0   
#> 3 cli_vec     23.24µs  24.24µs    40290.      448B     4.03
#> 4 base_vec    11.49µs  11.74µs    83396.      448B     0   
#> 5 cli_txt      23.2µs  23.98µs    40651.        0B     4.07
#> 6 base_txt    12.52µs  12.61µs    77675.        0B     0
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
#> 1 cli           8.1µs   8.85µs   107043.        0B    10.7 
#> 2 base         1.32µs   1.38µs   675372.        0B     0   
#> 3 cli_vec     28.55µs  29.55µs    33022.      448B     3.30
#> 4 base_vec    50.38µs  51.08µs    19288.      448B     0   
#> 5 cli_txt     28.98µs  29.75µs    32712.        0B     3.27
#> 6 base_txt    87.19µs  88.15µs    11194.        0B     2.01
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
#> 1 cli          8.72µs   9.42µs   102341.        0B    10.2 
#> 2 base       901.17ns 952.04ns   940133.        0B     0   
#> 3 cli_vec     19.47µs  20.49µs    47448.      448B     9.49
#> 4 base_vec     11.5µs  11.74µs    83720.      448B     0   
#> 5 cli_txt     20.39µs  21.23µs    45839.        0B     4.58
#> 6 base_txt    12.54µs  12.61µs    77829.        0B     0
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
#> 1 cli          6.41µs   7.01µs   136970.    22.2KB    27.4 
#> 2 base         1.09µs   1.16µs   801846.        0B     0   
#> 3 cli_vec     29.07µs  30.04µs    32501.     1.7KB     3.25
#> 4 base_vec      8.1µs   8.39µs   116791.      848B     0   
#> 5 cli_txt      6.33µs   6.89µs   139852.        0B    14.0 
#> 6 base_txt      5.5µs    5.6µs   173650.        0B    17.4
```

## Session info

``` r

sessioninfo::session_info()
```

``` fansi
#> ─ Session info ──────────────────────────────────────────────────────
#>  setting  value
#>  version  R version 4.6.1 (2026-06-24)
#>  os       Ubuntu 24.04.4 LTS
#>  system   x86_64, linux-gnu
#>  ui       X11
#>  language en
#>  collate  C.UTF-8
#>  ctype    C.UTF-8
#>  tz       UTC
#>  date     2026-08-23
#>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.12.0     2026-08-04 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.6.9000 2026-08-23 [1] local
#>  codetools     0.2-20     2024-03-31 [3] CRAN (R 4.6.1)
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
#>  otel          0.2.0      2025-08-29 [1] RSPM
#>  pillar        1.11.1     2025-09-17 [1] RSPM
#>  pkgconfig     2.0.3      2019-09-22 [1] RSPM
#>  pkgdown       2.2.1      2026-07-07 [1] any (@2.2.1)
#>  profmem       0.7.0      2025-05-02 [1] RSPM
#>  R6            2.6.1      2025-02-15 [1] RSPM
#>  ragg          1.5.2      2026-03-23 [1] RSPM
#>  rlang         1.3.0      2026-07-05 [1] RSPM
#>  rmarkdown     2.31       2026-03-26 [1] RSPM
#>  sass          0.4.10     2025-04-11 [1] RSPM
#>  sessioninfo   1.2.4      2026-06-04 [1] RSPM
#>  systemfonts   1.3.2      2026-03-05 [1] RSPM
#>  textshaping   1.0.5      2026-03-06 [1] RSPM
#>  tibble        3.3.1      2026-01-11 [1] RSPM
#>  utf8          1.2.6      2025-06-08 [1] RSPM
#>  vctrs         0.7.3      2026-04-11 [1] RSPM
#>  xfun          0.60       2026-07-09 [1] RSPM
#>  yaml          2.3.12     2025-12-10 [1] RSPM
#> 
#>  [1] /home/runner/work/_temp/Library
#>  [2] /opt/R/4.6.1/lib/R/site-library
#>  [3] /opt/R/4.6.1/lib/R/library
#>  * ── Packages attached to the search path.
#> 
#> ─────────────────────────────────────────────────────────────────────
```
