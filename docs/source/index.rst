oadr-cpep-fed-predict-aggregator-nf
===================================

The **coordinator workflow** for federated prediction of residual beta-cell
function (C-peptide AUC) in Type 1 Diabetes. It combines the parameter files each
institution produces with
`oadr-cpep-fed-predict-site-nf <https://github.com/NIH-NLM/oadr-cpep-fed-predict-site-nf>`_
— reading only feature lists, coefficient vectors, and trained forests; no
subject-level data is ever pooled.

``aggregate.nf`` combines the per-site coefficient vectors / forests into the
federated model (FedAvg / median / mean per method + union of forests).

Every step runs the ``oadr-cpep`` CLI from the shared
`ghcr.io/nih-nlm/oadr-cpep <https://github.com/NIH-NLM/oadr-cpep>`_ image and is
handed its inputs as explicit files (no directory reaches the CLI).

.. toctree::
   :maxdepth: 2
   :caption: Overview

   README

.. toctree::
   :maxdepth: 2
   :caption: Nextflow Workflow

   nextflow/index

Related projects
----------------

- `oadr-cpep <https://github.com/NIH-NLM/oadr-cpep>`_ — the Python package (CLI + methods) these processes call
- `oadr-cpep-fed-predict-site-nf <https://github.com/NIH-NLM/oadr-cpep-fed-predict-site-nf>`_ — the per-institution workflow

Indices and tables
==================

* :ref:`genindex`
* :ref:`search`
