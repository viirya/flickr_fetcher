
output_plot <- function(index, data, color, xlim, ylim) {

    dataMatrix <- read.csv(data, header = FALSE)
 
    if (index == 1) {
        plot(log(1 + dataMatrix[,2]), log(1 + dataMatrix[,1]), xlim = xlim, ylim = ylim, type = "p", col = color, cex = 1.5)
    } else {
        points(log(1 + dataMatrix[,2]), log(1 + dataMatrix[,1]), type = "p", col = color, cex = 1.5)
    }
 
}

arg <- commandArgs(trailingOnly = TRUE)
argLen <- length(arg)
if (argLen <= 5) {

    x_coords = c()
    y_coords = c()
    for (argIndex in 1:(argLen - 1)) {
        dataMatrix <- read.csv(arg[argIndex], header = FALSE)
        x_coords <- append(x_coords, dataMatrix[, 2])
        y_coords <- append(y_coords, dataMatrix[, 1])
    }

    x_min = x_coords[which.min(x_coords)]
    y_min = y_coords[which.min(y_coords)]
 
    x_max = x_coords[which.max(x_coords)]
    y_max = y_coords[which.max(y_coords)]

    xlim = c(log(1 + x_min), log(1 + x_max))
    ylim = c(log(1 + y_min), log(1 + y_max))

    print(xlim)
    print(ylim)
 
    symbols = 19:25
    colors = c("red", "blue", "yellow", "purple")

    png(filename = paste(arg[argLen], ".png", sep = ''))
    for (argIndex in 1:(argLen - 1)) {
 
        print(paste("Output plot for ", arg[argIndex], " data...", sep = ''))

        output_plot(argIndex, arg[argIndex], colors[argIndex], xlim, ylim)

    }
    dev.off()

}

