Require Import POCS.

Require Import Examples.Logging.TxnDiskAPI.
Require Import Examples.ReplicatedDisk.TwoDiskAPI.
Require Import Examples.ReplicatedDisk.OneDiskAPI.

Require Import Examples.Logging.HoareProof.
Require Import Examples.ReplicatedDisk.ReplicatedDiskImpl.

Module LoggingTwoDiskRefinement.
  Definition rf : LayerRefinement TwoDisk.TDLayer TxnDisk.l.
    eapply layer_compose.
    apply ReplicatedDisk.Refinement_TD_OD.
    apply LoggingRefinement.rf.
  Qed.
  Check rf.(compile_exec_seq_ok).
End LoggingTwoDiskRefinement.