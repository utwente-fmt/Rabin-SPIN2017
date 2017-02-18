if [ ! $# = 3 ]; then
    echo "Error: invalid number of arguments"
    echo "USAGE:"
    echo "     $0  LTL                                      AUT      WORKERS"
    echo "e.g. $0  BridgeAndVehicles-PT-V80P50N20_LTLC_13_  tgba     1"
    exit
fi


LTL=$1
AUT=$2
WORKERS=$3

FOLDER="mcc2015/${LTL%_LTL*}"

ALG="favoid"
if [ "$AUT" = "tgba" ]
then
    ALG="ufscc"

    echo "pnml2lts-mc \"$FOLDER/${LTL%_LTL*}.pnml\" --ltl \"$FOLDER/${LTL%.ltl*}.ltl.rabin.selected\" \
--buchi-type=\"tgba\" --strategy=\"$ALG\" --threads=\"$WORKERS\" --when --where -v \
--ltl-semantics=spin

"

    pnml2lts-mc "$FOLDER/${LTL%_LTL*}.pnml" --ltl "$FOLDER/${LTL%.ltl*}.ltl.rabin.selected" \
--buchi-type="tgba" --strategy="$ALG" --threads="$WORKERS" --when --where -v \
--ltl-semantics=spin
else
    # copy HOA file to tmp
    echo "cp \"$FOLDER/${LTL%.ltl*}.${AUT}.hoa\" \"/tmp/tmp.hoa\""
    cp "$FOLDER/${LTL%.ltl*}.${AUT}.hoa" "/tmp/tmp.hoa"

    echo "pnml2lts-mc \"$FOLDER/${LTL%_LTL*}.pnml\" --ltl \"$FOLDER/${LTL%.ltl*}.ltl.rabin.selected\" \
--buchi-type=\"readrabin\" --strategy=\"$ALG\" --threads=\"$WORKERS\" --when --where -v \
--ltl-semantics=spin

"

    pnml2lts-mc "$FOLDER/${LTL%_LTL*}.pnml" --ltl "$FOLDER/${LTL%.ltl*}.ltl.rabin.selected" \
--buchi-type="readrabin" --strategy="$ALG" --threads="$WORKERS" --when --where -v \
--ltl-semantics=spin
fi

