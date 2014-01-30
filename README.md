


'frame' an S4 class inheriting from data.frame
==============================================


A class inheriting from data.frame featuring  `drop=FALSE` as default, an 'end' keyword, 0 index for 'all' and a 'desc' field.



The problem
-----------

Despite very powerful, R language is mostly intended for interactive use. So in `x[i,j]`  it is not straight  to set  such a value for `i` or `j` to emulate  `x[,j]` or `x[i,]`.

Using `T` (which will get recycled)  is only a trick not always working. For example:

    x=matrix(1:12, ncol=3)
    `[<-`(x,T,4,0)

gives a "subscript out of bounds" error, while

     x[,4]=0

works.

Also the default `drop=TRUE` feature means breaking some programmatic code, like simple `nrow`, `ncol`, which will fail if the dimensions are dropped.

All these features are blessed time savers in interactive code, but oblige to many if/else check, prone to errors, in programmatic use.


The solution
-----------


I developed  a new data.frame S4 class, `frame`, inheriting  from data.frame but exploiting the `0`, unused in subsetting, to select all rows or columns, so `x[0,j]` and `x[i,0]`  as   `x[,j]` and `x[i,]`.
Also  `drop=FALSE`  is used as default value in place of `drop=TRUE`.
Besides it uses a Matlab like `end` operator to get the last  rows or columns item, e.g.: `x[3:end, 2:end]`.

A `desc` field can be added to annotate any  data description.



The old data.frame and the new one
---------------------------------

This class inherits from the data.frame class: if a function  works  with a data.frame it is supposed to work with 'frame'. If your code requires a formal data.frame you can obtain it from the 'frame' x with:

dfm(x)

This is a shortcut for `as.data.frame` which in turn will call the specialised function a`s.data.frame.frame`.



What you get on the field
-------------------------

    ## Create a 'frame', with a description from a matrix
    df=as.data.frame(matrix(1:12, ncol=3))
    fr=frame(df, desc='Ciao world')

    ## Faster with as.frame
    fr=as.frame(matrix(1:12, ncol=3), desc='Ciao world')

    fr
    #Frame: Ciao world
    #  V1 V2 V3
    #1  1  5  9
    #2  2  6 10
    #3  3  7 11
    #4  4  8 12


    ## Standard subsetting
    fr[c(1,3),2:3]
    #Frame: Ciao world
    #  V2 V3
    #1  5  9
    #3  7 11

    fr[2,]
    #Frame: Ciao world
    #  V1 V2 V3
    #2  2  6 10

    fr[2,c('V1', 'V3')]
    #Frame
    #  V1 V3
    #2  2 10

    fr[c(T,F,T,T),T]
    #Frame: Ciao world
    #  V1 V2 V3
    #1  1  5  9
    #3  3  7 11
    #4  4  8 12

    fr[2:3]
    #Frame: Ciao world
    #  V2 V3
    #1  5  9
    #2  6 10
    #3  7 11
    #4  8 12

    ## Non-standard behaviour:
    ## drop is false by default
    fr[1,1]
    #Frame: Ciao world
    #  V1
    #1  1

    fr[1,1, drop=T] #Traditional behaviour
    #[1] 1

    fr[ ,1, drop=T] #Traditional behaviour
    #[1] 1 2 3 4

    ## 'end' is last row or col according to position
    fr[end,end]  # 'end' is not quoted inside brackets!
    #Frame: Ciao world
    #  V3
    #4 12

    fr[end]
    #Frame: Ciao world
    #  V3
    #1  9
    #2 10
    #3 11
    #4 12

    fr[2:end]
    #Frame: Ciao world
    #  V2 V3
    #1  5  9
    #2  6 10
    #3  7 11
    #4  8 12

    fr[2:end,end:1]
    #Frame: Ciao world
    #  V3 V2 V1
    #2 10  6  2
    #1  9  5  1

    ## 'end' is always a keyword inside brackets
    end=100
    fr[end]
    #Frame: Ciao world
    #  V3
    #1  9
    #2 10
    #3 11
    #4 12

    ## Zero means all
    fr[0,1]
    #Frame: Ciao world
    #  V1
    #1  1
    #2  2
    #3  3
    #4  4

    fr[1,0]
    #Frame: Ciao world
    #  V1 V2 V3
    #1  1  5  9

    fr[0,0]
    #Frame: Ciao world
    #  V1 V2 V3
    #1  1  5  9
    #2  2  6 10
    #3  3  7 11
    #4  4  8 12

    ## Traditional zero behaviour
    ## For a DF [0:3,0:2] is like [1:3,1:2], and for 'frame' too
    fr[0:3,0:2] # Your old code won't break
    #Frame: Ciao world
    #  V1 V2
    #1  1  5
    #2  2  6
    #3  3  7


