module RecipeModel exposing (RecipeId, Recipe, recipeDecoder)

import Json.Decode as Decode exposing ((:=))

type alias RecipeId =
    Int

type alias Recipe =
    { id : RecipeId
    , name : String
    , description : String
    }

recipeDecoder : Decode.Decoder Recipe
recipeDecoder =
    Decode.object3 Recipe
        ("id" := Decode.int)
        ("name" := Decode.string)
        ("description" := Decode.string)

