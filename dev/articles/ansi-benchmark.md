# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x5631b6d18b98\>
\<environment: 0x5631b786b4b8\>

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
#> 1 ansi         45.9µs   49.3µs    19601.    99.3KB     18.9
#> 2 plain        46.1µs   49.5µs    19520.        0B     19.6
#> 3 base         11.3µs   12.4µs    77847.    48.4KB     15.6
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
#> 1 ansi         47.4µs   51.3µs    18776.        0B     21.2
#> 2 plain        47.6µs   51.1µs    18821.        0B     21.4
#> 3 base         13.2µs   14.4µs    67236.        0B     20.2
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
#> 1 ansi       110.67µs 117.15µs     8256.   75.07KB     16.8
#> 2 plain       87.54µs  92.64µs    10417.    8.73KB     14.6
#> 3 base         1.81µs   1.92µs   480148.        0B      0
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
#> 1 ansi          341µs    363µs     2675.   33.17KB     19.3
#> 2 plain         341µs    367µs     2693.    1.09KB     19.3
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
#>  1 cli_ansi          5.73µs   6.22µs   155148.     9.2KB     31.0
#>  2 fansi_ansi       30.77µs  33.63µs    28662.    4.18KB     22.9
#>  3 cli_plain         5.72µs   6.28µs   153251.        0B     30.7
#>  4 fansi_plain      30.12µs  32.75µs    29639.      688B     23.7
#>  5 cli_vec_ansi      7.16µs   7.58µs   128599.      448B     25.7
#>  6 fansi_vec_ansi   39.42µs  41.49µs    23327.    5.02KB     18.7
#>  7 cli_vec_plain     7.72µs   8.13µs   119600.      448B     23.9
#>  8 fansi_vec_plain  37.71µs  39.69µs    24413.    5.02KB     19.5
#>  9 cli_txt_ansi       5.7µs   6.11µs   158152.        0B     31.6
#> 10 fansi_txt_ansi   29.93µs  32.15µs    28630.      688B     22.9
#> 11 cli_txt_plain     6.53µs   6.91µs   140401.        0B     28.1
#> 12 fansi_txt_plain  37.18µs  39.65µs    23795.    5.02KB     19.1
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
#> 1 cli          56.5µs   58.1µs    16770.    22.7KB    10.3 
#> 2 fansi       117.9µs  121.6µs     8012.    55.3KB     8.20
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
#>  1 cli_ansi           6.8µs   7.32µs   132221.        0B    26.4 
#>  2 fansi_ansi       89.33µs     94µs    10254.   38.83KB    16.8 
#>  3 base_ansi       822.12ns 871.02ns  1064740.        0B     0   
#>  4 cli_plain         6.71µs   7.28µs   132480.        0B    26.5 
#>  5 fansi_plain      88.47µs   93.4µs    10320.      688B    16.8 
#>  6 base_plain      761.01ns 812.11ns  1114694.        0B   111.  
#>  7 cli_vec_ansi     33.29µs  36.32µs    27028.      448B     2.70
#>  8 fansi_vec_ansi  109.64µs 114.11µs     8421.    5.02KB    14.7 
#>  9 base_vec_ansi    14.67µs  14.74µs    66572.      448B     0   
#> 10 cli_vec_plain    31.74µs  34.67µs    28298.      448B     5.66
#> 11 fansi_vec_plain  99.69µs 104.17µs     9254.    5.02KB    14.7 
#> 12 base_vec_plain    8.75µs   8.82µs   110306.      448B    11.0 
#> 13 cli_txt_ansi     36.32µs  37.44µs    26178.        0B     2.62
#> 14 fansi_txt_ansi  101.45µs 106.32µs     9074.      688B    14.6 
#> 15 base_txt_ansi    14.25µs  14.32µs    68595.        0B     6.86
#> 16 cli_txt_plain    33.14µs  35.16µs    27715.        0B     5.54
#> 17 fansi_txt_plain  91.74µs  96.47µs     9969.      688B    14.6 
#> 18 base_txt_plain    8.39µs   8.55µs   113808.        0B    11.4
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
#>  1 cli_ansi          8.58µs   9.25µs   104902.        0B    31.5 
#>  2 fansi_ansi       88.85µs  94.22µs    10212.      688B    16.8 
#>  3 base_ansi         1.17µs   1.21µs   785095.        0B     0   
#>  4 cli_plain          8.5µs   9.14µs   105902.        0B    21.2 
#>  5 fansi_plain      89.22µs  93.25µs    10342.      688B    16.8 
#>  6 base_plain      962.06ns   1.01µs   918567.        0B     0   
#>  7 cli_vec_ansi     55.75µs  58.62µs    16710.      448B     4.05
#>  8 fansi_vec_ansi  112.51µs  116.9µs     8288.    5.02KB    14.7 
#>  9 base_vec_ansi    42.55µs  42.76µs    23085.      448B     0   
#> 10 cli_vec_plain     53.6µs  55.98µs    17565.      448B     4.05
#> 11 fansi_vec_plain 102.31µs 106.47µs     9056.    5.02KB    14.7 
#> 12 base_vec_plain   22.24µs  22.51µs    43494.      448B     0   
#> 13 cli_txt_ansi     57.62µs  60.82µs    16179.        0B     4.05
#> 14 fansi_txt_ansi  104.81µs 109.59µs     8776.      688B    14.6 
#> 15 base_txt_ansi     45.3µs  45.67µs    21538.        0B     0   
#> 16 cli_txt_plain    55.59µs  58.56µs    16808.        0B     4.04
#> 17 fansi_txt_plain  94.65µs  99.11µs     9767.      688B    16.7 
#> 18 base_txt_plain   24.05µs  24.58µs    40167.        0B     0
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
#> 1 cli_ansi        6.73µs   7.22µs   134502.        0B    13.5 
#> 2 cli_plain       6.29µs   6.81µs   141993.        0B    28.4 
#> 3 cli_vec_ansi   31.26µs  32.21µs    30398.      848B     6.08
#> 4 cli_vec_plain  10.15µs  10.79µs    90355.      848B     9.04
#> 5 cli_txt_ansi   30.73µs  31.66µs    31005.        0B     6.20
#> 6 cli_txt_plain   7.18µs    7.7µs   125481.        0B    12.5
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
#>  1 cli_ansi          25.2µs   26.9µs    35926.        0B     28.8
#>  2 fansi_ansi          28µs   29.7µs    32538.    7.24KB     26.1
#>  3 cli_plain         25.2µs   26.7µs    36093.        0B     28.9
#>  4 fansi_plain       27.5µs   29.3µs    32930.      688B     23.1
#>  5 cli_vec_ansi      34.4µs   36.1µs    26835.      848B     21.5
#>  6 fansi_vec_ansi    53.2µs   55.4µs    17488.    5.41KB     14.8
#>  7 cli_vec_plain       28µs   29.5µs    32673.      848B     26.2
#>  8 fansi_vec_plain   35.9µs   38.1µs    25149.    4.59KB     20.1
#>  9 cli_txt_ansi      34.2µs   35.7µs    27114.        0B     21.7
#> 10 fansi_txt_ansi    43.8µs   45.8µs    21213.    5.12KB     14.4
#> 11 cli_txt_plain       26µs   27.5µs    35195.        0B     28.2
#> 12 fansi_txt_plain   28.8µs   30.5µs    31727.      688B     25.4
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
#>  1 cli_ansi        163.37µs 171.82µs     5614.  104.34KB    19.0 
#>  2 fansi_ansi      126.58µs  132.8µs     7277.  106.35KB    21.3 
#>  3 base_ansi            4µs   4.36µs   223348.      224B     0   
#>  4 cli_plain       162.25µs 169.81µs     5672.    8.09KB    18.9 
#>  5 fansi_plain     124.39µs 131.48µs     7333.    9.62KB    21.3 
#>  6 base_plain        3.63µs   3.86µs   251942.        0B     0   
#>  7 cli_vec_ansi      7.59ms   7.75ms      128.  823.77KB    25.7 
#>  8 fansi_vec_ansi    1.04ms   1.08ms      894.  846.81KB    19.7 
#>  9 base_vec_ansi   154.36µs 160.52µs     6078.    22.7KB     2.05
#> 10 cli_vec_plain     7.49ms   7.69ms      128.  823.77KB    25.6 
#> 11 fansi_vec_plain 988.05µs   1.03ms      954.  845.98KB    19.8 
#> 12 base_vec_plain  104.58µs 107.25µs     9025.      848B     4.06
#> 13 cli_txt_ansi      3.53ms   3.57ms      279.    63.6KB     0   
#> 14 fansi_txt_ansi    1.55ms   1.57ms      629.   35.05KB     2.02
#> 15 base_txt_ansi   138.41µs 148.77µs     6636.   18.47KB     2.03
#> 16 cli_txt_plain     2.53ms   2.55ms      390.    63.6KB     0   
#> 17 fansi_txt_plain 514.49µs 535.83µs     1846.    30.6KB     6.17
#> 18 base_txt_plain      88µs   91.1µs    10770.   11.05KB     2.02
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
#>  1 cli_ansi        147.26µs 154.58µs     6221.   33.84KB     23.7
#>  2 fansi_ansi       54.12µs  57.84µs    16518.   31.42KB     21.3
#>  3 base_ansi         1.03µs   1.07µs   885885.     4.2KB     88.6
#>  4 cli_plain       141.46µs 147.92µs     6502.        0B     23.3
#>  5 fansi_plain      52.57µs  55.36µs    17473.      872B     23.5
#>  6 base_plain      972.07ns   1.02µs   919905.        0B      0  
#>  7 cli_vec_ansi    291.93µs 301.85µs     3252.   16.73KB     12.5
#>  8 fansi_vec_ansi  114.21µs 118.17µs     8232.    5.59KB     12.6
#>  9 base_vec_ansi    36.38µs  37.29µs    26482.      848B      0  
#> 10 cli_vec_plain    247.2µs  255.8µs     3824.   16.73KB     14.7
#> 11 fansi_vec_plain 107.87µs 111.73µs     8725.    5.59KB     12.5
#> 12 base_vec_plain   30.37µs  30.73µs    32061.      848B      0  
#> 13 cli_txt_ansi    153.23µs 159.65µs     6098.        0B     23.4
#> 14 fansi_txt_ansi   53.27µs   56.5µs    17099.      872B     23.5
#> 15 base_txt_ansi     1.08µs   1.13µs   848517.        0B      0  
#> 16 cli_txt_plain   143.09µs 149.56µs     6502.        0B     23.3
#> 17 fansi_txt_plain  53.16µs  56.27µs    17208.      872B     23.5
#> 18 base_txt_plain       1µs   1.04µs   898806.        0B      0
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
#>  1 cli_ansi        391.36µs 418.25µs    2374.         0B    21.5 
#>  2 fansi_ansi       97.35µs 103.52µs    9299.    97.32KB    21.2 
#>  3 base_ansi        37.89µs  40.42µs   23653.         0B    18.9 
#>  4 cli_plain        267.1µs 280.09µs    3488.         0B    12.0 
#>  5 fansi_plain      95.98µs 101.04µs    9619.       872B    12.4 
#>  6 base_plain       31.15µs  32.86µs   29479.         0B     8.85
#>  7 cli_vec_ansi     41.39ms  41.78ms      23.9    2.48KB    23.9 
#>  8 fansi_vec_ansi  237.01µs 246.09µs    3966.     7.25KB     6.19
#>  9 base_vec_ansi     2.21ms   2.29ms     434.    48.18KB    12.8 
#> 10 cli_vec_plain    28.25ms  28.43ms      35.0    2.48KB    19.1 
#> 11 fansi_vec_plain 192.52µs 199.39µs    4905.     6.42KB     6.14
#> 12 base_vec_plain     1.6ms   1.66ms     596.     47.4KB    12.7 
#> 13 cli_txt_ansi     23.95ms  24.24ms      41.2  507.59KB     6.86
#> 14 fansi_txt_ansi  227.31µs 234.77µs    4174.     6.77KB     6.13
#> 15 base_txt_ansi     1.24ms   1.27ms     774.   582.06KB     8.74
#> 16 cli_txt_plain     1.25ms   1.29ms     764.   369.84KB    11.0 
#> 17 fansi_txt_plain 178.28µs  185.7µs    5255.     2.51KB     6.13
#> 18 base_txt_plain   847.4µs 891.85µs    1103.   367.31KB    11.2
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
#>  1 cli_ansi          6.84µs   7.44µs   130099.   24.83KB    13.0 
#>  2 fansi_ansi       78.41µs  82.92µs    11654.   28.48KB    12.5 
#>  3 base_ansi       991.04ns   1.04µs   909466.        0B     0   
#>  4 cli_plain         6.74µs   7.35µs   131911.        0B    13.2 
#>  5 fansi_plain      78.67µs  83.25µs    11637.    1.98KB    10.4 
#>  6 base_plain      971.02ns   1.02µs   894341.        0B    89.4 
#>  7 cli_vec_ansi     29.13µs  30.12µs    32615.     1.7KB     3.26
#>  8 fansi_vec_ansi  114.24µs 119.02µs     8155.    8.86KB     8.35
#>  9 base_vec_ansi     6.06µs   6.37µs   152679.      848B     0   
#> 10 cli_vec_plain    24.25µs  25.17µs    38940.     1.7KB     3.89
#> 11 fansi_vec_plain 107.65µs 113.27µs     8511.    8.86KB     8.34
#> 12 base_vec_plain    5.67µs   5.98µs   163477.      848B     0   
#> 13 cli_txt_ansi       6.7µs   7.29µs   130987.        0B    26.2 
#> 14 fansi_txt_ansi   77.95µs   82.8µs    11676.    1.98KB    10.4 
#> 15 base_txt_ansi     5.14µs   5.21µs   187405.        0B     0   
#> 16 cli_txt_plain     7.43µs   8.09µs   120032.        0B    24.0 
#> 17 fansi_txt_plain  78.57µs  82.72µs    11699.    1.98KB    10.4 
#> 18 base_txt_plain    3.37µs   3.43µs   281894.        0B     0
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
#>  1 cli_ansi          105µs 110.83µs    8690.    11.88KB     8.21
#>  2 base_ansi        1.28µs   1.33µs  719833.         0B     0   
#>  3 cli_plain       84.21µs  88.31µs   10909.     8.73KB     8.20
#>  4 base_plain     981.03ns   1.02µs  926816.         0B     0   
#>  5 cli_vec_ansi     4.06ms    4.2ms     238.   838.77KB    15.6 
#>  6 base_vec_ansi   71.86µs  72.11µs   13701.       848B     0   
#>  7 cli_vec_plain    2.27ms   2.33ms     428.    816.9KB    15.1 
#>  8 base_vec_plain  43.06µs  43.64µs   22615.       848B     0   
#>  9 cli_txt_ansi    13.46ms  13.58ms      73.6  114.42KB     4.21
#> 10 base_txt_ansi    73.7µs  74.03µs   13290.         0B     0   
#> 11 cli_txt_plain  258.23µs 265.69µs    3690.    18.16KB     2.01
#> 12 base_txt_plain  40.97µs  41.63µs   23797.         0B     0
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
#>  1 cli_ansi        105.6µs  110.6µs     8753.        0B    12.4 
#>  2 base_ansi        16.2µs     17µs    57258.        0B    11.5 
#>  3 cli_plain       104.2µs  108.8µs     8893.        0B    12.4 
#>  4 base_plain       15.9µs   16.8µs    57407.        0B    11.5 
#>  5 cli_vec_ansi    193.5µs  207.1µs     4689.     7.2KB     6.21
#>  6 base_vec_ansi      54µs   60.8µs    16382.    1.66KB     4.06
#>  7 cli_vec_plain   180.3µs  191.9µs     5094.     7.2KB     8.26
#>  8 base_vec_plain   49.1µs   55.7µs    17955.    1.66KB     2.02
#>  9 cli_txt_ansi    171.6µs  177.7µs     5486.        0B     8.20
#> 10 base_txt_ansi    37.8µs     39µs    24676.        0B     4.94
#> 11 cli_txt_plain   154.9µs  160.7µs     6001.        0B    10.3 
#> 12 base_txt_plain   33.4µs   34.5µs    28325.        0B     5.67
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
#> 1 cli          8.01µs   8.65µs   111421.        0B    11.1 
#> 2 base       812.11ns 872.07ns  1051183.        0B     0   
#> 3 cli_vec     23.95µs  24.83µs    39311.      448B     3.93
#> 4 base_vec    11.68µs  11.91µs    82439.      448B     8.24
#> 5 cli_txt      24.3µs   25.1µs    39076.        0B     3.91
#> 6 base_txt    12.31µs  12.39µs    79448.        0B     0
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
#> 1 cli          7.96µs   8.59µs   113254.        0B    11.3 
#> 2 base         1.25µs   1.32µs   716467.        0B     0   
#> 3 cli_vec     30.67µs  31.77µs    30842.      448B     6.17
#> 4 base_vec    51.41µs  51.97µs    18997.      448B     0   
#> 5 cli_txt     31.33µs  32.63µs    30085.        0B     3.01
#> 6 base_txt    88.69µs  89.34µs    11068.        0B     0
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
#> 1 cli          8.59µs   9.22µs   105529.        0B    21.1 
#> 2 base       812.11ns 881.03ns  1071728.        0B     0   
#> 3 cli_vec     19.71µs  20.46µs    47872.      448B     4.79
#> 4 base_vec    11.63µs   11.9µs    82772.      448B     0   
#> 5 cli_txt     20.11µs  20.78µs    47157.        0B     9.43
#> 6 base_txt     12.3µs  12.39µs    79442.        0B     0
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
#> 1 cli          6.31µs   6.93µs   139250.    22.1KB    13.9 
#> 2 base         1.01µs   1.06µs   864647.        0B    86.5 
#> 3 cli_vec     30.55µs  31.43µs    31274.     1.7KB     3.13
#> 4 base_vec     8.31µs   8.59µs   114374.      848B     0   
#> 5 cli_txt      6.36µs    6.9µs   140886.        0B    14.1 
#> 6 base_txt     5.43µs    5.5µs   177799.        0B     0
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
#>  date     2026-04-08
#>  pandoc   3.1.11 @ /opt/hostedtoolcache/pandoc/3.1.11/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.10.0     2026-01-26 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.5.9000 2026-04-08 [1] local
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
