if [ ! $# = 3 ]; then
    echo "Error: invalid number of arguments"
    echo "USAGE:"
    echo "     $0  LTL        AUT      WORKERS"
    echo "e.g. $0  x_LTLC_1_  ltl3hoa  6"
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
--buchi-type=\"tgba\" --strategy=\"$ALG\" --threads=\"$WORKERS\" -s28 --when --where -v \
--state=table --ltl-semantics=spin

"

    pnml2lts-mc "$FOLDER/${LTL%_LTL*}.pnml" --ltl "$FOLDER/${LTL%.ltl*}.ltl.rabin.selected" \
--buchi-type="tgba" --strategy="$ALG" --threads="$WORKERS" -s28 --when --where -v \
--state=tree --ltl-semantics=spin
else
    # copy HOA file to tmp
    echo "cp \"$FOLDER/${LTL%.ltl*}.${AUT}.hoa\" \"/tmp/tmp.hoa\""
    cp "$FOLDER/${LTL%.ltl*}.${AUT}.hoa" "/tmp/tmp.hoa"

    echo "pnml2lts-mc \"$FOLDER/${LTL%_LTL*}.pnml\" --ltl \"$FOLDER/${LTL%.ltl*}.ltl.rabin.selected\" \
--buchi-type=\"readrabin\" --strategy=\"$ALG\" --threads=\"$WORKERS\" -s28 --when --where -v \
--state=table --ltl-semantics=spin

"

    pnml2lts-mc "$FOLDER/${LTL%_LTL*}.pnml" --ltl "$FOLDER/${LTL%.ltl*}.ltl.rabin.selected" \
--buchi-type="readrabin" --strategy="$ALG" --threads="$WORKERS" -s28 --when --where -v \
--state=tree --ltl-semantics=spin
fi

