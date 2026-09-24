# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x55b62653d0c0\>
\<environment: 0x55b627068880\>

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
#> 1 ansi         45.6µs   48.8µs    19825.    99.6KB     21.1
#> 2 plain        44.9µs   48.1µs    20085.        0B     19.7
#> 3 base         11.3µs   12.5µs    77321.    48.6KB     23.2
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
#> 1 ansi         47.3µs   50.8µs    19061.        0B     23.6
#> 2 plain        46.7µs   50.3µs    19232.        0B     23.3
#> 3 base         13.1µs   14.5µs    66764.        0B     26.7
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
#> 1 ansi       116.21µs  122.9µs     7823.   77.03KB     16.8
#> 2 plain       92.53µs   97.9µs     9871.    8.91KB     14.6
#> 3 base         1.86µs      2µs   478232.        0B      0
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
#> 1 ansi          339µs    361µs     2721.   33.24KB     21.3
#> 2 plain         337µs    362µs     2734.    1.09KB     19.1
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
#>  1 cli_ansi          5.69µs   6.24µs   154806.    9.27KB    31.0 
#>  2 fansi_ansi       30.38µs  33.52µs    28334.    4.18KB    25.5 
#>  3 cli_plain         5.63µs   6.06µs   158905.        0B    15.9 
#>  4 fansi_plain      29.99µs  31.98µs    29569.      688B    11.8 
#>  5 cli_vec_ansi      7.11µs   7.56µs   128330.      448B    12.8 
#>  6 fansi_vec_ansi   40.15µs  42.39µs    22611.    5.02KB    11.3 
#>  7 cli_vec_plain      7.7µs   8.15µs   119441.      448B    11.9 
#>  8 fansi_vec_plain  38.06µs  40.19µs    24228.    5.02KB     9.69
#>  9 cli_txt_ansi      5.67µs   6.04µs   160870.        0B    16.1 
#> 10 fansi_txt_ansi   30.08µs     32µs    30371.      688B    12.2 
#> 11 cli_txt_plain     6.46µs   6.93µs   138844.        0B    13.9 
#> 12 fansi_txt_plain  38.02µs   40.3µs    24136.    5.02KB    12.1
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
#> 1 cli          59.4µs   60.8µs    15928.    22.7KB     4.04
#> 2 fansi       117.9µs  122.5µs     7903.    55.3KB     4.05
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
#>  1 cli_ansi          6.82µs   7.39µs   130934.        0B    13.1 
#>  2 fansi_ansi       91.16µs  96.06µs    10075.   38.84KB    10.3 
#>  3 base_ansi       901.05ns 942.03ns   998409.        0B     0   
#>  4 cli_plain         6.76µs   7.39µs   131265.        0B    13.1 
#>  5 fansi_plain      90.81µs  95.61µs    10132.      688B     8.18
#>  6 base_plain      810.95ns 850.88ns  1068896.        0B     0   
#>  7 cli_vec_ansi     28.06µs  28.79µs    34071.      448B     3.41
#>  8 fansi_vec_ansi  111.91µs 116.56µs     8296.    5.02KB     8.25
#>  9 base_vec_ansi    18.44µs  18.52µs    53188.      448B     0   
#> 10 cli_vec_plain    26.71µs  27.49µs    35665.      448B     3.57
#> 11 fansi_vec_plain 102.46µs 106.99µs     9041.    5.02KB     8.24
#> 12 base_vec_plain   10.77µs  10.84µs    90649.      448B     0   
#> 13 cli_txt_ansi     27.99µs  28.65µs    34265.        0B     3.43
#> 14 fansi_txt_ansi  103.53µs 108.73µs     8920.      688B     8.19
#> 15 base_txt_ansi     18.2µs  18.26µs    53827.        0B     0   
#> 16 cli_txt_plain    26.23µs   26.9µs    36402.        0B     3.64
#> 17 fansi_txt_plain  92.95µs  98.16µs     9874.      688B     8.19
#> 18 base_txt_plain   10.57µs   11.1µs    89021.        0B     0
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
#>  1 cli_ansi          8.36µs   9.13µs   103919.        0B    10.4 
#>  2 fansi_ansi       91.17µs  96.73µs    10025.      688B    10.4 
#>  3 base_ansi         1.21µs   1.26µs   756557.        0B     0   
#>  4 cli_plain         8.43µs   9.08µs   106791.        0B    10.7 
#>  5 fansi_plain      91.26µs  95.92µs    10098.      688B     8.18
#>  6 base_plain      991.98ns   1.05µs   871944.        0B     0   
#>  7 cli_vec_ansi     34.28µs  35.11µs    27853.      448B     5.57
#>  8 fansi_vec_ansi  114.55µs 119.72µs     8107.    5.02KB     6.14
#>  9 base_vec_ansi    44.04µs  44.45µs    22203.      448B     0   
#> 10 cli_vec_plain    33.24µs  34.15µs    28689.      448B     2.87
#> 11 fansi_vec_plain 104.58µs 109.22µs     8864.    5.02KB     8.25
#> 12 base_vec_plain   23.02µs  23.29µs    42367.      448B     0   
#> 13 cli_txt_ansi     34.76µs  35.51µs    27430.        0B     5.49
#> 14 fansi_txt_ansi  106.37µs 111.38µs     8704.      688B     6.11
#> 15 base_txt_ansi    46.64µs  47.21µs    20730.        0B     0   
#> 16 cli_txt_plain    32.81µs   33.6µs    29047.        0B     5.81
#> 17 fansi_txt_plain  95.94µs 101.22µs     9377.      688B     8.19
#> 18 base_txt_plain   24.62µs  25.29µs    39046.        0B     0
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
#> 1 cli_ansi        6.78µs    7.3µs   132988.        0B    13.3 
#> 2 cli_plain       6.26µs   6.79µs   142298.        0B    14.2 
#> 3 cli_vec_ansi   32.41µs  33.56µs    29254.      848B     2.93
#> 4 cli_vec_plain  10.31µs  11.01µs    88581.      848B     8.86
#> 5 cli_txt_ansi   32.26µs  33.01µs    29668.        0B     0   
#> 6 cli_txt_plain   7.13µs   7.71µs   125729.        0B    12.6
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
#>  1 cli_ansi          25.7µs   27.5µs    33598.        0B    13.4 
#>  2 fansi_ansi        28.3µs   30.4µs    31923.    7.24KB    12.8 
#>  3 cli_plain         25.5µs   27.1µs    35772.        0B    14.3 
#>  4 fansi_plain       27.5µs   29.5µs    32904.      688B    13.2 
#>  5 cli_vec_ansi      35.5µs   37.2µs    26196.      848B    13.1 
#>  6 fansi_vec_ansi    54.9µs   57.9µs    16864.    5.41KB     6.19
#>  7 cli_vec_plain     28.3µs     30µs    32464.      848B    13.0 
#>  8 fansi_vec_plain   36.7µs   38.5µs    25300.    4.59KB    10.1 
#>  9 cli_txt_ansi      34.2µs   35.5µs    27479.        0B    11.0 
#> 10 fansi_txt_ansi    43.8µs   45.3µs    21438.    5.12KB    10.7 
#> 11 cli_txt_plain     26.4µs   27.6µs    35201.        0B    14.1 
#> 12 fansi_txt_plain   28.3µs   29.9µs    32246.      688B    12.9
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
#>  1 cli_ansi        163.29µs 170.08µs     5709.  104.86KB    10.3 
#>  2 fansi_ansi      128.81µs 135.58µs     7167.  106.35KB    10.3 
#>  3 base_ansi         4.07µs   4.42µs   220482.      224B     0   
#>  4 cli_plain       161.57µs 168.89µs     5705.    8.09KB    10.3 
#>  5 fansi_plain      125.9µs 133.44µs     7290.    9.62KB    10.4 
#>  6 base_plain        3.54µs   3.85µs   251946.        0B     0   
#>  7 cli_vec_ansi      7.65ms   7.82ms      128.  823.77KB    13.7 
#>  8 fansi_vec_ansi    1.07ms    1.1ms      885.  846.81KB    17.3 
#>  9 base_vec_ansi   156.13µs 165.47µs     6004.    22.7KB     2.04
#> 10 cli_vec_plain     7.53ms   7.69ms      129.  823.77KB    11.3 
#> 11 fansi_vec_plain      1ms   1.03ms      960.  845.98KB    19.7 
#> 12 base_vec_plain  106.95µs 110.36µs     8847.      848B     2.01
#> 13 cli_txt_ansi      3.21ms   3.24ms      306.    63.6KB     0   
#> 14 fansi_txt_ansi    1.55ms   1.57ms      634.   35.05KB     2.02
#> 15 base_txt_ansi   134.62µs 145.56µs     6782.   18.47KB     2.02
#> 16 cli_txt_plain     2.36ms    2.4ms      415.    63.6KB     0   
#> 17 fansi_txt_plain 513.45µs 535.09µs     1851.    30.6KB     4.08
#> 18 base_txt_plain   86.79µs  89.23µs    11004.   11.05KB     2.02
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
#>  1 cli_ansi        147.61µs 155.14µs     6253.   33.84KB    12.4 
#>  2 fansi_ansi       54.38µs  58.32µs    16593.   31.42KB    12.5 
#>  3 base_ansi         1.04µs   1.09µs   870587.     4.2KB     0   
#>  4 cli_plain        144.1µs 150.33µs     6450.        0B    12.4 
#>  5 fansi_plain      53.95µs  57.49µs    16850.      872B    12.5 
#>  6 base_plain      952.04ns      1µs   943705.        0B     0   
#>  7 cli_vec_ansi    271.92µs 283.33µs     3453.   16.73KB     6.29
#>  8 fansi_vec_ansi  115.23µs 119.85µs     8089.    5.59KB     6.16
#>  9 base_vec_ansi    36.54µs  37.18µs    26527.      848B     0   
#> 10 cli_vec_plain   228.94µs  240.6µs     4056.   16.73KB     8.30
#> 11 fansi_vec_plain 107.75µs 112.14µs     8694.    5.59KB     6.16
#> 12 base_vec_plain   30.09µs  30.69µs    32184.      848B     3.22
#> 13 cli_txt_ansi    155.24µs 162.49µs     5980.        0B    10.3 
#> 14 fansi_txt_ansi   52.97µs   57.2µs    16895.      872B    12.2 
#> 15 base_txt_ansi     1.07µs   1.11µs   842560.        0B     0   
#> 16 cli_txt_plain   143.23µs 149.08µs     6512.        0B    12.4 
#> 17 fansi_txt_plain   52.8µs  55.29µs    17513.      872B    12.5 
#> 18 base_txt_plain  971.14ns   1.01µs   930251.        0B    93.0
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
#>  1 cli_ansi        416.69µs 444.71µs    2233.     6.18KB    10.5 
#>  2 fansi_ansi       96.89µs 104.03µs    9307.    97.33KB    10.3 
#>  3 base_ansi        37.42µs  39.84µs   24169.         0B    12.1 
#>  4 cli_plain       269.46µs 283.64µs    3431.         0B    10.3 
#>  5 fansi_plain      95.87µs 101.98µs    9516.       872B    10.3 
#>  6 base_plain       30.69µs  32.52µs   29597.         0B    11.8 
#>  7 cli_vec_ansi     43.96ms  44.47ms      22.5   94.67KB    18.7 
#>  8 fansi_vec_ansi  236.44µs  246.3µs    3987.     7.25KB     6.13
#>  9 base_vec_ansi     2.25ms   2.31ms     431.    48.18KB    12.9 
#> 10 cli_vec_plain    28.44ms  28.79ms      34.6    2.48KB    14.4 
#> 11 fansi_vec_plain 188.58µs 197.74µs    4891.     6.42KB     8.24
#> 12 base_vec_plain    1.64ms   1.69ms     582.     47.4KB    10.5 
#> 13 cli_txt_ansi     27.53ms  27.82ms      35.9    4.27MB     7.17
#> 14 fansi_txt_ansi  223.83µs 233.34µs    4186.     6.77KB     6.13
#> 15 base_txt_ansi     1.27ms   1.31ms     757.   582.06KB     8.80
#> 16 cli_txt_plain     1.29ms   1.33ms     744.   369.84KB     8.73
#> 17 fansi_txt_plain 176.35µs 183.96µs    5307.     2.51KB     6.16
#> 18 base_txt_plain  856.55µs 896.46µs    1100.   367.31KB    11.0
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
#>  1 cli_ansi          6.58µs   7.17µs   133422.   25.09KB    13.3 
#>  2 fansi_ansi       78.65µs  83.97µs    11542.   28.48KB    12.5 
#>  3 base_ansi         1.03µs   1.09µs   857053.        0B     0   
#>  4 cli_plain         6.54µs    7.2µs   133320.        0B    13.3 
#>  5 fansi_plain      77.64µs  83.61µs    11602.    1.98KB    10.5 
#>  6 base_plain           1µs   1.07µs   835023.        0B    83.5 
#>  7 cli_vec_ansi     26.51µs  27.44µs    35725.     1.7KB     3.57
#>  8 fansi_vec_ansi  115.48µs 121.63µs     7977.    8.86KB     6.20
#>  9 base_vec_ansi     6.39µs   6.74µs   144062.      848B    14.4 
#> 10 cli_vec_plain    22.84µs  23.75µs    41206.     1.7KB     4.12
#> 11 fansi_vec_plain 110.24µs 115.63µs     8396.    8.86KB     8.34
#> 12 base_vec_plain    6.04µs   6.37µs   153754.      848B     0   
#> 13 cli_txt_ansi      6.69µs   7.36µs   131142.        0B    13.1 
#> 14 fansi_txt_ansi   78.56µs  83.91µs    11542.    1.98KB    10.4 
#> 15 base_txt_ansi     6.47µs   6.55µs   148362.        0B     0   
#> 16 cli_txt_plain      7.3µs   7.75µs   124565.        0B    24.9 
#> 17 fansi_txt_plain  76.43µs  79.93µs    12108.    1.98KB    10.3 
#> 18 base_txt_plain     4.1µs   4.17µs   234051.        0B     0
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
#>  1 cli_ansi       109.75µs 114.73µs    8459.     12.1KB     8.20
#>  2 base_ansi        1.31µs   1.35µs  723333.         0B     0   
#>  3 cli_plain        89.1µs  93.43µs   10363.     8.91KB     8.21
#>  4 base_plain       1.02µs   1.05µs  913908.         0B     0   
#>  5 cli_vec_ansi     4.11ms   4.23ms     232.   838.95KB    13.3 
#>  6 base_vec_ansi   75.47µs  76.19µs   12952.       848B     0   
#>  7 cli_vec_plain    2.33ms   2.39ms     413.   817.08KB    15.1 
#>  8 base_vec_plain  45.33µs  45.97µs   21477.       848B     0   
#>  9 cli_txt_ansi    14.93ms  15.25ms      65.9   114.6KB     2.06
#> 10 base_txt_ansi   75.41µs  76.62µs   12904.         0B     0   
#> 11 cli_txt_plain  295.56µs 308.86µs    2960.    18.34KB     4.04
#> 12 base_txt_plain   42.3µs  43.05µs   22889.         0B     0
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
#>  1 cli_ansi        107.8µs    114µs     8482.        0B    12.4 
#>  2 base_ansi        16.6µs   17.6µs    55098.        0B    11.0 
#>  3 cli_plain       106.9µs  112.6µs     8596.        0B    10.3 
#>  4 base_plain       16.5µs   17.7µs    54652.        0B    10.9 
#>  5 cli_vec_ansi    209.7µs  219.9µs     4446.     7.2KB     6.14
#>  6 base_vec_ansi    59.3µs   65.5µs    14945.    1.66KB     4.06
#>  7 cli_vec_plain   195.3µs  205.1µs     4763.     7.2KB     6.14
#>  8 base_vec_plain   52.5µs     59µs    16584.    1.66KB     4.06
#>  9 cli_txt_ansi    183.4µs    190µs     5131.        0B     6.11
#> 10 base_txt_ansi    41.9µs   43.2µs    22622.        0B     4.53
#> 11 cli_txt_plain   167.5µs  176.3µs     5545.        0B     8.29
#> 12 base_txt_plain   35.1µs   36.4µs    26828.        0B     5.37
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
#> 1 cli          8.05µs   8.73µs   110736.        0B    11.1 
#> 2 base       861.01ns 942.03ns   885523.        0B    88.6 
#> 3 cli_vec     23.06µs  23.86µs    40672.      448B     4.07
#> 4 base_vec    11.45µs   11.7µs    84025.      448B     0   
#> 5 cli_txt      23.1µs  23.88µs    40335.        0B     4.03
#> 6 base_txt    12.49µs  12.57µs    77102.        0B     0
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
#> 1 cli          8.06µs   8.75µs   110131.        0B    22.0 
#> 2 base         1.29µs   1.34µs   708145.        0B     0   
#> 3 cli_vec     28.62µs  29.52µs    33028.      448B     3.30
#> 4 base_vec    50.28µs  50.87µs    19423.      448B     0   
#> 5 cli_txt     28.93µs   29.8µs    32664.        0B     3.27
#> 6 base_txt     86.5µs  87.49µs    11312.        0B     0
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
#> 1 cli          8.56µs   9.31µs   103445.        0B    10.3 
#> 2 base       851.11ns  902.1ns  1021275.        0B     0   
#> 3 cli_vec      19.4µs  20.36µs    47862.      448B     4.79
#> 4 base_vec    11.44µs   11.7µs    83979.      448B     0   
#> 5 cli_txt     20.33µs   21.1µs    46157.        0B     9.23
#> 6 base_txt     12.5µs  12.57µs    78348.        0B     0
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
#> 1 cli          6.36µs   6.98µs   138060.    22.2KB    13.8 
#> 2 base         1.05µs   1.12µs   801252.        0B    80.1 
#> 3 cli_vec     28.78µs  29.68µs    33047.     1.7KB     3.31
#> 4 base_vec     8.05µs   8.36µs   105764.      848B     0   
#> 5 cli_txt      6.28µs   6.91µs   139638.        0B    14.0 
#> 6 base_txt     5.47µs   5.54µs   176094.        0B     0
```

## Session info

``` r

