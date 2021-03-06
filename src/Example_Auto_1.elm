module Main exposing (main)

import Autocomplete
import Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Task


type alias Model =
    { focus : Maybe FormField

    -- FIELDS VALUES
    , field1 : String
    , field2 : String
    , field3 : String

    -- AUTOCOMPLETE
    , autocomMenuItems : List MenuItem
    , autocomState : Autocomplete.State
    , autocomHowManyToShow : Int
    , autocomSelectedMenuItem : Maybe MenuItem
    , autocomShowMenu : Bool
    , autocomFocus : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { -- FIELDS VALUES
        field1 = ""
      , field3 = ""
      , field2 = ""

      -- FOCUS
      , focus = Nothing

      -- AUTOCOMPLETE
      , autocomMenuItems = menuItems
      , autocomState = Autocomplete.empty
      , autocomHowManyToShow = 10
      , autocomSelectedMenuItem = Nothing
      , autocomShowMenu = False
      , autocomFocus = False
      }
    , Cmd.none
    )


type Msg
    = NoOp
    | OnFocus FormField
    | OnBlur FormField
    | SetField FormField String
      -- AUTOCOMPLETE
    | MsgAutocom MsgAutocom


type FormField
    = Field1
    | Field2
    | Field3


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg" msg of
        NoOp ->
            ( model, Cmd.none )

        SetField field value ->
            ( model
                |> setField field value
            , Cmd.none
            )

        OnFocus formField ->
            ( { model | focus = Just formField }, Cmd.none )

        OnBlur formField ->
            ( { model | focus = Nothing }, Cmd.none )

        -- AUTOCOMPLETE
        MsgAutocom autocomMsg ->
            updateAutocom autocomMsg model



-- HELPERS


setField : FormField -> String -> Model -> Model
setField field value model =
    case field of
        Field1 ->
            { model | field1 = value }

        Field2 ->
            { model | field2 = value }

        Field3 ->
            { model | field3 = value }



-- VIEWS


view : Model -> Html Msg
view model =
    viewForm model


