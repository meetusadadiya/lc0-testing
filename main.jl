using JSON

args = []
config = JSON.parsefile("config.json")

for option in config["cli"]
    if !isempty(option[2])
        if typeof(option[2])==String
            if option[2]=="true"
                push!(args,"-$(option[1])")
            elseif option[2]!="false"
                push!(args,"-$(option[1])", "$(option[2])")
            end
        else
            push!(args,"-$(option[1])")
            for params in option[2]
                if !isempty(params[2])
                    push!(args,"$(params[1])=$(params[2])")
                end
            end
        end
    end
end

sfpath = "engines/stockfish-11-popcnt/stockfish_20011801_x64_modern.exe"
lc0path = "engines/lc0-cudnn/lc0.exe"

push!(args,"-engine","name=Stockfish-11","cmd=$sfpath")
push!(args,"option.Threads=$(config["Threads"])")
push!(args,"option.SyzygyPath=$(config["tablebases"])")

for net in readdir("nets/")
    push!(args,"-engine","name=Lc0-$net","cmd=$lc0path")
    push!(args,"option.WeightsFile=$(pwd())\\nets\\$net")
    push!(args,"option.Backend=cudnn-auto")
    push!(args,"option.Threads=2")
    push!(args,"option.SyzygyPath=$(config["tablebases"])")

end

# print(args)
run(`cutechess-cli $args`)
