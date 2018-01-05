module Main exposing (..)

import Html exposing (..)
import Svg
import Svg.Attributes


-- Original from https://github.com/elm-lang/svg/blob/master/examples/Logo.elm


main : Html.Html msg
main =
    div []
        [ logoElmOriginal "200px" "200px"
        , logoElm Colored "200px" "200px"
        , logoElm Orange "200px" "200px"
        , logoElm Green "200px" "200px"
        , logoElm LightBlue "200px" "200px"
        , logoElm Blue "200px" "200px"
        , logoElm White "200px" "200px"
        , logoElm Black "200px" "200px"
        ]


logoElmOriginal : String -> String -> Html msg
logoElmOriginal x y =
    let
        f =
            Svg.Attributes.fill

        p =
            Svg.Attributes.points
    in
    Svg.svg
        [ Svg.Attributes.version "1.1"
        , Svg.Attributes.width x
        , Svg.Attributes.height y
        , Svg.Attributes.viewBox "0 0 323.141 322.95"
        ]
        [ Svg.polygon [ f "#F0AD00", p "161.649,152.782 231.514,82.916 91.783,82.916" ] []
        , Svg.polygon [ f "#7FD13B", p "8.867,0 79.241,70.375 232.213,70.375 161.838,0" ] []
        , Svg.rect [ f "#7FD13B", Svg.Attributes.x "192.99", Svg.Attributes.y "107.392", Svg.Attributes.width "107.676", Svg.Attributes.height "108.167", Svg.Attributes.transform "matrix(0.7071 0.7071 -0.7071 0.7071 186.4727 -127.2386)" ] []
        , Svg.polygon [ f "#60B5CC", p "323.298,143.724 323.298,0 179.573,0" ] []
        , Svg.polygon [ f "#5A6378", p "152.781,161.649 0,8.868 0,314.432" ] []
        , Svg.polygon [ f "#F0AD00", p "255.522,246.655 323.298,314.432 323.298,178.879" ] []
        , Svg.polygon [ f "#60B5CC", p "161.649,170.517 8.869,323.298 314.43,323.298" ] []
        ]


type LogoColor
    = Colored
    | Orange
    | Green
    | LightBlue
    | Blue
    | White
    | Black


logoColor : LogoColor -> String
logoColor color =
    case color of
        Orange ->
            "#F0AD00"

        Green ->
            "#7FD13B"

        LightBlue ->
            "#60B5CC"

        Blue ->
            "#5A6378"

        _ ->
            "black"


logoElm : LogoColor -> String -> String -> Html msg
logoElm color x y =
    let
        f =
            Svg.Attributes.fill

        d =
            Svg.Attributes.d

        p =
            Svg.path

        orange =
            logoColor Orange

        green =
            logoColor Green

        lightBlue =
            logoColor LightBlue

        blue =
            logoColor Blue

        c =
            case color of
                Colored ->
                    { c1 = orange, c2 = green, c3 = lightBlue, c4 = blue }

                Orange ->
                    { c1 = orange, c2 = orange, c3 = orange, c4 = orange }

                Green ->
                    { c1 = green, c2 = green, c3 = green, c4 = green }

                LightBlue ->
                    { c1 = lightBlue, c2 = lightBlue, c3 = lightBlue, c4 = lightBlue }

                Blue ->
                    { c1 = blue, c2 = blue, c3 = blue, c4 = blue }

                White ->
                    { c1 = "white", c2 = "white", c3 = "white", c4 = "white" }

                Black ->
                    { c1 = "black", c2 = "black", c3 = "black", c4 = "black" }
    in
    Svg.svg
        [ Svg.Attributes.version "1"
        , Svg.Attributes.viewBox "0 0 323 323"
        , Svg.Attributes.width x
        , Svg.Attributes.height y
        ]
        [ p [ f c.c1, d "M162 153l70-70H92zm94 94l67 67V179z" ] []
        , p [ f c.c2, d "M9 0l70 70h153L162 0zm238 85l77 76-77 77-76-77z" ] []
        , p [ f c.c3, d "M323 144V0H180zm-161 27L9 323h305z" ] []
        , p [ f c.c4, d "M153 162L0 9v305z" ] []
        ]
