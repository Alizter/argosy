(* TODO: this is a bit of a hack, should be using a dedicated Options.v *)
Global Unset Auto Template Polymorphism.
Global Set Implicit Arguments.

From Coq Require Import NArith.NArith.
Local Open Scope N.

Axiom ByteString : Type.

Record MachineUint (bits:nat) : Type :=
  { intTy :> Type;
    int_val0 : intTy;
    int_val1 : intTy;
    intPlus : intTy -> intTy -> intTy;
    intSub : intTy -> intTy -> intTy;
    intCmp : intTy -> intTy -> comparison;
    toNum : intTy -> N;
    toNum_ok : forall x, toNum x < N.pow 2 (N.of_nat bits);
    encodeLE : intTy -> ByteString;
    decodeLE : ByteString -> intTy;
    encode_decode_LE_ok : forall x, decodeLE (encodeLE x) = x; }.

Arguments int_val0 {bits int} : rename.
Arguments int_val1 {bits int} : rename.
Arguments intCmp {bits int} : rename.
Arguments intSub {bits int} : rename.

Axiom uint64 : MachineUint 64.
Axiom uint32 : MachineUint 32.
Axiom uint16 : MachineUint 16.
Axiom uint8   : MachineUint 8.

Axiom uint_val4096 : uint64.

Axiom uint64_to_uint16 : uint64 -> uint16.
Axiom uint16_to_uint64 : uint16 -> uint64.

Module BS.
  Axiom append : ByteString -> ByteString -> ByteString.
  Axiom length : ByteString -> uint64.
  (* BS.take n bs ++ BS.drop n bs = bs *)
  Axiom take : uint64 -> ByteString -> ByteString.
  Axiom drop : uint64 -> ByteString -> ByteString.
  Axiom empty : ByteString.
End BS.

Module BSNotations.
  Delimit Scope bs_scope with bs.
  Infix "++" := BS.append : bs_scope.
End BSNotations.

Axiom Fd:Type.
