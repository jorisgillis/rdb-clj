module RecipeView exposing (..)

import Html exposing (Html, div, p, h2, h5, text)
import Html.Attributes exposing (class)
import Http
import Task
import Navigation exposing (newUrl)
import Json.Decode

import RecipeModel exposing (RecipeId, Recipe, recipeDecoder)
import Util exposing (errorToString)

-- MODEL
type alias Model =
    { recipeId : Maybe RecipeId
    , recipe   : Maybe Recipe
    , error    : Maybe String
    }

initialModel : Model
initialModel = Model Nothing Nothing Nothing

-- MESSAGES
type Msg
    = Load RecipeId
    | FetchSuccess Recipe
    | FetchFailure Http.Error
    | Edit
    | Delete
    | DeleteFailure Http.Error
    | DeleteSuccess
    | Overview

-- VIEW
view : Model -> Html Msg
view recipe =
    div [] [ (showError recipe.error)
           , (showRecipe recipe.recipe) ]

showError : Maybe String -> Html Msg
showError error =
    case error of
        Just errorMsg ->
            div [ class "panel panel-danger" ]
                [ div [ class "panel-heading" ]
                      [ p [ class "panel-title" ] [ text "Error" ] ]
                , div [ class "panel-body" ] [ text errorMsg ] 
                ]
        Nothing -> div [] []

showRecipe : Maybe Recipe -> Html Msg
showRecipe mRecipe =
    case mRecipe of
        Just recipe ->
            div [ class "row" ]
                [ div [ class "col-md-12" ]
                      [ h2 [] [ text recipe.name ]
                      , p [] [ text recipe.description ]
                      ]
                ]
        Nothing ->
            div [] [ h5 [] [ text "No recipe found" ] ]

-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Load id ->
            ({ model | recipeId = Just id, error = Nothing }, fetchRecipe id)

        FetchSuccess recipe ->
            ({ model | recipe = Just recipe }, Cmd.none)

        FetchFailure error ->
            ({ model |
                   recipe = Nothing,
                   error = (Just (errorToString error))
             }
            , Cmd.none)

        Edit ->
            case model.recipeId of
                Just id ->
                    let
                        editUrl =
                            "/recipe" ++ (toString id) ++ "/edit/"
                    in
                        (model, (newUrl editUrl))
                Nothing ->
                    ({ model | error = Just "No recipe selected" }, Cmd.none)

        Delete ->
            case model.recipeId of
                Just id ->
                    (model, deleteRecipe id)
                Nothing ->
                    ({ model | error = Just "No recipe selected" }, Cmd.none)

        DeleteFailure error ->
            ({ model | error = (Just (errorToString error)) }, Cmd.none)

        DeleteSuccess ->
            (initialModel, newUrl "/")
                        
        Overview ->
            (model, newUrl "/")
                        
fetchRecipe : RecipeId -> Cmd Msg
fetchRecipe id =
    Http.get recipeDecoder ("http://localhost:3000/recipe" ++ (toString id))
        |> Task.perform FetchFailure FetchSuccess

deleteRecipe : RecipeId -> Cmd Msg
deleteRecipe id =
    Http.send Http.defaultSettings (deleteRequest id)
        |> Http.fromJson (Json.Decode.succeed ())
        |> Task.perform DeleteFailure (\_ -> DeleteSuccess)

deleteRequest : RecipeId -> Http.Request
deleteRequest id =
        { verb = "DELETE"
        , headers = []
        , url = ("http://localhost:3000/recipe/" ++ (toString id))
        , body = Http.empty
        }
