From Coq Require Import List.

From RecoveryRefinement Require Export Lib.
From RecoveryRefinement Require Import Helpers.MachinePrimitives.
From RecoveryRefinement Require Import Database.Base.


Axiom pid_to_tmpfile : uint64 -> Path.
Axiom rnd_to_msgfile : uint64 -> Path.

Module MailServer.

  Import ProcNotations.
  Local Open Scope proc.


  Definition deliver (msg : ByteString) :=
    pid <- FS.getpid;
    let tmpfile := pid_to_tmpfile pid in
    fd <- FS.open tmpfile;
    _ <- FS.append fd msg;
    _ <- FS.close fd;
    Loop
      (fun _ =>
        rnd <- FS.random;
        let msgfile := rnd_to_msgfile rnd in
        ok <- FS.link tmpfile msgfile;
        if ok then
          LoopRet tt
        else
          Continue tt) tt.

  Definition pickup :=
    fns <- FS.list;
    Loop
      (fun '(fns, msgs) =>
        match fns with
        | nil => LoopRet msgs
        | fn :: fns' =>
          fd <- FS.open fn;
          len <- FS.size fd;
          msg <- FS.readAt fd 0 len;
          _ <- FS.close fd;
          Continue (fns', (fn, msg) :: msgs)
        end) (fns, nil).

  Definition delete (fn : Path) :=
    FS.delete fn.

End MailServer.