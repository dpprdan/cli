# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x55f582189a18\>
\<environment: 0x55f582cdc338\>

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
#> 1 ansi         45.6µs   49.2µs    19602.    99.3KB     19.0
#> 2 plain        45.9µs   49.3µs    19601.        0B     17.5
#> 3 base         11.4µs   12.7µs    75925.    48.4KB     22.8
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
#> 1 ansi           48µs   51.4µs    18736.        0B     21.3
#> 2 plain          48µs   51.3µs    18780.        0B     21.5
#> 3 base         13.2µs   14.6µs    66019.        0B     26.4
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
#> 1 ansi       110.86µs 118.57µs     8130.   75.07KB     14.7
#> 2 plain       88.22µs  93.62µs    10296.    8.73KB     14.7
#> 3 base         1.81µs   1.93µs   495887.        0B      0
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
#> 1 ansi          337µs    357µs     2746.   33.17KB     19.2
#> 2 plain         337µs    358µs     2742.    1.09KB     19.2
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
#>  1 cli_ansi          5.73µs   6.28µs   152674.     9.2KB     30.5
#>  2 fansi_ansi          31µs  34.07µs    28278.    4.18KB     22.6
#>  3 cli_plain         5.76µs    6.3µs   152803.        0B     30.6
#>  4 fansi_plain      30.22µs  33.62µs    28918.      688B     23.2
#>  5 cli_vec_ansi       7.1µs   7.55µs   128326.      448B     25.7
#>  6 fansi_vec_ansi   39.73µs  41.97µs    23021.    5.02KB     18.4
#>  7 cli_vec_plain     7.69µs   8.14µs   119240.      448B     23.9
#>  8 fansi_vec_plain  37.29µs  39.97µs    24206.    5.02KB     19.4
#>  9 cli_txt_ansi      5.66µs   6.08µs   156889.        0B     31.4
#> 10 fansi_txt_ansi   30.59µs  32.35µs    29914.      688B     24.0
#> 11 cli_txt_plain     6.43µs   6.87µs   140631.        0B     28.1
#> 12 fansi_txt_plain  37.82µs  40.24µs    24007.    5.02KB     19.2
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
#> 1 cli          56.1µs   57.8µs    16825.    22.7KB    10.3 
#> 2 fansi       118.9µs  122.1µs     7967.    55.3KB     8.21
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
#>  1 cli_ansi          6.59µs   7.23µs   131464.        0B    26.3 
#>  2 fansi_ansi       90.98µs  96.48µs    10004.   38.83KB    16.8 
#>  3 base_ansi        841.1ns 892.09ns  1023356.        0B     0   
#>  4 cli_plain         6.76µs   7.36µs   130479.        0B    26.1 
#>  5 fansi_plain      90.88µs  96.28µs    10013.      688B    16.8 
#>  6 base_plain      781.03ns 822.12ns  1126990.        0B     0   
#>  7 cli_vec_ansi     29.14µs     30µs    32552.      448B     6.51
#>  8 fansi_vec_ansi  111.31µs 116.32µs     8283.    5.02KB    12.5 
#>  9 base_vec_ansi    14.69µs  14.79µs    66392.      448B     6.64
#> 10 cli_vec_plain    27.27µs  28.06µs    34872.      448B     6.98
#> 11 fansi_vec_plain 101.81µs 107.13µs     8986.    5.02KB    14.8 
#> 12 base_vec_plain    8.78µs   8.87µs   109114.      448B     0   
#> 13 cli_txt_ansi     28.67µs  29.46µs    33255.        0B     6.65
#> 14 fansi_txt_ansi  102.77µs 108.88µs     8843.      688B    14.6 
#> 15 base_txt_ansi    14.28µs  14.34µs    68508.        0B     0   
#> 16 cli_txt_plain    26.95µs  27.66µs    35421.        0B     7.09
#> 17 fansi_txt_plain  93.06µs  98.48µs     9772.      688B    14.7 
#> 18 base_txt_plain    8.41µs   8.97µs   111157.        0B    11.1
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
#>  1 cli_ansi          8.48µs   9.12µs   106068.        0B    21.2 
#>  2 fansi_ansi       91.59µs  96.23µs    10003.      688B    16.8 
#>  3 base_ansi         1.19µs   1.23µs   747468.        0B    74.8 
#>  4 cli_plain         8.38µs   9.11µs   105373.        0B    21.1 
#>  5 fansi_plain      91.06µs  95.81µs    10065.      688B    17.2 
#>  6 base_plain      962.06ns   1.01µs   935202.        0B     0   
#>  7 cli_vec_ansi     34.34µs  35.14µs    27802.      448B     5.56
#>  8 fansi_vec_ansi  113.52µs 118.39µs     8165.    5.02KB    14.8 
#>  9 base_vec_ansi    42.56µs  42.86µs    23023.      448B     0   
#> 10 cli_vec_plain    32.81µs   33.7µs    29023.      448B     5.81
#> 11 fansi_vec_plain    104µs 108.38µs     8904.    5.02KB    14.7 
#> 12 base_vec_plain    22.2µs  22.53µs    43739.      448B     0   
#> 13 cli_txt_ansi     34.24µs  35.05µs    27910.        0B     8.38
#> 14 fansi_txt_ansi  106.35µs 111.02µs     8721.      688B    12.4 
#> 15 base_txt_ansi    45.16µs  45.72µs    21612.        0B     2.16
#> 16 cli_txt_plain    32.33µs  33.16µs    29513.        0B     5.90
#> 17 fansi_txt_plain   96.4µs 101.17µs     9567.      688B    16.8 
#> 18 base_txt_plain   23.71µs  24.58µs    40166.        0B     0
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
#> 1 cli_ansi        6.71µs   7.28µs   133195.        0B    26.6 
#> 2 cli_plain       6.34µs    6.9µs   140303.        0B    28.1 
#> 3 cli_vec_ansi   31.07µs  32.25µs    30384.      848B     3.04
#> 4 cli_vec_plain  10.21µs  10.85µs    89662.      848B    17.9 
#> 5 cli_txt_ansi   30.72µs  31.79µs    30792.        0B     3.08
#> 6 cli_txt_plain   7.19µs   7.76µs   125129.        0B    25.0
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
#>  1 cli_ansi          25.6µs   27.2µs    35163.        0B     28.2
#>  2 fansi_ansi        28.5µs   30.4µs    31737.    7.24KB     25.4
#>  3 cli_plain         25.6µs   27.2µs    35413.        0B     28.4
#>  4 fansi_plain       28.3µs   30.1µs    32087.      688B     25.7
#>  5 cli_vec_ansi      35.1µs   36.7µs    26385.      848B     21.1
#>  6 fansi_vec_ansi    53.7µs   56.4µs    17195.    5.41KB     12.6
#>  7 cli_vec_plain     28.5µs   30.1µs    31965.      848B     25.6
#>  8 fansi_vec_plain   36.8µs   39.1µs    24770.    4.59KB     19.8
#>  9 cli_txt_ansi      34.6µs   36.1µs    26828.        0B     21.5
#> 10 fansi_txt_ansi    44.4µs   46.5µs    20814.    5.12KB     17.3
#> 11 cli_txt_plain     26.3µs   27.7µs    35100.        0B     28.1
#> 12 fansi_txt_plain   29.1µs   30.7µs    31539.      688B     22.1
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
#>  1 cli_ansi        164.64µs 172.29µs     5625.  104.34KB    19.2 
#>  2 fansi_ansi      127.94µs  135.4µs     7149.  106.35KB    21.5 
#>  3 base_ansi            4µs   4.43µs   219216.      224B     0   
#>  4 cli_plain       163.16µs 170.36µs     5669.    8.09KB    19.1 
#>  5 fansi_plain     125.81µs 133.41µs     7238.    9.62KB    19.2 
#>  6 base_plain        3.39µs   3.71µs   260174.        0B    26.0 
#>  7 cli_vec_ansi      7.71ms   7.87ms      126.  823.77KB    25.7 
#>  8 fansi_vec_ansi    1.06ms   1.11ms      874.  846.81KB    17.4 
#>  9 base_vec_ansi   153.31µs 158.89µs     6164.    22.7KB     2.03
#> 10 cli_vec_plain     7.67ms   7.84ms      127.  823.77KB    26.4 
#> 11 fansi_vec_plain   1.02ms   1.06ms      922.  845.98KB    20.0 
#> 12 base_vec_plain  105.47µs 108.02µs     8999.      848B     2.02
#> 13 cli_txt_ansi      3.42ms   3.46ms      288.    63.6KB     2.03
#> 14 fansi_txt_ansi    1.56ms   1.59ms      626.   35.05KB     2.02
#> 15 base_txt_ansi   135.97µs  144.9µs     6831.   18.47KB     2.03
#> 16 cli_txt_plain     2.46ms    2.5ms      400.    63.6KB     0   
#> 17 fansi_txt_plain 516.98µs 541.71µs     1826.    30.6KB     6.18
#> 18 base_txt_plain    87.8µs  89.82µs    10860.   11.05KB     2.02
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
#>  1 cli_ansi        147.49µs 156.02µs     6142.   33.84KB     24.0
#>  2 fansi_ansi       54.81µs  58.43µs    16384.   31.42KB     21.3
#>  3 base_ansi         1.04µs    1.1µs   859851.     4.2KB      0  
#>  4 cli_plain       143.29µs 150.97µs     6412.        0B     24.8
#>  5 fansi_plain      53.53µs  56.22µs    17195.      872B     23.5
#>  6 base_plain      971.14ns   1.01µs   941824.        0B      0  
#>  7 cli_vec_ansi    272.11µs 282.85µs     3450.   16.73KB     12.6
#>  8 fansi_vec_ansi     122µs 126.16µs     7688.    5.59KB     12.6
#>  9 base_vec_ansi    36.31µs  37.14µs    26590.      848B      0  
#> 10 cli_vec_plain   232.03µs 243.06µs     3878.   16.73KB     14.8
#> 11 fansi_vec_plain 114.33µs 118.93µs     8173.    5.59KB     12.6
#> 12 base_vec_plain    30.4µs  31.17µs    31791.      848B      0  
#> 13 cli_txt_ansi    152.95µs  159.5µs     6081.        0B     21.2
#> 14 fansi_txt_ansi   53.83µs  57.57µs    16764.      872B     23.7
#> 15 base_txt_ansi     1.07µs   1.13µs   842403.        0B      0  
#> 16 cli_txt_plain   144.96µs 151.57µs     6401.        0B     23.5
#> 17 fansi_txt_plain  53.49µs   57.3µs    16863.      872B     23.6
#> 18 base_txt_plain  991.04ns   1.03µs   920507.        0B      0
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
#>  1 cli_ansi        397.89µs 424.05µs    2339.         0B    21.4 
#>  2 fansi_ansi       98.61µs 104.95µs    9139.    97.32KB    21.5 
#>  3 base_ansi        39.14µs  41.62µs   22908.         0B    18.3 
#>  4 cli_plain       275.85µs 291.41µs    3330.         0B    17.3 
#>  5 fansi_plain       97.1µs 102.89µs    9454.       872B    12.4 
#>  6 base_plain       31.56µs  33.51µs   28732.         0B    11.5 
#>  7 cli_vec_ansi     42.06ms  42.25ms      23.6    2.48KB    16.8 
#>  8 fansi_vec_ansi  236.87µs 244.37µs    4019.     7.25KB     6.14
#>  9 base_vec_ansi     2.26ms   2.35ms     424.    48.18KB    13.0 
#> 10 cli_vec_plain    28.87ms   29.2ms      34.3    2.48KB    18.7 
#> 11 fansi_vec_plain 192.97µs 200.15µs    4887.     6.42KB     6.15
#> 12 base_vec_plain    1.64ms   1.71ms     584.     47.4KB    12.7 
#> 13 cli_txt_ansi     23.99ms  24.25ms      41.3  507.59KB     6.88
#> 14 fansi_txt_ansi  231.02µs 240.41µs    4078.     6.77KB     6.14
#> 15 base_txt_ansi     1.24ms   1.29ms     770.   582.06KB     8.80
#> 16 cli_txt_plain     1.26ms   1.31ms     760.   369.84KB    11.1 
#> 17 fansi_txt_plain 183.87µs 190.85µs    5107.     2.51KB     6.13
#> 18 base_txt_plain  849.07µs 886.88µs    1115.   367.31KB    11.0
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
#>  1 cli_ansi          6.72µs   7.34µs   127410.   24.83KB    12.7 
#>  2 fansi_ansi        79.2µs  83.94µs    11549.   28.48KB    12.4 
#>  3 base_ansi       972.07ns   1.04µs   896780.        0B     0   
#>  4 cli_plain         6.74µs   7.34µs   132149.        0B    13.2 
#>  5 fansi_plain      79.11µs  83.82µs    11576.    1.98KB    10.4 
#>  6 base_plain      942.03ns      1µs   917456.        0B    91.8 
#>  7 cli_vec_ansi     28.11µs  29.04µs    33751.     1.7KB     3.38
#>  8 fansi_vec_ansi  115.72µs 120.69µs     8062.    8.86KB     8.35
#>  9 base_vec_ansi     6.06µs   6.34µs   155011.      848B     0   
#> 10 cli_vec_plain    24.33µs  25.21µs    38809.     1.7KB     3.88
#> 11 fansi_vec_plain 109.73µs 115.56µs     8386.    8.86KB     8.38
#> 12 base_vec_plain    5.63µs   5.94µs   164611.      848B     0   
#> 13 cli_txt_ansi      6.79µs   7.43µs   129452.        0B    12.9 
#> 14 fansi_txt_ansi   78.82µs  84.09µs    11470.    1.98KB    12.5 
#> 15 base_txt_ansi     5.14µs   5.21µs   187014.        0B     0   
#> 16 cli_txt_plain     7.55µs   8.18µs   118466.        0B    11.8 
#> 17 fansi_txt_plain   79.1µs  83.76µs    11561.    1.98KB    12.5 
#> 18 base_txt_plain    3.36µs   3.42µs   283641.        0B     0
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
#>  1 cli_ansi       104.75µs 111.19µs    8667.    11.88KB    10.5 
#>  2 base_ansi        1.26µs   1.31µs  731300.         0B     0   
#>  3 cli_plain       84.46µs  89.54µs   10756.     8.73KB     8.24
#>  4 base_plain     972.07ns   1.02µs  939742.         0B     0   
#>  5 cli_vec_ansi     4.17ms   4.34ms     230.   838.77KB    13.3 
#>  6 base_vec_ansi   71.82µs  72.22µs   13677.       848B     0   
#>  7 cli_vec_plain    2.32ms   2.39ms     416.    816.9KB    15.3 
#>  8 base_vec_plain  42.98µs  43.54µs   22683.       848B     0   
#>  9 cli_txt_ansi    13.59ms  13.67ms      73.0  114.42KB     4.29
#> 10 base_txt_ansi   73.62µs  73.95µs   13351.         0B     0   
#> 11 cli_txt_plain  259.73µs 269.75µs    3636.    18.16KB     2.01
#> 12 base_txt_plain  40.94µs  41.59µs   23823.         0B     0
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
#>  1 cli_ansi        108.2µs    113µs     8551.        0B    12.4 
#>  2 base_ansi        16.2µs   17.2µs    56244.        0B    11.3 
#>  3 cli_plain       107.9µs  112.3µs     8618.        0B    12.4 
#>  4 base_plain       16.1µs   17.1µs    56680.        0B    11.3 
#>  5 cli_vec_ansi    199.8µs  209.3µs     4655.     7.2KB     6.15
#>  6 base_vec_ansi    54.3µs   61.2µs    16243.    1.66KB     4.11
#>  7 cli_vec_plain   185.5µs  195.5µs     4990.     7.2KB     6.16
#>  8 base_vec_plain   49.1µs   56.3µs    17795.    1.66KB     4.07
#>  9 cli_txt_ansi    175.3µs  182.5µs     5346.        0B     8.20
#> 10 base_txt_ansi      38µs   39.3µs    24785.        0B     4.96
#> 11 cli_txt_plain   157.3µs  163.2µs     5952.        0B     8.19
#> 12 base_txt_plain   33.4µs   34.9µs    27646.        0B     5.53
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
#> 1 cli          8.09µs   8.76µs   110805.        0B    11.1 
#> 2 base       831.09ns 892.09ns  1018813.        0B   102.  
#> 3 cli_vec     23.63µs  24.48µs    39922.      448B     3.99
#> 4 base_vec    11.67µs  11.93µs    82336.      448B     0   
#> 5 cli_txt     23.86µs  24.58µs    39745.        0B     3.97
#> 6 base_txt    12.33µs  12.41µs    79236.        0B     0
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
#> 1 cli          8.06µs   8.74µs   110925.        0B    22.2 
#> 2 base         1.28µs   1.35µs   703891.        0B     0   
#> 3 cli_vec     28.95µs     30µs    32611.      448B     3.26
#> 4 base_vec    51.44µs  51.98µs    18996.      448B     0   
#> 5 cli_txt     29.47µs  30.32µs    32295.        0B     3.23
#> 6 base_txt    88.17µs  88.75µs    11139.        0B     2.01
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
#> 1 cli          8.62µs   9.34µs   103652.        0B    10.4 
#> 2 base       832.14ns 892.09ns  1027311.        0B     0   
#> 3 cli_vec     19.68µs  20.67µs    47170.      448B     9.44
#> 4 base_vec    11.67µs  11.95µs    82508.      448B     0   
#> 5 cli_txt     20.04µs  20.79µs    47008.        0B     4.70
#> 6 base_txt    12.31µs   12.4µs    79248.        0B     0
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
#> 1 cli          6.36µs   6.89µs   140330.    22.1KB    28.1 
#> 2 base            1µs   1.07µs   869842.        0B     0   
#> 3 cli_vec     30.39µs  31.32µs    31266.     1.7KB     3.13
#> 4 base_vec      8.3µs   8.53µs   114829.      848B     0   
#> 5 cli_txt      6.32µs   6.89µs   140488.        0B    28.1 
#> 6 base_txt     5.42µs   5.49µs   178224.        0B     0
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
#>  date     2026-04-09
#>  pandoc   3.1.11 @ /opt/hostedtoolcache/pandoc/3.1.11/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.10.0     2026-01-26 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.6.9000 2026-04-09 [1] local
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
#>  sessioninfo   1.2.3      2025-02-05 [1] any (@1.2.3)
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
