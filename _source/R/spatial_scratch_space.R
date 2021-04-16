sample_data
n = 4
mat = matrix(1:n^2, nrow = n)
mat.pad = rbind(NA, cbind(NA, mat, NA), NA)
ind = 2:(n + 1) # row/column indices of the "middle"
neigh = rbind(N  = as.vector(mat.pad[ind - 1, ind    ]),
              NE = as.vector(mat.pad[ind - 1, ind + 1]),
              E  = as.vector(mat.pad[ind    , ind + 1]),
              SE = as.vector(mat.pad[ind + 1, ind + 1]),
              S  = as.vector(mat.pad[ind + 1, ind    ]),
              SW = as.vector(mat.pad[ind + 1, ind - 1]),
              W  = as.vector(mat.pad[ind    , ind - 1]),
              NW = as.vector(mat.pad[ind - 1, ind - 1]))

mat
mat.pad
neigh[, 1:6]


mat <- matrix(1:16, 4, 4)
mat
m2<-cbind(NA,rbind(NA,mat,NA),NA)
m2
addresses <- expand.grid(x = 1:4, y = 1:4)
addresses

ret<-c()
for(i in 1:-1)
  for(j in 1:-1)
    if(i!=0 || j !=0)
      ret<-rbind(ret,m2[addresses$x+i+1+nrow(m2)*(addresses$y+j)]) 
ret
mat







n.col <- 5
n.row <- 10
mat <- matrix(seq(n.col * n.row), n.row, n.col)

> mat
[,1] [,2] [,3] [,4] [,5]
[1,]    1   11   21   31   41
[2,]    2   12   22   32   42
[3,]    3   13   23   33   43
[4,]    4   14   24   34   44
[5,]    5   15   25   35   45
[6,]    6   16   26   36   46
[7,]    7   17   27   37   47
[8,]    8   18   28   38   48
[9,]    9   19   29   39   49
[10,]   10   20   30   40   50

mat <- sample_data
n.row <- nrow(mat)
n.col <- ncol(mat)
addresses <- expand.grid(x = 1:n.row, y = 1:n.col)

# Relative addresses
z <- rbind(c(-1,0,1,-1,1,-1,0,1),c(-1,-1,-1,0,0,1,1,1))

get.neighbors <- function(rw) {
  # Convert to absolute addresses 
  z2 <- t(z + unlist(rw))
  # Choose those with indices within mat 
  b.good <- rowSums(z2 > 0)==2  &  z2[,1] <= nrow(mat)  &  z2[,2] <=ncol(mat)
  mat[z2[b.good,]]
}

neighborsz <- apply(addresses,1, get.neighbors) # Returns a list with neighbors
mat
head(neighborsz)
length(neighborsz)
