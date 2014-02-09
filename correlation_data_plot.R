
output_plot <- function(data, symbol) {

    dataMatrix <- read.csv(data, header = FALSE)

    png(filename = paste(data, ".png", sep = ''))
    plot(log(1 + dataMatrix[,2]), dataMatrix[,1], pch = symbol, cex = 1.5)
    dev.off()

}

arg <- commandArgs(trailingOnly = TRUE)
argLen <- length(arg)
if (argLen <= 5) {
    symbols = 19:25
    for (argIndex in 1:argLen) {
        print(paste("Output plot for ", arg[argIndex], " data...", sep = ''))
        output_plot(arg[argIndex], symbols[argIndex])
    }
}

