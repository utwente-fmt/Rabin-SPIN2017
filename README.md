Explicit State Model Checking with Generalized Büchi and Rabin Automata
===

This repository hosts the experiments and results for the paper and provides a
short guide on how to install the tools and reproduce the results.

Please note that all experiments in the paper were performed on a machine 
running Ubuntu 14.04 with 4 AMD Opteron<sup>TM</sup> 6376 processors, 
each with 16 cores, forming a total of 64 cores. There is a total of 
512GB memory available. All experiments are explicitly set up to use 16 threads,
consult `benchmark.sh` for modifying this configuration. 

Submitted to [SPIN 2017].

Authors:
---

* Formal Methods and Tools, University of Twente, The Netherlands
    - Vincent Bloemen*:      [<v.bloemen@utwente.nl>](mailto:v.bloemen@utwente.nl)
    - Jaco van de Pol:       [<j.c.vandepol@utwente.nl>](mailto:j.c.vandepol@utwente.nl)

* Laboratoire de Recherche et Développement de l'Epita, France
    - Alexandre Duret-Lutz:  [<adl@lrde.epita.fr>](mailto:adl@lrde.epita.fr)

\* Supported by the 3TU.BSR project.

Abstract
---

*In the automata theoretic approach to explicit state LTL
model checking, the synchronized product of the model and
an automata that represents the negated formula is checked
for emptiness. In practice, a (generalized) Büchi automaton
(GBA) is constructed and used for this procedure.*

*This paper investigates whether using a more general form
of automaton, a generalized Rabin automaton (GRA), improves
the model checking procedure. An advantage of using
a GRA is that its number of states can be significantly less
than that of a GBA. Unlike a GBA, a GRA can also deterministically
represent any LTL formula. However, the corresponding
emptiness checking procedure is more involved.*

*With recent advances in probabilistic model checking and
LTL to GRA translators, it is only natural to ask whether
checking a GRA directly is more advantageous in practice.
We designed a multi-core GRA checking algorithm and
performed experiments on a subset of the models and formulas
from the 2015 Model Checking Contest. Findings
include that our algorithm can be used as a replacement
for a GBA checking algorithm without losing performance.
We also report advantages and disadvantages of using our
algorithm to check TGRAs directly.*

Installation
---

If you experience any issues with the installation please consult the [LTSmin] 
website and [Spot] website for further instructions.

Firstly for Ubuntu we need to install the following dependencies:

```
$ sudo apt-get install build-essential automake autoconf libtool libpopt-dev 
zlib1g-dev zlib1g flex ant asciidoc xmlto doxygen wget git
```

### Installing Spot 2.3

1. Download Spot:
    * `$ wget https://www.lrde.epita.fr/dload/spot/spot-2.3.tar.gz`
2. Unpack the tar:
    * `$ tar -xvf  spot-2.3.tar.gz`
2. Change directory:
    * `$ cd spot-2.3`
4. Configure:
    * `$ ./configure --prefix=$HOME/install --disable-python`
    * Perhaps change the prefix location. At current it will install to your `$HOME` directory under `install`.
5. Make and install:
    * `$ make && make install`


### Installing LTSmin

1. Clone the LTSmin repository:
    * `$ git clone git@github.com:utwente-fmt/ltsmin.git -b spin2017 --recursive`
2. Change directory:
    * `$ cd ltsmin`
3. Run `ltsminreconf`:
    * `$ ./ltsminreconf`
4. Configure the LTSmin build:
    * `$ ./configure --without-scoop --with-spot=$HOME/install --prefix $HOME/install`
    * Perhaps change the prefix location. At current it will install to your `$HOME` directory under `install`.
5. Make and install (we set a timeout during the compilation):
    * `$ make CFLAGS="-DCHECKER_TIMEOUT_TIME=600" && make install`


Usage
---

### Testing

To test if the tools have been successfully installed, a single benchmark can
be tested as follows (in the Rabin-SPIN2017 folder):

```
$ ./test_one.sh  BridgeAndVehicles-PT-V80P50N20_LTLC_13_  tgba  1
```

As a result, after a few seconds,
the program output should report a counterexample similar to the following:

```
(...)
pnml2lts-mc, 20.991: Accepting cycle FOUND at depth ~658!
(...)
```

### Running the benchmarks

The script `benchmark.sh` is set up to perform all benchmark experiments 5 times
on each configuration (see the bottom of the script). Note that this script uses
a timeout of 10 minutes for each experiment. Also note that running this script 
will take several days to complete, using the above-mentioned machine.

The `benchmark.sh` script provides information on the standard output regarding 
which experiment is currently being performed. Error messages, due to crashes
or timeouts are also provided on the standard output. Results are appended to 
the thee CSV files (one for each benchmark suite) in the `results` directory.

### Analyzing the benchmark results

The `results.csv` file contains the results, obtained by performing the
`benchmark.sh` script. Calling `./cleanup.sh` will remove all results.

The graphs and tables in the paper were obtained from these results, using the
R script `csv2plot.r`, which can be used to generate a PDF containing various
graphs by calling:

```
$ ./make_plots.sh
```

[LTSmin]: http://fmt.cs.utwente.nl/tools/ltsmin/
[SPIN 2017]: http://conf.researchr.org/home/spin-2017
[Spot]: https://spot.lrde.epita.fr/


