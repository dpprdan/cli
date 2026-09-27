# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x557554fb4cf0\>
\<environment: 0x557555ae08f0\>

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
#> 1 ansi        30.11µs  34.16µs    28616.    99.6KB     28.6
#> 2 plain       29.69µs  34.03µs    28505.        0B     31.4
#> 3 base         8.45µs   9.94µs    97617.    48.6KB     19.5
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
#> 1 ansi        31.59µs   35.9µs    27138.        0B     32.6
#> 2 plain       31.63µs   35.9µs    27090.        0B     32.5
#> 3 base         9.89µs   11.6µs    83625.        0B     33.5
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
#> 1 ansi        79.22µs  86.94µs    11214.   77.03KB     23.7
#> 2 plain       60.61µs  66.68µs    14599.    8.91KB     21.4
#> 3 base         1.44µs   1.68µs   563334.        0B      0
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
#> 1 ansi          224µs    245µs     4016.   33.24KB     30.9
#> 2 plain         208µs    246µs     3728.    1.09KB     23.4
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
#>  1 cli_ansi          4.27µs   4.92µs   193582.    9.27KB     19.4
#>  2 fansi_ansi       21.22µs  23.84µs    40583.    4.18KB     16.2
#>  3 cli_plain         4.25µs   4.83µs   200060.        0B     20.0
#>  4 fansi_plain      21.14µs  23.48µs    41488.      688B     20.8
#>  5 cli_vec_ansi      5.32µs   6.04µs   160216.      448B     16.0
#>  6 fansi_vec_ansi      28µs  31.17µs    31231.    5.02KB     12.5
#>  7 cli_vec_plain     5.86µs   6.55µs   147969.      448B     14.8
#>  8 fansi_vec_plain  27.33µs  30.48µs    32087.    5.02KB     12.8
#>  9 cli_txt_ansi      4.27µs   4.87µs   195800.        0B     19.6
#> 10 fansi_txt_ansi   21.04µs  23.77µs    41046.      688B     20.5
#> 11 cli_txt_plain     5.02µs   5.65µs   170542.        0B     17.1
#> 12 fansi_txt_plain  27.54µs  30.73µs    31432.    5.02KB     12.6
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
#> 1 cli          43.1µs   45.2µs    21376.    22.7KB     6.41
#> 2 fansi        86.2µs   91.4µs    10734.    55.3KB     6.13
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
#>  1 cli_ansi          5.06µs   5.84µs   163991.        0B    16.4 
#>  2 fansi_ansi       57.25µs  63.06µs    15511.   38.84KB    14.7 
#>  3 base_ansi       701.05ns 771.13ns  1183611.        0B     0   
#>  4 cli_plain         4.98µs   5.76µs   166855.        0B    16.7 
#>  5 fansi_plain      57.13µs  62.84µs    15468.      688B    12.5 
#>  6 base_plain      631.09ns 711.07ns  1222350.        0B     0   
#>  7 cli_vec_ansi     23.34µs  24.38µs    40242.      448B     4.02
#>  8 fansi_vec_ansi   75.26µs  81.63µs    11906.    5.02KB    10.5 
#>  9 base_vec_ansi    15.83µs  15.95µs    61662.      448B     0   
#> 10 cli_vec_plain     21.6µs   22.8µs    42437.      448B     4.24
#> 11 fansi_vec_plain  66.72µs  73.14µs    12269.    5.02KB    10.7 
#> 12 base_vec_plain    9.11µs   9.19µs   106613.      448B     0   
#> 13 cli_txt_ansi     23.41µs  24.29µs    40504.        0B     4.05
#> 14 fansi_txt_ansi   67.56µs  73.29µs    13268.      688B    12.5 
#> 15 base_txt_ansi     15.8µs  15.91µs    61768.        0B     0   
#> 16 cli_txt_plain    21.35µs  22.73µs    43356.        0B     4.34
#> 17 fansi_txt_plain  58.99µs  65.15µs    14955.      688B    12.5 
#> 18 base_txt_plain    9.13µs   9.23µs   106084.        0B    10.6
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
#>  1 cli_ansi          6.23µs   7.13µs   136202.        0B    13.6 
#>  2 fansi_ansi       57.18µs  63.29µs    15321.      688B    12.5 
#>  3 base_ansi       971.02ns   1.05µs   853903.        0B    85.4 
#>  4 cli_plain         6.14µs      7µs   135334.        0B    13.5 
#>  5 fansi_plain      57.43µs  63.11µs    15521.      688B    12.5 
#>  6 base_plain      781.15ns 881.03ns  1023828.        0B     0   
#>  7 cli_vec_ansi     26.23µs   27.4µs    35825.      448B     7.17
#>  8 fansi_vec_ansi   76.54µs  82.84µs    11827.    5.02KB    10.5 
#>  9 base_vec_ansi    35.01µs  35.97µs    27472.      448B     0   
#> 10 cli_vec_plain    24.93µs  26.03µs    37772.      448B     3.78
#> 11 fansi_vec_plain  68.94µs  74.61µs    13098.    5.02KB    10.6 
#> 12 base_vec_plain    18.3µs  18.54µs    53230.      448B     0   
#> 13 cli_txt_ansi     26.74µs  27.76µs    35118.        0B     7.03
#> 14 fansi_txt_ansi   69.39µs  75.54µs    12985.      688B    10.3 
#> 15 base_txt_ansi    36.41µs  37.42µs    26513.        0B     0   
#> 16 cli_txt_plain    24.84µs  25.85µs    38070.        0B     7.62
#> 17 fansi_txt_plain  61.28µs  67.44µs    14551.      688B    12.5 
#> 18 base_txt_plain    19.5µs  19.73µs    50059.        0B     0
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
#> 1 cli_ansi        4.91µs   5.59µs   172883.        0B    17.3 
#> 2 cli_plain       4.62µs   5.28µs   183242.        0B    18.3 
#> 3 cli_vec_ansi   23.68µs  24.48µs    40291.      848B     4.03
#> 4 cli_vec_plain   7.83µs   8.42µs   115451.      848B    11.5 
#> 5 cli_txt_ansi   23.21µs   24.7µs    39792.        0B     0   
#> 6 cli_txt_plain    5.4µs   5.86µs   167185.        0B    16.7
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
#>  1 cli_ansi          18.6µs     20µs    48979.        0B     19.6
#>  2 fansi_ansi        19.3µs   21.1µs    46374.    7.24KB     18.6
#>  3 cli_plain         18.5µs   19.9µs    49019.        0B     19.6
#>  4 fansi_plain       19.3µs   20.9µs    46631.      688B     18.7
#>  5 cli_vec_ansi        26µs   28.6µs    34287.      848B     13.7
#>  6 fansi_vec_ansi    40.1µs   42.9µs    22864.    5.41KB     11.4
#>  7 cli_vec_plain       21µs   22.9µs    42612.      848B     17.1
#>  8 fansi_vec_plain     27µs   29.5µs    33198.    4.59KB     13.3
#>  9 cli_txt_ansi      25.7µs   27.6µs    35394.        0B     14.2
#> 10 fansi_txt_ansi    32.6µs   34.7µs    28124.    5.12KB     11.3
#> 11 cli_txt_plain     19.2µs   21.2µs    46207.        0B     18.5
#> 12 fansi_txt_plain   20.2µs   22.4µs    43648.      688B     17.5
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
#>  1 cli_ansi        104.39µs 112.17µs     8705.  104.86KB    14.6 
#>  2 fansi_ansi       83.76µs  93.34µs    10534.  106.35KB    14.9 
#>  3 base_ansi         3.12µs   3.48µs   279564.      224B     0   
#>  4 cli_plain       102.52µs 111.55µs     8728.    8.09KB    16.9 
#>  5 fansi_plain      83.68µs     93µs    10609.    9.62KB    14.8 
#>  6 base_plain        2.66µs   2.94µs   327136.        0B     0   
#>  7 cli_vec_ansi      5.17ms   5.49ms      183.  823.77KB    18.5 
#>  8 fansi_vec_ansi  812.13µs 857.83µs     1140.  846.81KB    22.1 
#>  9 base_vec_ansi   122.08µs 126.57µs     7696.    22.7KB     4.12
#> 10 cli_vec_plain     5.24ms   5.45ms      183.  823.77KB    16.4 
#> 11 fansi_vec_plain    776µs 817.16µs     1213.  845.98KB    24.8 
#> 12 base_vec_plain   83.04µs  87.64µs    11257.      848B     4.06
#> 13 cli_txt_ansi      2.58ms   2.77ms      361.    63.6KB     2.02
#> 14 fansi_txt_ansi    1.26ms   1.29ms      775.   35.05KB     0   
#> 15 base_txt_ansi   108.73µs 117.29µs     8542.   18.47KB     2.51
#> 16 cli_txt_plain     2.01ms   2.04ms      487.    63.6KB     2.02
#> 17 fansi_txt_plain 408.01µs 427.33µs     2328.    30.6KB     2.02
#> 18 base_txt_plain   69.92µs  71.93µs    13693.   11.05KB     4.07
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
#>  1 cli_ansi          96.9µs  102.8µs     9533.   33.84KB    19.0 
#>  2 fansi_ansi        37.1µs   40.6µs    24038.   31.42KB    16.8 
#>  3 base_ansi        811.1ns    891ns  1059028.     4.2KB     0   
#>  4 cli_plain         98.4µs  106.9µs     9231.        0B    17.1 
#>  5 fansi_plain       37.8µs   42.2µs    23337.      872B    18.7 
#>  6 base_plain         751ns  831.1ns  1116949.        0B     0   
#>  7 cli_vec_ansi     195.8µs  206.8µs     4785.   16.73KB     8.30
#>  8 fansi_vec_ansi    89.1µs   93.7µs    10519.    5.59KB     8.30
#>  9 base_vec_ansi     28.8µs   29.2µs    33660.      848B     0   
#> 10 cli_vec_plain    167.3µs  175.9µs     5165.   16.73KB    10.5 
#> 11 fansi_vec_plain   82.4µs     87µs    11329.    5.59KB    10.5 
#> 12 base_vec_plain      24µs   24.3µs    40604.      848B     0   
#> 13 cli_txt_ansi     105.6µs    113µs     8692.        0B    16.7 
#> 14 fansi_txt_ansi    37.9µs   42.2µs    23301.      872B    16.3 
#> 15 base_txt_ansi    841.1ns  922.1ns   978205.        0B     0   
#> 16 cli_txt_plain    100.1µs  107.7µs     9165.        0B    18.9 
#> 17 fansi_txt_plain   37.9µs   42.1µs    22959.      872B    16.1 
#> 18 base_txt_plain   781.1ns  861.1ns  1079095.        0B     0
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
#>  1 cli_ansi        273.01µs 296.16µs    3349.     6.18KB    16.9 
#>  2 fansi_ansi       68.02µs  75.05µs   13103.    97.33KB    14.6 
#>  3 base_ansi        24.52µs  27.02µs   35777.         0B    17.9 
#>  4 cli_plain       173.38µs 185.55µs    5244.         0B    16.8 
#>  5 fansi_plain      67.78µs  75.13µs   13003.       872B    14.7 
#>  6 base_plain       19.79µs  21.86µs   44562.         0B    17.8 
#>  7 cli_vec_ansi     28.66ms  29.01ms      34.4   94.67KB    30.6 
#>  8 fansi_vec_ansi  182.39µs 189.25µs    5181.     7.25KB     6.15
#>  9 base_vec_ansi      1.7ms   1.76ms     564.    48.18KB    17.4 
#> 10 cli_vec_plain     18.4ms   18.7ms      53.3    2.48KB    23.7 
#> 11 fansi_vec_plain 145.78µs 154.26µs    6375.     6.42KB    10.4 
#> 12 base_vec_plain    1.26ms   1.32ms     752.     47.4KB    15.0 
#> 13 cli_txt_ansi     22.48ms   22.7ms      44.1    4.27MB     6.96
#> 14 fansi_txt_ansi   181.4µs 190.66µs    5175.     6.77KB     6.13
#> 15 base_txt_ansi     1.01ms   1.06ms     929.   582.06KB    11.4 
#> 16 cli_txt_plain     1.03ms   1.06ms     923.   369.84KB    11.2 
#> 17 fansi_txt_plain 141.49µs 149.33µs    6594.     2.51KB     8.30
#> 18 base_txt_plain  687.09µs  724.6µs    1348.   367.31KB    13.7
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
#>  1 cli_ansi          5.04µs   5.83µs   165105.   25.09KB    16.5 
#>  2 fansi_ansi       55.72µs  61.88µs    15827.   28.48KB    14.7 
#>  3 base_ansi       821.08ns 901.05ns  1015778.        0B     0   
#>  4 cli_plain         5.01µs    5.8µs   163038.        0B    32.6 
#>  5 fansi_plain      55.18µs  61.82µs    15796.    1.98KB    14.7 
#>  6 base_plain      781.03ns 871.02ns  1051432.        0B     0   
#>  7 cli_vec_ansi     20.93µs  22.31µs    43998.     1.7KB     4.40
#>  8 fansi_vec_ansi   84.56µs   90.6µs    10813.    8.86KB    10.7 
#>  9 base_vec_ansi     5.13µs   5.42µs   180400.      848B     0   
#> 10 cli_vec_plain    18.08µs  19.32µs    50742.     1.7KB     5.07
#> 11 fansi_vec_plain  80.48µs  86.68µs    11229.    8.86KB    10.6 
#> 12 base_vec_plain       5µs   5.19µs   188374.      848B     0   
#> 13 cli_txt_ansi      5.03µs   5.82µs   158288.        0B    31.7 
#> 14 fansi_txt_ansi   56.31µs  63.23µs    13496.    1.98KB    12.6 
#> 15 base_txt_ansi      5.5µs   5.62µs   174152.        0B     0   
#> 16 cli_txt_plain     5.72µs   6.56µs   147410.        0B    14.7 
#> 17 fansi_txt_plain  54.27µs  57.74µs    16733.    1.98KB    15.4 
#> 18 base_txt_plain    3.44µs   3.51µs   276408.        0B     0
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
#>  1 cli_ansi        72.55µs  77.75µs   12587.     12.1KB    12.5 
#>  2 base_ansi           1µs   1.06µs  904686.         0B     0   
#>  3 cli_plain       56.89µs  60.77µs   16103.     8.91KB    12.5 
#>  4 base_plain     771.02ns 832.14ns 1148625.         0B     0   
#>  5 cli_vec_ansi     3.27ms   3.46ms     282.   838.95KB    15.7 
#>  6 base_vec_ansi   58.54µs   59.1µs   16741.       848B     0   
#>  7 cli_vec_plain    1.87ms   1.95ms     511.   817.08KB    17.5 
#>  8 base_vec_plain  36.08µs  36.66µs   27013.       848B     2.70
#>  9 cli_txt_ansi    12.53ms  12.64ms      78.9   114.6KB     2.02
#> 10 base_txt_ansi   56.52µs  59.26µs   16711.         0B     0   
#> 11 cli_txt_plain  229.92µs 240.69µs    4093.    18.34KB     4.05
#> 12 base_txt_plain  33.19µs  33.81µs   29248.         0B     0
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
#>  1 cli_ansi         69.4µs     75µs    13044.        0B    19.0 
#>  2 base_ansi        11.8µs     13µs    74496.        0B    14.9 
#>  3 cli_plain        69.1µs   74.8µs    12958.        0B    18.9 
#>  4 base_plain       11.6µs     13µs    74200.        0B    14.8 
#>  5 cli_vec_ansi      154µs  161.1µs     6104.     7.2KB     8.26
#>  6 base_vec_ansi    44.5µs   50.8µs    19533.    1.66KB     4.12
#>  7 cli_vec_plain   142.2µs  150.6µs     6548.     7.2KB     8.27
#>  8 base_vec_plain   38.9µs   44.6µs    22076.    1.66KB     4.42
#>  9 cli_txt_ansi    133.4µs  139.7µs     7024.        0B    10.3 
#> 10 base_txt_ansi      32µs   33.5µs    29331.        0B     5.87
#> 11 cli_txt_plain   121.4µs  127.7µs     7687.        0B    10.3 
#> 12 base_txt_plain   26.9µs   28.3µs    34727.        0B     6.95
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
#> 1 cli          5.86µs   6.73µs   143211.        0B    14.3 
#> 2 base       650.99ns 751.11ns  1171519.        0B     0   
#> 3 cli_vec     17.93µs  19.09µs    51164.      448B    10.2 
#> 4 base_vec     9.45µs   9.82µs   100399.      448B     0   
#> 5 cli_txt      17.9µs  18.81µs    52251.        0B     5.23
#> 6 base_txt    10.22µs  10.36µs    94823.        0B     0
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
#> 1 cli          5.91µs   6.77µs   142614.        0B    14.3 
#> 2 base         1.02µs   1.13µs   796745.        0B    79.7 
#> 3 cli_vec     22.76µs  24.07µs    40947.      448B     4.10
#> 4 base_vec    41.85µs  42.35µs    23361.      448B     0   
#> 5 cli_txt     22.94µs  23.96µs    41082.        0B     4.11
#> 6 base_txt    73.47µs  74.43µs    13306.        0B     0
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
#> 1 cli          6.38µs   7.33µs   131102.        0B    26.2 
#> 2 base       661.12ns 751.11ns  1181961.        0B     0   
#> 3 cli_vec     15.42µs  16.67µs    58797.      448B     5.88
#> 4 base_vec     9.42µs   9.73µs   100833.      448B     0   
#> 5 cli_txt     15.87µs  16.91µs    57894.        0B    11.6 
#> 6 base_txt    10.19µs  10.34µs    95257.        0B     0
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
#> 1 cli          4.74µs   5.51µs   174327.    22.2KB    17.4 
#> 2 base       801.05ns 881.15ns  1030549.        0B     0   
#> 3 cli_vec     22.68µs  23.77µs    41044.     1.7KB     8.21
#> 4 base_vec      6.4µs   6.71µs   143775.      848B     0   
#> 5 cli_txt      4.73µs   5.55µs   117038.        0B    11.7 
#> 6 base_txt     4.05µs   4.29µs   155579.        0B     0
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
#>  date     2026-09-27
#>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.12.0     2026-08-04 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.6.9000 2026-09-27 [1] local
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
