#!/bin/bash -e

# extract trained nnet3 model for online decoding, the files 
# will be stored in current directory

DIR=$1
mkdir -p conf
cp $DIR/conf/mfcc_hires.conf conf


EXPDIR=$DIR/exp/chain_cleaned/tdnn1f_sp_bi
cp $EXPDIR/final.mdl .
cp $EXPDIR/frame_subsampling_factor .
cp $EXPDIR/graph/HCLG.fst .
cp $EXPDIR/graph/words.txt .


SILPHONES=$(cat $EXPDIR/graph/phones/silence.csl)

IVECDIR=$DIR/exp/nnet3_cleaned/extractor
mkdir -p extractor
cp $IVECDIR/online_cmvn.conf conf
for FILENAME in final.dubm  final.ie final.mat global_cmvn.stats; do
  cp $IVECDIR/$FILENAME extractor
done
cp $DIR/exp/nnet3_cleaned/ivectors_test_hires/conf/splice.conf conf/splice.conf

OUTDIR=/home/azureuser/arc
cat >conf/ivector_extractor.conf <<EOF
--cmvn-config=$OUTDIR/conf/online_cmvn.conf
--ivector-period=10
--splice-config=$OUTDIR/conf/splice.conf
--lda-matrix=$OUTDIR/extractor/final.mat
--global-cmvn-stats=$OUTDIR/extractor/global_cmvn.stats
--diag-ubm=$OUTDIR/extractor/final.dubm
--ivector-extractor=$OUTDIR/extractor/final.ie
--num-gselect=5
--min-post=0.025
--posterior-scale=0.1
--max-remembered-frames=1000
--max-count=0
EOF

cat >model.yaml <<EOF
use-nnet2: True
decoder:
  nnet-mode: 3
  use-threaded-decoder: false
  model : $OUTDIR/final.mdl
  word-syms : $OUTDIR/words.txt
  fst : $OUTDIR/HCLG.fst
  mfcc-config : $OUTDIR/conf/mfcc.conf
  ivector-extraction-config : $OUTDIR/conf/ivector_extractor.conf
  #    add-pitch: True
  #    online-pitch-config:
  max-active: 7000
  beam: 15
  lattice-beam: 8.0
  acoustic-scale: 1.0
  #    lm-fst:
  #    big-lm-const-arpa:
  do-endpointing : True
  endpoint-silence-phones : "$SILPHONES"
  endpoint.rule1.min-utterance-length : 5
  endpoint.rule2.min-utterance-length : 15
  endpoint.rule3.min-utterance-length : 15
  #endpoint.rule4.min-utterance-length : 5
  chunk-length-in-secs : 0.15
  traceback-period-in-secs : 0.2
  frame-subsampling-factor: 3
out-dir: /mnt/asr

use-vad: False
silence-timeout: 120

# remove <UNK> from result
post-processor: perl -npe 'BEGIN {use IO::Handle; STDOUT->autoflush(1);} s/<UNK>//i;'
logging:
  version : 1
  disable_existing_loggers: False
  formatters:
    simpleFormater:
      format: '%(asctime)s - %(levelname)7s: %(name)10s: %(message)s'
      datefmt: '%Y-%m-%d %H:%M:%S'
  handlers:
    console:
      class: logging.StreamHandler
      formatter: simpleFormater
      level: DEBUG
  root:
    level: DEBUG
    handlers: [console]
EOF
