module RecipeView exposing (..)

import Html exposing (Html, div, p, h2, h5, text, form, input, textarea, button)
import Html.Attributes exposing (class, type', value, name, href)
import Html.Events exposing (onClick, onInput)
import Http
import Task
import Navigation exposing (modifyUrl)
import Routing
import Json.Decode exposing ((:=))
import Json.Encode as JSE
import RecipeModel as RecipeModel exposing (..)
import Util exposing (errorToString)

-- MODEL
type CrudMode
    = Read
    | Update
    | Create

type alias Model =
    { recipe : Recipe
    , mode : CrudMode
    , error : Maybe String
    }

initialModel : Model
initialModel =
    Model newRecipe Read Nothing

createNewModel : Model
createNewModel =
    Model newRecipe Create Nothing


-- MESSAGES
type Msg
    = FetchSuccess Recipe
    | FetchFailure Http.Error
    | UpdateName String
    | UpdateDescription String
    | PersistRecipe
    | DeleteRecipe
    | DeleteFailure Http.Error
    | DeleteSuccess
    | UpdateFailure Http.Error
    | UpdateSuccess
    | CreateFailure Http.Error
    | CreateSuccess RecipeId
    | UpdateRecipe

-- VIEW
view : Model -> Html Msg
view model =
    div []
        [ showError model.error
        , modeView model
        ]

showError : Maybe String -> Html Msg
showError error =
    case error of
        Just errorMsg ->
            div [ class "panel panel-danger" ]
                [ div [ class "panel-heading" ]
                    [ p [ class "panel-title" ] [ text "Error" ] ]
                , div [ class "panel-body" ] [ text errorMsg ]
                ]

        Nothing ->
            div [] []

modeView : Model -> Html Msg
modeView model =
    case model.mode of
        Read ->
            showRecipe model.recipe

        Update ->
            showForm model.recipe

        Create ->
            showForm model.recipe

showRecipe : Recipe -> Html Msg
showRecipe recipe =
    div [ class "row" ]
        [ div [ class "row" ]
            [ div [ class "col-md-12" ]
                [ button
                    [ href ""
                    , class "btn btn-sm btn-primary"
                    , onClick UpdateRecipe
                    ]
                    [ text "Update recipe" ]
                , button
                    [ href ""
                    , class "btn btn-sm btn-danger"
                    , onClick DeleteRecipe
                    ]
                    [ text "Delete recipe" ]
                ]
            ]
        , div
            [ class "row" ]
            [ div [ class "col-md-12" ]
                [ div [ class "panel panel-default" ]
                    [ div [ class "panel-heading" ]
                        [ div [ class "panel-title" ]
                            [ text recipe.name ]
                        ]
                    , div [ class "panel-body" ]
                        [ text recipe.description ]
                    ]
                ]
            ]
        ]

showForm : Recipe -> Html Msg
showForm recipe =
    div [ class "row" ]
        [ div [ class "col-md-12" ]
            [ div [ class "panel panel-primary" ]
                [ div [ class "panel-heading" ]
                    [ div [ class "panel-title" ]
                        [ text "Update recipe" ]
                    ]
                , div [ class "panel-body" ]
                    [ recipeForm recipe ]
                ]
            ]
        ]

recipeForm : Recipe -> Html Msg
recipeForm recipe =
    form []
        [ div
            [ class "row" ]
            [
              div
                [ class "col-sm-2" ]
                [ text "Name" ]
            , div
                [ class "col-sm-10" ]
                [
                  input
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
                [
                  textarea
                      [ name "description"
                      , onInput (\description -> UpdateDescription description)
                      ]
                      [ text recipe.description ]
                ]
            ]
        , div
            [ class "row" ]
            [ button
                [ onClick PersistRecipe ]
                [ text "Save" ]
            ]
        ]

-- UPDATE
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchSuccess recipe ->
            ( { model | recipe = recipe }, Cmd.none )

        FetchFailure error ->
            ( { model | error = (Just (errorToString error)) }, Cmd.none )

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
                    ( { model | mode = Read }, updateRecipe id model.recipe )

                Nothing ->
                    ( { model | mode = Read }, createRecipe model.recipe )

        DeleteRecipe ->
            case model.recipe.id of
                Just id ->
                    ( model, deleteRecipe id )

                Nothing ->
                    ( { model | error = Just "No recipe selected" }, Cmd.none )

        DeleteFailure error ->
            ( { model | error = (Just (errorToString error)) }, Cmd.none )

        DeleteSuccess ->
            ( initialModel, modifyUrl (Routing.toHash Routing.Home) )

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

        UpdateRecipe ->
            ( { model | mode = Update }, Cmd.none )

-- COMMANDS
fetchRecipe : RecipeId -> Cmd Msg
fetchRecipe id =
    Http.get recipeDecoder (recipeUrl id)
        |> Task.perform FetchFailure FetchSuccess

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

idDecoder : Json.Decode.Decoder Int
idDecoder =
    "id" := Json.Decode.int

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

deleteRecipe : RecipeId -> Cmd Msg
deleteRecipe id =
    Http.send Http.defaultSettings (deleteRequest id)
        |> Http.fromJson Json.Decode.value
        |> Task.perform DeleteFailure (\_ -> DeleteSuccess)

deleteRequest : RecipeId -> Http.Request
deleteRequest id =
    { verb = "DELETE"
    , headers = []
    , url = recipeUrl id
    , body = Http.empty
    }

baseRecipeUrl : String
baseRecipeUrl =
    "http://localhost:3000/recipe/"

recipeUrl : RecipeId -> String
recipeUrl id =
    baseRecipeUrl ++ (toString id)
