
data_cluster <- function(dataset) {
    library(apcluster)

    dataMatrix <- read.table(paste(dataset, ".data", sep = ''), row.names = 1)
    simMatrix <- negDistMat(dataMatrix)
    apresult <- apcluster(simMatrix)

    save(apresult, file = paste(dataset, ".apc", sep = ''))
    write.table(simMatrix, file = paste(dataset, ".apc.similarity", sep = ''))

    exemplars <- apresult@exemplars
    clusters <- apresult@clusters

    write.table(exemplars, file = paste(dataset, ".apc.exemplars", sep = ''))
    lapply(clusters, write.table, paste(dataset, ".apc.clusters", sep = ''), append = TRUE)

    return (apresult)
}

arg <- commandArgs(trailingOnly = TRUE)
argLen <- length(arg)
if (argLen == 1) {
    arg <- arg[argLen]
    print(paste("Clusering ", arg, " dataset...", sep = ''))
    data_cluster(arg)
}

