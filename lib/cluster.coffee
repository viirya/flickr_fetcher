
lazy = require('lazy')
fs = require('fs')

class VladCluster

    constructor: () ->

    load_clusers: (apcfile, cb) ->

        readStream = fs.createReadStream("#{apcfile}")
        readStream.on('error', (err) =>
            console.log(err)
        ) 
        
        @clusters = []
        cur_cluster = {}
        new lazy(readStream)
            .lines
            .forEach((line) =>
            
                add_cluster_member = (match) =>
                    member = match[1]
            
                    if (cur_cluster.exemplar?)
                        unless (cur_cluster.member?)
                            cur_cluster.member = []
                        cur_cluster.member.push(member)
                    else 
                        cur_cluster.exemplar = member
                        cur_cluster.member = []
            
                line = line.toString()
            
                regex = /\"x\"/
                match = regex.exec(line)
        
                if (match?)
                    if (cur_cluster.exemplar?)
                        @clusters.push(cur_cluster)
                    cur_cluster = {}
        
                regex = /\"(.*?)\"\s.*/
                match = regex.exec(line)
            
                if (match?)
                    add_cluster_member(match)
        
            ).on('end', =>

                if (cur_cluster.exemplar?)
                    @clusters.push(cur_cluster)

                console.log("Cluster file parsed.")
                if (cb?)
                    cb(@clusters)
            )


    iter: (cb) ->

        if (@clusters?)
            for cluster in @clusters
                if (cb?)
                    cb(cluster.exemplar, cluster.member)


exports.VladCluster = VladCluster

