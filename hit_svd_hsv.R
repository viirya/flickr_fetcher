
perform_svd <- function(data, colorData, colorDataDim, colorLabel) {

    dataMatrix <- read.table(data, row.names = 1)
    
    (s <- svd(dataMatrix))
    u <- s$u
    v <- s$v
    d <- s$d 

    write.table(u, file = paste(data, ".u", sep = ''))
    write.table(v, file = paste(data, ".v", sep = ''))
    write.table(d, file = paste(data, ".d", sep = ''))
 
    png(filename = paste(data, ".d.png", sep = ''))
    plot(1:length(s$d), s$d)
    dev.off()

    png(filename = paste(data, ".v.png", sep = ''))
    plot(s$v[,1], s$v[,2], xlab = "factor 1", ylab = " factor 2")
    dev.off()

    png(filename = paste(data, ".v_id.png", sep = ''))
    plot(s$v[,1], s$v[,2], xlab = "factor 1", ylab = " factor 2")
    text(s$v[,1], s$v[,2], labels = seq_along(s$v[,1]), pos = 1)
    dev.off()

    colorMatrix <- read.csv(colorData, header = FALSE)
    print(colorMatrix)
    png(filename = paste(paste(paste(data, ".v_", sep = ''), colorLabel, sep = ''), ".png", sep = ''))
    plot(s$v[,1], s$v[,2], xlab = "factor 1", ylab = " factor 2", col = hsv(colorMatrix[, colorDataDim], colorMatrix[, colorDataDim + 1], colorMatrix[, colorDataDim + 2], 1), pch = 19, cex = 1.5)
    dev.off()


    return (s)
}

arg <- commandArgs(trailingOnly = TRUE)
argLen <- length(arg)
if (argLen == 4) {
    rawDataMatrix <- arg[1]
    colorData <- arg[2]
    colorDataDim <- as.numeric(arg[3])
    colorLabel <- arg[4]
    print(paste("Applying SVD on ", arg, " data...", sep = ''))
    perform_svd(rawDataMatrix, colorData, colorDataDim, colorLabel)
}

