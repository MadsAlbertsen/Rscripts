#### Locator Function for ggplot v3####

ggplot_locator <- function(p){
  # Load Libraries
  library(ggplot2)
  library(grid)
  
  # Generate x/y data and define variables
  pi <- ggplot_build(p)
  x <- unlist(lapply(pi$data, function(l){l$x}))
  y <- unlist(lapply(pi$data, function(l){l$y})) 
  x <- x[!is.infinite(x)]
  y <- y[!is.infinite(y)]
  n = 100
  d <- data.frame(matrix(as.numeric(), 0, 2))
  colnames(d) <- c(pi$plot$mapping$x, pi$plot$mapping$y)
  
  # Locate coordinates and store in d
  for (i in 1:n){    
    seekViewport('panel.3-4-3-4', recording=TRUE) 
    pushViewport(dataViewport(x,y))
    tmp <- grid.locator('native')
    if (is.null(tmp))break
    grid.points(tmp$x,tmp$y, pch = 16, gp=gpar(cex=0.5, col="blue"))
    d[i, ] <- as.numeric(tmp)
  }
  grid.polygon(x= unit(d[,1], "native"), y= unit(d[,2], "native"), gp=gpar(fill=NA))
  
  # Data Output
  if (pi$panel$x_scales[[1]]$trans$name == "log-10") d[,1] <- 10^(d[,1])
  if (pi$panel$y_scales[[1]]$trans$name == "log-10") d[,2] <- 10^(d[,2])
  show(d)
  return(d)
}


#### Simulated Test Data

#### 1.  Infinite Values
#
# The locator function gives an error when working with datasets containing contigs with zero coverage 
# which are attempted plotted in a log10-scaled scatterplot using ggplot. The reason is when ggplot engine
# transforms 0 to log10 scale it becomes -Inf. We use the transformed coverage co-ordinates of our contigs
# when creating a the co-ordinate system of the new viewport for our locator function. The viewport can't
# have -Inf in its range and the 'create'pushViewport' returns an error. When need to find a suitible
# value to replace -Inf with.

# This test function shows that whatever interval of numbers we use, when we add a 0 to this range and
# log10 transform the range and plot with ggplot the x/y range will only depend on the none inf values.
# The datapoint containing inf will still be plottet but on the very edge of the axis.

# Therefore we can merely remove the inf values when feeding the x/ intervals to the pushViewport function.
# However if the x value is inf and the corrosponding y value is finite do not remove the y value.
# The finite y value will still have an impact in the ggplot axis range.

# library(ggplot2)
# library(grid)
# 
# 
# d <- data.frame(x = c(exp(0:10)), y = c(exp(10:0)))
# 
# test <- function(d){
#   apply(d, MARGIN=1, FUN= function(d){
#     x <- unlist(d["x"])
#     y <- unlist(d["y"])
#     yr <- c(0, seq(from=y, to=y*10, length.out=11))
#     xr <- c(seq(from=x*10, to=x, length.out=11), 0)
#     yo <- seq(from=y, to=y*10, length.out=11)
#     xo <- seq(from=x*10, to=x, length.out=11)
#     
#     pr <- ggplot(data.frame(xr, yr), aes(xr, yr)) +
#       geom_point(size = 3, color = "red") +
#       scale_x_log10() +
#       scale_y_log10()
#     prb <- ggplot_build(pr)
#     
#     po <- ggplot(data.frame(xo, yo), aes(xo, yo)) +
#       geom_point(size = 3, color = "red") +
#       scale_x_log10() +
#       scale_y_log10()
#     pob <- ggplot_build(po)
#     return(data.frame(x_ref = prb$panel$ranges[[1]]$x.range[1],
#              x_0 = pob$panel$ranges[[1]]$x.range[1],
#              y_ref = prb$panel$ranges[[1]]$y.range[1],
#              y_0 = pob$panel$ranges[[1]]$y.range[1])
#            )
#   }
#   )
# }
# 
# d <- data.frame(x = c(0,exp(0:10)), y = c(exp(10:0),0))
# 
# p <- ggplot(d, aes(x, y)) +
#   geom_point(size = 3, color = "red") +
#   scale_x_log10() +
#   scale_y_log10()
# p

#### Extract from ahull ####

extract <- function(data, sel){
  library("alphahull")
  xname <- names(sel[1])
  yname <- names(sel[2])
  xr <- range(sel[xname])
  yr <- range(sel[yname])
  sel.hull <- ahull(sel, alpha=100000)
  ds <- subset(data, data[xname] > min(xr) & data[xname] < max(xr) & data[yname] > min(yr) & data[yname] < max(yr))
  hull <- apply(ds[c(xname, yname)],1,function(x){inahull(ahull.obj=sel.hull, p=x)})
  return(ds[hull, ])
}
