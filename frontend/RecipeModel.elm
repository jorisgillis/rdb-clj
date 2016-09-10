module RecipeModel exposing (..)

import Json.Decode as Decode exposing ((:=))


type alias RecipeId =
    Int


type alias Recipe =
    { id : Maybe RecipeId
    , name : String
    , description : String
    }


newRecipe : Recipe
newRecipe =
    { id = Nothing
    , name = ""
    , description = ""
    }


recipeDecoder : Decode.Decoder Recipe
recipeDecoder =
    Decode.object3 Recipe
        ("id" := Decode.maybe Decode.int)
        ("name" := Decode.string)
        ("description" := Decode.string)
