
stats <- function(dataDimX, dataDimY, colorMatrix, xThresholds, yThreshold) {

    record_nums = NULL

    for (i in 1:length(xThresholds)) {
        record_nums[i] = nrow(colorMat[colorMat[, dataDimX] > xThresholds[i] - 0.05 & colorMat[, dataDimX] < xThresholds[i] + 0.05 & colorMat[, dataDimY] > yThreshold, ]) / (nrow(colorMat[colorMat[, dataDimX] > xThresholds[i] - 0.05 & colorMat[, dataDimX] < xThresholds[i] + 0.05, ]) + 1)
    }
    return(record_nums)
}

perform_plot_regression <- function(colorData, colorDataDim, colorLabel, xLabel, yLabel, dataDimX, dataDimY, logScale) {

    colorMatrix <- read.csv(colorData, header = FALSE)
    print(colorMatrix)

    yStats = seq(0.0, 0.9, by = 0.2)
    xStats = stats(dataDimX, dataDimY, colorMatrix, yStats, 400)
    print(xStats)
    print(yStats)

    lm.out = lm(xStats ~ (I(yStats ^ 2) + yStats))
    summary(lm.out)

    setEPS()
    postscript(paste(paste(paste(colorData, "_", sep = ''), colorLabel, sep = ''), ".eps", sep = ''))
    par(mfrow=c(1,1)) 
    plot(xStats ~ yStats)
    curve(0.11397 + 0.36582 * x ^ 2 - 0.12958 * x, add = TRUE)
    #plot(lm.out$fitted, lm.out$resid)
    #plot(lm.out$fitted, lm.out$resid, xlab = xLabel, ylab = yLabel, pch = 19, cex = 1.5, log = logScale, cex.axis = 1.5, cex.lab = 1.5, yaxp = c(10, 1000, 1))
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
    perform_plot_regression(colorData, colorDataDim, colorLabel, xLabel, yLabel, dataDimX, dataDimY, logScale)
}

