// JILN 321034SG0ABK00A01 pin header model

$horizPinCount = 17;


// dimensions are in mm
$pinLength = 11.5;
$pinTubProtrusion = 5.7;
$pinBottomProtrusion = 3.3;
$pinBodySide = 0.64;
$pinTipSide = $pinBodySide * 2 / 3;

$pinSpacing = 2.54;
$tubSideSpacing = 3.8;
$tubFrontRearSpacing = 3.08;
$tubOuterHeight = 8.8;
$tubLipThickness = (8.7 - 6.7)/2;

$keyholeWidth = 4.5;
$keyholeHeight = 6.9;


// calculated dimensions
$tubInnerHeight = $tubOuterHeight - ($pinLength - ($pinTubProtrusion + $pinBottomProtrusion));
$tubOuterLength = $pinSpacing * ($horizPinCount-1) + 2 * $tubSideSpacing;
$allPinsWidth = ($horizPinCount-1) * $pinSpacing;


module cutPyramid($baseSide, $topSide, $height) {
    $sideOffset = ($baseSide - $topSide)/2;
    polyhedron
        ( points =
            [ [0, 0, 0]
            , [$baseSide, 0, 0]
            , [$baseSide, $baseSide, 0]
            , [0, $baseSide, 0]
            , [$sideOffset, $sideOffset, $height]
            , [$sideOffset+$topSide, $sideOffset, $height]
            , [$sideOffset+$topSide, $sideOffset+$topSide, $height]
            , [$sideOffset, $sideOffset+$topSide, $height]
            ]
        , faces =
            [ [0, 3, 2, 1]
            , [0, 4, 7, 3]
            , [0, 1, 5, 4]
            , [2, 6, 5, 1]
            , [3, 7, 6, 2]
            , [4, 5, 6, 7]
            ]
    );
};

module pin() {
    $pinTipOffset = ($pinBodySide - $pinTipSide) / 2;

    translate([-$pinBodySide/2, -$pinBodySide/2, -$pinBottomProtrusion])
        union() {
            // body
            cube([$pinBodySide, $pinBodySide, $pinLength - 2*$pinTipSide]);

            // tip
            translate([0, 0, $pinLength - 2*$pinTipSide])
                cutPyramid($pinBodySide, $pinTipSide, $pinTipSide);

            // base
            translate([$pinBodySide, 0, 0])
            rotate([0, 180, 0])
                cutPyramid($pinBodySide, $pinTipSide, $pinTipSide);
        }
};

// place pins
for (i = [0:$horizPinCount-1]) {
    translate([i * $pinSpacing, 0, 0])
        pin();
    translate([i * $pinSpacing, $pinSpacing, 0])
        pin();
}

difference() {
    // tub
    translate([-$tubSideSpacing, -$tubFrontRearSpacing, 0])
    difference() {
        cube(
            [ $tubOuterLength
            , $pinSpacing + 2 * $tubFrontRearSpacing
            , $tubOuterHeight
            ]);

        translate([$tubLipThickness, $tubLipThickness, $tubOuterHeight - $tubInnerHeight])
        cube(
            [ $tubOuterLength - 2 * $tubLipThickness
            , $pinSpacing + 2 * $tubFrontRearSpacing - 2 * $tubLipThickness
            , $tubInnerHeight + 1
            ]);
    }
    
    // keyhole
    translate([($allPinsWidth-$keyholeWidth)/2, -($pinSpacing+$tubFrontRearSpacing), $tubOuterHeight - $keyholeHeight])
    cube(
        [ $keyholeWidth
        , 4
        , $keyholeHeight + 1
        ]);
}
//