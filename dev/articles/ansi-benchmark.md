# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x558e03e4ec98\>
\<environment: 0x558e048f56c0\>

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
#> 1 ansi         38.2µs   42.1µs    23172.    99.6KB     23.2
#> 2 plain        37.6µs   41.9µs    23301.        0B     23.3
#> 3 base         11.1µs   12.5µs    78126.    48.6KB     23.4
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
#> 1 ansi         39.9µs   44.2µs    22161.        0B     24.4
#> 2 plain        39.7µs   44.1µs    22203.        0B     26.7
#> 3 base         12.7µs   14.2µs    68686.        0B     27.5
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
#> 1 ansi        99.09µs 107.01µs     9111.   77.03KB     19.1
#> 2 plain       76.41µs  82.72µs    11769.    8.91KB     16.8
#> 3 base         1.87µs   2.07µs   460509.        0B      0
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
#> 1 ansi          286µs    308µs     3221.   33.23KB     23.9
#> 2 plain         278µs    306µs     3246.    1.09KB     23.7
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
#>  1 cli_ansi          5.57µs    6.3µs   153597.    9.27KB     30.7
#>  2 fansi_ansi       27.69µs  30.42µs    31381.    4.18KB     15.7
#>  3 cli_plain         5.54µs   6.12µs   156762.        0B     15.7
#>  4 fansi_plain      27.89µs  30.32µs    32169.      688B     12.9
#>  5 cli_vec_ansi      7.06µs   7.64µs   127626.      448B     12.8
#>  6 fansi_vec_ansi   36.81µs  39.86µs    24355.    5.02KB     12.2
#>  7 cli_vec_plain     7.68µs   8.33µs   116883.      448B     11.7
#>  8 fansi_vec_plain  36.03µs  38.65µs    25335.    5.02KB     10.1
#>  9 cli_txt_ansi      5.53µs   6.14µs   157194.        0B     15.7
#> 10 fansi_txt_ansi   27.84µs  30.64µs    31927.      688B     16.0
#> 11 cli_txt_plain     6.52µs   7.08µs   137193.        0B     13.7
#> 12 fansi_txt_plain  36.27µs  38.94µs    25114.    5.02KB     10.0
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
#> 1 cli          57.2µs   59.2µs    16617.    22.7KB     4.06
#> 2 fansi       110.9µs  115.8µs     8343.    55.3KB     6.13
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
#>  1 cli_ansi          6.71µs   7.43µs   130022.        0B    13.0 
#>  2 fansi_ansi       72.61µs     78µs    12521.   38.84KB    10.3 
#>  3 base_ansi       892.09ns 991.04ns   936813.        0B     0   
#>  4 cli_plain         6.63µs   7.35µs   131992.        0B    13.2 
#>  5 fansi_plain      71.49µs  77.82µs    12534.      688B    12.5 
#>  6 base_plain      821.08ns  902.1ns  1029633.        0B     0   
#>  7 cli_vec_ansi      29.2µs  30.35µs    32128.      448B     3.21
#>  8 fansi_vec_ansi   94.62µs 100.23µs     9709.    5.02KB     8.28
#>  9 base_vec_ansi    18.96µs  19.11µs    51512.      448B     0   
#> 10 cli_vec_plain    27.19µs  28.13µs    34948.      448B     3.50
#> 11 fansi_vec_plain  83.94µs  89.34µs    10889.    5.02KB    10.4 
#> 12 base_vec_plain   10.95µs  11.09µs    88590.      448B     0   
#> 13 cli_txt_ansi     29.27µs  30.25µs    32523.        0B     3.25
#> 14 fansi_txt_ansi   85.73µs  91.58µs    10663.      688B     8.31
#> 15 base_txt_ansi    18.87µs     19µs    51812.        0B     0   
#> 16 cli_txt_plain    26.63µs  27.43µs    35856.        0B     3.59
#> 17 fansi_txt_plain  74.03µs   79.8µs    12230.      688B    12.4 
#> 18 base_txt_plain   10.91µs  11.03µs    89266.        0B     0
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
#>  1 cli_ansi          8.08µs   8.91µs   108943.        0B    10.9 
#>  2 fansi_ansi       72.27µs  78.19µs    12472.      688B    12.4 
#>  3 base_ansi          1.2µs   1.31µs   728839.        0B     0   
#>  4 cli_plain            8µs   8.83µs   109190.        0B    10.9 
#>  5 fansi_plain      72.06µs  78.43µs    11641.      688B    10.3 
#>  6 base_plain           1µs   1.11µs   832096.        0B     0   
#>  7 cli_vec_ansi     33.91µs  35.28µs    26461.      448B     2.65
#>  8 fansi_vec_ansi      98µs 104.08µs     9376.    5.02KB     8.29
#>  9 base_vec_ansi    41.04µs  41.72µs    23636.      448B     0   
#> 10 cli_vec_plain    32.22µs  33.36µs    29437.      448B     5.89
#> 11 fansi_vec_plain  85.35µs   91.3µs    10671.    5.02KB     8.27
#> 12 base_vec_plain   21.61µs  21.98µs    44848.      448B     0   
#> 13 cli_txt_ansi     34.62µs  35.66µs    27541.        0B     5.51
#> 14 fansi_txt_ansi   88.52µs  94.13µs    10356.      688B     8.21
#> 15 base_txt_ansi     43.3µs  43.87µs    22468.        0B     0   
#> 16 cli_txt_plain    32.05µs  33.11µs    29695.        0B     2.97
#> 17 fansi_txt_plain  77.05µs   83.2µs    11690.      688B    10.4 
#> 18 base_txt_plain   22.99µs  23.21µs    42460.        0B     0
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
#> 1 cli_ansi        6.43µs   7.08µs   136414.        0B    13.6 
#> 2 cli_plain       6.13µs   6.79µs   143111.        0B     0   
#> 3 cli_vec_ansi   31.24µs  32.29µs    30296.      848B     3.03
#> 4 cli_vec_plain  10.14µs  11.01µs    72797.      848B     7.28
#> 5 cli_txt_ansi   30.52µs  31.51µs    29250.        0B     2.93
#> 6 cli_txt_plain   7.07µs   7.81µs   123455.        0B    12.3
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
#>  1 cli_ansi          24.1µs     26µs    37530.        0B    18.8 
#>  2 fansi_ansi        25.9µs   28.2µs    34605.    7.24KB    13.8 
#>  3 cli_plain           23µs   25.5µs    38346.        0B    15.3 
#>  4 fansi_plain       25.2µs   26.6µs    36752.      688B    14.7 
#>  5 cli_vec_ansi      33.3µs   35.1µs    27918.      848B    11.2 
#>  6 fansi_vec_ansi    51.5µs   53.7µs    18287.    5.41KB     8.36
#>  7 cli_vec_plain     26.4µs   27.9µs    35043.      848B    14.0 
#>  8 fansi_vec_plain   34.5µs   36.6µs    26771.    4.59KB    10.7 
#>  9 cli_txt_ansi      32.9µs     35µs    28021.        0B    14.0 
#> 10 fansi_txt_ansi    42.3µs   44.5µs    22023.    5.12KB     8.81
#> 11 cli_txt_plain     24.8µs   26.8µs    36603.        0B    14.6 
#> 12 fansi_txt_plain   26.8µs   28.9µs    33775.      688B    13.5
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
#>  1 cli_ansi        131.14µs 140.16µs     6949.  104.86KB    12.5 
#>  2 fansi_ansi      108.71µs 117.33µs     8377.  106.35KB    12.6 
#>  3 base_ansi         4.07µs   4.54µs   215258.      224B     0   
#>  4 cli_plain       128.99µs 138.61µs     7027.    8.09KB    12.5 
#>  5 fansi_plain     107.55µs 116.39µs     8447.    9.62KB    12.6 
#>  6 base_plain         3.6µs   4.08µs   238945.        0B    23.9 
#>  7 cli_vec_ansi      6.46ms   6.67ms      149.  823.77KB    13.5 
#>  8 fansi_vec_ansi    1.01ms   1.05ms      911.  846.81KB    17.6 
#>  9 base_vec_ansi   155.69µs 160.56µs     5972.    22.7KB     2.03
#> 10 cli_vec_plain     6.42ms   6.65ms      150.  823.77KB    16.4 
#> 11 fansi_vec_plain 974.11µs   1.02ms      969.  845.98KB    17.9 
#> 12 base_vec_plain  106.32µs  111.2µs     8843.      848B     2.02
#> 13 cli_txt_ansi      3.27ms   3.31ms      300.    63.6KB     2.02
#> 14 fansi_txt_ansi    1.61ms   1.63ms      611.   35.05KB     0   
#> 15 base_txt_ansi   142.43µs 153.22µs     6485.   18.47KB     2.03
#> 16 cli_txt_plain     2.42ms   2.47ms      404.    63.6KB     2.02
#> 17 fansi_txt_plain 532.64µs 565.69µs     1767.    30.6KB     2.02
#> 18 base_txt_plain   91.85µs  94.63µs    10427.   11.05KB     2.02
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
#>  1 cli_ansi        127.43µs  136.6µs     7155.   33.84KB    15.0 
#>  2 fansi_ansi       49.05µs   53.2µs    18350.   31.42KB    12.5 
#>  3 base_ansi         1.06µs   1.17µs   803491.     4.2KB     0   
#>  4 cli_plain       127.25µs 134.51µs     7299.        0B    14.6 
#>  5 fansi_plain      48.84µs  53.29µs    18297.      872B    12.5 
#>  6 base_plain      991.04ns   1.09µs   854840.        0B     0   
#>  7 cli_vec_ansi    248.18µs 256.45µs     3821.   16.73KB     7.48
#>  8 fansi_vec_ansi  112.86µs 116.55µs     8440.    5.59KB     8.30
#>  9 base_vec_ansi    36.47µs   36.8µs    26811.      848B     0   
#> 10 cli_vec_plain   209.04µs 215.18µs     4584.   16.73KB     8.31
#> 11 fansi_vec_plain  103.5µs  107.3µs     9158.    5.59KB     8.32
#> 12 base_vec_plain    30.3µs  30.64µs    32233.      848B     0   
#> 13 cli_txt_ansi    132.79µs 138.14µs     7094.        0B    14.6 
#> 14 fansi_txt_ansi   48.33µs  52.37µs    18775.      872B    12.5 
#> 15 base_txt_ansi     1.09µs   1.21µs   775025.        0B     0   
#> 16 cli_txt_plain   127.37µs 134.72µs     7316.        0B    14.6 
#> 17 fansi_txt_plain  48.49µs  52.85µs    18587.      872B    12.5 
#> 18 base_txt_plain  992.09ns   1.13µs   822120.        0B    82.2
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
#>  1 cli_ansi        346.53µs 371.06µs    2678.     6.18KB    12.5 
#>  2 fansi_ansi       86.72µs  93.74µs   10512.    97.33KB    12.5 
#>  3 base_ansi        32.19µs  34.47µs   28426.         0B    14.2 
#>  4 cli_plain       220.87µs 234.15µs    4210.         0B    12.7 
#>  5 fansi_plain      86.58µs  93.73µs   10106.       872B    12.5 
#>  6 base_plain       26.31µs  28.18µs   34639.         0B    10.4 
#>  7 cli_vec_ansi     37.44ms  37.78ms      26.4   94.67KB    30.9 
#>  8 fansi_vec_ansi  233.11µs 244.03µs    4043.     7.25KB     6.16
#>  9 base_vec_ansi      2.2ms   2.25ms     442.    48.18KB    12.9 
#> 10 cli_vec_plain    22.82ms  23.14ms      43.2    2.48KB    17.3 
#> 11 fansi_vec_plain 183.91µs 192.84µs    5096.     6.42KB     8.25
#> 12 base_vec_plain    1.59ms   1.66ms     600.     47.4KB    13.0 
#> 13 cli_txt_ansi     27.28ms  27.44ms      36.4    4.27MB     4.55
#> 14 fansi_txt_ansi  227.74µs 236.74µs    4172.     6.77KB     6.14
#> 15 base_txt_ansi     1.28ms   1.31ms     753.   582.06KB    11.2 
#> 16 cli_txt_plain     1.25ms    1.3ms     760.   369.84KB     8.69
#> 17 fansi_txt_plain 172.97µs 182.03µs    5401.     2.51KB     6.14
#> 18 base_txt_plain  843.84µs 873.99µs    1127.   367.31KB    10.8
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
#>  1 cli_ansi          6.44µs   7.02µs   137951.   25.09KB    13.8 
#>  2 fansi_ansi       69.77µs  72.92µs    13382.   28.48KB    12.5 
#>  3 base_ansi         1.02µs   1.15µs   820894.        0B    82.1 
#>  4 cli_plain         6.42µs   6.97µs   140228.        0B    14.0 
#>  5 fansi_plain      70.17µs  73.17µs    13349.    1.98KB    12.5 
#>  6 base_plain      992.09ns   1.09µs   858086.        0B     0   
#>  7 cli_vec_ansi     26.55µs  27.61µs    35679.     1.7KB     3.57
#>  8 fansi_vec_ansi  104.73µs 111.97µs     8760.    8.86KB     8.48
#>  9 base_vec_ansi     6.19µs    6.5µs   150060.      848B     0   
#> 10 cli_vec_plain    23.29µs  24.48µs    40072.     1.7KB     8.02
#> 11 fansi_vec_plain 101.88µs 107.99µs     9088.    8.86KB     8.35
#> 12 base_vec_plain    5.85µs   6.18µs   158749.      848B     0   
#> 13 cli_txt_ansi      6.54µs   7.27µs   133394.        0B    13.3 
#> 14 fansi_txt_ansi   70.34µs  76.66µs    12820.    1.98KB    12.5 
#> 15 base_txt_ansi     7.07µs   7.21µs   135781.        0B     0   
#> 16 cli_txt_plain     7.46µs   8.23µs   117089.        0B    23.4 
#> 17 fansi_txt_plain  70.92µs  76.61µs    12824.    1.98KB    10.4 
#> 18 base_txt_plain    4.42µs   4.54µs   214028.        0B    21.4
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
#>  1 cli_ansi        92.48µs  99.01µs    9851.     12.1KB    10.3 
#>  2 base_ansi        1.28µs   1.37µs  702228.         0B     0   
#>  3 cli_plain       74.07µs  78.59µs   12389.     8.91KB     8.21
#>  4 base_plain     990.93ns   1.08µs  863444.         0B    86.4 
#>  5 cli_vec_ansi     4.21ms   4.35ms     230.   838.95KB    13.1 
#>  6 base_vec_ansi   70.08µs  70.48µs   14023.       848B     0   
#>  7 cli_vec_plain    2.37ms   2.43ms     407.   817.08KB    15.5 
#>  8 base_vec_plain  41.86µs  43.62µs   22725.       848B     0   
#>  9 cli_txt_ansi    15.48ms  15.54ms      64.1   114.6KB     2.07
#> 10 base_txt_ansi    68.7µs  70.05µs   14047.         0B     0   
#> 11 cli_txt_plain  295.67µs 311.56µs    3167.    18.34KB     2.01
#> 12 base_txt_plain  39.67µs  40.27µs   24514.         0B     0
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
#>  1 cli_ansi         88.8µs   93.8µs    10447.        0B    14.6 
#>  2 base_ansi        15.1µs   16.5µs    59154.        0B    11.8 
#>  3 cli_plain        90.1µs   95.5µs    10253.        0B    14.7 
#>  4 base_plain       15.3µs   16.6µs    58288.        0B    11.7 
#>  5 cli_vec_ansi    192.2µs  202.8µs     4813.     7.2KB     6.17
#>  6 base_vec_ansi    55.1µs   62.6µs    15840.    1.66KB     4.07
#>  7 cli_vec_plain   177.9µs    188µs     5217.     7.2KB     6.17
#>  8 base_vec_plain   48.3µs   54.8µs    18000.    1.66KB     4.07
#>  9 cli_txt_ansi    168.6µs  175.4µs     5602.        0B     8.22
#> 10 base_txt_ansi    41.3µs   42.8µs    22939.        0B     4.59
#> 11 cli_txt_plain     153µs  160.3µs     6144.        0B     8.32
#> 12 base_txt_plain   34.8µs   36.4µs    26970.        0B     5.40
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
#> 1 cli          7.73µs   8.49µs   113995.        0B    22.8 
#> 2 base       840.87ns 960.89ns   983914.        0B     0   
#> 3 cli_vec     23.36µs  24.38µs    40272.      448B     4.03
#> 4 base_vec     12.3µs  12.56µs    78313.      448B     0   
#> 5 cli_txt     22.93µs  23.91µs    41123.        0B     4.11
#> 6 base_txt    13.42µs  13.92µs    70797.        0B     0
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
#> 1 cli          7.73µs   8.49µs   114430.        0B    11.4 
#> 2 base          1.3µs   1.42µs   659413.        0B     0   
#> 3 cli_vec     30.96µs  32.26µs    30167.      448B     3.02
#> 4 base_vec    54.24µs  55.07µs    17943.      448B     0   
#> 5 cli_txt     30.23µs  31.97µs    30777.        0B     6.16
#> 6 base_txt    89.81µs  90.83µs    10886.        0B     0
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
#> 1 cli          8.24µs   9.14µs   106305.        0B    10.6 
#> 2 base       860.89ns 961.01ns   902682.        0B     0   
#> 3 cli_vec     19.71µs  20.83µs    47029.      448B     9.41
#> 4 base_vec    12.27µs  12.58µs    78392.      448B     0   
#> 5 cli_txt     20.72µs  21.83µs    44928.        0B     4.49
#> 6 base_txt    13.41µs  13.89µs    70885.        0B     0
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
#> 1 cli           6.3µs   7.05µs   136656.    22.2KB    27.3 
#> 2 base         1.04µs   1.17µs   799621.        0B     0   
#> 3 cli_vec     30.74µs  32.09µs    30669.     1.7KB     3.07
#> 4 base_vec     8.58µs   8.78µs   111903.      848B     0   
#> 5 cli_txt      6.14µs   6.68µs   145304.        0B    29.1 
#> 6 base_txt     5.64µs   6.18µs   161168.        0B     0
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
#>  date     2026-06-04
#>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.11.0     2026-05-16 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.6.9000 2026-06-04 [1] local
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
