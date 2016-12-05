# Advanced R--Data structures
hoho  
Monday, November 09, 2015  

# 总述

R的基本数据结构可以根据其维数以及其是否允许多种数据类型来区分成以下五类：

Dimensionality |Homogeneous|Heterogeneous
-------------- |-----------|-------------
1d|Atomic vector | List
2d|Matrix  | Data frame
nd|Array |

**注意** R中不存在0维或标量类型，所有单一的数值或字符串实际上都是长度为1的vector！

可以使用`str()`函数来查看数据结构（structure缩写）。


# Vectors 向量

最基本的数据类型，可以分为atomic vectors和lists两种，它们都有以下特性：

* 类型，`typeof()`，它是什么；
* 长度，`length()`，它包含多少个元素；
* 属性，`attributes()`，附加的任意元数据。

它们的区别在于其包含的元素的类型，在atomic vector中所有元素必须是同一类型的，而在list中的元素可以是不同类型的。

**注意** `is.vector()`并不能检验一个对象是否是一个向量，它仅在一个向量不存在除了names以外的属性时才返回`TRUE`。使用`is.atomic(x) || is.list(x)`来检查一个对象是否是一个向量。

## Atomic vectors

四种常见的atomic vector类型：logical、integer、double（numeric）以及character；两种比较少用的类型complex和raw。

atomic vector通常用`c()`来创建（combine的缩写）：


```r
dbl_var <- c(1, 2.5, 4.5)
# With the L suffix, you get an integer rather than a double
int_var <- c(1L, 6L, 10L)
# Use TRUE and FALSE (or T and F) to create logical vectors
log_var <- c(TRUE, FALSE, T, F)
chr_var <- c("these are", "some strings")
```

atomic vector永远是平的（？），即使你嵌套使用了多个`c()`：

```r
c(1, c(2, c(3, 4)))
## [1] 1 2 3 4
# the same as
c(1, 2, 3, 4)
## [1] 1 2 3 4
```

缺失数据用一个长度为1的**逻辑向量**`NA`定义，在`c()`中使用的`NA`会自动转换成合适的类型，也可以通过`NA_real_`、`NA_integer_`和`NA_character_`来定义特定类型的`NA`。

### Types and tests 类型和检验

对于一个向量，可以使用`typeof()`来检验其类型，或者使用“is”类的函数来检验其是否是某一特定的类型，如`is.character()`、`is.double()`、`is.integer()`、`is.logical()`或者更一般的`is.atomic()`：


```r
int_var <- c(1L, 6L, 10L)
typeof(int_var)
## [1] "integer"
is.integer(int_var)
## [1] TRUE
is.atomic(int_var)
## [1] TRUE

dbl_var <- c(1, 2.5, 4.5)
typeof(dbl_var)
## [1] "double"
is.double(dbl_var)
## [1] TRUE
is.atomic(dbl_var)
## [1] TRUE
```

**注意** `is.numeric()`是用于检验一个向量是否为“数值型”，它对整型与浮点型的向量都会返回`TRUE`。

```r
is.numeric(int_var)
## [1] TRUE
is.numeric(dbl_var)
## [1] TRUE
```

### Coercion 强制转换

一个atomic vector里的所有元素必须是同一类型的，因此当你尝试将不同类型的元素连接在一起时，它们会被强制转换成最具弹性的类型。各种类型的数据按以下顺序弹性递增：logical、integer、double、character。

比如，连接一个字符型向量和一个整型向量将得到一个字符型的向量：


```r
str(c("a", 1))
##  chr [1:2] "a" "1"
```

当一个逻辑型向量被强制转换成一个整型或浮点型的向量时，`TRUE`会变成1而`FALSE`会变成0。这在结合使用`sum()`和`mean()`的时候非常有用：


```r
x <- c(FALSE, FALSE, TRUE)
as.numeric(x)
## [1] 0 0 1

# Total number of TRUEs
sum(x)
## [1] 1

# Proportion that are TRUE
mean(x)
## [1] 0.3333333
```

