module AutocompleteWrapper exposing (..)

import Autocomplete
import Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Task


type Msg
    = SetQuery String
    | SetAutoState Autocomplete.Msg
    | Wrap Bool
    | SelectMenuItemKeyboard String
    | SelectMenuItemMouse String
    | PreviewMenuItem String
    | HandleEscape
    | OnFocusAutocom
    | OnBlurAutocom
    | PreventFocusAndBlur
    | Reset
    | NoOpAutocom


type alias MenuItem =
    String


type alias Model =
    { value : String
    , id : String
    , name : String
    , menuItems : List MenuItem
    , state : Autocomplete.State
    , howManyToShow : Int
    , selectedMenuItem : Maybe MenuItem
    , showMenu : Bool
    , focus : Bool
    , preventingBlur : Bool
    , preventingFocus : Bool
    }


init : String -> String -> List MenuItem -> Model
init id name menuItems1 =
    { value = ""
    , id = id
    , name = name
    , menuItems = menuItems1
    , state = Autocomplete.empty
    , howManyToShow = 50
    , selectedMenuItem = Nothing
    , showMenu = False
    , focus = False
    , preventingBlur = False
    , preventingFocus = False
    }


update :
    Msg
    -> Model
    -> (String -> Msg -> msg)
    -> (msg -> ( a, Msg ))
    -> ( Model, Cmd msg )
update msg model originMessage msgConverter =
    case msg of
        SetQuery newQuery ->
            let
                showMenu =
                    not << List.isEmpty <| acceptableItems newQuery model.menuItems
            in
            { model
                | value = newQuery
                , showMenu = showMenu
                , selectedMenuItem = Nothing
            }
                ! []

        SetAutoState autoMsg ->
            if not model.focus then
                model ! []
            else
                let
                    ( newState, maybeMsg ) =
                        Autocomplete.update (updateConfig model.id originMessage) autoMsg model.howManyToShow model.state (acceptableItems model.value model.menuItems)

                    newModel =
                        { model | state = newState }
                in
                case maybeMsg of
                    Nothing ->
                        newModel ! []

                    Just updateMsg ->
                        let
                            ( id, autocomMsg ) =
                                msgConverter updateMsg
                        in
                        update autocomMsg newModel originMessage msgConverter

        Wrap toTop ->
            case model.selectedMenuItem of
                Just menuItem ->
                    update Reset model originMessage msgConverter

                Nothing ->
                    if toTop then
                        { model
                            | state = Autocomplete.resetToLastItem (updateConfig model.id originMessage) (acceptableItems model.value model.menuItems) model.howManyToShow model.state
                            , selectedMenuItem = List.head <| List.reverse <| List.take model.howManyToShow <| acceptableItems model.value model.menuItems
                        }
                            ! []
                    else
                        { model
                            | state = Autocomplete.resetToFirstItem (updateConfig model.id originMessage) (acceptableItems model.value model.menuItems) model.howManyToShow model.state
                            , selectedMenuItem = List.head <| List.take model.howManyToShow <| acceptableItems model.value model.menuItems
                        }
                            ! []

        SelectMenuItemKeyboard id ->
            let
                newModel =
                    setQuery model id
                        |> resetMenu
            in
            newModel ! []

        SelectMenuItemMouse id ->
            let
                newModel =
                    setQuery model id
                        |> resetMenu

                msgId =
                    99
            in
            -- Giving the focus again (Dom.focus) because it was lost upon
            -- the click on the menu
            ( newModel, Task.attempt (\_ -> originMessage model.id NoOpAutocom) (Dom.focus model.id) )

        PreviewMenuItem id ->
            { model | selectedMenuItem = Just <| getMenuItemAtId model.menuItems id } ! []

        HandleEscape ->
            let
                validOptions =
                    not <| List.isEmpty (acceptableItems model.value model.menuItems)

                handleEscape =
                    if validOptions then
                        model
                            |> removeSelection
                            |> resetMenu
                    else
                        model
                            |> resetInput

                escapedModel =
                    case model.selectedMenuItem of
                        Just menuItem ->
                            if model.value == menuItem then
                                model
                                    |> resetInput
                            else
                                handleEscape

                        Nothing ->
                            handleEscape
            in
            escapedModel ! []

        Reset ->
            { model | state = Autocomplete.reset (updateConfig model.id originMessage) model.state, selectedMenuItem = Nothing }
                ! []

        OnFocusAutocom ->
            -- lucamug -
            if model.preventingFocus then
                { model | preventingFocus = False } ! []
            else
                { model | focus = True, showMenu = True } ! []

        OnBlurAutocom ->
            -- Closing the drop down on Blur
            if model.preventingBlur then
                { model | preventingBlur = False } ! []
            else
                { model | focus = False, showMenu = False } ! []

        PreventFocusAndBlur ->
            { model | preventingFocus = True, preventingBlur = True } ! []

        NoOpAutocom ->
            model ! []


resetMenu : Model -> Model
resetMenu model =
    { model
        | state = Autocomplete.empty
        , showMenu = False
    }


