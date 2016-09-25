module RecipeEdit exposing (..)

import Http
import Html exposing (Html, div, p, h2, h5, text, form, input, textarea, button)
import Html.Attributes exposing (class, type', value, name, href)
import Html.Events exposing (onClick, onInput)
import Task
import Navigation exposing (modifyUrl)
import Routing
import Json.Decode exposing ((:=))
import Json.Encode as JSE
import RecipeModel as RecipeModel exposing (..)
import ErrorHandling exposing (errorToString, showError)


type Msg
    = UpdateName String
    | UpdateDescription String
    | PersistRecipe
    | Cancel
    | UpdateFailure Http.Error
    | UpdateSuccess
    | CreateFailure Http.Error
    | CreateSuccess RecipeId


showForm : Recipe -> Html Msg
showForm recipe =
    div [ class "row" ]
        [ div [ class "col-sm-12" ]
            [ div [ class "panel panel-primary" ]
                [ div [ class "panel-heading" ]
                    [ div [ class "panel-title" ]
                        [ text "Edit recipe" ]
                    ]
                , div [ class "panel-body" ]
                    [ recipeForm recipe ]
                ]
            ]
        ]


view : RecipeModel -> Html Msg
view model =
    div []
        [ showError model.error
        , recipeForm model.recipe
        ]


recipeForm : Recipe -> Html Msg
recipeForm recipe =
    form []
        [ div
            [ class "row" ]
            [ div
                [ class "col-sm-2" ]
                [ text "Name" ]
            , div
                [ class "col-sm-10" ]
                [ input
                    [ type' "text"
                    , value recipe.name
                    , onInput (\name -> UpdateName name)
                    ]
                    []
                ]
            ]
        , div
            [ class "row" ]
            [ div
                [ class "col-sm-2" ]
                [ text "Description" ]
            , div
                [ class "col-sm-10" ]
                [ textarea
                    [ name "description"
                    , onInput (\description -> UpdateDescription description)
                    ]
                    [ text recipe.description ]
                ]
            ]
        , div
            [ class "row" ]
            [ div
                [ class "col-sm-2" ]
                [ button
                    [ class "btn btn-sm btn-primary"
                    , onClick PersistRecipe
                    ]
                    [ text "Save" ]
                ]
            , div
                [ class "col-sm-2" ]
                [ button
                    [ class "btn btn-sm btn-primary"
                    , onClick Cancel
                    ]
                    [ text "Cancel" ]
                ]
            ]
        ]


update : Msg -> RecipeModel -> ( RecipeModel, Cmd Msg )
update msg model =
    case msg of
        UpdateName name ->
            let
                recipe =
                    model.recipe

                newRecipe =
                    { recipe | name = name }
            in
                ( { model | recipe = newRecipe }, Cmd.none )

        UpdateDescription description ->
            let
                recipe =
                    model.recipe

                newRecipe =
                    { recipe | description = description }
            in
                ( { model | recipe = newRecipe }, Cmd.none )

        PersistRecipe ->
            case model.recipe.id of
                Just id ->
                    ( model, updateRecipe id model.recipe )

                Nothing ->
                    ( model, createRecipe model.recipe )

        Cancel ->
            let
                cmd =
                    case model.recipe.id of
                        Just id ->
                            Navigation.modifyUrl
                                (Routing.toHash (Routing.RecipeView id))

                        Nothing ->
                            Navigation.modifyUrl
                                (Routing.toHash (Routing.Home))
            in
                ( model, cmd )

        UpdateFailure error ->
            ( { model | error = (Just (errorToString error)) }, Cmd.none )

        UpdateSuccess ->
            ( { model | error = Nothing }, Cmd.none )

        CreateFailure error ->
            ( { model | error = (Just (errorToString error)) }, Cmd.none )

        CreateSuccess id ->
            let
                recipe =
                    model.recipe

                newRecipe =
                    { recipe | id = Just id }
            in
                ( { model | recipe = newRecipe, error = Nothing }, Cmd.none )


idDecoder : Json.Decode.Decoder Int
idDecoder =
    "id" := Json.Decode.int


updateRecipe : RecipeId -> Recipe -> Cmd Msg
updateRecipe id recipe =
    Http.send Http.defaultSettings (updateRequest id recipe)
        |> Http.fromJson Json.Decode.value
        |> Task.perform UpdateFailure (\_ -> UpdateSuccess)


updateRequest : RecipeId -> Recipe -> Http.Request
updateRequest id recipe =
    { verb = "PUT"
    , headers = [ ( "Content-Type", "application/json" ) ]
    , url = baseRecipeUrl
    , body = Http.string (updateRequestBody id recipe)
    }


updateRequestBody : RecipeId -> Recipe -> String
updateRequestBody id recipe =
    let
        jsonRecipe =
            (JSE.object
                [ ( "id", JSE.int id )
                , ( "name", JSE.string recipe.name )
                , ( "description", JSE.string recipe.description )
                ]
            )
    in
        JSE.encode 0 jsonRecipe


createRecipe : Recipe -> Cmd Msg
createRecipe recipe =
    Http.send Http.defaultSettings (createRequest recipe)
        |> Http.fromJson idDecoder
        |> Task.perform CreateFailure CreateSuccess


createRequest : Recipe -> Http.Request
createRequest recipe =
    { verb = "POST"
    , headers = [ ( "Content-Type", "application/json" ) ]
    , url = baseRecipeUrl
    , body = Http.string (createRequestBody recipe)
    }


createRequestBody : Recipe -> String
createRequestBody recipe =
    let
        jsonRecipe =
            (JSE.object
                [ ( "name", JSE.string recipe.name )
                , ( "description", JSE.string recipe.description )
                ]
            )
    in
        JSE.encode 0 jsonRecipe
