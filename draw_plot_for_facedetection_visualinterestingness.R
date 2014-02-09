
perform_draw <- function(colorData, colorDataDim, colorLabel, xLabel, yLabel, dataDimX, dataDimY, logScale) {

    colorMatrix <- read.csv(colorData, header = FALSE)
    print(colorMatrix)
    png(filename = paste(paste(paste(colorData, "_", sep = ''), colorLabel, sep = ''), ".png", sep = ''))
    plot(log(colorMatrix[,dataDimX] + 1) / log(which.max(colorMatrix[,dataDimX]) + 1), log(colorMatrix[,dataDimY] + 1) / log(which.max(colorMatrix[,dataDimY]) + 1), xlab = xLabel, ylab = yLabel, col = rgb(log(1 + (colorMatrix[, colorDataDim] - colorMatrix[, colorDataDim][which.min(colorMatrix[, colorDataDim])])), 0, 0, maxColorValue = log(1 + (colorMatrix[, colorDataDim][which.max(colorMatrix[, colorDataDim])] - colorMatrix[, colorDataDim][which.min(colorMatrix[, colorDataDim])]))), pch = 19, cex = 1.5, log = logScale, cex.axis = 1.5, cex.lab = 1.5, xaxp = c(0.4, 1, 10), yaxp = c(0, 1, 10), xlim = c(0.4, 1))
    dev.off()
 

    setEPS()
    postscript(paste(paste(paste(colorData, "_", sep = ''), colorLabel, sep = ''), ".eps", sep = ''))
    plot(log(colorMatrix[,dataDimX] + 1) / log(which.max(colorMatrix[,dataDimX]) + 1), colorMatrix[,dataDimY], xlab = xLabel, ylab = yLabel, col = rgb(log(1 + (colorMatrix[, colorDataDim] - colorMatrix[, colorDataDim][which.min(colorMatrix[, colorDataDim])])), 0, 0, maxColorValue = log(1 + (colorMatrix[, colorDataDim][which.max(colorMatrix[, colorDataDim])] - colorMatrix[, colorDataDim][which.min(colorMatrix[, colorDataDim])]))), pch = 19, cex = 1.5, log = logScale, cex.axis = 1.5, cex.lab = 1.5, xaxp = c(0.4, 1, 10), yaxp = c(1, 10, 1), xlim = c(0.4, 1))
    dev.off()
 
}

arg <- commandArgs(trailingOnly = TRUE)
argLen <- length(arg)
if (argLen >= 7) {
    colorData <- arg[1]
    dataDimX <- as.numeric(arg[2])
    dataDimY <- as.numeric(arg[3])
    colorDataDim <- as.numeric(arg[4])
    xLabel <- arg[5]
    yLabel <- arg[6]
    colorLabel <- arg[7]
    logScale <- ""
    if (argLen == 8) {
        logScale <- arg[8]
    }
    print(paste("Draw plot on ", arg, " data...", sep = ''))
    perform_draw(colorData, colorDataDim, colorLabel, xLabel, yLabel, dataDimX, dataDimY, logScale)
}

