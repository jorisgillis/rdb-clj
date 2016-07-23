module Recipe exposing (..)

import Http
import Json.Decode as Decode exposing ((:=))
import Task
import Html exposing (..)
import Bootstrap.Html exposing (row_, colXs_, container_)

-- MESSAGES
type Msg
    = FetchSuccess {recipes : (List Recipe)}
    | FetchFailure Http.Error

-- MODEL
type alias RecipeId =
    Int

type alias Recipe =
    { id : RecipeId
    , name : String
    , description : String
    }

type alias Model =
    { recipes : List Recipe
    , error   : Maybe String
    }

initialModel : Model
initialModel = Model [] (Nothing)

-- VIEW
view : Model -> Html Msg
view model =
    div []
        [ (row_ [(colXs_ 12 [(showError model.error)])])
        , (row_ [(colXs_ 12 [(showRecipes model.recipes)])])
        ]

showError : Maybe String -> Html Msg
showError x =
    case x of
        Just error -> div [] [ text error ]
        Nothing    -> div [] []

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
update : Msg -> Model -> (Model, Cmd Msg)
update message recipes =
    case message of
        FetchSuccess newRecipes ->
            (Model newRecipes.recipes (Nothing), Cmd.none)
        FetchFailure error ->
            (Model [] (Just (errorToString error)), Cmd.none)

errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.Timeout             -> "Timeout"
        Http.NetworkError        -> "NetworkError"
        Http.UnexpectedPayload e -> "UnexpectedPayload: " ++ e
        Http.BadResponse code e  -> "BadResponse: " ++ (toString code) ++ " " ++ e

fetchAll : Cmd Msg
fetchAll =
    Http.get recipesDecoder "http://localhost:3000/recipe/"
        |> Task.perform FetchFailure FetchSuccess

type alias Recipes = { recipes : (List Recipe) }
              
recipesDecoder : Decode.Decoder Recipes
recipesDecoder =
    Decode.object1 Recipes ("recipes" := collectionDecoder)
              
collectionDecoder : Decode.Decoder (List Recipe)
collectionDecoder =
    Decode.list memberDecoder

memberDecoder : Decode.Decoder Recipe
memberDecoder =
    Decode.object3 Recipe
        ("id" := Decode.int)
        ("name" := Decode.string)
        ("description" := Decode.string)

