From RecoveryRefinement Require Import Helpers.MachinePrimitives.
From RecoveryRefinement Require Import Spec.Proc.
From RecoveryRefinement Require Import Spec.SumProc.

Set Implicit Arguments.

Axiom Array : Type -> Type.
Axiom IORef : Type -> Type.

Inductive LogVar : Type -> Type :=
| File : LogVar Fd
.

Inductive Var : Type -> Type :=
| Log : forall T, LogVar T -> Var T
.

Module Data.
  Inductive Op : Type -> Type :=
  (* generic variable operations *)
  | GetVar : forall T, Var T -> Op T
  | SetVar : forall T, Var T -> T -> Op T

  (* arbitrary references *)
  | NewIORef : forall T, T -> Op (IORef T)
  | ReadIORef : forall T, IORef T -> Op T
  | WriteIORef : forall T, IORef T -> T -> Op unit

  (* arrays *)
  | NewArray : forall T, Op (Array T)
  | ArrayLength : forall T, Array T -> Op uint64
  | ArrayGet : forall T, Array T -> uint64 -> Op T
  | ArrayAppend : forall T, Array T -> T -> Op unit

  (* TODO: hashtables *)
  .

  Definition get Op' {i:Injectable Op Op'} T (var: Var T) : proc Op' T :=
    Call (inject (GetVar var)).

  Definition set Op' {i:Injectable Op Op'} T (var: Var T) (v: T) : proc Op' T :=
    Call (inject (SetVar var v)).

  Definition newIORef Op' {i:Injectable Op Op'}
             T (v:T) : proc Op' (IORef T) :=
    Call (inject (NewIORef v)).

  Definition readIORef Op' {i:Injectable Op Op'}
             T (ref:IORef T) : proc Op' T :=
    Call (inject (ReadIORef ref)).

  Definition writeIORef Op' {i:Injectable Op Op'}
             T (ref:IORef T) (v:T) : proc Op' unit :=
    Call (inject (WriteIORef ref v)).

  (* non-atomic modify (we could add atomicModifyIORef' but I don't think we
  need it) *)
  Definition modifyIORef Op' {i:Injectable Op Op'}
             T (ref:IORef T) (f: T -> T) : proc Op' unit :=
    Bind (Call (inject (ReadIORef ref)))
         (fun x => Call (inject (WriteIORef ref (f x)))).

  Definition arrayAppend Op' {i:Injectable Op Op'} T (a: Array T) (v:T) : proc Op' unit :=
    Call (inject (ArrayAppend a v)).
End Data.

(* TODO: we should be able to make this pattern more convenient, but for now
calling withEnv results in worse syntax than a Bind (due to poor indentation)
and still requires calling lift over the second part. *)
Definition withEnv env (p: proc Data.Op env)
           Op' T (p': env -> proc Op' T)
           {i:Injectable Data.Op Op'} : proc Op' T :=
  Bind (lift p) p'.
