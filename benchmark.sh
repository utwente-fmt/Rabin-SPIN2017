#!/bin/bash

# ALG
RABIN_ALG="ltl3hoa"

# binaries
PNML_LTSMIN="pnml2lts-mc"
LTSMIN=${PNML_LTSMIN}

# file extension
PNML_EXTENSION="pnml"
EXTENSION=$PNML_EXTENSION
LTL_EXT=".ltl.rabin.selected"

# variables
TIMEOUT_TIME="900s" # 15 minutes timeout for program (10 minute timeout is provided in compilation)
MAX_TRIES="3" # number of retries after known failures

# misc fields
BENCHDIR=`pwd`
ALL_OUTPUT="${BENCHDIR}/all_output.out"
TMPFILE="${BENCHDIR}/test.out" # Create a temporary file to store the output
FAILFOLDER="${BENCHDIR}/failures"

# input graphs folders
MCC_FOLDER="${BENCHDIR}/mcc2015"
LTL_FOLDER=${TACAS_FOLDER}

# results
TMPFILE="${BENCHDIR}/tmp.out" # Create a temporary file to store the output
MCC_RESULTS="${BENCHDIR}/results.csv"
RESULTS=$MCC_RESULTS

trap "exit" INT #ensures that we can exit this bash program

# create new output file, or append to the exisiting one
create_results() {
    output_file=${1}
    if [ ! -e ${output_file} ]
    then
        touch ${output_file}
        # Add column info to output CSV
        echo "model,alg,rabinpairorder,workers,buchi,ltl,errmsg,time,date,sccs,ustates,utrans,tstates,ttrans,selfloop,claimdead,claimfound,claimsuccess,cumstack,autsize,rabinpairs,ftrans,formula,hoa" > ${output_file}
    fi
}

# create necessary folders and files
init() {
    if [ ! -d "${FAILFOLDER}" ]; then
      mkdir "${FAILFOLDER}"
    fi
    if [ ! -d "${BENCHDIR}/results" ]; then
      mkdir "${BENCHDIR}/results"
    fi
    touch ${ALL_OUTPUT}
    touch ${TMPFILE}
    create_results ${MCC_RESULTS}
}


# test_ltsmin BASE INPUT ALG WORKERS
# e.g. test_ltsmin exit.3 exit.3_T_002.ltl 1 ndfs ba
test_ltsmin() {
    if [ ! $# = 5 ]; then
        echo "Error: invalid number of arguments"
        echo "USAGE:"
        echo "     test_ltsmin  BASE  INPUT  WORKERS  ALG  BUCHI"
        echo "e.g. test_ltsmin  exit.3  exit.3_T_002  1  ndfs  spotba"
        exit
    fi

    base=${1%/}
    input=${2%$LTL_EXT}
    workers=${3}
    alg=${4}
    buchi=${5}

    model="${LTL_FOLDER}/${base}/${base}.${EXTENSION}"
    ltlfile="${LTL_FOLDER}/${base}/${input}$LTL_EXT"

    # readrabin
    rm -f /tmp/tmp.hoa

    if [ "$buchi" = "readrabin" ]; then
	cp "${LTL_FOLDER}/${base}/${input}.${RABIN_ALG}.hoa" "/tmp/tmp.hoa"

        if [ ! -s /tmp/tmp.hoa ];
        then
            echo "- No HOA found"
	    return
	fi

	# Check if there are 2 Rabin pairs or more
	#if cat /tmp/tmp.hoa | grep -q "Rabin 1"
	#then
	#    return
	#fi

    fi

    try_again=0
    retry=1

    while [  $retry -eq 1 ]; do
        let retry=0
	if [ "$buchi" = "readrabin" ]; then
          echo "Running ${alg} on ${input} with ${workers} worker(s) and buchi=${RABIN_ALG}"
	else
	  echo "Running ${alg} on ${input} with ${workers} worker(s) and buchi=${buchi}"
	fi

        ERR_MSG="OK"
        # run the algorithm
        timeout ${TIMEOUT_TIME} time ${LTSMIN} --state=table -s28 --strategy=${alg} --threads=${workers} --buchi-type=${buchi} --ltl-semantics=spin --ltl=${ltlfile} ${model} --rabin-order=seq -v --when  &> ${TMPFILE}

        if [ "$?" = "124" ]; then
            echo "- Timeout!"
            ERR_MSG="TLE"
        fi

	if grep -q "ERROR: Timeout" ${TMPFILE}
	then
	    echo "- Timeout"
	    ERR_MSG="TLE"
	fi

        ## Store output
        cat ${TMPFILE} >> ${ALL_OUTPUT}

        ## check for errors
        if grep -q "slab->cur_len != SIZE_MAX\
\|isba_size_int(balloc) == index + 1\
\|There is no group that can produce edge\
\|strcomp(pval(str), name, slab) == 0" "${TMPFILE}"
        then
            let try_again=$try_again+1
            if [ "$try_again" -lt "$MAX_TRIES" ]
            then 
                echo "- Found known failure, trying again ($try_again)"
                let retry=1
            else
                echo "- Found known failure, already tried $try_again times, reporting error and continuing.."
                ERR_MSG="FAIL"
            fi
        fi
        if grep -q "hash table full! Change\
\|out of memory on allocating" "${TMPFILE}"
        then
            echo "- Out of memory!"
            ERR_MSG="MEM"
        fi
    done

    # readrabin
    if [ "$buchi" = "readrabin" ]; then
      python parse-output.py "${input}" "${alg}" "${workers}" "${RABIN_ALG}" "${FAILFOLDER}" "${TMPFILE}" "${ERR_MSG}" "${RESULTS}"
    else
      ## analyze the results
      python parse-output.py "${input}" "${alg}" "${workers}" "${buchi}" "${FAILFOLDER}" "${TMPFILE}" "${ERR_MSG}" "${RESULTS}"
    fi
}

#time test_all_mcc2015_ltsmin 1
test_all_mcc2015_ltsmin() {
    if [ ! $# = 1 ]; then
        echo "Error: invalid number of arguments"
        echo "USAGE:"
        echo "     test_all_mcc2015_ltsmin  WORKERS"
        echo "e.g. test_all_mcc2015_ltsmin  1"
        exit
    fi
    workers=${1}

    RESULTS=$MCC_RESULTS
    LTL_FOLDER=$MCC_FOLDER
    LTSMIN=$PNML_LTSMIN
    EXTENSION=$PNML_EXTENSION

    for folder in `(cd ${LTL_FOLDER}; ls -d */)`
    do
        for ltl in `ls ${LTL_FOLDER}/${folder} | grep -e "$LTL_EXT"`
        do
	    echo ""
	    echo "${ltl}"
	    echo ""
	    for count in `seq 10`
	    do
		test_ltsmin ${folder} ${ltl} ${workers} ufscc tgba
		RABIN_ALG="ltl3hoa"
		test_ltsmin ${folder} ${ltl} ${workers} favoid readrabin
		RABIN_ALG="ltl3dra"
		test_ltsmin ${folder} ${ltl} ${workers} favoid readrabin
		RABIN_ALG="rabinizer3"
		test_ltsmin ${folder} ${ltl} ${workers} favoid readrabin
		RABIN_ALG="tgbarabin"
		test_ltsmin ${folder} ${ltl} ${workers} favoid readrabin
	    done
        done
    done
}


# initialize
init


############################################################

test_all_mcc2015_ltsmin 16

############################################################


# cleanup
rm ${TMPFILE}