sessioninfo::session_info()
```

``` fansi
#> ─ Session info ──────────────────────────────────────────────────────
#>  setting  value
#>  version  R version 4.6.1 (2026-06-24)
#>  os       Ubuntu 24.04.5 LTS
#>  system   x86_64, linux-gnu
#>  ui       X11
#>  language en
#>  collate  C.UTF-8
#>  ctype    C.UTF-8
#>  tz       UTC
#>  date     2026-09-24
#>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.12.0     2026-08-04 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.6.9000 2026-09-24 [1] local
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
#>  knitr         1.52       2026-09-06 [1] RSPM
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
#>  rmarkdown     2.32       2026-09-01 [1] RSPM
#>  sass          0.4.10     2025-04-11 [1] RSPM
#>  sessioninfo   1.2.4      2026-06-04 [1] RSPM
#>  systemfonts   1.3.2      2026-03-05 [1] RSPM
#>  textshaping   1.0.5      2026-03-06 [1] RSPM
#>  tibble        3.3.1      2026-01-11 [1] RSPM
#>  utf8          1.2.6      2025-06-08 [1] RSPM
#>  vctrs         0.7.3      2026-04-11 [1] RSPM
#>  xfun          0.61       2026-09-16 [1] RSPM
#>  yaml          2.3.12     2025-12-10 [1] RSPM
#> 
#>  [1] /home/runner/work/_temp/Library
#>  [2] /opt/R/4.6.1/lib/R/site-library
#>  [3] /opt/R/4.6.1/lib/R/library
#>  * ── Packages attached to the search path.
#> 
#> ─────────────────────────────────────────────────────────────────────
```
