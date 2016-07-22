module Recipe exposing (..)

import Http
import Json.Decode as Decode exposing ((:=))
import Task
import Html exposing (..)

-- MESSAGES
type Msg
    = FetchSuccess (List Recipe)
    | FetchFailure Http.Error

-- MODEL
type alias RecipeId =
    Int

type alias Recipe =
    { id : RecipeId
    , name : String
    , description : String
    }

-- VIEW
view : List Recipe -> List String -> Html Msg
view recipes errors =
    div []
        [ (showErrors errors)
        , (showRecipes recipes)
        ]

showErrors : List String -> Html Msg
showErrors errors = div [] (List.map text errors)

showRecipes : List Recipe -> Html Msg
showRecipes recipes =
    div []
        [ h1 [] [ text "Recipes" ]
        , div []
            [table []
                 [thead []
                      [tr []
                           [ th [] [ text "ID" ]
                           , th [] [ text "Name" ]
                           , th [] [ text "Description" ]
                           ]
                      ]
                 , tbody [] (List.map recipeRow recipes)
                 ]
            ]
        ]

recipeRow : Recipe -> Html Msg
recipeRow recipe =
    tr []
        [ td [] [ text (toString recipe.id) ]
        , td [] [ text recipe.name ]
        , td [] [ text recipe.description ]
        ]

-- UPDATE
type alias APIRecipeList =
    { recipes : Maybe (List Recipe)
    , error : Maybe String
    }

update : Msg -> List Recipe -> (APIRecipeList, Cmd Msg)
update message recipes =
    case message of
        FetchSuccess newRecipes ->
            (APIRecipeList (Just newRecipes) (Nothing), Cmd.none)
        FetchFailure error ->
            (APIRecipeList (Nothing) (Just (errorToString error)), Cmd.none)

errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.Timeout             -> "Timeout"
        Http.NetworkError        -> "NetworkError"
        Http.UnexpectedPayload e -> "UnexpectedPayload: " ++ e
        Http.BadResponse code e  -> "BadResponse: " ++ (toString code) ++ " " ++ e
            
fetchAll : Cmd Msg
fetchAll = Http.get collectionDecoder fetchAllUrl
           |> Task.perform FetchFailure FetchSuccess

fetchAllUrl : String
fetchAllUrl = "http://localhost:3000/recipe"

collectionDecoder : Decode.Decoder (List Recipe)
collectionDecoder =
    Decode.list memberDecoder

memberDecoder : Decode.Decoder Recipe
memberDecoder =
    Decode.object3 Recipe
        ("id" := Decode.int)
        ("name" := Decode.string)
        ("description" := Decode.string)

