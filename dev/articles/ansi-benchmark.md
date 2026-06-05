# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x555bf3bb06a0\>
\<environment: 0x555bf4654f78\>

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
#> 1 ansi         45.4µs     49µs    19778.    99.6KB     21.0
#> 2 plain        45.2µs   48.6µs    19894.        0B     21.9
#> 3 base         11.4µs   12.5µs    77835.    48.6KB     23.4
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
#> 1 ansi         47.4µs   50.9µs    19011.        0B     23.5
#> 2 plain        47.9µs   51.2µs    18897.        0B     21.2
#> 3 base         13.2µs   14.5µs    66991.        0B     26.8
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
#> 1 ansi       116.53µs 123.27µs     7847.   77.03KB     16.9
#> 2 plain       92.75µs  97.95µs     9879.    8.91KB     14.6
#> 3 base         1.84µs   1.97µs   489343.        0B      0
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
#> 1 ansi          338µs    362µs     2730.   33.23KB     21.3
#> 2 plain         334µs    359µs     2749.    1.09KB     19.1
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
#>  1 cli_ansi          5.64µs   6.16µs   156447.    9.27KB    31.3 
#>  2 fansi_ansi       30.68µs  33.53µs    28825.    4.18KB    26.0 
#>  3 cli_plain          5.6µs   6.12µs   158096.        0B    31.6 
#>  4 fansi_plain      29.93µs  31.88µs    29728.      688B    14.9 
#>  5 cli_vec_ansi      7.09µs   7.54µs   126529.      448B    12.7 
#>  6 fansi_vec_ansi   40.31µs   42.5µs    21629.    5.02KB     8.65
#>  7 cli_vec_plain     7.74µs   8.21µs   117988.      448B    11.8 
#>  8 fansi_vec_plain  37.73µs  40.06µs    24187.    5.02KB     9.68
#>  9 cli_txt_ansi       5.6µs   5.96µs   163056.        0B    16.3 
#> 10 fansi_txt_ansi   30.36µs   32.1µs    29912.      688B    15.0 
#> 11 cli_txt_plain     6.44µs    6.8µs   142742.        0B    14.3 
#> 12 fansi_txt_plain   38.4µs  40.66µs    23813.    5.02KB     9.53
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
#> 1 cli          60.1µs   61.8µs    15808.    22.7KB     6.12
#> 2 fansi       118.1µs  124.8µs     7890.    55.3KB     4.06
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
#>  1 cli_ansi          7.05µs   7.68µs   125915.        0B    12.6 
#>  2 fansi_ansi       90.72µs   95.7µs    10117.   38.84KB     8.20
#>  3 base_ansi       881.03ns 932.02ns  1001521.        0B     0   
#>  4 cli_plain         6.85µs   7.48µs   128367.        0B    12.8 
#>  5 fansi_plain      89.97µs     95µs    10191.      688B    10.3 
#>  6 base_plain      801.05ns 861.01ns  1071192.        0B     0   
#>  7 cli_vec_ansi     28.28µs  29.12µs    33151.      448B     3.32
#>  8 fansi_vec_ansi   111.3µs 117.21µs     8215.    5.02KB     6.15
#>  9 base_vec_ansi    17.18µs  17.27µs    57018.      448B     0   
#> 10 cli_vec_plain    26.88µs  27.71µs    35217.      448B     3.52
#> 11 fansi_vec_plain 101.77µs 107.11µs     8989.    5.02KB     8.27
#> 12 base_vec_plain   10.09µs  10.17µs    96521.      448B     0   
#> 13 cli_txt_ansi     28.19µs  28.88µs    33929.        0B     3.39
#> 14 fansi_txt_ansi  102.07µs 107.91µs     8964.      688B     8.20
#> 15 base_txt_ansi    16.88µs  16.94µs    58200.        0B     0   
#> 16 cli_txt_plain    26.38µs  27.08µs    36168.        0B     3.62
#> 17 fansi_txt_plain  92.56µs  97.17µs     9954.      688B    10.3 
#> 18 base_txt_plain    9.84µs  10.36µs    95410.        0B     0
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
#>  1 cli_ansi          8.42µs   9.15µs   105636.        0B    10.6 
#>  2 fansi_ansi       89.96µs  95.46µs    10112.      688B    10.4 
#>  3 base_ansi          1.2µs   1.25µs   766689.        0B     0   
#>  4 cli_plain         8.39µs   9.08µs   106744.        0B    10.7 
#>  5 fansi_plain      88.98µs  94.45µs    10249.      688B     8.19
#>  6 base_plain      991.04ns   1.04µs   905921.        0B     0   
#>  7 cli_vec_ansi      34.3µs  35.15µs    27732.      448B     5.55
#>  8 fansi_vec_ansi  113.63µs 118.15µs     8194.    5.02KB     6.14
#>  9 base_vec_ansi    40.99µs  41.25µs    23931.      448B     0   
#> 10 cli_vec_plain    33.26µs   34.2µs    28456.      448B     5.69
#> 11 fansi_vec_plain 103.33µs 107.89µs     8961.    5.02KB     6.14
#> 12 base_vec_plain   21.63µs  21.97µs    44788.      448B     4.48
#> 13 cli_txt_ansi     34.81µs  35.66µs    26296.        0B     2.63
#> 14 fansi_txt_ansi  104.89µs 110.22µs     8781.      688B     8.20
#> 15 base_txt_ansi    43.02µs  43.92µs    22511.        0B     0   
#> 16 cli_txt_plain    32.92µs  33.68µs    29088.        0B     2.91
#> 17 fansi_txt_plain  94.89µs 100.09µs     9685.      688B     8.20
#> 18 base_txt_plain   22.97µs  23.81µs    41492.        0B     0
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
#> 1 cli_ansi        6.87µs   7.43µs   129854.        0B     0   
#> 2 cli_plain       6.42µs   7.01µs   137667.        0B    13.8 
#> 3 cli_vec_ansi    33.1µs  34.03µs    28798.      848B     2.88
#> 4 cli_vec_plain  10.45µs   11.1µs    87739.      848B     8.77
#> 5 cli_txt_ansi   32.63µs  33.41µs    29326.        0B     2.93
#> 6 cli_txt_plain   7.28µs   7.92µs   122300.        0B    12.2
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
#>  1 cli_ansi          25.4µs   26.8µs    36147.        0B    14.5 
#>  2 fansi_ansi        28.4µs   30.4µs    31665.    7.24KB    15.8 
#>  3 cli_plain         25.1µs   26.4µs    36690.        0B    14.7 
#>  4 fansi_plain       27.9µs   29.7µs    32418.      688B    13.0 
#>  5 cli_vec_ansi      34.8µs   36.4µs    26699.      848B    10.7 
#>  6 fansi_vec_ansi    54.5µs   56.8µs    17133.    5.41KB     8.31
#>  7 cli_vec_plain     27.6µs   29.1µs    33362.      848B    13.4 
#>  8 fansi_vec_plain   36.9µs   38.6µs    24971.    4.59KB     9.99
#>  9 cli_txt_ansi        34µs   35.1µs    27694.        0B    11.1 
#> 10 fansi_txt_ansi    44.1µs   45.5µs    21312.    5.12KB    10.7 
#> 11 cli_txt_plain     25.6µs   26.7µs    36290.        0B    14.5 
#> 12 fansi_txt_plain     29µs   30.5µs    31692.      688B    12.7
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
#>  1 cli_ansi        161.41µs 168.37µs     5714.  104.86KB    10.3 
#>  2 fansi_ansi      128.37µs 134.96µs     7192.  106.35KB    10.3 
#>  3 base_ansi         4.08µs    4.4µs   220743.      224B     0   
#>  4 cli_plain       159.84µs 167.04µs     5752.    8.09KB    10.3 
#>  5 fansi_plain     125.98µs 133.75µs     7248.    9.62KB    12.5 
#>  6 base_plain        3.65µs   3.86µs   252490.        0B     0   
#>  7 cli_vec_ansi      7.61ms   7.75ms      129.  823.77KB    11.1 
#>  8 fansi_vec_ansi    1.04ms   1.07ms      912.  846.81KB    19.5 
#>  9 base_vec_ansi   157.44µs 163.78µs     5982.    22.7KB     2.04
#> 10 cli_vec_plain     7.53ms    7.7ms      129.  823.77KB    11.3 
#> 11 fansi_vec_plain 987.62µs   1.01ms      981.  845.98KB    19.6 
#> 12 base_vec_plain  107.14µs 115.73µs     8612.      848B     2.02
#> 13 cli_txt_ansi      3.27ms   3.49ms      288.    63.6KB     2.03
#> 14 fansi_txt_ansi    1.56ms   1.59ms      626.   35.05KB     0   
#> 15 base_txt_ansi   137.74µs 146.66µs     6749.   18.47KB     2.02
#> 16 cli_txt_plain     2.36ms   2.53ms      396.    63.6KB     2.02
#> 17 fansi_txt_plain 511.64µs 531.06µs     1876.    30.6KB     2.02
#> 18 base_txt_plain   91.01µs  93.72µs    10519.   11.05KB     2.02
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
#>  1 cli_ansi        147.23µs 153.55µs     6319.   33.84KB    12.5 
#>  2 fansi_ansi       54.46µs  57.91µs    16702.   31.42KB    12.5 
#>  3 base_ansi         1.04µs   1.09µs   875159.     4.2KB     0   
#>  4 cli_plain       143.68µs 150.24µs     6445.        0B    12.4 
#>  5 fansi_plain      54.02µs  57.29µs    16752.      872B    12.5 
#>  6 base_plain      962.17ns   1.01µs   922478.        0B     0   
#>  7 cli_vec_ansi     273.7µs 285.56µs     3431.   16.73KB     6.30
#>  8 fansi_vec_ansi  115.14µs 119.35µs     8159.    5.59KB     6.16
#>  9 base_vec_ansi    35.38µs  36.39µs    26837.      848B     2.68
#> 10 cli_vec_plain   227.58µs 236.57µs     4130.   16.73KB     8.28
#> 11 fansi_vec_plain    108µs 112.26µs     8668.    5.59KB     6.16
#> 12 base_vec_plain   30.04µs  30.61µs    32189.      848B     0   
#> 13 cli_txt_ansi    156.04µs 162.12µs     5998.        0B    12.4 
#> 14 fansi_txt_ansi   53.74µs  56.34µs    17172.      872B    11.9 
#> 15 base_txt_ansi     1.08µs   1.13µs   848953.        0B     0   
#> 16 cli_txt_plain   144.26µs 149.83µs     6490.        0B    12.4 
#> 17 fansi_txt_plain   52.8µs  55.19µs    17564.      872B    12.4 
#> 18 base_txt_plain  992.09ns   1.04µs   908694.        0B     0
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
#>  1 cli_ansi        412.38µs 441.36µs    2256.     6.18KB    10.5 
#>  2 fansi_ansi       97.72µs 103.94µs    9336.    97.33KB    10.3 
#>  3 base_ansi        38.71µs  40.87µs   23575.         0B    11.8 
#>  4 cli_plain       272.45µs 286.34µs    3405.         0B    10.3 
#>  5 fansi_plain      97.86µs 104.25µs    9321.       872B    10.3 
#>  6 base_plain       31.81µs  33.64µs   28663.         0B    11.5 
#>  7 cli_vec_ansi     43.67ms  44.01ms      22.7   94.67KB    27.3 
#>  8 fansi_vec_ansi  236.91µs 245.56µs    3999.     7.25KB     4.07
#>  9 base_vec_ansi     2.25ms   2.31ms     430.    48.18KB    12.8 
#> 10 cli_vec_plain    28.45ms  28.73ms      34.7    2.48KB    18.9 
#> 11 fansi_vec_plain 190.97µs 197.89µs    4935.     6.42KB     6.14
#> 12 base_vec_plain    1.64ms   1.68ms     593.     47.4KB    12.7 
#> 13 cli_txt_ansi     26.62ms  26.89ms      37.0    4.27MB     6.94
#> 14 fansi_txt_ansi  224.34µs 233.46µs    4203.     6.77KB     6.11
#> 15 base_txt_ansi     1.24ms   1.27ms     778.   582.06KB     8.75
#> 16 cli_txt_plain     1.25ms   1.29ms     760.   369.84KB     8.64
#> 17 fansi_txt_plain 177.31µs 184.94µs    5272.     2.51KB     8.28
#> 18 base_txt_plain  827.57µs 868.62µs    1135.   367.31KB     8.63
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
#>  1 cli_ansi          6.81µs   7.45µs   129439.   25.09KB    12.9 
#>  2 fansi_ansi       79.29µs  84.92µs    11394.   28.48KB    10.5 
#>  3 base_ansi         1.01µs   1.07µs   846003.        0B     0   
#>  4 cli_plain          6.6µs   7.23µs   132277.        0B    26.5 
#>  5 fansi_plain      79.14µs  84.27µs    11486.    1.98KB    10.4 
#>  6 base_plain      982.08ns   1.03µs   908689.        0B     0   
#>  7 cli_vec_ansi     26.62µs  27.97µs    34023.     1.7KB     3.40
#>  8 fansi_vec_ansi  115.22µs 120.78µs     8038.    8.86KB     8.32
#>  9 base_vec_ansi     6.01µs   6.27µs   156246.      848B     0   
#> 10 cli_vec_plain     22.7µs   23.6µs    41420.     1.7KB     4.14
#> 11 fansi_vec_plain 110.44µs 115.58µs     8381.    8.86KB     8.33
#> 12 base_vec_plain    5.59µs    5.9µs   165538.      848B     0   
#> 13 cli_txt_ansi      6.56µs   7.26µs   131951.        0B    26.4 
#> 14 fansi_txt_ansi   77.86µs  81.57µs    11791.    1.98KB     9.58
#> 15 base_txt_ansi     6.45µs    6.5µs   150392.        0B    15.0 
#> 16 cli_txt_plain     7.41µs    7.9µs   123051.        0B    12.3 
#> 17 fansi_txt_plain  77.47µs  80.76µs    11901.    1.98KB    10.4 
#> 18 base_txt_plain    4.09µs   4.15µs   235320.        0B     0
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
#>  1 cli_ansi       109.72µs 114.35µs    8361.     12.1KB     8.20
#>  2 base_ansi         1.3µs   1.34µs  722864.         0B     0   
#>  3 cli_plain       88.56µs  92.17µs   10459.     8.91KB     8.18
#>  4 base_plain          1µs   1.04µs  936388.         0B     0   
#>  5 cli_vec_ansi     4.19ms   4.29ms     232.   838.95KB    13.2 
#>  6 base_vec_ansi    71.9µs  72.22µs   13689.       848B     0   
#>  7 cli_vec_plain    2.34ms    2.4ms     414.   817.08KB    15.1 
#>  8 base_vec_plain  42.53µs  43.14µs   22844.       848B     0   
#>  9 cli_txt_ansi    14.38ms  14.44ms      69.2   114.6KB     4.19
#> 10 base_txt_ansi   74.11µs  74.36µs   13283.         0B     0   
#> 11 cli_txt_plain     304µs 312.45µs    3132.    18.34KB     2.01
#> 12 base_txt_plain  41.07µs  41.98µs   23628.         0B     0
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
#>  1 cli_ansi        106.8µs  111.6µs     8685.        0B    12.4 
#>  2 base_ansi        16.5µs   17.6µs    54859.        0B    11.0 
#>  3 cli_plain       106.2µs  111.1µs     8673.        0B    12.4 
#>  4 base_plain       16.4µs   17.4µs    55476.        0B    11.1 
#>  5 cli_vec_ansi    205.4µs    215µs     4534.     7.2KB     6.13
#>  6 base_vec_ansi    58.9µs   64.2µs    15306.    1.66KB     4.06
#>  7 cli_vec_plain   189.5µs  199.5µs     4884.     7.2KB     6.14
#>  8 base_vec_plain   51.3µs   57.3µs    17151.    1.66KB     4.06
#>  9 cli_txt_ansi    178.7µs  186.5µs     5214.        0B     8.28
#> 10 base_txt_ansi    41.3µs   42.6µs    21830.        0B     4.37
#> 11 cli_txt_plain   162.8µs  168.7µs     5765.        0B     8.18
#> 12 base_txt_plain   35.3µs   36.4µs    26436.        0B     5.29
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
#> 1 cli          8.13µs   8.76µs   110631.        0B    11.1 
#> 2 base          851ns 892.09ns  1039748.        0B     0   
#> 3 cli_vec     23.21µs  23.98µs    40711.      448B     4.07
#> 4 base_vec    11.63µs  11.84µs    83138.      448B     0   
#> 5 cli_txt     23.28µs  23.91µs    40835.        0B     8.17
#> 6 base_txt    12.59µs  12.68µs    77525.        0B     0
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
#> 1 cli          8.12µs   8.79µs   110309.        0B    11.0 
#> 2 base         1.29µs   1.36µs   697571.        0B     0   
#> 3 cli_vec     28.54µs  29.35µs    33323.      448B     6.67
#> 4 base_vec    51.66µs  54.05µs    18313.      448B     0   
#> 5 cli_txt     28.87µs  29.66µs    32878.        0B     3.29
#> 6 base_txt    89.69µs  92.46µs    10595.        0B     0
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
#> 1 cli          8.66µs    9.4µs   102614.        0B    10.3 
#> 2 base        841.1ns    1.7µs   607946.        0B    60.8 
#> 3 cli_vec     19.72µs   20.5µs    47547.      448B     4.76
#> 4 base_vec    11.62µs   11.9µs    82991.      448B     0   
#> 5 cli_txt     20.42µs   21.2µs    46115.        0B     4.61
#> 6 base_txt     12.6µs   12.7µs    77340.        0B     7.73
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
#> 1 cli          6.27µs   6.82µs   141722.    22.2KB    14.2 
#> 2 base         1.03µs   1.08µs   869822.        0B     0   
#> 3 cli_vec     30.31µs  31.29µs    31320.     1.7KB     3.13
#> 4 base_vec     8.42µs   8.64µs   113165.      848B    11.3 
#> 5 cli_txt      6.25µs   6.77µs   142786.        0B    14.3 
#> 6 base_txt     5.69µs   5.75µs   169599.        0B     0
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
#>  date     2026-06-05
#>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.11.0     2026-05-16 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.6.9000 2026-06-05 [1] local
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
#>  sessioninfo   1.2.3      2025-02-05 [1] any (@1.2.3)
#>  systemfonts   1.3.2      2026-03-05 [1] RSPM
#>  textshaping   1.0.5      2026-03-06 [1] RSPM
#>  tibble        3.3.1      2026-01-11 [1] RSPM
#>  utf8          1.2.6      2025-06-08 [1] RSPM
#>  vctrs         0.7.3      2026-04-11 [1] RSPM
#>  xfun          0.58       2026-06-01 [1] RSPM
#>  yaml          2.3.12     2025-12-10 [1] RSPM
#> 
#>  [1] /home/runner/work/_temp/Library
#>  [2] /opt/R/4.6.0/lib/R/site-library
#>  [3] /opt/R/4.6.0/lib/R/library
#>  * ── Packages attached to the search path.
#> 
#> ─────────────────────────────────────────────────────────────────────
```
