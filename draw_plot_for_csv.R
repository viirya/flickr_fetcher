
perform_draw <- function(colorData, colorDataDim, colorLabel, xLabel, yLabel, dataDimX, dataDimY, logScale) {

    colorMatrix <- read.csv(colorData, header = FALSE)
    print(colorMatrix)
    png(filename = paste(paste(paste(colorData, "_", sep = ''), colorLabel, sep = ''), ".png", sep = ''))
    plot(colorMatrix[,dataDimX], colorMatrix[,dataDimY], xlab = xLabel, ylab = yLabel, col = hsv(colorMatrix[, colorDataDim], colorMatrix[, colorDataDim + 1], colorMatrix[, colorDataDim + 2], 1), pch = 19, cex = 1.5, log = logScale, cex.axis = 1.5, cex.lab = 1.5)
    dev.off()
 

    setEPS()
    postscript(paste(paste(paste(colorData, "_", sep = ''), colorLabel, sep = ''), ".eps", sep = ''))
    plot(colorMatrix[,dataDimX], colorMatrix[,dataDimY], xlab = xLabel, ylab = yLabel, col = hsv(colorMatrix[, colorDataDim], colorMatrix[, colorDataDim + 1], colorMatrix[, colorDataDim + 2], 1), pch = 19, cex = 1.5, log = logScale, cex.axis = 1.5, cex.lab = 1.5, yaxp = c(10, 1000, 1))
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

