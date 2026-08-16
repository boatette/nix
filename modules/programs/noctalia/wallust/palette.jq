
def hexdigit:
    if . >= 48 and . <= 57 then . - 48
    elif . >= 97 then . - 87
    else . - 55
    end;

def rgb:
    ltrimstr("#")
    | explode
    | map(hexdigit)
    | [ .[0] * 16 + .[1], .[2] * 16 + .[3], .[4] * 16 + .[5] ];

def hsl:
    rgb
    | (.[0] / 255) as $r
    | (.[1] / 255) as $g
    | (.[2] / 255) as $b
    | ([ $r, $g, $b ] | max) as $max
    | ([ $r, $g, $b ] | min) as $min
    | ($max - $min) as $chroma
    | (($max + $min) / 2) as $l
    | (if $chroma == 0 then 0
       elif $max == $r then 60 * (($g - $b) / $chroma)
       elif $max == $g then 60 * (($b - $r) / $chroma + 2)
       else 60 * (($r - $g) / $chroma + 4)
       end) as $hue
    | [ (if $hue < 0 then $hue + 360 else $hue end),
        (if $chroma == 0 then 0 else $chroma / (1 - ((2 * $l - 1) | length)) end),
        $l,
        $chroma ];

def luminance:
    rgb
    | map(. / 255)
    | map(if . <= 0.04045 then . / 12.92 else pow((. + 0.055) / 1.055; 2.4) end)
    | 0.2126 * .[0] + 0.7152 * .[1] + 0.0722 * .[2];

def contrast($a; $b):
    ($a | luminance) as $la
    | ($b | luminance) as $lb
    | if $la > $lb then ($la + 0.05) / ($lb + 0.05) else ($lb + 0.05) / ($la + 0.05) end;

def onColor($c):
    ([ .background, .foreground ] | max_by(contrast($c; .))) as $best
    | if contrast($c; $best) >= 4.5
      then $best
      else ([ "#000000", "#FFFFFF" ] | max_by(contrast($c; .)))
      end;

def toHex2:
    (if . < 0 then 0 elif . > 255 then 255 else . end | floor) as $v
    | "0123456789ABCDEF" as $d
    | $d[($v / 16 | floor):($v / 16 | floor) + 1] + $d[($v % 16):($v % 16) + 1];

def hslToHex($h; $s; $l):
    ((($h | floor) % 360 + 360) % 360) as $hn
    | ((1 - ((2 * $l - 1) | length)) * $s) as $c
    | ($hn / 60) as $hp
    | ($c * (1 - ($hp - 2 * (($hp / 2) | floor) - 1 | length))) as $x
    | ($l - $c / 2) as $m
    | (if $hp < 1 then [ $c, $x, 0 ]
       elif $hp < 2 then [ $x, $c, 0 ]
       elif $hp < 3 then [ 0, $c, $x ]
       elif $hp < 4 then [ 0, $x, $c ]
       elif $hp < 5 then [ $x, 0, $c ]
       else [ $c, 0, $x ] end)
    | map((. + $m) * 255)
    | "#" + (.[0] | toHex2) + (.[1] | toHex2) + (.[2] | toHex2);

def hueDistance($a; $b):
    (($a - $b) | length) as $d | if $d > 180 then 360 - $d else $d end;

def accents($lo; $hi):
    ([ .colors[] | { hex: ., h: hsl } ] | unique_by(.hex)) as $all
    | ($all | sort_by([ (if .h[2] >= $lo and .h[2] <= $hi then 0 else 1 end), -.h[3] ])) as $ranked
    | ([ $ranked[] | select(.h[3] >= 0.15) ]) as $usable
    | (if ($usable | length) > 0 then $usable else [ ($all | max_by(.h[3])) ] end) as $cands
    | (reduce $cands[] as $x ([];
          if length >= 3 then .
          elif all(.[]; hueDistance(.h[0]; $x.h[0]) >= 30) then . + [$x]
          else . end)) as $picked
    | ($picked[0].h) as $p
    | ($picked | map(.hex))
    + [ hslToHex($p[0] + 30; $p[1]; $p[2]), hslToHex($p[0] - 30; $p[1]; $p[2]) ]
    | .[0:3];

def errorColor:
    ( [ .colors[]
        | select(hsl as $c
                 | ($c[0] <= 30 or $c[0] >= 330)
                 and $c[1] > 0.4
                 and $c[2] > 0.3
                 and $c[2] < 0.7)
      ][0]
    ) // "#FD4663";

def palette($lo; $hi):
    . as $w
    | .colors as $c
    | ($w | errorColor) as $error
    | ($w | accents($lo; $hi)) as $a
    | {
        mPrimary: $a[0],
        mOnPrimary: ($w | onColor($a[0])),
        mSecondary: $a[1],
        mOnSecondary: ($w | onColor($a[1])),
        mTertiary: $a[2],
        mOnTertiary: ($w | onColor($a[2])),
        mError: $error,
        mOnError: ($w | onColor($error)),
        mSurface: $w.background,
        mOnSurface: $w.foreground,
        mSurfaceVariant: $c[0],
        mOnSurfaceVariant: (if contrast($c[7]; $c[0]) >= 4.5 then $c[7] else ($w | onColor($c[0])) end),
        mOutline: $c[8],
        mShadow: $w.background,
        terminal: {
            foreground: $w.foreground,
            background: $w.background,
            cursor: $w.cursor,
            cursorText: $w.background,
            selectionFg: $w.foreground,
            selectionBg: $c[0],
            normal: {
                black: $c[0],
                red: $c[1],
                green: $c[2],
                yellow: $c[3],
                blue: $c[4],
                magenta: $c[5],
                cyan: $c[6],
                white: $c[7]
            },
            bright: {
                black: $c[8],
                red: $c[9],
                green: $c[10],
                yellow: $c[11],
                blue: $c[12],
                magenta: $c[13],
                cyan: $c[14],
                white: $c[15]
            }
        }
      };

(if $mode == "light" then palette(0.15; 0.60) else palette(0.35; 0.80) end) as $p
| { dark: $p, light: $p }
