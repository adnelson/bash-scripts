let makeFrac = (main, numinator, denominator) => float_of_int(main) +. float_of_int(numinator) /. float_of_int(denominator);
let feet = n => n *. 12.0;

// Constraints
let doorThickness = 1.75;
let doorWidth = makeFrac(35, 7, 8);
let doorHeight = makeFrac(79, 3, 8);
let windowPaneWidth = makeFrac(24, 7, 16);
let windowPaneHeight = makeFrac(28, 9, 16);
let deadboltHeight = 39.0;
let handleHeight = makeFrac(33, 1, 4);

// Variables
let outerSideWidth = 6.0;
let outerSideLengthLong = feet(5.0);
let outerSideLengthShort = doorHeight -. outerSideLengthLong;
let bottomSideHeight = 9.0;
let innerWindowWidth = doorWidth -. 2.0 *. outerSideWidth;
let windowPaneHiddenSides = (windowPaneWidth -. innerWindowWidth) /. 2.0;

let innerWindowHeight = windowPaneHeight -. 1.0;
let nonWindowVerticalTotal = doorHeight -. innerWindowHeight *. 2.0;

// TODO function that gives the closest fraction which is a power of 2, up to a max denominator
type fraction = { numerator: int, denominator: int};
let zeroFraction = { numerator: 0, denominator: 1};
let oneFraction = { numerator: 1, denominator: 1};
let fractionToFloat = ({numerator, denominator}) => float_of_int(numerator) /. float_of_int(denominator);

module Math = {
  @val @scope("Math") external abs: float => float = "abs";
 }

/* let getFraction = (~highestDenominator=32, flt) => { */
/*   Js.log(flt); */
/*   let precision = 1.0 /. float_of_int(highestDenominator); */
/*   let iters = ref(0); */
/*   let rec loop = (lowerGuess, upperGuess) => { */
/*     iters := iters.contents + 1; */
/*     if (iters.contents > 10) { */
/*       failwith("too many iterations") */
/*     } */
/*       let upperGuessF = upperGuess->fractionToFloat */
/*       let lowerGuessF = lowerGuess->fractionToFloat */
/*       let diff = g => Math.abs(flt -. g) */
/*       Js.log4(lowerGuess, upperGuess, diff(upperGuessF), diff(lowerGuessF)); */
/*     if (diff(upperGuessF) < precision) { */
/*       upperGuess */
/*     } else if (diff(lowerGuessF) < precision) { */
/*       lowerGuess */
/*     } else if (flt > lowerGuessF) { */
/*       let newLowerGuess = {numerator: (lowerGuess.numerator * 2) + 1, denominator: lowerGuess.denominator * 2}; */
/*       if (newLowerGuess->fractionToFloat <=  flt) { */
/*         loop(newLowerGuess, upperGuess) */
/*       } */
/*     } else { */
/*       loop(lowerGuess, {numerator: (upperGuess.numerator, denominator: upperGuess.denominator * 2}) */
/*     } */
/*   } */

/*   loop(zeroFraction, oneFraction) */
/* } */


let getClosestFraction: (float, float) => fraction = %raw(`
function (value, tol) {
    var original_value = value;
    var iteration = 0;
    var denominator=1, last_d = 0, numerator;
    while (iteration < 20) {
        value = 1 / (value - Math.floor(value))
        var _d = denominator;
        denominator = Math.floor(denominator * value + last_d);
        last_d = _d;
        numerator = Math.ceil(original_value * denominator)

        if (Math.abs(numerator/denominator - original_value) < tol)
            break;
        iteration++;
    }
    return {numerator: numerator, denominator: denominator};
}
`)

let getFraction = n => getClosestFraction(n, 0.1);

let pageDoorHeight = 8.5;
let pageDoorScale = pageDoorHeight /. doorHeight;
let pageDoorWidth = pageDoorScale *. doorWidth;

let mod_: float => float => float = (_a, _b) => %raw(`_a % _b`);

let renderFractional = n => { Js.log(n); let frac = getFraction(mod_(n, 1.0)); return `${n->Js.Math.floor->Js.Int.toString} ${frac.numerator->Js.Int.toString}/${frac.denominator->Js.Int.toString}` }

let render = n => renderFractional(n *. pageDoorScale);

Js.log({
  "pageDoorWidth": doorWidth->render,
  "pageDoorHeight": doorHeight->render,
  "outerSideWidth": outerSideWidth->render,
  "bottomSideHeight": bottomSideHeight->render,
  "innerWindowHeight": innerWindowHeight->render,
});