viewForm : Model -> Html Msg
viewForm model =
    div [ class "form-container" ]
        [ div [] [ text <| "Field 1: " ++ model.field1 ]
        , div [] [ text <| "Field 2: " ++ model.field2 ]
        , div [] [ text <| "Field 3: " ++ model.field3 ]
        , div [] [ text <| "Focus: " ++ toString model.focus ]
        , div [] [ text <| "autocomFocus: " ++ toString model.autocomFocus ]
        , div
            []
            [ label
                []
                [ input
                    [ type_ "text"
                    , onInput <| SetField Field1
                    , onFocus <| OnFocus Field1
                    , onBlur <| OnBlur Field1
                    , value <| model.field1
                    ]
                    []
                ]
            , label [] [ viewAutocom model ]
            , label []
                [ input
                    [ type_ "text"
                    , onInput <| SetField Field3
                    , onFocus <| OnFocus Field3
                    , onBlur <| OnBlur Field3
                    , value <| model.field3
                    , list "programmingLanguage"
                    ]
                    []
                , datalist [ id "programmingLanguage" ]
                    (List.map
                        (\item -> option [ value item.name ] [])
                        menuItems
                    )
                ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map (MsgAutocom << SetAutoState) Autocomplete.subscription



-- MAIN


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- AUTOCOMPLETE


type MsgAutocom
    = SetQuery String
    | SetAutoState Autocomplete.Msg
    | Wrap Bool
    | SelectMenuItemKeyboard String
    | SelectMenuItemMouse String
    | PreviewMenuItem String
    | HandleEscape
    | OnFocusAutocom
    | OnBlurAutocom
    | Reset
    | NoOpAutocom


updateAutocom : MsgAutocom -> Model -> ( Model, Cmd Msg )
updateAutocom msg model =
    case msg of
        SetQuery newQuery ->
            let
                autocomShowMenu =
                    not << List.isEmpty <| acceptableItems newQuery model.autocomMenuItems
            in
            { model | field2 = newQuery, autocomShowMenu = autocomShowMenu, autocomSelectedMenuItem = Nothing } ! []

        SetAutoState autoMsg ->
            let
                ( newState, maybeMsg ) =
                    Autocomplete.update updateConfig autoMsg model.autocomHowManyToShow model.autocomState (acceptableItems model.field2 model.autocomMenuItems)

                newModel =
                    { model | autocomState = newState }
            in
            case maybeMsg of
                Nothing ->
                    newModel ! []

                Just updateMsg ->
                    update updateMsg newModel

        Wrap toTop ->
            case model.autocomSelectedMenuItem of
                Just menuItem ->
                    update (MsgAutocom Reset) model

                Nothing ->
                    if toTop then
                        { model
                            | autocomState = Autocomplete.resetToLastItem updateConfig (acceptableItems model.field2 model.autocomMenuItems) model.autocomHowManyToShow model.autocomState
                            , autocomSelectedMenuItem = List.head <| List.reverse <| List.take model.autocomHowManyToShow <| acceptableItems model.field2 model.autocomMenuItems
                        }
                            ! []
                    else
                        { model
                            | autocomState = Autocomplete.resetToFirstItem updateConfig (acceptableItems model.field2 model.autocomMenuItems) model.autocomHowManyToShow model.autocomState
                            , autocomSelectedMenuItem = List.head <| List.take model.autocomHowManyToShow <| acceptableItems model.field2 model.autocomMenuItems
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
            in
            ( newModel, Task.attempt (\_ -> MsgAutocom NoOpAutocom) (Dom.focus "president-input") )

        PreviewMenuItem id ->
            { model | autocomSelectedMenuItem = Just <| getMenuItemAtId model.autocomMenuItems id } ! []

        HandleEscape ->
            let
                validOptions =
                    not <| List.isEmpty (acceptableItems model.field2 model.autocomMenuItems)

                handleEscape =
                    if validOptions then
                        model
                            |> removeSelection
                            |> resetMenu
                    else
                        model
                            |> resetInput

                escapedModel =
                    case model.autocomSelectedMenuItem of
                        Just menuItem ->
                            if model.field2 == menuItem.name then
                                model
                                    |> resetInput
                            else
                                handleEscape

                        Nothing ->
                            handleEscape
            in
            escapedModel ! []

        Reset ->
            { model | autocomState = Autocomplete.reset updateConfig model.autocomState, autocomSelectedMenuItem = Nothing } ! []

        OnFocusAutocom ->
            { model | autocomFocus = True } ! []

        OnBlurAutocom ->
            { model | autocomFocus = False } ! []

        NoOpAutocom ->
            model ! []


resetInput : Model -> Model
resetInput model =
    { model | field2 = "" }
        |> removeSelection
        |> resetMenu


removeSelection : Model -> Model
removeSelection model =
    { model | autocomSelectedMenuItem = Nothing }


getMenuItemAtId : List MenuItem -> String -> MenuItem
getMenuItemAtId autocomMenuItems id =
    List.filter (\menuItem -> menuItem.name == id) autocomMenuItems
        |> List.head
        |> Maybe.withDefault (MenuItem "")


setQuery : Model -> String -> Model
setQuery model id =
    { model
        | field2 = .name <| getMenuItemAtId model.autocomMenuItems id
        , autocomSelectedMenuItem = Just <| getMenuItemAtId model.autocomMenuItems id
    }


resetMenu : Model -> Model
resetMenu model =
    { model
        | autocomState = Autocomplete.empty
        , autocomShowMenu = False
    }


viewAutocom : Model -> Html Msg
viewAutocom model =
    let
        options =
            { preventDefault = True, stopPropagation = False }

        dec =
            Decode.map
                (\code ->
                    if code == 38 || code == 40 then
                        Ok (MsgAutocom NoOpAutocom)
                    else if code == 27 then
                        Ok (MsgAutocom HandleEscape)
                    else
                        Err "not handling that key"
                )
                keyCode
                |> Decode.andThen
                    fromResult

        fromResult : Result String a -> Decode.Decoder a
        fromResult result =
            case result of
                Ok val ->
                    Decode.succeed val

                Err reason ->
                    Decode.fail reason

        menu =
            if model.autocomShowMenu then
                [ viewMenu model ]
            else
                []

        field2 =
            case model.autocomSelectedMenuItem of
                Just menuItem ->
                    menuItem.name

                Nothing ->
                    model.field2

        activeDescendant attributes =
            case model.autocomSelectedMenuItem of
                Just menuItem ->
                    attribute "aria-activedescendant"
                        menuItem.name
                        :: attributes

                Nothing ->
                    attributes
    in
    div []
        (List.append
            [ input
                (activeDescendant
                    [ type_ "text"
                    , onInput (MsgAutocom << SetQuery)
                    , onFocus (MsgAutocom OnFocusAutocom)
                    , onBlur (MsgAutocom OnBlurAutocom)
                    , onWithOptions "keydown" options dec
                    , value field2
                    , id "president-input"
                    , classList
                        [ ( "autocomplete-input", True )
                        ]
                    , autocomplete False
                    , attribute "aria-owns" "list-of-presidents"
                    , attribute "aria-expanded" <| String.toLower <| toString model.autocomShowMenu
                    , attribute "aria-haspopup" <| String.toLower <| toString model.autocomShowMenu
                    , attribute "role" "combobox"
                    , attribute "aria-autocomplete" "list"
                    ]
                )
                []
            ]
            menu
        )


acceptableItems : String -> List MenuItem -> List MenuItem
acceptableItems field2 autocomMenuItems =
    let
        lowerQuery =
            String.toLower field2
    in
    List.filter (String.contains lowerQuery << String.toLower << .name) autocomMenuItems


viewMenu : Model -> Html Msg
viewMenu model =
    div [ class "autocomplete-menu" ]
        [ Html.map (MsgAutocom << SetAutoState) (Autocomplete.view viewConfig model.autocomHowManyToShow model.autocomState (acceptableItems model.field2 model.autocomMenuItems)) ]


updateConfig : Autocomplete.UpdateConfig Msg MenuItem
updateConfig =
    Autocomplete.updateConfig
        { toId = .name
        , onKeyDown =
            \code maybeId ->
                if code == 38 || code == 40 then
                    Maybe.map (MsgAutocom << PreviewMenuItem) maybeId
                else if code == 13 then
                    Maybe.map (MsgAutocom << SelectMenuItemKeyboard) maybeId
                else
                    Just <| MsgAutocom Reset
        , onTooLow = Just <| (MsgAutocom << Wrap) False
        , onTooHigh = Just <| (MsgAutocom << Wrap) True
        , onMouseEnter = \id -> Just <| (MsgAutocom << PreviewMenuItem) id
        , onMouseLeave = \_ -> Nothing
        , onMouseClick = \id -> Just <| (MsgAutocom << SelectMenuItemMouse) id
        , separateSelections = False
        }


viewConfig : Autocomplete.ViewConfig MenuItem
viewConfig =
    let
        customizedLi keySelected mouseSelected menuItem =
            { attributes =
                [ classList [ ( "autocomplete-item", True ), ( "key-selected", keySelected || mouseSelected ) ]
                , id menuItem.name
                ]
            , children = [ Html.text menuItem.name ]
            }
    in
    Autocomplete.viewConfig
        { toId = .name
        , ul = [ class "autocomplete-list" ]
        , li = customizedLi
        }



-- MENU ITEMS


type alias MenuItem =
    { name : String
    }


menuItems : List MenuItem
menuItems =
    [ MenuItem "4th Dimension/4D"
    , MenuItem "ABAP"
    , MenuItem "ABC"
    , MenuItem "ActionScript"
    , MenuItem "Ada"
    , MenuItem "Agilent VEE"
    , MenuItem "Algol"
    , MenuItem "Alice"
    , MenuItem "Angelscript"
    , MenuItem "Apex"
    , MenuItem "APL"
    , MenuItem "AppleScript"
    , MenuItem "Arc"
    , MenuItem "Arduino"
    , MenuItem "ASP"
    , MenuItem "AspectJ"
    , MenuItem "Assembly"
    , MenuItem "ATLAS"
    , MenuItem "Augeas"
    , MenuItem "AutoHotkey"
    , MenuItem "AutoIt"
    , MenuItem "AutoLISP"
    , MenuItem "Automator"
    , MenuItem "Avenue"
    , MenuItem "Awk"
    , MenuItem "Bash"
    , MenuItem "(Visual) Basic"
    , MenuItem "bc"
    , MenuItem "BCPL"
    , MenuItem "BETA"
    , MenuItem "BlitzMax"
    , MenuItem "Boo"
    , MenuItem "Bourne Shell"
    , MenuItem "Bro"
    , MenuItem "C"
    , MenuItem "C Shell"
    , MenuItem "C#"
    , MenuItem "C++"
    , MenuItem "C++/CLI"
    , MenuItem "C-Omega"
    , MenuItem "Caml"
    , MenuItem "Ceylon"
    , MenuItem "CFML"
    , MenuItem "cg"
    , MenuItem "Ch"
    , MenuItem "CHILL"
    , MenuItem "CIL"
    , MenuItem "CL (OS/400)"
    , MenuItem "Clarion"
    , MenuItem "Clean"
    , MenuItem "Clipper"
    , MenuItem "Clojure"
    , MenuItem "CLU"
    , MenuItem "COBOL"
    , MenuItem "Cobra"
    , MenuItem "CoffeeScript"
    , MenuItem "ColdFusion"
    , MenuItem "COMAL"
    , MenuItem "Common Lisp"
    , MenuItem "Coq"
    , MenuItem "cT"
    , MenuItem "Curl"
    , MenuItem "D"
    , MenuItem "Dart"
    , MenuItem "DCL"
    , MenuItem "DCPU-16 ASM"
    , MenuItem "Delphi/Object Pascal"
    , MenuItem "DiBOL"
    , MenuItem "Dylan"
    , MenuItem "E"
    , MenuItem "eC"
    , MenuItem "Ecl"
    , MenuItem "ECMAScript"
    , MenuItem "EGL"
    , MenuItem "Eiffel"
    , MenuItem "Elixir"
    , MenuItem "Elm"
    , MenuItem "Emacs Lisp"
    , MenuItem "Erlang"
    , MenuItem "Etoys"
    , MenuItem "Euphoria"
    , MenuItem "EXEC"
    , MenuItem "F#"
    , MenuItem "Factor"
    , MenuItem "Falcon"
    , MenuItem "Fancy"
    , MenuItem "Fantom"
    , MenuItem "Felix"
    , MenuItem "Forth"
    , MenuItem "Fortran"
    , MenuItem "Fortress"
    , MenuItem "(Visual) FoxPro"
    , MenuItem "Gambas"
    , MenuItem "GNU Octave"
    , MenuItem "Go"
    , MenuItem "Google AppsScript"
    , MenuItem "Gosu"
    , MenuItem "Groovy"
    , MenuItem "Haskell"
    , MenuItem "haXe"
    , MenuItem "Heron"
    , MenuItem "HPL"
    , MenuItem "HyperTalk"
    , MenuItem "Icon"
    , MenuItem "IDL"
    , MenuItem "Inform"
    , MenuItem "Informix-4GL"
    , MenuItem "INTERCAL"
    , MenuItem "Io"
    , MenuItem "Ioke"
    , MenuItem "J"
    , MenuItem "J#"
    , MenuItem "JADE"
    , MenuItem "Java"
    , MenuItem "Java FX Script"
    , MenuItem "JavaScript"
    , MenuItem "JScript"
    , MenuItem "JScript.NET"
    , MenuItem "Julia"
    , MenuItem "Korn Shell"
    , MenuItem "Kotlin"
    , MenuItem "LabVIEW"
    , MenuItem "Ladder Logic"
    , MenuItem "Lasso"
    , MenuItem "Limbo"
    , MenuItem "Lingo"
    , MenuItem "Lisp"
    , MenuItem "Logo"
    , MenuItem "Logtalk"
    , MenuItem "LotusScript"
    , MenuItem "LPC"
    , MenuItem "Lua"
    , MenuItem "Lustre"
    , MenuItem "M4"
    , MenuItem "MAD"
    , MenuItem "Magic"
    , MenuItem "Magik"
    , MenuItem "Malbolge"
    , MenuItem "MANTIS"
    , MenuItem "Maple"
    , MenuItem "Mathematica"
    , MenuItem "MATLAB"
    , MenuItem "Max/MSP"
    , MenuItem "MAXScript"
    , MenuItem "MEL"
    , MenuItem "Mercury"
    , MenuItem "Mirah"
    , MenuItem "Miva"
    , MenuItem "ML"
    , MenuItem "Monkey"
    , MenuItem "Modula-2"
    , MenuItem "Modula-3"
    , MenuItem "MOO"
    , MenuItem "Moto"
    , MenuItem "MS-DOS Batch"
    , MenuItem "MUMPS"
    , MenuItem "NATURAL"
    , MenuItem "Nemerle"
    , MenuItem "Nimrod"
    , MenuItem "NQC"
    , MenuItem "NSIS"
    , MenuItem "Nu"
    , MenuItem "NXT-G"
    , MenuItem "Oberon"
    , MenuItem "Object Rexx"
    , MenuItem "Objective-C"
    , MenuItem "Objective-J"
    , MenuItem "OCaml"
    , MenuItem "Occam"
    , MenuItem "ooc"
    , MenuItem "Opa"
    , MenuItem "OpenCL"
    , MenuItem "OpenEdge ABL"
    , MenuItem "OPL"
    , MenuItem "Oz"
    , MenuItem "Paradox"
    , MenuItem "Parrot"
    , MenuItem "Pascal"
    , MenuItem "Perl"
    , MenuItem "PHP"
    , MenuItem "Pike"
    , MenuItem "PILOT"
    , MenuItem "PL/I"
    , MenuItem "PL/SQL"
    , MenuItem "Pliant"
    , MenuItem "PostScript"
    , MenuItem "POV-Ray"
    , MenuItem "PowerBasic"
    , MenuItem "PowerScript"
    , MenuItem "PowerShell"
    , MenuItem "Processing"
    , MenuItem "Prolog"
    , MenuItem "Puppet"
    , MenuItem "Pure Data"
    , MenuItem "Python"
    , MenuItem "Q"
    , MenuItem "R"
    , MenuItem "Racket"
    , MenuItem "REALBasic"
    , MenuItem "REBOL"
    , MenuItem "Revolution"
    , MenuItem "REXX"
    , MenuItem "RPG (OS/400)"
    , MenuItem "Ruby"
    , MenuItem "Rust"
    , MenuItem "S"
    , MenuItem "S-PLUS"
    , MenuItem "SAS"
    , MenuItem "Sather"
    , MenuItem "Scala"
    , MenuItem "Scheme"
    , MenuItem "Scilab"
    , MenuItem "Scratch"
    , MenuItem "sed"
    , MenuItem "Seed7"
    , MenuItem "Self"
    , MenuItem "Shell"
    , MenuItem "SIGNAL"
    , MenuItem "Simula"
    , MenuItem "Simulink"
    , MenuItem "Slate"
    , MenuItem "Smalltalk"
    , MenuItem "Smarty"
    , MenuItem "SPARK"
    , MenuItem "SPSS"
    , MenuItem "SQR"
    , MenuItem "Squeak"
    , MenuItem "Squirrel"
    , MenuItem "Standard ML"
    , MenuItem "Suneido"
    , MenuItem "SuperCollider"
    , MenuItem "TACL"
    , MenuItem "Tcl"
    , MenuItem "Tex"
    , MenuItem "thinBasic"
    , MenuItem "TOM"
    , MenuItem "Transact-SQL"
    , MenuItem "Turing"
    , MenuItem "TypeScript"
    , MenuItem "Vala/Genie"
    , MenuItem "VBScript"
    , MenuItem "Verilog"
    , MenuItem "VHDL"
    , MenuItem "VimL"
    , MenuItem "Visual Basic .NET"
    , MenuItem "WebDNA"
    , MenuItem "Whitespace"
    , MenuItem "X10"
    , MenuItem "xBase"
    , MenuItem "XBase++"
    , MenuItem "Xen"
    , MenuItem "XPL"
    , MenuItem "XSLT"
    , MenuItem "XQuery"
    , MenuItem "yacc"
    , MenuItem "Yorick"
    , MenuItem "Z shell, MenuItem "
    ]
