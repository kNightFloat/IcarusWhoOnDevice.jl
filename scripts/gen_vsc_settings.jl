#=
  @ author: ChenyuBao <chenyu.bao@outlook.com>
  @ date: 2025-12-10 11:45:08
  @ license: MIT
  @ language: Julia
  @ declaration: IcarusWhoOnDevice.jl is a repo to find who can run on device.
  @ description: /
 =#

using JSON
using OrderedCollections

const kDeclaration = "IcarusWhoOnDevice.jl is a repo to find who can run on device."
const kVSCSettingsPath = joinpath(".vscode", "settings.json")

kAutoHeader::OrderedDict{String, Any} = OrderedDict(
    "format" => OrderedDict("startWith" => "#=", "middleWith" => "", "endWith" => "=#", "headerPrefix" => "@"),
    "header" => OrderedDict(
        "author" => "ChenyuBao <chenyu.bao@outlook.com>",
        "date" => OrderedDict("type" => "createTime", "format" => "YYYY-MM-DD HH:mm:ss"),
        "license" => "MIT",
        "language" => "Julia",
        "declaration" => kDeclaration,
        "description" => "/",
    ),
)

function main()::Nothing
    settings = OrderedDict{String, Any}()
    settings["autoHeader"] = kAutoHeader
    isdir(".vscode") || mkpath(".vscode")
    open(kVSCSettingsPath, "w") do io
        JSON.print(io, settings, 4)
    end
    return nothing
end

main()
