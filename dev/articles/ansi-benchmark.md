# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x55f735c852a0\>
\<environment: 0x55f73672e038\>

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
#> 1 ansi           47µs   50.2µs    19150.    99.6KB     19.0
#> 2 plain        46.6µs   50.1µs    19207.        0B     19.9
#> 3 base         11.5µs   12.6µs    76709.    48.6KB     23.0
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
#> 1 ansi         49.3µs   52.8µs    18262.        0B     21.3
#> 2 plain          49µs   52.4µs    18436.        0B     23.7
#> 3 base         13.2µs   14.6µs    66114.        0B     19.8
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
#> 1 ansi       117.54µs  125.5µs     7704.   77.03KB     14.7
#> 2 plain       94.06µs  99.28µs     9655.    8.91KB     14.6
#> 3 base         1.84µs   1.96µs   488340.        0B      0
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
#> 1 ansi          347µs    371µs     2644.   33.23KB     19.2
#> 2 plain         344µs    371µs     2667.    1.09KB     19.2
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
#>  1 cli_ansi          5.55µs   6.22µs   144407.    9.27KB    28.9 
#>  2 fansi_ansi        31.4µs  34.24µs    27113.    4.18KB    24.4 
#>  3 cli_plain         5.59µs   6.19µs   150774.        0B    15.1 
#>  4 fansi_plain      30.29µs  33.29µs    27655.      688B    16.6 
#>  5 cli_vec_ansi      7.13µs   7.63µs   122979.      448B    12.3 
#>  6 fansi_vec_ansi    40.8µs  43.37µs    21408.    5.02KB    10.7 
#>  7 cli_vec_plain     7.62µs   8.11µs   116667.      448B    11.7 
#>  8 fansi_vec_plain  38.73µs  41.04µs    22819.    5.02KB     9.13
#>  9 cli_txt_ansi      5.56µs   6.02µs   155207.        0B    15.5 
#> 10 fansi_txt_ansi   30.79µs  32.89µs    28555.      688B    11.4 
#> 11 cli_txt_plain     6.38µs    6.8µs   142431.        0B    14.2 
#> 12 fansi_txt_plain  38.58µs  41.35µs    22568.    5.02KB    11.3
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
#> 1 cli          58.7µs   60.8µs    15628.    22.7KB     4.06
#> 2 fansi       119.2µs  126.9µs     7617.    55.3KB     4.05
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
#>  1 cli_ansi          6.98µs   7.59µs   127463.        0B    12.7 
#>  2 fansi_ansi       91.79µs  97.61µs     9779.   38.84KB     8.22
#>  3 base_ansi       891.04ns 942.03ns   994578.        0B     0   
#>  4 cli_plain         6.78µs   7.48µs   129233.        0B    12.9 
#>  5 fansi_plain      92.23µs  97.27µs     9891.      688B     8.21
#>  6 base_plain      811.07ns 861.01ns  1055583.        0B     0   
#>  7 cli_vec_ansi     28.09µs  28.92µs    33780.      448B     3.38
#>  8 fansi_vec_ansi  112.72µs 118.49µs     8139.    5.02KB     8.29
#>  9 base_vec_ansi    17.19µs  17.31µs    56545.      448B     0   
#> 10 cli_vec_plain    26.79µs  27.56µs    35402.      448B     3.54
#> 11 fansi_vec_plain 103.71µs 109.62µs     8789.    5.02KB     8.31
#> 12 base_vec_plain    10.1µs  10.23µs    95833.      448B     0   
#> 13 cli_txt_ansi     28.05µs  28.74µs    33910.        0B     3.39
#> 14 fansi_txt_ansi  104.08µs 109.73µs     8772.      688B     6.12
#> 15 base_txt_ansi    16.88µs  16.94µs    57912.        0B     5.79
#> 16 cli_txt_plain    26.28µs  26.95µs    36247.        0B     3.63
#> 17 fansi_txt_plain  93.98µs  99.58µs     9654.      688B     8.21
#> 18 base_txt_plain    9.85µs  10.37µs    94274.        0B     0
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
#>  1 cli_ansi          8.52µs   9.27µs   104094.        0B    10.4 
#>  2 fansi_ansi        92.7µs  98.22µs     9796.      688B    10.5 
#>  3 base_ansi         1.21µs   1.25µs   758712.        0B     0   
#>  4 cli_plain         8.43µs   9.17µs   105580.        0B    10.6 
#>  5 fansi_plain      91.46µs  97.37µs     9831.      688B     8.21
#>  6 base_plain      991.04ns   1.04µs   893973.        0B     0   
#>  7 cli_vec_ansi      34.4µs  35.32µs    27675.      448B     5.54
#>  8 fansi_vec_ansi  116.54µs 121.87µs     7879.    5.02KB     6.16
#>  9 base_vec_ansi    40.98µs  41.35µs    23850.      448B     0   
#> 10 cli_vec_plain    33.25µs  34.19µs    28501.      448B     2.85
#> 11 fansi_vec_plain 105.69µs 111.17µs     8680.    5.02KB     8.27
#> 12 base_vec_plain   21.67µs  21.95µs    44564.      448B     0   
#> 13 cli_txt_ansi     34.78µs  35.64µs    27388.        0B     2.74
#> 14 fansi_txt_ansi  106.57µs 112.68µs     8571.      688B     8.21
#> 15 base_txt_ansi    43.08µs  44.13µs    22352.        0B     0   
#> 16 cli_txt_plain    32.88µs  33.75µs    28971.        0B     2.90
#> 17 fansi_txt_plain   96.8µs  102.7µs     9190.      688B     8.20
#> 18 base_txt_plain   23.66µs  23.89µs    41218.        0B     4.12
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
#> 1 cli_ansi        6.78µs   7.39µs   130549.        0B    13.1 
#> 2 cli_plain       6.36µs   6.93µs   139357.        0B    13.9 
#> 3 cli_vec_ansi   32.97µs  33.89µs    28871.      848B     0   
#> 4 cli_vec_plain  10.41µs  11.09µs    87637.      848B     8.76
#> 5 cli_txt_ansi   32.23µs  33.02µs    29445.        0B     2.94
#> 6 cli_txt_plain   7.21µs    7.8µs   124145.        0B    12.4
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
#>  1 cli_ansi          25.8µs   27.6µs    35067.        0B    17.5 
#>  2 fansi_ansi        28.7µs   30.8µs    31272.    7.24KB    12.5 
#>  3 cli_plain         25.7µs   27.4µs    35313.        0B    14.1 
#>  4 fansi_plain       28.3µs   30.5µs    31580.      688B    12.6 
#>  5 cli_vec_ansi      35.6µs   37.3µs    25986.      848B    13.0 
#>  6 fansi_vec_ansi    55.3µs   57.7µs    16799.    5.41KB     6.19
#>  7 cli_vec_plain     28.3µs   29.8µs    32600.      848B    13.0 
#>  8 fansi_vec_plain     37µs   38.9µs    24845.    4.59KB     9.94
#>  9 cli_txt_ansi      34.1µs   35.2µs    27515.        0B    13.8 
#> 10 fansi_txt_ansi    44.1µs   45.8µs    21172.    5.12KB     8.47
#> 11 cli_txt_plain       26µs   27.2µs    35563.        0B    14.2 
#> 12 fansi_txt_plain   29.1µs   30.5µs    31600.      688B    12.6
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
#>  1 cli_ansi        162.23µs 169.97µs     5669.  104.86KB    10.3 
#>  2 fansi_ansi      128.34µs  135.4µs     7169.  106.35KB    10.3 
#>  3 base_ansi         4.13µs   4.47µs   217298.      224B     0   
#>  4 cli_plain        160.8µs 167.88µs     5749.    8.09KB    10.3 
#>  5 fansi_plain     127.36µs  134.2µs     7244.    9.62KB    10.4 
#>  6 base_plain        3.56µs   3.86µs   250186.        0B     0   
#>  7 cli_vec_ansi      7.58ms   7.73ms      129.  823.77KB    13.8 
#>  8 fansi_vec_ansi    1.06ms   1.08ms      893.  846.81KB    17.3 
#>  9 base_vec_ansi   157.71µs 161.68µs     6055.    22.7KB     2.03
#> 10 cli_vec_plain     7.53ms   7.74ms      129.  823.77KB    13.8 
#> 11 fansi_vec_plain 991.24µs   1.02ms      973.  845.98KB    17.2 
#> 12 base_vec_plain  106.69µs 111.68µs     8734.      848B     4.06
#> 13 cli_txt_ansi      3.17ms   3.21ms      311.    63.6KB     0   
#> 14 fansi_txt_ansi    1.57ms   1.61ms      618.   35.05KB     0   
#> 15 base_txt_ansi   137.35µs 144.79µs     6806.   18.47KB     4.07
#> 16 cli_txt_plain     2.35ms   2.38ms      419.    63.6KB     0   
#> 17 fansi_txt_plain 517.04µs 565.05µs     1748.    30.6KB     2.02
#> 18 base_txt_plain   88.35µs  91.19µs    10700.   11.05KB     2.02
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
#>  1 cli_ansi        147.97µs 154.24µs     6273.   33.84KB    12.4 
#>  2 fansi_ansi        54.8µs   58.5µs    16475.   31.42KB    12.5 
#>  3 base_ansi         1.05µs    1.1µs   875577.     4.2KB     0   
#>  4 cli_plain        145.9µs 151.69µs     6383.        0B    12.4 
#>  5 fansi_plain      54.61µs  58.29µs    16527.      872B    12.5 
#>  6 base_plain      972.07ns   1.02µs   936717.        0B     0   
#>  7 cli_vec_ansi    271.63µs 283.02µs     3466.   16.73KB     6.16
#>  8 fansi_vec_ansi  115.08µs 120.07µs     7962.    5.59KB     6.29
#>  9 base_vec_ansi     35.5µs     36µs    27406.      848B     0   
#> 10 cli_vec_plain   229.19µs 239.08µs     4075.   16.73KB     8.29
#> 11 fansi_vec_plain 108.46µs 112.87µs     8531.    5.59KB     8.29
#> 12 base_vec_plain   30.02µs  31.17µs    31778.      848B     0   
#> 13 cli_txt_ansi    155.59µs 162.56µs     5964.        0B    12.4 
#> 14 fansi_txt_ansi   54.39µs  58.04µs    16666.      872B    12.1 
#> 15 base_txt_ansi     1.07µs   1.12µs   854455.        0B     0   
#> 16 cli_txt_plain    144.2µs 149.72µs     6483.        0B    12.4 
#> 17 fansi_txt_plain  53.24µs  55.78µs    17290.      872B    12.4 
#> 18 base_txt_plain  991.04ns   1.03µs   928544.        0B     0
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
#>  1 cli_ansi         415.4µs 443.07µs    2248.     6.18KB    12.5 
#>  2 fansi_ansi        98.5µs 104.76µs    9255.    97.33KB    10.3 
#>  3 base_ansi         38.3µs  40.92µs   23493.         0B     9.40
#>  4 cli_plain       273.36µs 286.56µs    3385.         0B    12.4 
#>  5 fansi_plain      96.37µs 102.87µs    9359.       872B    10.3 
#>  6 base_plain       31.61µs  33.57µs   28677.         0B    11.5 
#>  7 cli_vec_ansi     44.28ms  44.49ms      22.4   94.67KB    18.7 
#>  8 fansi_vec_ansi  236.47µs 246.27µs    3982.     7.25KB     6.13
#>  9 base_vec_ansi     2.23ms   2.31ms     433.    48.18KB    12.8 
#> 10 cli_vec_plain     28.6ms  28.82ms      34.5    2.48KB    14.4 
#> 11 fansi_vec_plain 190.55µs 197.68µs    4936.     6.42KB     8.23
#> 12 base_vec_plain    1.62ms   1.68ms     593.     47.4KB    12.7 
#> 13 cli_txt_ansi     26.44ms  26.69ms      37.3    4.27MB     4.39
#> 14 fansi_txt_ansi  223.84µs 233.66µs    4201.     6.77KB     6.13
#> 15 base_txt_ansi     1.24ms   1.27ms     780.   582.06KB    11.0 
#> 16 cli_txt_plain     1.26ms    1.3ms     763.   369.84KB     8.62
#> 17 fansi_txt_plain 178.25µs 184.89µs    5276.     2.51KB     6.15
#> 18 base_txt_plain  840.75µs 877.15µs    1128.   367.31KB    10.9
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
#>  1 cli_ansi          6.65µs   7.27µs   130152.   25.09KB    26.0 
#>  2 fansi_ansi       79.28µs   83.9µs    11534.   28.48KB    10.3 
#>  3 base_ansi         1.01µs   1.06µs   892288.        0B     0   
#>  4 cli_plain         6.52µs   7.12µs   135220.        0B    13.5 
#>  5 fansi_plain      79.67µs  84.42µs    11431.    1.98KB    12.7 
#>  6 base_plain      982.08ns   1.03µs   909998.        0B     0   
#>  7 cli_vec_ansi     26.11µs  27.22µs    35983.     1.7KB     3.60
#>  8 fansi_vec_ansi  116.95µs 121.94µs     7928.    8.86KB     8.35
#>  9 base_vec_ansi     6.04µs   6.31µs   155467.      848B     0   
#> 10 cli_vec_plain    22.82µs  23.65µs    41323.     1.7KB     4.13
#> 11 fansi_vec_plain 110.66µs 116.22µs     8336.    8.86KB     8.32
#> 12 base_vec_plain    5.81µs    5.9µs   165885.      848B     0   
#> 13 cli_txt_ansi      6.59µs    7.2µs   132552.        0B    13.3 
#> 14 fansi_txt_ansi   78.88µs  83.97µs    11523.    1.98KB    12.1 
#> 15 base_txt_ansi     6.45µs    6.5µs   150987.        0B     0   
#> 16 cli_txt_plain      7.4µs   7.83µs   123567.        0B    12.4 
#> 17 fansi_txt_plain  78.06µs  81.19µs    11914.    1.98KB    12.4 
#> 18 base_txt_plain    4.09µs   4.14µs   236526.        0B     0
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
#>  1 cli_ansi       109.48µs 114.21µs    8441.     12.1KB     8.20
#>  2 base_ansi         1.3µs   1.33µs  729890.         0B     0   
#>  3 cli_plain       88.11µs  92.01µs   10483.     8.91KB     6.11
#>  4 base_plain       1.01µs   1.05µs  911648.         0B    91.2 
#>  5 cli_vec_ansi     4.15ms   4.25ms     233.   838.95KB    13.2 
#>  6 base_vec_ansi   71.78µs  72.12µs   13702.       848B     0   
#>  7 cli_vec_plain    2.36ms   2.42ms     411.   817.08KB    15.1 
#>  8 base_vec_plain  42.46µs  43.05µs   22895.       848B     0   
#>  9 cli_txt_ansi    14.46ms  14.56ms      68.6   114.6KB     2.02
#> 10 base_txt_ansi   72.86µs  73.83µs   13375.         0B     2.01
#> 11 cli_txt_plain  305.32µs 315.38µs    3095.    18.34KB     2.02
#> 12 base_txt_plain  40.85µs  41.66µs   23752.         0B     0
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
#>  1 cli_ansi          108µs    114µs     8456.        0B    12.4 
#>  2 base_ansi        16.4µs   17.5µs    55101.        0B    11.0 
#>  3 cli_plain       107.9µs  112.7µs     8524.        0B    12.4 
#>  4 base_plain       16.2µs   17.5µs    55031.        0B    11.0 
#>  5 cli_vec_ansi    207.3µs  216.8µs     4479.     7.2KB     6.15
#>  6 base_vec_ansi    59.2µs   64.6µs    15095.    1.66KB     2.02
#>  7 cli_vec_plain   190.1µs  201.7µs     4787.     7.2KB     8.28
#>  8 base_vec_plain   51.4µs   57.1µs    17154.    1.66KB     2.02
#>  9 cli_txt_ansi    180.3µs    187µs     5180.        0B     8.20
#> 10 base_txt_ansi    40.9µs   42.3µs    22925.        0B     4.59
#> 11 cli_txt_plain   165.2µs  171.8µs     5654.        0B     8.18
#> 12 base_txt_plain     35µs   36.3µs    26798.        0B     5.36
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
#> 1 cli          8.21µs   8.83µs   109636.        0B    11.0 
#> 2 base       850.88ns 901.99ns  1017910.        0B     0   
#> 3 cli_vec     23.21µs  23.98µs    40733.      448B     8.15
#> 4 base_vec    11.62µs  11.87µs    82932.      448B     0   
#> 5 cli_txt      23.3µs  24.05µs    40709.        0B     4.07
#> 6 base_txt    12.61µs  12.69µs    77344.        0B     0
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
#> 1 cli          8.14µs   8.82µs   109761.        0B    11.0 
#> 2 base         1.28µs   1.34µs   699770.        0B    70.0 
#> 3 cli_vec     28.67µs  29.55µs    33152.      448B     3.32
#> 4 base_vec    50.44µs  51.13µs    19261.      448B     0   
#> 5 cli_txt        29µs  29.82µs    32833.        0B     3.28
#> 6 base_txt    86.85µs  87.71µs    11267.        0B     0
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
#> 1 cli          8.64µs   9.37µs   103399.        0B    20.7 
#> 2 base       861.01ns    912ns  1030903.        0B     0   
#> 3 cli_vec     19.76µs  20.63µs    47345.      448B     4.73
#> 4 base_vec    11.62µs  11.86µs    82923.      448B     0   
#> 5 cli_txt     20.47µs  21.25µs    45985.        0B     9.20
#> 6 base_txt    12.61µs  12.69µs    77452.        0B     0
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
#> 1 cli          6.27µs   6.86µs   141046.    22.2KB    14.1 
#> 2 base         1.02µs   1.08µs   862870.        0B     0   
#> 3 cli_vec     30.41µs  31.34µs    31285.     1.7KB     6.26
#> 4 base_vec     8.29µs   8.55µs   114781.      848B     0   
#> 5 cli_txt       6.2µs   6.75µs   142936.        0B    14.3 
#> 6 base_txt     5.69µs   5.76µs   169288.        0B     0
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
#>  date     2026-06-01
#>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.11.0     2026-05-16 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.6.9000 2026-06-01 [1] local
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
