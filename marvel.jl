using Printf
using SparseArrays
const spiderman = 5306

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
Recieves collaboration matrix and character matrix, calculates c^2 - c^5, then
loops through the characters to find their spiderman index number. 
"""
function CalculateSpiderman(collaborations, characters)
	collaborationsToThe0 = collaborations^0
	collaborationsToThe2 = collaborations^2
	collaborationsToThe3 = collaborations^3
	collaborationsToThe4 = collaborations^4
	collaborationsToThe5 = collaborations^5
	
	for i = 1:length(characters)
		if i == spiderman
			println( "SPI: Spiderman\t",characters[i])
		elseif collaborations[spiderman,i] > 0
			println("SPI: 1\t",characters[i])
		elseif collaborationsToThe2[spiderman,i] > 0
			println("SPI: 2\t",characters[i])
		elseif collaborationsToThe3[spiderman,i] > 0
			println("SPI: 3\t",characters[i])
		elseif collaborationsToThe4[spiderman,i] > 0 
			println("SPI: 4\t",characters[i])
		elseif collaborationsToThe5[spiderman,i] > 0
			println("SPI: 5\t",characters[i])
		else
			println("\tSPI: Unkown",characters[i])
		end
	end
end


"""
The main program for the Marvel universe assignment. In this hint version it
reads the Marvel universe network from the file "porgat.txt" and prints some
simple statistics to make sure the file was properly read. Then it computes
the collaboration matrix.
"""
function main()
    println("Reading Marvel universe network")
    characters, comics, appearances = read_network("porgat.txt")
    ncharacters = length(characters)
    ncomics = length(comics)
    nappearances = sum(appearances)
    collaborations = appearances * appearances'
	CalculateSpiderman(collaborations, characters)
end

main()