Use in a programmatic environment
---------------------------------

Consider this code snippet

    size=function(x)
         if(nrow(x)>100) print("I am a long series") else
                          print("I am a short series")

It will break when a data.frame loses a dimension, due to the default `drop=TRUE`.

    df=as.data.frame(matrix(1:12, ncol=3))
    fr=frame(df)

    ## All columns
    size(df)
    #[1] "I am a short series"

    ## Only the first col
    size(df[,1])
    #Error: argument is of length zero

    size(fr[,1])
    #[1] "I am a short series"


Assume that `fr` represents real observations.

    fr=as.frame(matrix(rnorm(16), ncol=4))

Calculate the covariance matrix of some or all the `fr` columns. Generate a random frame like `fr`, calculate the same covariance matrix and obtain the differences.


    dcov=function(fr,i,j){
        v1=fr[i,j]
        m=matrix(rnorm(nrow(fr) * ncol(fr)), ncol=ncol(fr))
        v2=as.frame(m)[i,j]
        var(v1)-var(v2)
    }

Get delta-cov for  all columns in `fr`:

    dcov(fr, 0, 0)

Only columns starting from second:

    dcov(fr, 0, '2:end') #Quoting necessary!!

Without quoting, if you have a variable `end=3`, you are sending `2:3`.

All columns except, but remove last row:

    dcov(fr, '-end', 0) #Quoting necessary!!


'end' quotation
---------------

*Inside brackets* you *do not quote* 'end' to use it as a keyword for last element.

    fr=as.frame(matrix(1:16, nrow=4))

    end=100
    fr[2:end,] #'end' is the last row (4 not 100)
    #Frame:
    #  V1 V2 V3 V4
    #2  2  6 10 14
    #3  3  7 11 15
    #4  4  8 12 16

*Outside brackets*, that is  in a programmatic environment when using 'end' keyword indirectly in a variable assignment, *quote* end!

    end=1
    a=end
    b='end'

    ## Without quoting, variable value 'end' is 1
    fr[1:2,a]
    #Frame:
    #  V1
    #1  1
    #2  2

    ## By quoting, variable value 'end' is a keyword
    fr[1:2,b]
    #Frame:
    #  V4
    #1 13
    #2 14

If the assignment is an *expression* contains 'end' the same rule applies to get it as a keyword: *quote too*.

    a='3:end'
    b=0
    fr[a,b]
    #Frame
    #  V1 V2 V3 V4
    #3  3  7 11 15
    #4  4  8 12 16

**In assignments**, without quoting 'end', it will get the current value of end, if any and valid, or raise an error. Inside brackets it will be passed unevaluated and after converted to a keyword.
Quoting in brackets means querying for the row/column named "end".


**Bracket alternatives**

These rules keep for bracket alternatives `` `[`(x,i,j)`` and  `` `[<-`(x,i,j)``.

    `[`(fr,end,end)
    #Frame
    #  V4
    #4 16

    a='3:end'
    `[`(fr,a,a)
    #Frame
    #  V3 V4
    #3 11 15
    #4 12 16



What if my column is named 'end'?
--------------------------------


    fr=as.frame(matrix(1:16, nrow=4))
    names(fr)[3]='end'
    fr[1,]
    #Frame
    #  V1 V2 end V4
    #1  1  5   9 13

Inside brackets nothing special happens. As a keyword 'end' is unquoted, while as a name:

    fr[c('V1','end')]
    #Frame:
    #  V1 end
    #1  1   9
    #2  2  10
    #3  3  11
    #4  4  12


For assignments to a variable, outside brackets, quote twice.

    a="'end'"
    b="c('V1', 'end')"

    fr[1:2,a]
    #Frame:
    #  end
    #1   9
    #2  10

    fr[1:2,b]
    #Frame:
    #  V1 end
    #1  1   9
    #2  2  10

Obviously you can quote twice also with `sQuote`, `dQuote` or escaping inner quotation marks with "\\".


