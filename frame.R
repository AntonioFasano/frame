

## frame is an S4 class by Antonio Fasano
## A class, inheriting from data.frame, featuring:
## drop=FALSE as default, end keyword, 0 index for 'all' and a 'desc' field.


setClass("frame", #Fancier name wanted))
         slots=c(desc = "character"),
         prototype=c(desc = NULL),
         contains = c("data.frame"))

frame=function(..., col.names=NULL, row.names = NULL, desc=character(),
               check.rows = FALSE, check.names = FALSE, fix.empty.names = TRUE,
               stringsAsFactors = FALSE ){

    x=data.frame (..., row.names = row.names, check.rows = check.rows, check.names = check.names,
                  fix.empty.names = fix.empty.names, stringsAsFactors = stringsAsFactors)
    if(!is.null(col.names)) names(x)=col.names
    new("frame", x, desc=desc)

}
setMethod("show", "frame",
          function(object){
              message("Frame ", paste(dim(object), collapse="x"), appendLF=FALSE)
              if(!length(object@desc)) cat('\n') else
                                                     message(': ', object@desc)
              o=S3Part(object)
              if(dim(o)[1]>20){
                  print(o[1:20,])
                  message("...")
              } else {
                  print(o)
              }
})

setMethod(
    `[`,
    signature=signature(x="frame"),
    function(x,i,j, ..., drop=FALSE){
p=as.list(sys.call())[-c(1,2)]; p$drop=NULL
        args=frame.extract(p, dim(x), paren=-2)
        if(length(p)==2 || !missing(drop)) args=c(args, drop=drop)
        x3=do.call(`[.data.frame`, c(list(S3Part(x, strictS3=TRUE)), args))
        if(drop) return(x3) else S3Part(x)=x3; x
    })





setMethod(
    `[<-`,
    signature=signature(x="frame"),
    function(x,i,j,value){
        p=as.list(sys.call(-1))[c(3,4)]; p$value=NULL
        args=frame.extract(p, dim(x), paren=-3)
        x@.Data=x3=do.call(`[<-.data.frame`, c(list(S3Part(x, strictS3=TRUE)), args, list(value=value)))
        names(x)=names(x3)
        x
    })


frame.extract=function(p, end, paren){
    M= (function(a,b){ as.list(sys.call())[3] }) ( , )
    e=sys.frame( paren )
    if(length(p)==1) end=rev(end)
    for (h in 1:length(p)){
        if(identical(p[[h]], M[[1]]) || identical(eval(p[[h]], list(end=end[h]), e), 0)) {p[h]=M; next}
        if(class(p[[h]])=='name' || class(p[[h]])=='call'){
            p[[h]]= eval(p[[h]], list(end=end[h]), e)
            if(length(p[[h]])==1 && class(p[[h]])=='character')
                p[[h]]=eval(parse(text=eval(p[[h]])), list(end=end[h]), e)
        }
    }
    p
}


as.frame=function(m, desc=NULL, col.names=NULL, row.names=NULL, ...){
    df=as.data.frame.matrix(m, row.names, ...)
    if(!is.null(col.names)) names(df)=col.names
    if(is.null(desc)) frame(df) else frame(df, desc=desc)
}

as.matrix.frame=function (x, rownames.force = NA, ...){
    x=S3Part(x, strictS3=T)
    as.matrix.data.frame(x, rownames.force = NA, ...)
}

#setMethod(
#    `[`,
#    signature=signature(x="frame"),
#    function(x,i,j, ...){
#
#        p=as.list(sys.call())[-c(1,2)]
#        M= (function(a,b){ g=as.list(sys.call())[3] }) ( , )
#        end=c(end=nrow(x), end=ncol(x))
#        l=list(end=end[[h]])
#        e=sys.frame(sys.parent())
#
#        for (h in 1:2){
#            if(identical(p[h], M) || identical(p[[h]], 0)) {p[h]=M; next}
#            if(class(p[[h]])=='name' || class(p[[h]])=='call'){
#                p[[h]]= eval(p[[h]], l, e)
#                if(length(p[[h]])==1 && class(p[[h]])=='character')
#                    p[[h]]=eval(parse(text=eval(p[[h]])), l, e)
#            }
#        }
#
#        if(missing(drop)) drop=FALSE
#        do.call(`[.data.frame`, list(x, p[[1]], p[[2]],drop=drop))
#
#
#
#    })




