
perform_svd <- function(data, colorData, colorDataDim, colorLabel) {

    dataMatrix <- read.table(data, row.names = 1)
    
    (s <- svd(dataMatrix))
    u <- s$u
    v <- s$v
    d <- s$d 

    write.table(u, file = paste(data, ".u", sep = ''))
    write.table(v, file = paste(data, ".v", sep = ''))
    write.table(d, file = paste(data, ".d", sep = ''))
 
    png(filename = paste(data, ".d.png", sep = ''), res = 600, height = 3, width = 3, units = "in", pointsize = 6)
    plot(1:length(s$d), s$d, xlab = "component number", ylab = "singular value", cex.axis = 1.5, cex.lab = 1.5)
    dev.off()

    setEPS()
    postscript(paste(data, ".d.eps", sep = ''))
    plot(1:length(s$d), s$d, xlab = "component number", ylab = "singular value", cex.axis = 1.5, cex.lab = 1.5)
    dev.off()

    png(filename = paste(data, ".v.png", sep = ''), res = 600, height = 3, width = 3, units = "in", pointsize = 6)
    plot(s$v[,1], s$v[,2], xlab = "factor 1", ylab = " factor 2", cex.axis = 1.5, cex.lab = 1.5)
    dev.off()

    setEPS()
    postscript(paste(data, ".v.eps", sep = ''))
    plot(s$v[,1], s$v[,2], xlab = "factor 1", ylab = " factor 2", cex.axis = 1.5, cex.lab = 1.5)
    dev.off()

    png(filename = paste(data, ".v_id.png", sep = ''), res = 600, height = 3, width = 3, units = "in", pointsize = 6)
    plot(s$v[,1], s$v[,2], xlab = "factor 1", ylab = " factor 2", cex.axis = 1.5, cex.lab = 1.5)
    text(s$v[,1], s$v[,2], labels = seq_along(s$v[,1]), pos = 1)
    dev.off()
 
    setEPS()
    postscript(paste(data, ".v_id.eps", sep = ''))
    plot(s$v[,1], s$v[,2], xlab = "factor 1", ylab = " factor 2", cex.axis = 1.5, cex.lab = 1.5)
    text(s$v[,1], s$v[,2], labels = seq_along(s$v[,1]), pos = 1)
    dev.off()
 
    colorMatrix <- read.csv(colorData, header = FALSE)
    png(filename = paste(paste(paste(data, ".v_", sep = ''), colorLabel, sep = ''), ".png", sep = ''), res = 600, height = 3, width = 3, units = "in", pointsize = 6)
    plot(s$v[,1], s$v[,2], xlab = "factor 1", ylab = " factor 2", col = rgb(log(1 + (colorMatrix[, colorDataDim] - colorMatrix[, colorDataDim][which.min(colorMatrix[, colorDataDim])])), 0, 0, maxColorValue = log(1 + (colorMatrix[, colorDataDim][which.max(colorMatrix[, colorDataDim])] - colorMatrix[, colorDataDim][which.min(colorMatrix[, colorDataDim])])),  alpha = log(1 + (colorMatrix[, colorDataDim] - colorMatrix[, colorDataDim][which.min(colorMatrix[, colorDataDim])]))), pch = 19, cex = 1.5, cex.axis = 1.5, cex.lab = 1.5)
    dev.off()
 
    setEPS()
    postscript(paste(paste(paste(data, ".v_", sep = ''), colorLabel, sep = ''), ".eps", sep = ''))
    plot(s$v[,1], s$v[,2], xlab = "factor 1", ylab = " factor 2", col = rgb(log(1 + (colorMatrix[, colorDataDim] - colorMatrix[, colorDataDim][which.min(colorMatrix[, colorDataDim])])), 0, 0, maxColorValue = log(1 + (colorMatrix[, colorDataDim][which.max(colorMatrix[, colorDataDim])] - colorMatrix[, colorDataDim][which.min(colorMatrix[, colorDataDim])]))), pch = 19, cex = 1.5, cex.axis = 1.5, cex.lab = 1.5)
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