这些转换通常是自动完成的。大部分数学函数（如`+`、`log`、`abs`等）会转换成浮点型或整型，而大部分逻辑操作符（如`&`、`|`、`any`等）会转换成逻辑型。如果转换会造成信息丢失，通常会有警告提示。你也可以使用`as.character()`、`as.double()`、`as.integer()`或`as.logical()`进行特定的转换从而为止转换产生的混乱。


## Lists 列表

列表的元素可以是任意类型的，包换列表本身。使用`list()`来创建列表：


```r
x <- list(1:3, "a", c(TRUE, FALSE, TRUE), c(2.3, 5.9))
str(x)
## List of 4
##  $ : int [1:3] 1 2 3
##  $ : chr "a"
##  $ : logi [1:3] TRUE FALSE TRUE
##  $ : num [1:2] 2.3 5.9
```

列表有的时候也被称作递归向量，因为一个列表可以包含其它列表：


```r
x <- list(list(list(list())))
str(x)
## List of 1
##  $ :List of 1
##   ..$ :List of 1
##   .. ..$ : list()
is.recursive(x)
## [1] TRUE
```

`c()`可以将多个列表结合成一个。如果同时给予`c()` atomic vector和列表，它会将向量转换成列表然后再进行结合。比较以下`list()`和`c()`的结果：


```r
x <- list(list(1, 2), c(3, 4))
y <- c(list(1, 2), c(3, 4))
str(x)
## List of 2
##  $ :List of 2
##   ..$ : num 1
##   ..$ : num 2
##  $ : num [1:2] 3 4
str(y)
## List of 4
##  $ : num 1
##  $ : num 2
##  $ : num 3
##  $ : num 4
```

`typeof()`一个列表将会返回`list`。可以用`is.list()`来检验一个列表，用`as.list()`强制将一个对象转换成列表。

**将一个列表转换成atomic vector要使用`unlist()`，如果该列表包含多种类型的元素，`unlist()`将使用与`c()`一致的转换规则进行强制转换。**

列表被广泛地用于构建R中许多更复杂的数据结构，比如数据框和`lm()`产生的线性回归模型对象实际上都是列表：


```r
is.list(mtcars)
## [1] TRUE

mod <- lm(mpg ~ wt, data = mtcars)
is.list(mod)
## [1] TRUE
```

## Attributes 属性

所有对象都可以添加额外的属性来记录有关该对象的元数据。属性可以认为是一种命名列表（名字唯一），可以通过`attr()`分别访问各个属性，或用`attributes()`来一次性以列表的形式访问所有属性。


```r
y <- 1:10
attr(y, "my_attribute") <- "This is a vector"
attr(y, "my_attribute")
## [1] "This is a vector"

str(attributes(y))
## List of 1
##  $ my_attribute: chr "This is a vector"
```

`structure()`函数返回一个属性修改后的新对象：


```r
structure(1:10, my_attribute = "This is a vector")
##  [1]  1  2  3  4  5  6  7  8  9 10
## attr(,"my_attribute")
## [1] "This is a vector"
```

默认情况下，修改一个向量会导致大部分属性的丢失：


```r
attributes(y[1])
## NULL
attributes(sum(y))
## NULL
```

**仅有三种重要属性不会丢失：**

* Names，赋予每个元素名字的一个字符型向量，通过`names()`访问；
* Dimensions，用于将向量转换成矩阵和数组，通过`dims()`访问；
* Class，用于实现S3对象系统，通过`class()`访问。

### Names 名字

可以通过三种方式命名一个向量：

* 创建同时命名：`x <- c(a = 1, b = 2, c = 3)` ；
* 修饰一个已经存在的向量： `x <- 1:3; names(x) <- c("a", "b", "c")` ；
* 或者创建一个向量修饰后的拷贝： `x <- setNames(1:3, c("a", "b", "c"))` 。

**名字不必是唯一的，然而由于使用名字来创建子集（subsetting）使用非常频繁，使用唯一的名字能更好地用于创建子集**

一个向量中的所有元素不必全都拥有名字，如果某些元素缺失名字，`names()`会在对应位置返回空字符串，如果所有元素都没有名字，则会返回`NULL`：


