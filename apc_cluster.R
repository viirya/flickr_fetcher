
data_cluster <- function(dataset) {
    library(apcluster)

    dataMatrix <- read.table(paste(dataset, ".data", sep = ''), row.names = 1)
    simMatrix <- negDistMat(dataMatrix)

    apresult <- apcluster(simMatrix)
    save(apresult, file = paste(dataset, ".apc", sep = ''))

    exemplars <- apresult@exemplars
    clusters <- apresult@clusters

    write.table(exemplars, file = paste(dataset, ".apc.exemplars", sep = ''))
    lapply(clusters, write.table, paste(dataset, ".apc.clusters", sep = ''), append = TRUE)

    return (apresult)
}