removeSelection : Model -> Model
removeSelection model =
    { model | selectedMenuItem = Nothing }


resetInput : Model -> Model
resetInput model =
    { model | value = "" }
        |> removeSelection
        |> resetMenu


getMenuItemAtId : List String -> String -> String
getMenuItemAtId menuItems id =
    List.filter (\menuItem -> menuItem == id) menuItems
        |> List.head
        |> Maybe.withDefault ""


setQuery : Model -> String -> Model
setQuery model id =
    { model
        | value = getMenuItemAtId model.menuItems id
        , selectedMenuItem = Just <| getMenuItemAtId model.menuItems id
    }


acceptableItems : String -> List String -> List String
acceptableItems value menuItems =
    let
        lowerQuery =
            String.toLower value
    in
    List.filter (String.contains lowerQuery << String.toLower) menuItems


view : Model -> (String -> Msg -> msg) -> Html msg
view model originMessage =
    -- originMessage = MsgAutocom
    let
        options =
            { preventDefault = True, stopPropagation = False }

        dec =
            Decode.map
                (\code ->
                    if code == 38 || code == 40 then
                        Ok (originMessage model.id NoOpAutocom)
                    else if code == 27 then
                        Ok (originMessage model.id HandleEscape)
                    else
                        Err "not handling that key"
                )
                keyCode
                |> Decode.andThen
                    fromResult

        -- fromResult : Result String a -> Decode.Decoder a
        fromResult result =
            case result of
                Ok val ->
                    Decode.succeed val

                Err reason ->
                    Decode.fail reason

        menu =
            if model.showMenu then
                [ viewMenu model originMessage ]
            else
                []

        fieldValue =
            case model.selectedMenuItem of
                Just menuItem ->
                    menuItem

                Nothing ->
                    model.value

        activeDescendant attributes =
            case model.selectedMenuItem of
                Just menuItem ->
                    attribute "aria-activedescendant"
                        menuItem
                        :: attributes

                Nothing ->
                    attributes
    in
    label [ style [ ( "position", "relative" ) ] ]
        (List.append
            [ div
                [ classList
                    [ ( "placeholder", True )
                    , ( "upperPosition", model.focus || fieldValue /= "" )
                    ]
                ]
                [ text model.name ]
            , input
                (activeDescendant
                    [ type_ "text"
                    , onInput (originMessage model.id << SetQuery)
                    , onFocus (originMessage model.id OnFocusAutocom)
                    , onBlur (originMessage model.id OnBlurAutocom)
                    , onWithOptions "keydown" options dec
                    , value fieldValue
                    , id model.id
                    , classList
                        [ ( "autocomplete-input", True )
                        , ( "autocomplete-open", model.showMenu )
                        ]
                    , autocomplete False
                    , attribute "aria-owns" "list-of-presidents"
                    , attribute "aria-expanded" <| String.toLower <| toString model.showMenu
                    , attribute "aria-haspopup" <| String.toLower <| toString model.showMenu
                    , attribute "role" "combobox"
                    , attribute "aria-autocomplete" "list"
                    ]
                )
                []
            ]
            menu
        )


viewMenu : Model -> (String -> Msg -> msg) -> Html msg
viewMenu model originMessage =
    -- This is the menu that appear below the input box
    div [ class "autocomplete-menu", onMouseDown (originMessage model.id PreventFocusAndBlur) ]
        [ Html.map (originMessage model.id << SetAutoState) (Autocomplete.view viewConfig model.howManyToShow model.state (acceptableItems model.value model.menuItems)) ]


viewConfig : Autocomplete.ViewConfig String
viewConfig =
    let
        customizedLi keySelected mouseSelected menuItem =
            { attributes =
                [ classList [ ( "autocomplete-item", True ), ( "key-selected", keySelected || mouseSelected ) ]
                , id menuItem
                ]
            , children = [ Html.text menuItem ]
            }
    in
    Autocomplete.viewConfig
        { toId = \id -> id
        , ul = [ class "autocomplete-list" ]
        , li = customizedLi
        }


updateConfig : String -> (String -> Msg -> msg) -> Autocomplete.UpdateConfig msg String
updateConfig msgId originMessage =
    Autocomplete.updateConfig
        { toId = \id -> id
        , onKeyDown =
            \code maybeId ->
                if code == 38 || code == 40 then
                    Maybe.map (originMessage msgId << PreviewMenuItem) maybeId
                else if code == 13 then
                    Maybe.map (originMessage msgId << SelectMenuItemKeyboard) maybeId
                else
                    Just <| originMessage msgId Reset
        , onTooLow = Just <| (originMessage msgId << Wrap) False
        , onTooHigh = Just <| (originMessage msgId << Wrap) True

        -- lucamug - Removed this to avoid the input field changing on mouse
        -- over
        -- , onMouseEnter = \id -> Just <| (MsgAutocom << PreviewMenuItem) id
        , onMouseEnter = \_ -> Nothing
        , onMouseLeave = \_ -> Nothing
        , onMouseClick = \id -> Just <| (originMessage msgId << SelectMenuItemMouse) id
        , separateSelections = False
        }
