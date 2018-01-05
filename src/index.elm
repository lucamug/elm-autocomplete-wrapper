module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Html msg
view =
    ul []
        [ li [] [ a [ href "Example_Auto_0.html" ] [ text "Example_Auto_0.html" ] ]
        , li [] [ a [ href "Example_Auto_1.html" ] [ text "Example_Auto_1.html" ] ]
        , li [] [ a [ href "Example_Auto_2.html" ] [ text "Example_Auto_2.html" ] ]
        , li [] [ a [ href "Example_Auto_3.html" ] [ text "Example_Auto_3.html" ] ]
        , li [] [ a [ href "Example_Auto_4.html" ] [ text "Example_Auto_4.html" ] ]
        , li [] [ a [ href "Example_Auto_5.html" ] [ text "Example_Auto_5.html" ] ]
        , li [] [ a [ href "Example_Auto_6.html" ] [ text "Example_Auto_6.html" ] ]
        , li [] [ a [ href "Example_Auto_7.html" ] [ text "Example_Auto_7.html" ] ]
        , li [] [ a [ href "Example_Auto_8.html" ] [ text "Example_Auto_8.html" ] ]
        , li [] [ a [ href "Example_Auto_9.html" ] [ text "Example_Auto_9.html" ] ]
        , li [] [ a [ href "Example_Auto_10.html" ] [ text "Example_Auto_10.html" ] ]
        , li [] [ a [ href "Example_Auto_11.html" ] [ text "Example_Auto_11.html" ] ]
        , li [] [ a [ href "Example_Auto_12.html" ] [ text "Example_Auto_12.html" ] ]
        , li [] [ a [ href "Example_Auto_13.html" ] [ text "Example_Auto_13.html" ] ]
        , li [] [ a [ href "Example_Auto_14.html" ] [ text "Example_Auto_14.html" ] ]
        ]


main : Html msg
main =
    view
