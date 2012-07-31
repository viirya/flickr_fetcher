
lazy = require('lazy')
fs = require('fs')

class APCluster

    constructor: () ->

    load_clusers: (@pathname, @mappingfile, cb) ->

        @load_mapping(=>

            fs.readdir("#{@pathname}", (err, files) =>
                console.log(files)
                @clusters = []
                @assoc_clusters = {}
            
                load = =>
                    file = files.pop()
                    if (file?) 
                        console.log("processing #{file}")
                        @load_file(file, load)
                    else
                        @fill_clusters()
                        if (cb?)
                            cb(@clusters)
                    
                load()
                
            )
        )

    load_mapping: (cb) ->

        readStream = fs.createReadStream("#{@mappingfile}")
        readStream.on('error', (err) =>
            console.log(err)
        ) 
        count = 0
        @mapping = {}

        console.log("loading image id mapping file")

        new lazy(readStream)
            .lines
            .forEach((line) =>

                line = line.toString()
                @mapping[count] = line
                count++
 
            ).on('end', =>
                cb()
            )
 
    fill_clusters: ->

        for exemplar, members of @assoc_clusters
            cluster = {}
            cluster.exemplar = exemplar
            cluster.member  = members

            @clusters.push(cluster)

        console.log(@clusters)

    load_file: (file, cb) ->

        readStream = fs.createReadStream("#{@pathname}/#{file}")
        readStream.on('error', (err) =>
            console.log(err)
        ) 
        
        new lazy(readStream)
            .lines
            .forEach((line) =>
 
                add_cluster_member = (match) =>
                    member = @mapping[match[1]]
                    exemplar = @mapping[match[2]]

                    if (exemplar != '-1')
                        unless (@assoc_clusters[exemplar]?)
                            @assoc_clusters[exemplar] = []

                        if (@assoc_clusters[exemplar]?)
                            @assoc_clusters[exemplar].push(member)

                line = line.toString()
            
                regex = /(.*?)\t(.*?)\s(.*?)\s(.*?)\s(.*)/
                match = regex.exec(line)

                if (match?)
                    add_cluster_member(match)
            
            ).on('end', =>
                cb()
            )
 


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
exports.APCluster = APCluster


