

## frame is an S4 class by Antonio Fasano
## A class inherithing from data.frame featuring:
## drop=FALSE as default, end keyword, 0 index for 'all' and a desc field.


frame=setClass("frame", #Fancier name wanted))
         slots=c(desc = "character"),
         prototype=c(desc = NULL),
         contains = c("data.frame"))

setMethod("show", "frame",
          function(object){
              cat("Frame")
              if(!length(object@desc)) cat('\n') else
              cat(':', object@desc, '\n')
              print(S3Part(object))
})

setMethod(
    `[`,
    signature=signature(x="frame"),
    function(x,i,j, ..., drop=FALSE){
        p=as.list(sys.call())[-c(1,2)]; p$drop=NULL
        args=frame.extract(p, dim(x), paren=-2)
        if(length(p)==2 || !missing(drop)) args=c(args, drop=drop)
        x3=do.call(`[.data.frame`, c(list(S3Part(x, strictS3=T)), args))
        if(drop) return(x3) else S3Part(x)=x3; x
    })


setMethod(
    `[<-`,
    signature=signature(x="frame"),
    function(x,i,j,value){
        p=as.list(sys.call(-1))[c(3,4)]; p$value=NULL
        args=frame.extract(p, dim(x), paren=-3)
        x@.Data=x3=do.call(`[<-.data.frame`, c(list(S3Part(x, strictS3=T)), args, list(value=value)))
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


as.frame=function(m, desc=NULL, row.names=NULL, ...){
    df=as.data.frame.matrix(m, row.names, ...)
    if(is.null(desc)) frame(df) else frame(df, desc=desc)
}

as.matrix.frame=function (x, rownames.force = NA, ...){
    x=S3Part(x, strictS3=T)
    as.matrix.data.frame(x, rownames.force = NA, ...)
}

setMethod(
    `[`,
    signature=signature(x="frame"),
    function(x,i,j, ...){

        p=as.list(sys.call())[-c(1,2)]
        M= (function(a,b){ g=as.list(sys.call())[3] }) ( , )
        end=c(end=nrow(x), end=ncol(x))
        l=list(end=end[[h]])
        e=sys.frame(sys.parent())

        for (h in 1:2){
            if(identical(p[h], M) || identical(p[[h]], 0)) {p[h]=M; next}
            if(class(p[[h]])=='name' || class(p[[h]])=='call'){
                p[[h]]= eval(p[[h]], l, e)
                if(length(p[[h]])==1 && class(p[[h]])=='character')
                    p[[h]]=eval(parse(text=eval(p[[h]])), l, e)
            }
        }

        if(missing(drop)) drop=FALSE
        do.call(`[.data.frame`, list(x, p[[1]], p[[2]],drop=drop))



    })



