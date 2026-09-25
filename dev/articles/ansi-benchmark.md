# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x564a1614ef00\>
\<environment: 0x564a16c7aa30\>

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
#> 1 ansi        26.79µs  32.62µs    29825.    99.6KB     29.9
#> 2 plain       26.62µs  32.49µs    29884.        0B     32.9
#> 3 base         7.82µs   9.53µs   101455.    48.6KB     20.3
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
#> 1 ansi        27.96µs   34.4µs    28238.        0B     33.9
#> 2 plain       27.25µs     34µs    28409.        0B     34.1
#> 3 base         8.88µs   10.8µs    88929.        0B     35.6
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
#> 1 ansi        70.36µs  82.31µs    11805.   77.03KB     23.4
#> 2 plain       54.28µs   63.7µs    15249.    8.91KB     23.4
#> 3 base         1.49µs   1.59µs   567987.        0B      0
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
#> 1 ansi          203µs    236µs     4157.   33.24KB     30.4
#> 2 plain         191µs    229µs     4309.    1.09KB     23.1
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
#>  1 cli_ansi          3.85µs   4.51µs   204731.    9.27KB     20.5
#>  2 fansi_ansi       19.81µs  22.72µs    42540.    4.18KB     17.0
#>  3 cli_plain         3.85µs   4.49µs   208215.        0B     20.8
#>  4 fansi_plain      19.51µs  22.56µs    42821.      688B     21.4
#>  5 cli_vec_ansi      5.11µs   5.91µs   160556.      448B     16.1
#>  6 fansi_vec_ansi   28.71µs  32.08µs    30377.    5.02KB     12.2
#>  7 cli_vec_plain      5.6µs   6.33µs   150019.      448B     15.0
#>  8 fansi_vec_plain  27.04µs   30.8µs    31649.    5.02KB     12.7
#>  9 cli_txt_ansi      3.83µs   4.54µs   204238.        0B     20.4
#> 10 fansi_txt_ansi   19.86µs  22.88µs    42352.      688B     21.2
#> 11 cli_txt_plain     4.59µs   5.28µs   178636.        0B      0  
#> 12 fansi_txt_plain  26.76µs  30.74µs    31590.    5.02KB     15.8
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
#> 1 cli          46.5µs   48.9µs    20169.    22.7KB     6.11
#> 2 fansi        89.1µs   95.5µs    10338.    55.3KB     6.12
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
#>  1 cli_ansi          4.64µs   5.39µs   174625.        0B    17.5 
#>  2 fansi_ansi       49.99µs  57.38µs    16978.   38.84KB    14.6 
#>  3 base_ansi       622.12ns 645.06ns  1286255.        0B     0   
#>  4 cli_plain         4.62µs   5.29µs   177117.        0B    17.7 
#>  5 fansi_plain       49.3µs  57.34µs    17005.      688B    14.6 
#>  6 base_plain      560.07ns 582.08ns  1396877.        0B     0   
#>  7 cli_vec_ansi     20.22µs  23.32µs    42303.      448B     4.23
#>  8 fansi_vec_ansi   67.77µs  77.81µs    12620.    5.02KB    12.6 
#>  9 base_vec_ansi    13.31µs  15.48µs    63835.      448B     0   
#> 10 cli_vec_plain       19µs  20.73µs    46937.      448B     4.69
#> 11 fansi_vec_plain  60.35µs  69.57µs    14074.    5.02KB    10.4 
#> 12 base_vec_plain    8.03µs   9.09µs   107616.      448B    10.8 
#> 13 cli_txt_ansi     20.25µs  23.45µs    42181.        0B     4.22
#> 14 fansi_txt_ansi   59.62µs  68.32µs    14242.      688B    12.4 
#> 15 base_txt_ansi    13.63µs  15.67µs    63280.        0B     0   
#> 16 cli_txt_plain    18.08µs  19.18µs    50957.        0B     5.10
#> 17 fansi_txt_plain  52.36µs   60.2µs    16255.      688B    12.4 
#> 18 base_txt_plain    7.99µs   8.66µs   113517.        0B    11.4
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
#>  1 cli_ansi          5.55µs   6.55µs   144807.        0B    14.5 
#>  2 fansi_ansi       49.92µs  57.54µs    17004.      688B    14.6 
#>  3 base_ansi       886.97ns 937.03ns   898261.        0B     0   
#>  4 cli_plain         5.57µs   6.49µs   145301.        0B    29.1 
#>  5 fansi_plain      50.28µs  57.58µs    16942.      688B    14.6 
#>  6 base_plain      700.94ns 740.05ns  1181184.        0B     0   
#>  7 cli_vec_ansi     23.89µs  26.78µs    36809.      448B     3.68
#>  8 fansi_vec_ansi   69.39µs  79.04µs    12438.    5.02KB    10.5 
#>  9 base_vec_ansi    34.57µs  36.62µs    27065.      448B     0   
#> 10 cli_vec_plain    23.09µs  24.94µs    39303.      448B     7.86
#> 11 fansi_vec_plain  61.85µs  71.22µs    13742.    5.02KB    10.4 
#> 12 base_vec_plain   18.49µs  19.04µs    51953.      448B     0   
#> 13 cli_txt_ansi     23.82µs  26.56µs    36793.        0B     7.36
#> 14 fansi_txt_ansi   62.11µs  70.01µs    13988.      688B    12.4 
#> 15 base_txt_ansi       38µs  39.66µs    25052.        0B     0   
#> 16 cli_txt_plain    22.63µs  24.49µs    40189.        0B     4.02
#> 17 fansi_txt_plain  53.38µs  58.17µs    16344.      688B    15.3 
#> 18 base_txt_plain   20.95µs  21.58µs    45920.        0B     0
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
#> 1 cli_ansi        4.47µs   4.93µs   194006.        0B    19.4 
#> 2 cli_plain       4.25µs   4.71µs   202388.        0B    20.2 
#> 3 cli_vec_ansi   26.33µs  27.55µs    35851.      848B     3.59
#> 4 cli_vec_plain   7.56µs   8.18µs   119758.      848B     0   
#> 5 cli_txt_ansi   25.52µs  27.03µs    36474.        0B     3.65
#> 6 cli_txt_plain   5.02µs   5.46µs   177068.        0B    17.7
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
#>  1 cli_ansi          17.2µs   18.7µs    51195.        0B    25.6 
#>  2 fansi_ansi        18.3µs     20µs    48186.    7.24KB    19.3 
#>  3 cli_plain         17.2µs   19.2µs    49285.        0B    19.7 
#>  4 fansi_plain         18µs   20.9µs    46107.      688B    18.5 
#>  5 cli_vec_ansi      25.7µs   29.2µs    33444.      848B    13.4 
#>  6 fansi_vec_ansi    41.7µs   45.7µs    21481.    5.41KB     8.60
#>  7 cli_vec_plain       20µs   22.9µs    42301.      848B    21.2 
#>  8 fansi_vec_plain   26.9µs   30.3µs    32034.    4.59KB    12.8 
#>  9 cli_txt_ansi      24.9µs   28.7µs    34094.        0B    13.6 
#> 10 fansi_txt_ansi    32.5µs     36µs    27140.    5.12KB    10.9 
#> 11 cli_txt_plain     18.1µs   21.3µs    45731.        0B    18.3 
#> 12 fansi_txt_plain   19.1µs   22.1µs    43590.      688B    17.4
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
#>  1 cli_ansi         92.16µs 107.86µs     9093.  104.86KB    14.7 
#>  2 fansi_ansi       77.05µs  90.79µs    10834.  106.35KB    16.9 
#>  3 base_ansi         3.04µs    3.5µs   273816.      224B     0   
#>  4 cli_plain        90.65µs 106.91µs     9149.    8.09KB    16.8 
#>  5 fansi_plain      76.15µs  90.01µs    10855.    9.62KB    14.7 
#>  6 base_plain        2.69µs   3.07µs   299341.        0B    29.9 
#>  7 cli_vec_ansi      4.77ms    5.2ms      195.  823.77KB    18.3 
#>  8 fansi_vec_ansi   795.9µs 853.98µs     1150.  846.81KB    22.4 
#>  9 base_vec_ansi   112.39µs 124.53µs     7890.    22.7KB     4.15
#> 10 cli_vec_plain     4.79ms   5.15ms      195.  823.77KB    18.6 
#> 11 fansi_vec_plain 742.56µs 791.38µs     1220.  845.98KB    24.8 
#> 12 base_vec_plain   78.16µs  87.57µs    11247.      848B     4.06
#> 13 cli_txt_ansi      2.44ms   2.52ms      395.    63.6KB     0   
#> 14 fansi_txt_ansi    1.17ms   1.19ms      827.   35.05KB     2.02
#> 15 base_txt_ansi    96.35µs 111.36µs     8985.   18.47KB     2.02
#> 16 cli_txt_plain     1.66ms   1.69ms      586.    63.6KB     2.02
#> 17 fansi_txt_plain 368.59µs 384.54µs     2589.    30.6KB     4.09
#> 18 base_txt_plain   64.06µs  73.94µs    13439.   11.05KB     2.02
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
#>  1 cli_ansi          89.4µs   94.9µs    10053.   33.84KB    19.3 
#>  2 fansi_ansi        34.7µs     40µs    24322.   31.42KB    17.0 
#>  3 base_ansi          748ns  783.9ns  1126099.     4.2KB     0   
#>  4 cli_plain         88.3µs  102.9µs     9189.        0B    18.9 
#>  5 fansi_plain       34.5µs   39.9µs    24359.      872B    17.1 
#>  6 base_plain         695ns    732ns  1186483.        0B     0   
#>  7 cli_vec_ansi     194.6µs  210.6µs     4710.   16.73KB    10.4 
#>  8 fansi_vec_ansi      83µs   89.2µs    11050.    5.59KB     8.27
#>  9 base_vec_ansi     26.8µs   30.3µs    32970.      848B     0   
#> 10 cli_vec_plain    159.8µs    174µs     5692.   16.73KB    10.5 
#> 11 fansi_vec_plain   77.1µs     83µs    11861.    5.59KB    10.5 
#> 12 base_vec_plain    22.1µs   24.5µs    40364.      848B     0   
#> 13 cli_txt_ansi      98.1µs  112.5µs     8788.        0B    16.7 
#> 14 fansi_txt_ansi    34.9µs   40.1µs    24299.      872B    17.0 
#> 15 base_txt_ansi    765.1ns  802.1ns  1071160.        0B     0   
#> 16 cli_txt_plain     90.6µs  104.5µs     9437.        0B    18.9 
#> 17 fansi_txt_plain   34.5µs   40.2µs    24281.      872B    17.0 
#> 18 base_txt_plain   705.1ns  740.2ns  1150754.        0B     0
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
#>  1 cli_ansi        254.24µs 295.68µs    3363.     6.18KB    14.9 
#>  2 fansi_ansi       61.77µs  70.91µs   13711.    97.33KB    16.7 
#>  3 base_ansi        22.22µs  25.12µs   38337.         0B    19.2 
#>  4 cli_plain       158.13µs 179.41µs    5480.         0B    17.3 
#>  5 fansi_plain      60.47µs  64.24µs   14987.       872B    16.7 
#>  6 base_plain       17.97µs  19.09µs   50451.         0B    20.2 
#>  7 cli_vec_ansi     27.04ms  27.29ms      36.6   94.67KB    29.2 
#>  8 fansi_vec_ansi  175.91µs 187.39µs    5280.     7.25KB     8.33
#>  9 base_vec_ansi      1.6ms   1.76ms     572.    48.18KB    17.3 
#> 10 cli_vec_plain     17.1ms  18.42ms      55.2    2.48KB    23.2 
#> 11 fansi_vec_plain    142µs 151.78µs    6468.     6.42KB    10.4 
#> 12 base_vec_plain    1.18ms   1.28ms     780.     47.4KB    14.9 
#> 13 cli_txt_ansi     23.04ms   24.3ms      41.7    4.27MB     6.95
#> 14 fansi_txt_ansi  166.73µs 177.96µs    5538.     6.77KB     8.21
#> 15 base_txt_ansi   985.01µs   1.07ms     923.   582.06KB    11.2 
#> 16 cli_txt_plain    996.1µs   1.06ms     924.   369.84KB    11.0 
#> 17 fansi_txt_plain 128.28µs 139.62µs    7050.     2.51KB     8.24
#> 18 base_txt_plain   661.8µs 720.96µs    1360.   367.31KB    13.4
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
#>  1 cli_ansi          4.48µs   5.43µs   169939.   25.09KB    17.0 
#>  2 fansi_ansi        50.7µs  58.26µs    16601.   28.48KB    16.9 
#>  3 base_ansi       689.06ns 736.09ns  1188377.        0B     0   
#>  4 cli_plain         4.44µs   5.34µs   175661.        0B    17.6 
#>  5 fansi_plain      50.73µs  57.85µs    16745.    1.98KB    14.7 
#>  6 base_plain      661.94ns 745.06ns  1128818.        0B   113.  
#>  7 cli_vec_ansi     21.46µs  23.66µs    41526.     1.7KB     4.15
#>  8 fansi_vec_ansi   80.16µs  87.83µs    11071.    8.86KB    10.5 
#>  9 base_vec_ansi     5.54µs   5.88µs   166740.      848B     0   
#> 10 cli_vec_plain    17.32µs  19.37µs    50469.     1.7KB     5.05
#> 11 fansi_vec_plain  75.32µs  84.53µs    11485.    8.86KB    10.6 
#> 12 base_vec_plain    5.05µs    5.5µs   174941.      848B    17.5 
#> 13 cli_txt_ansi       4.5µs   5.35µs   173606.        0B    17.4 
#> 14 fansi_txt_ansi    50.6µs  57.84µs    16769.    1.98KB    14.7 
#> 15 base_txt_ansi     4.72µs   5.56µs   177508.        0B    17.8 
#> 16 cli_txt_plain     5.18µs   6.04µs   155963.        0B    15.6 
#> 17 fansi_txt_plain  50.43µs  57.64µs    16854.    1.98KB    15.4 
#> 18 base_txt_plain    2.88µs   3.47µs   277196.        0B     0
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
#>  1 cli_ansi        64.98µs  71.36µs   13606.     12.1KB    12.4 
#>  2 base_ansi      966.95ns 996.98ns  968977.         0B     0   
#>  3 cli_plain       52.05µs  56.52µs   17143.     8.91KB    12.4 
#>  4 base_plain        717ns 735.98ns 1285377.         0B     0   
#>  5 cli_vec_ansi     3.18ms   3.28ms     302.   838.95KB    17.9 
#>  6 base_vec_ansi   58.51µs  59.85µs   16551.       848B     2.01
#>  7 cli_vec_plain    1.85ms   1.99ms     503.   817.08KB    17.4 
#>  8 base_vec_plain  34.84µs  37.01µs   26792.       848B     0   
#>  9 cli_txt_ansi    12.61ms  12.87ms      77.7   114.6KB     2.05
#> 10 base_txt_ansi   58.18µs  61.41µs   16181.         0B     0   
#> 11 cli_txt_plain  218.47µs 231.62µs    4266.    18.34KB     4.05
#> 12 base_txt_plain  31.14µs  32.46µs   30531.         0B     0
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
#>  1 cli_ansi         62.9µs   72.4µs    13416.        0B    18.9 
#>  2 base_ansi          11µs   12.7µs    75356.        0B    15.1 
#>  3 cli_plain          63µs   72.4µs    13271.        0B    18.8 
#>  4 base_plain       10.9µs   12.7µs    75833.        0B    15.2 
#>  5 cli_vec_ansi    146.7µs  159.8µs     6140.     7.2KB     8.23
#>  6 base_vec_ansi    43.7µs   49.3µs    19992.    1.66KB     4.06
#>  7 cli_vec_plain   135.5µs  147.9µs     6670.     7.2KB    10.5 
#>  8 base_vec_plain   37.5µs   43.4µs    22783.    1.66KB     4.56
#>  9 cli_txt_ansi      129µs  139.9µs     7066.        0B     8.17
#> 10 base_txt_ansi    31.6µs   34.5µs    28466.        0B     8.54
#> 11 cli_txt_plain   113.3µs  124.4µs     7931.        0B    10.3 
#> 12 base_txt_plain   27.1µs   29.3µs    33502.        0B     6.70
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
#> 1 cli          5.38µs   6.35µs   148293.        0B    14.8 
#> 2 base       593.02ns 627.01ns  1288302.        0B     0   
#> 3 cli_vec      19.4µs  22.12µs    44062.      448B     8.81
#> 4 base_vec     9.98µs  10.33µs    95547.      448B     0   
#> 5 cli_txt     19.34µs   21.7µs    45135.        0B     4.51
#> 6 base_txt    11.32µs  11.75µs    83386.        0B     0
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
#> 1 cli          5.29µs   6.29µs   149381.        0B    14.9 
#> 2 base       949.02ns   1.02µs   835326.        0B    83.5 
#> 3 cli_vec     19.62µs  22.89µs    43041.      448B     4.30
#> 4 base_vec    41.43µs  43.17µs    22949.      448B     0   
#> 5 cli_txt     20.56µs  22.21µs    44122.        0B     4.41
#> 6 base_txt    70.28µs  72.49µs    13707.        0B     0
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
#> 1 cli          5.71µs   6.76µs   139035.        0B    27.8 
#> 2 base       590.92ns 622.01ns  1376342.        0B     0   
#> 3 cli_vec     15.42µs  16.67µs    58519.      448B     5.85
#> 4 base_vec    10.03µs  10.31µs    95255.      448B     0   
#> 5 cli_txt     16.89µs  17.99µs    54097.        0B    10.8 
#> 6 base_txt    11.44µs  11.79µs    83647.        0B     0
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
#> 1 cli          4.27µs   5.18µs   179297.    22.2KB    17.9 
#> 2 base       701.98ns 786.15ns  1070916.        0B     0   
#> 3 cli_vec     25.77µs  27.95µs    35158.     1.7KB     7.03
#> 4 base_vec     6.67µs   6.93µs   141949.      848B     0   
#> 5 cli_txt       4.3µs   5.14µs   180628.        0B    18.1 
#> 6 base_txt     4.23µs    4.7µs   205474.        0B     0
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