```r
y <- c(a = 1, 2, 3)
names(y)
## [1] "a" ""  ""

z <- c(1, 2, 3)
names(z)
## NULL
```

可以使用`unname(x)`来创建一个不带名字的新向量, 或者用`names(x) <- NULL`来清空一个既有向量的名字。

### Facotrs 因子

属性的一个重要应用是定义因子。因子是一种用于存储分类数据的向量，只允许包含预定义的值。因子实际上是在整型向量中加入了两个属性：一个使之与常规的整型变量不同的类（`class()`）"factor"，以及用于定义允许使用的值的`levels()`：


```r
x <- factor(c("a", "b", "b", "a"))
x
## [1] a b b a
## Levels: a b
class(x)
## [1] "factor"
levels(x)
## [1] "a" "b"

# You can't use values that are not in the levels
x[2] <- "c"
## Warning in `[<-.factor`(`*tmp*`, 2, value = "c"): invalid factor level, NA
## generated
x
## [1] a    <NA> b    a   
## Levels: a b

# NB: you can't combine factors
c(factor("a"), factor("b"))
## [1] 1 1
```

因子在你知道一个变量所有可能的值，而不能观测到在某个给定数据集中的所有值时非常有用。使用因子比使用字符型向量更容易知道哪些分组中没有观测到值：


```r
sex_char <- c("m", "m", "m")
sex_factor <- factor(sex_char, levels = c("m", "f"))

table(sex_char)
## sex_char
## m 
## 3
table(sex_factor)
## sex_factor
## m f 
## 3 0
```

**重要！！！** 我们通过读取文件来产生数据框，有时某一列本应该产生数值型的向量，却产生了一个因子。这是由于该列包含了某些非数值型的值，通常是`.`或`-`之类的用于记录缺失值的符号。此时可以将这个因子向量强制转换成字符型向量，然后再转换成浮点型向量（注意转换后要检查缺失值）。当然更好的方法是在源文件中就发现了该问题并加以修改，使用`read.csv()`的`na.strings`参数往往可以初步解决此类问题。


```r
# Reading in "text" instead of from a file here:
z <- read.csv(text = "value\n12\n1\n.\n9")
typeof(z$value)
## [1] "integer"
as.double(z$value)
## [1] 3 2 1 4
# Oops, that's not right: 3 2 1 4 are the levels of a factor, 
# not the values we read in!
class(z$value)
## [1] "factor"
# We can fix it now:
as.double(as.character(z$value))
## Warning: 强制改变过程中产生了NA
## [1] 12  1 NA  9

# Or change how we read it in:
z <- read.csv(text = "value\n12\n1\n.\n9", na.strings=".")
typeof(z$value)
## [1] "integer"
class(z$value)
## [1] "integer"
z$value
## [1] 12  1 NA  9
# Perfect! :)
```

不幸的是，大部分R的数据读取函数都会自动将字符型向量转换成因子。这是一种次优的设计，因为这些函数无法知道所有可能的level以及它们的优先级。我们可以使用`stringsAsFactors = FALSE`参数来关闭这一行为，然后根据我们对数据的理解将必要的字符型向量手动转换成因子。此外，我们可以用一个全局设置`option(stringsAsFactors = FALSE)`来全局地控制这一行为，但是一般不建议这么做。改变一个全局设置可能会在使用来自各种包或由`source()`引入的其它代码时产生意外的结果，全局设置也会降低代码的可读性。

虽然因子看起来很像字符型向量，它们本质上还是整型向量。把它们看成字符串时必须十分小心。某些字符串相关的函数（如`gsub()`和`grepl()`）会将因子强制转换成字符串，某些函数（如`nchar()`）则会抛出错误，而另一些函数（如`c()`）则会使用因子底层的整型数值。因此，当你需要字符串的特性时最好将因子显式地转换成字符型向量。在R的早期版本中，因子比字符型向量更节约内存，然而在目前的版本中已经不再如此。

# Matrices and arrays 矩阵和数组


