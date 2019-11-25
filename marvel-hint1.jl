using Plots
using Printf
using SparseArrays
using LinearAlgebra

"""
    read_network(pathname)

Read the Marvel universe network from the file. The format of the file is
given in the referenced papers.
"""
function read_network(pathname)
    # Reads the ith vertex from file
    function read_vertex(i, file)
        m = match(r"""^([0-9]*)\s*"(.*)"$""", readline(file))
        if parse(Int, m[1]) != i
            error("Vertex number $i does not match expected number $line[1]")
        end
        return m[2]
    end
    # Process the input file
    open(pathname) do file
        # Read the *Vertices line
        parsed = split(readline(file))
        if parsed[1] != "*Vertices"
            error("Missing *Vertices line")
        end
        nvertices = parse(Int, parsed[2])
        ncharacters = parse(Int, parsed[3])
        ncomics = nvertices - ncharacters
        # Read vertices - characters and comics
        characters = [read_vertex(i, file) for i = 1:ncharacters]
        comics = [read_vertex(i, file) for i = ncharacters+1:nvertices]
        # Read *Edgeslist line
        if readline(file) != "*Edgeslist" then
            error("Missing *Edgeslist line")
        end
        # Read the edges - appearances
        appearances = spzeros(Int, ncharacters, ncomics)
        while !eof(file)
            parsed = split(readline(file))
            character = parse(Int, parsed[1])
            for i = 2:length(parsed)
                comic = parse(Int, parsed[i]) - ncharacters
                appearances[character, comic] = 1
            end
        end
        return characters, comics, appearances
    end
end

"""
The main program for the Marvel universe assignment. In this hint version it
reads the Marvel universe network from the file "porgat.txt" and prints some
simple statistics to make sure the file was properly read. Then it computes
the collaboration matrix.
"""
function main()
    # Read the network
    println("Reading Marvel universe network")
    characters, comics, appearances = read_network("porgat.txt")
    ncharacters = length(characters)
    ncomics = length(comics)
    # Print some statistics
    println("Number of characters = $ncharacters")
    println("Number of comics = $ncomics")
    nappearances = sum(appearances)
    @printf("Mean books per character = %0.2f\n", nappearances / ncharacters)
    @printf("Mean characters per book = %0.2f\n", nappearances / ncomics)
    # Compute books per character histogram
    println("Plotting books per character histogram")
    let x = 1:ncharacters, y = [sum(appearances[i, :]) for i = 1:ncharacters]
        p = plot(x, y, seriestype=:histogram, title="Books per Character")
        savefig(p, "plot1.png")
    end
    # Compute characters per book histogram
    println("Plotting characters per book histogram")
    let x = 1:ncomics, y = [sum(appearances[:, j]) for j = 1:ncomics]
        p = plot(x, y, seriestype=:histogram, title="Characters per Book")
        savefig(p, "plot2.png")
    end
    # Compute collaboration matrix
    println("Computing collaboration matrix")
    collaborations = appearances * appearances'
    @show collaborations[1:30, 1:30]
    # Compute collaboration histogram
    println("Plotting collaboration histogram")
    let x = 1:ncharacters, y = [sum(collaborations[i, 1:i-1]) for i = 1:ncharacters]
        p = plot(x, y, seriestype=:histogram, title="Collaborations")
        savefig(p, "plot3.png")
    end
end

main()
