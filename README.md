## Online server and decoding workers:

https://github.com/alumae/kaldi-gstreamer-server
https://github.com/alumae/gst-kaldi-nnet2-online

## Model configuration

  max-active: 7000

Maximum number of active node in decoding. This parameter limits the number of search path we can track at any given frame. Consider this as when you betting on which horse to win, the number of horses you can put money on (when there is infinity number of house)

  beam: 15

This is to prune the search path by limit the worst probability of path we would like to keep. View this parameter as the distance to best path we have. i.e. we don't want to keep our money on horses are x worse than the best horse we find. 

  lattice-beam: 8.0

This is used to prune lattice after decoding, for online decoding it doesn't really matter. However, if you want to do another pass of rescoring or you want to save a lattice rather than one best, you can use this to adjust the size of lattice.


For endpoint detection:

    /// We support four rules.  We terminate decoding if ANY of these rules
    /// evaluates to "true". If you want to add more rules, do it by changing this
    /// code.  If you want to disable a rule, you can set the silence-timeout for
    /// that rule to a very large number.

    /// rule1 times out after 5 seconds of silence, even if we decoded nothing.
    OnlineEndpointRule rule1;
    /// rule2 times out after 0.5 seconds of silence if we reached the final-state
    /// with good probability (relative_cost < 2.0) after decoding something.
    OnlineEndpointRule rule2;
    /// rule3 times out after 1.0 seconds of silence if we reached the final-state
    /// with OK probability (relative_cost < 8.0) after decoding something
    OnlineEndpointRule rule3;
    /// rule4 times out after 2.0 seconds of silence after decoding something,
    /// even if we did not reach a final-state at all.
    OnlineEndpointRule rule4;
    /// rule5 times out after the utterance is 20 seconds long, regardless of
    /// anything else.
    OnlineEndpointRule rule5;


  endpoint.rule1.min-utterance-length : 5
  
  endpoint.rule2.min-utterance-length : 15
  
  endpoint.rule3.min-utterance-length : 15
  
  #endpoint.rule4.min-utterance-length : 5



  chunk-length-in-secs : 0.15

recognition is performed with chunks of audio, this specifies the size of chunk

  traceback-period-in-secs : 0.2

this is how long does the decoder wait before it can do a traceback and output what we have recognized so far

