Oadr Cpep Modules
=================

Aggregate Vectors Process
^^^^^^^^^^^^^^^^^^^^^^^^^

.. rubric:: ``aggregate_vectors_process``

*Source:* ``modules/oadr_cpep/aggregate_vectors.nf``

::

   Phase 2 (aggregator) — combine the per-site model parameters.
   
   Runs `oadr-cpep aggregate-vectors` over the staged per-site outputs, passed
   EXPLICITLY as one `--vector <file>` per file (coefficient vector CSVs and RF
   .pkl forests; no directory, no glob). The CLI dispatches each by type:
     - Ridge / LASSO vectors -> one federated vector per method (FedAvg / median / mean).
     - Random Forests        -> a union-of-forests ensemble.
   The from-/panel tags of the output are derived from the files' provenance
   columns; panels and feature sources never mix. Only fitted parameters are read.
   
   Input : path vector_files — the staged per-site vectors / forests
   Output: path federated_* — federated vectors (.csv) and forest union (.pkl)

**Params referenced:**

- ``params.aggregation``
- ``params.outdir``
- ``params.publish_mode``


Consensus Features Process
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. rubric:: ``consensus_features_process``

*Source:* ``modules/oadr_cpep/consensus_features.nf``

::

   Aggregator — consensus feature set = the intersection of the per-site selections.
   
   Runs `oadr-cpep consensus-features` over the staged per-site *_selected_features.csv,
   passed EXPLICITLY as one `--features <file>` per file (no directory, no glob). The
   consensus is the intersection — the features every site selected. Only feature lists
   are read, never subject-level data.
   
   Input : path features_files — the staged per-site *_selected_features.csv
   Output: consensus -> consensus*features.csv

**Params referenced:**

- ``params.outdir``
- ``params.publish_mode``

