(*Generated by Sail from capfns.*)
Require Import Sail.Base.
Require Import Sail.Real.
From CheriCaps Require Import CapFnsTypes.
Import ListNotations.
Open Scope string.
Open Scope bool.
Open Scope Z.

Definition eq_unit (_ : unit) (_ : unit) : bool := true.

Definition neq_int (x : Z) (y : Z) : bool := negb (Z.eqb x y).

Definition neq_bool (x : bool) (y : bool) : bool := negb (Bool.eqb x y).

Definition __id (x : Z) : Z := x.

Definition sail_mask {v0 : Z} (len : Z) (v : mword v0) : mword len :=
			  
   if Z.leb len (length_mword v) then vector_truncate v len else zero_extend v len.

Definition sail_ones (n : Z) : mword n := not_vec (zeros n).

Definition slice_mask (n : Z) (i : Z) (l : Z) : mword n :=
   if Z.geb l n then shiftl (sail_ones n) i
   else
     let one : bits n := sail_mask n (('b"1")  : bits 1) in
     shiftl (sub_vec (shiftl one l) one) i.

Definition _shl_int_general (m : Z) (n : Z) : Z :=
   if Z.geb n 0 then shl_int m n else shr_int m (Z.opp n).

Definition _shr_int_general (m : Z) (n : Z) : Z :=
   if Z.geb n 0 then shr_int m n else shl_int m (Z.opp n).

Definition fdiv_int (n : Z) (m : Z) : Z :=
   if andb (Z.ltb n 0) (Z.gtb m 0) then Z.sub (Z.quot (Z.add n 1) m) 1
   else if andb (Z.gtb n 0) (Z.ltb m 0) then Z.sub (Z.quot (Z.sub n 1) m) 1
   else Z.quot n m.

Definition fmod_int (n : Z) (m : Z) : Z := Z.sub n (Z.mul m (fdiv_int n m)).

Definition undefined_option {a : Type} (typ_a : a) : M (option a) :=
   (undefined_unit tt) >>= fun (u_0 : unit) =>
   let u_1 : a := typ_a in
   (internal_pick [Some u_1; None])
    : M (option a).

Definition is_none {a : Type} (opt : option a) : bool :=
   match opt with | Some _ => false | None => true end.

Definition is_some {a : Type} (opt : option a) : bool :=
   match opt with | Some _ => true | None => false end.

Definition concat_str_bits {n : Z} (str : string) (x : mword n) : string :=
   String.append str (string_of_bits x).

Definition concat_str_dec (str : string) (x : Z) : string := String.append str (dec_str x).

Definition eq_bits_int {n : Z} (x : mword n) (y : Z) : bool :=
   Z.eqb (uint x) y.

Definition Ones (n : Z) (*n >=? 0*) : mword n := sail_ones n.

Definition Zeros (n : Z) (*n >=? 0*) : mword n := zeros n.

Definition Bit (b : mword 1) : bitU := access_vec_dec b 0.

Definition integer_subrange (i : Z) (hi : Z) (lo : Z) (*lo <=? hi*) : mword (hi - lo + 1) :=
   get_slice_int (Z.add (Z.sub hi lo) 1) i lo.

Definition Slice_int (i : Z) (l : Z) (n : Z) (*n >=? 0*) : mword n := get_slice_int n i l.

Definition CAP_FLAGS_LO_BIT : Z := 56.
#[export] Hint Unfold CAP_FLAGS_LO_BIT : sail.
Definition CAP_VALUE_HI_BIT : Z := 63.
#[export] Hint Unfold CAP_VALUE_HI_BIT : sail.
Definition CAP_VALUE_LO_BIT : Z := 0.
#[export] Hint Unfold CAP_VALUE_LO_BIT : sail.
Definition CAP_VALUE_NUM_BITS : Z := Z.add (Z.sub CAP_VALUE_HI_BIT CAP_VALUE_LO_BIT) 1.
#[export] Hint Unfold CAP_VALUE_NUM_BITS : sail.
Definition CAP_BASE_HI_BIT : Z := 79.
#[export] Hint Unfold CAP_BASE_HI_BIT : sail.
Definition CAP_BASE_LO_BIT : Z := 64.
#[export] Hint Unfold CAP_BASE_LO_BIT : sail.
Definition CAP_MW : Z := Z.add (Z.sub CAP_BASE_HI_BIT CAP_BASE_LO_BIT) 1.
#[export] Hint Unfold CAP_MW : sail.
Definition CapBoundsUsesValue (exp : Z) : bool := Z.ltb (Z.add exp CAP_MW) CAP_VALUE_NUM_BITS.

Definition CAP_BASE_EXP_HI_BIT : Z := 66.
#[export] Hint Unfold CAP_BASE_EXP_HI_BIT : sail.
Definition CAP_LIMIT_EXP_HI_BIT : Z := 82.
#[export] Hint Unfold CAP_LIMIT_EXP_HI_BIT : sail.
Definition CAP_LIMIT_LO_BIT : Z := 80.
#[export] Hint Unfold CAP_LIMIT_LO_BIT : sail.
Definition CAP_IE_BIT : Z := 94.
#[export] Hint Unfold CAP_IE_BIT : sail.
Definition CapIsInternalExponent (c : mword 129) : bool :=
   eq_vec (vec_of_bits [access_vec_dec c CAP_IE_BIT]  : mword 1) (('b"0")  : mword 1).

Definition CapGetExponent (c : mword 129) : Z :=
   if CapIsInternalExponent c then
     let nexp : bits 6 :=
       concat_vec (subrange_vec_dec c CAP_LIMIT_EXP_HI_BIT CAP_LIMIT_LO_BIT)
         (subrange_vec_dec c CAP_BASE_EXP_HI_BIT CAP_BASE_LO_BIT) in
     uint (not_vec nexp)
   else 0.

Definition CapGetValue (c : mword 129) : mword (63 - 0 + 1) :=
   subrange_vec_dec c CAP_VALUE_HI_BIT CAP_VALUE_LO_BIT.

Definition CAP_BOUND_NUM_BITS : Z := Z.add CAP_VALUE_NUM_BITS 1.
#[export] Hint Unfold CAP_BOUND_NUM_BITS : sail.
Definition CAP_BOUND_MAX : bits CAP_BOUND_NUM_BITS :=
Slice_int (shl_int 1 CAP_VALUE_NUM_BITS) 0 CAP_BOUND_NUM_BITS.
#[export] Hint Unfold CAP_BOUND_MAX : sail.
Definition CAP_BOUND_MIN : bits CAP_BOUND_NUM_BITS :=
Slice_int (uint ((Ox"0")  : mword 4)) 0 CAP_BOUND_NUM_BITS.
#[export] Hint Unfold CAP_BOUND_MIN : sail.
Definition CAP_MAX_ENCODEABLE_EXPONENT : Z := 63.
#[export] Hint Unfold CAP_MAX_ENCODEABLE_EXPONENT : sail.
Definition CAP_MAX_EXPONENT : Z := Z.add (Z.sub CAP_VALUE_NUM_BITS CAP_MW) 2.
#[export] Hint Unfold CAP_MAX_EXPONENT : sail.
Definition CapBoundsAddress (address : mword (63 - 0 + 1)) : mword (63 - 0 + 1) :=
   sign_extend (subrange_vec_dec address (Z.sub CAP_FLAGS_LO_BIT 1) 0) CAP_VALUE_NUM_BITS.

Definition CAP_BASE_MANTISSA_LO_BIT : Z := 67.
#[export] Hint Unfold CAP_BASE_MANTISSA_LO_BIT : sail.
Definition CapGetBottom (c : mword 129) : mword (79 - 64 + 1) :=
   if CapIsInternalExponent c then
     concat_vec (subrange_vec_dec c CAP_BASE_HI_BIT CAP_BASE_MANTISSA_LO_BIT) (('b"000")  : mword 3)
   else subrange_vec_dec c CAP_BASE_HI_BIT CAP_BASE_LO_BIT.

Definition CAP_LIMIT_HI_BIT : Z := 93.
#[export] Hint Unfold CAP_LIMIT_HI_BIT : sail.
Definition CAP_LIMIT_MANTISSA_LO_BIT : Z := 83.
#[export] Hint Unfold CAP_LIMIT_MANTISSA_LO_BIT : sail.
Definition CapUnsignedLessThan {N : Z} (a : mword N) (b : mword N) : bool :=
   Z.ltb (uint a) (uint b).

Definition CapGetTop (c : mword 129) : mword (79 - 64 + 1) :=
   let lmsb : bits 2 := ('b"00")  : mword 2 in
   let lcarry : bits 2 := ('b"00")  : mword 2 in
   let b : bits CAP_MW := CapGetBottom c in
   let t : bits CAP_MW := mword_of_int (Z.add (Z.sub 79 64) 1) in  
   let '(lmsb, t) :=
     (if CapIsInternalExponent c then
        let lmsb : bits 2 := ('b"01")  : mword 2 in
        let t : bits CAP_MW :=
          concat_vec
            (concat_vec (('b"00")  : mword 2)
               (subrange_vec_dec c CAP_LIMIT_HI_BIT CAP_LIMIT_MANTISSA_LO_BIT))
            (('b"000")
             : mword 3) in
        (lmsb, t)
      else
        let t : bits CAP_MW :=
          concat_vec (('b"00")  : mword 2) (subrange_vec_dec c CAP_LIMIT_HI_BIT CAP_LIMIT_LO_BIT) in
        (lmsb, t))
      : (mword 2 * mword (79 - 64 + 1)) in
   let lcarry : mword 2 :=
     if CapUnsignedLessThan (subrange_vec_dec t (Z.sub CAP_MW 3) 0)
          (subrange_vec_dec b (Z.sub CAP_MW 3) 0) then
       ('b"01")
        : mword 2
     else lcarry in
   let t : bits CAP_MW :=
     update_subrange_vec_dec t (Z.sub CAP_MW 1) (Z.sub CAP_MW 2)
       (add_vec (add_vec (subrange_vec_dec b (Z.sub CAP_MW 1) (Z.sub CAP_MW 2)) lmsb) lcarry) in
   t.

Definition CapIsExponentOutOfRange (c : mword 129) : bool :=
   let exp := CapGetExponent c in
   andb (Z.gtb exp CAP_MAX_EXPONENT) (Z.ltb exp CAP_MAX_ENCODEABLE_EXPONENT).

Definition CapUnsignedGreaterThan {N : Z} (a : mword N) (b : mword N) : bool :=
   Z.gtb (uint a) (uint b).

Definition CapGetBounds (c : mword 129)
:  ((mword (63 - 0 + 1 + 1) * mword (63 - 0 + 1 + 1) * bool)) :=
   let exp : Z := CapGetExponent c in
   (if Z.eqb exp CAP_MAX_ENCODEABLE_EXPONENT then 
		(CAP_BOUND_MIN, CAP_BOUND_MAX, true)										   
    else if CapIsExponentOutOfRange c then (CAP_BOUND_MIN, CAP_BOUND_MAX, false)
    else
      let base : mword 66 := mword_of_int 0 in
      let limit : mword 66 := mword_of_int 0 in
      let bottom : bits CAP_MW := CapGetBottom c in							   
      let top : mword CAP_MW := CapGetTop c in								  
      let base : bits 66 := set_slice 66 exp base 0 (Zeros exp) in
      let limit : bits 66 := set_slice 66 exp limit 0 (Zeros exp) in
      let base : bits 66 :=
        update_subrange_vec_dec base (Z.sub (Z.add exp CAP_MW) 1) exp (autocast bottom) in
      let limit : bits 66 :=
        update_subrange_vec_dec limit (Z.sub (Z.add exp CAP_MW) 1) exp (autocast top) in
      let a : bits 66 := concat_vec (('b"00")  : mword 2) (CapBoundsAddress (CapGetValue c)) in
      let A3 : bits 3 :=
        autocast (subrange_vec_dec a (Z.sub (Z.add exp CAP_MW) 1) (Z.sub (Z.add exp CAP_MW) 3)) in
      let B3 : bits 3 := subrange_vec_dec bottom (Z.sub CAP_MW 1) (Z.sub CAP_MW 3) in
      let T3 : bits 3 := subrange_vec_dec top (Z.sub CAP_MW 1) (Z.sub CAP_MW 3) in
      let R3 : bits 3 := sub_vec B3 (('b"001")  : mword 3) in
      let aHi : Z := 0 in
      let aHi : Z := if CapUnsignedLessThan A3 R3 then 1 else 0 in
      let '(aHi) := aHi in
      let bHi : Z := 0 in
      let bHi : Z := if CapUnsignedLessThan B3 R3 then 1 else 0 in
      let '(bHi) := bHi in
      let tHi : Z := 0 in
      let tHi : Z := if CapUnsignedLessThan T3 R3 then 1 else 0 in
      let '(tHi) := tHi in
      let '(correction_base) := Z.sub bHi aHi in
      let '(correction_limit) := Z.sub tHi aHi in
      let '((base, limit)) :=
        (if Z.ltb (Z.add exp CAP_MW) (Z.add CAP_MAX_EXPONENT CAP_MW) then
           let atop : bits (65 - (exp + CAP_MW) + 1) := subrange_vec_dec a 65 (Z.add exp CAP_MW) in
           let base : bits 66 :=
             update_subrange_vec_dec base 65 (Z.add exp CAP_MW)
               (add_vec_int (autocast atop) correction_base) in
           let limit : bits 66 :=
             update_subrange_vec_dec limit 65 (Z.add exp CAP_MW)
               (add_vec_int (autocast atop) correction_limit) in
           (base, limit)
         else (base, limit))
         : (mword 66 * mword 66) in
      let l2 : bits 2 := subrange_vec_dec limit 64 63 in
      let b2 : bits 2 :=
        concat_vec (('b"0")  : mword 1) (vec_of_bits [access_vec_dec base 63]  : mword 1) in
      let limit : mword 66 :=
		  if andb (Z.ltb exp (Z.sub CAP_MAX_EXPONENT 1))
             (CapUnsignedGreaterThan (sub_vec l2 b2) (('b"01")  : mword 2)) then
          update_vec_dec limit 64 (Bit (not_vec (vec_of_bits [access_vec_dec limit 64]  : mword 1)))
        else limit in
      (concat_vec (('b"0")  : mword 1) (subrange_vec_dec base 63 0), subrange_vec_dec limit
                                                                               64 0, true))
    : ((mword (63 - 0 + 1 + 1) * mword (63 - 0 + 1 + 1) * bool)).

Definition CapBoundsEqual (a : mword 129) (b : mword 129) : bool :=
   let abase : (bits CAP_BOUND_NUM_BITS) := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in
   let alimit : (bits CAP_BOUND_NUM_BITS) := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let avalid : bool := false in 
   let bbase : (bits CAP_BOUND_NUM_BITS) := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let blimit : (bits CAP_BOUND_NUM_BITS) := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in  
   let bvalid : bool := false in 
   let w_0 : (mword (63 - 0 + 1 + 1) * mword (63 - 0 + 1 + 1) * bool) := (CapGetBounds a) in
   let '(tup_0, tup_1, tup_2) := w_0  : (mword (63 - 0 + 1 + 1) * mword (63 - 0 + 1 + 1) * bool) in
   let abase : bits CAP_BOUND_NUM_BITS := tup_0 in
   let alimit : bits CAP_BOUND_NUM_BITS := tup_1 in
   let avalid : bool := tup_2 in
   let w_1 : (mword (63 - 0 + 1 + 1) * mword (63 - 0 + 1 + 1) * bool) := CapGetBounds b in
   let '(tup_0, tup_1, tup_2) := w_1  : (mword (63 - 0 + 1 + 1) * mword (63 - 0 + 1 + 1) * bool) in
   let bbase : bits CAP_BOUND_NUM_BITS := tup_0 in
   let blimit : bits CAP_BOUND_NUM_BITS := tup_1 in
   let bvalid : bool := tup_2 in
   (andb (andb (andb (eq_vec abase bbase) (eq_vec alimit blimit)) avalid) bvalid).

Definition CapIsRepresentable (c : mword 129) (address : mword (63 - 0 + 1)) : bool :=
   let newc : bits 129 := c in
   let newc : bits 129 := update_subrange_vec_dec newc CAP_VALUE_HI_BIT CAP_VALUE_LO_BIT address in
   (CapBoundsEqual c newc)
    : bool.

Definition CAP_TAG_BIT : Z := 128.
#[export] Hint Unfold CAP_TAG_BIT : sail.
Definition CapSetTag (c : mword 129) (t : mword 64) : mword 129 :=
   let r : bits 129 := c in
   update_vec_dec r CAP_TAG_BIT (Bit (vec_of_bits [access_vec_dec t 0]  : mword 1)).

Definition CapWithTagClear (c : mword 129) : mword 129 :=
   CapSetTag c (zero_extend (('b"0")  : mword 1) 64).

Definition CapSetValue (c_arg : mword 129) (v : mword (63 - 0 + 1)) : mword 129 :=
   let c : bits 129 := c_arg in
   let oldv : bits CAP_VALUE_NUM_BITS := CapGetValue c in
   let w_0 : bool := CapIsRepresentable c v in
   let c : mword 129 := if sumbool_of_bool (negb w_0) then CapWithTagClear c else c in
   let c : bits 129 := update_subrange_vec_dec c CAP_VALUE_HI_BIT CAP_VALUE_LO_BIT v in
   let c : mword 129 :=
     if andb (CapBoundsUsesValue (CapGetExponent c))
          (neq_vec (vec_of_bits [access_vec_dec v (Z.sub CAP_FLAGS_LO_BIT 1)]  : mword 1)
             (vec_of_bits [access_vec_dec oldv (Z.sub CAP_FLAGS_LO_BIT 1)]  : mword 1)) then
       CapWithTagClear c
     else c in
   c.

Definition CAP_OTYPE_HI_BIT : Z := 109.
#[export] Hint Unfold CAP_OTYPE_HI_BIT : sail.
Definition CAP_OTYPE_LO_BIT : Z := 95.
#[export] Hint Unfold CAP_OTYPE_LO_BIT : sail.
Definition CapGetObjectType (c : mword 129) : mword (63 - 0 + 1) :=
   zero_extend (subrange_vec_dec c CAP_OTYPE_HI_BIT CAP_OTYPE_LO_BIT) CAP_VALUE_NUM_BITS.
  
Definition CapIsSealed (c : mword 129) : bool :=
   neq_vec (CapGetObjectType c) (Zeros CAP_VALUE_NUM_BITS).
   
Definition CAP_FLAGS_HI_BIT : Z := 63.
#[export] Hint Unfold CAP_FLAGS_HI_BIT : sail.
Definition CapSetFlags (c__arg : mword 129) (f : mword (63 - 0 + 1)) : mword 129 :=
   let c : bits 129 := c__arg in
   update_subrange_vec_dec c CAP_FLAGS_HI_BIT CAP_FLAGS_LO_BIT
     (subrange_vec_dec f CAP_FLAGS_HI_BIT CAP_FLAGS_LO_BIT).
   
Definition CAP_PERMS_HI_BIT : Z := 127.
#[export] Hint Unfold CAP_PERMS_HI_BIT : sail.
Definition CAP_PERMS_LO_BIT : Z := 110.
#[export] Hint Unfold CAP_PERMS_LO_BIT : sail.
Definition CAP_PERMS_NUM_BITS : Z := Z.add (Z.sub CAP_PERMS_HI_BIT CAP_PERMS_LO_BIT) 1.
#[export] Hint Unfold CAP_PERMS_NUM_BITS : sail.
   
Definition CAP_PERM_EXECUTIVE : bits 64 := integer_subrange (shl_int 1 1) 63 0.
#[export] Hint Unfold CAP_PERM_EXECUTIVE : sail.
Definition CAP_PERM_EXECUTE : bits 64 := integer_subrange (shl_int 1 15) 63 0.
#[export] Hint Unfold CAP_PERM_EXECUTE : sail.
Definition CAP_PERM_SYSTEM : bits 64 := integer_subrange (shl_int 1 9) 63 0.
#[export] Hint Unfold CAP_PERM_SYSTEM : sail.
Definition CAP_PERM_LOAD : bits 64 := integer_subrange (shl_int 1 17) 63 0.
#[export] Hint Unfold CAP_PERM_LOAD : sail.
Definition CAP_PERM_STORE : bits 64 := integer_subrange (shl_int 1 16) 63 0.
#[export] Hint Unfold CAP_PERM_STORE : sail.
Definition CAP_PERM_LOAD_CAP : bits 64 := integer_subrange (shl_int 1 14) 63 0.
#[export] Hint Unfold CAP_PERM_LOAD_CAP : sail.
Definition CAP_PERM_STORE_CAP : bits 64 := integer_subrange (shl_int 1 13) 63 0.
#[export] Hint Unfold CAP_PERM_STORE_CAP : sail.
Definition CAP_PERM_STORE_LOCAL : bits 64 := integer_subrange (shl_int 1 12) 63 0.
#[export] Hint Unfold CAP_PERM_STORE_LOCAL : sail.
Definition CAP_PERM_SEAL : bits 64 := integer_subrange (shl_int 1 11) 63 0.
#[export] Hint Unfold CAP_PERM_SEAL : sail.
Definition CAP_PERM_UNSEAL : bits 64 := integer_subrange (shl_int 1 10) 63 0.
#[export] Hint Unfold CAP_PERM_UNSEAL : sail.
Definition CAP_PERM_BRANCH_SEALED_PAIR : bits 64 := integer_subrange (shl_int 1 8) 63 0.
#[export] Hint Unfold CAP_PERM_BRANCH_SEALED_PAIR : sail.
Definition CAP_PERM_COMPARTMENT_ID : bits 64 := integer_subrange (shl_int 1 7) 63 0.
#[export] Hint Unfold CAP_PERM_COMPARTMENT_ID : sail.
Definition CAP_PERM_MUTABLE_LOAD : bits 64 := integer_subrange (shl_int 1 6) 63 0.
#[export] Hint Unfold CAP_PERM_MUTABLE_LOAD : sail.
Definition CAP_PERM_USER4 : bits 64 := integer_subrange (shl_int 1 5) 63 0.
#[export] Hint Unfold CAP_PERM_USER4 : sail.
Definition CAP_PERM_USER3 : bits 64 := integer_subrange (shl_int 1 4) 63 0.
#[export] Hint Unfold CAP_PERM_USER3 : sail.
Definition CAP_PERM_USER2 : bits 64 := integer_subrange (shl_int 1 3) 63 0.
#[export] Hint Unfold CAP_PERM_USER2 : sail.
Definition CAP_PERM_USER1 : bits 64 := integer_subrange (shl_int 1 2) 63 0.
#[export] Hint Unfold CAP_PERM_USER1 : sail.
Definition CAP_PERM_GLOBAL : bits 64 := integer_subrange 1 63 0.
#[export] Hint Unfold CAP_PERM_GLOBAL : sail.
Definition CAP_PERM_NONE : bits 64 := integer_subrange 0 63 0.
#[export] Hint Unfold CAP_PERM_NONE : sail.
   
Definition CAP_OTYPE_NUM_BITS : Z := Z.add (Z.sub CAP_OTYPE_HI_BIT CAP_OTYPE_LO_BIT) 1.
#[export] Hint Unfold CAP_OTYPE_NUM_BITS : sail.
Definition CAP_LENGTH_NUM_BITS : Z := Z.add CAP_VALUE_NUM_BITS 1.
#[export] Hint Unfold CAP_LENGTH_NUM_BITS : sail.

Definition CapGetPermissions (c : mword 129) : mword (127 - 110 + 1) :=
   subrange_vec_dec c CAP_PERMS_HI_BIT CAP_PERMS_LO_BIT.
   
Definition CapCheckPermissions (c : mword 129) (mask : mword 64) : bool :=
   let perms : bits CAP_PERMS_NUM_BITS := CapGetPermissions c in
   eq_vec (or_vec perms (not_vec (subrange_vec_dec mask (Z.sub CAP_PERMS_NUM_BITS 1) 0)))
     (Ones CAP_PERMS_NUM_BITS).

Definition CapIsSystemAccessPermitted (c : mword 129) : bool :=
   CapCheckPermissions c (or_vec CAP_PERM_EXECUTE CAP_PERM_SYSTEM).

Definition CapIsExecutive (c : mword 129) : bool := CapCheckPermissions c CAP_PERM_EXECUTIVE.

Definition CapUnsignedGreaterThanOrEqual {N : Z} (a : mword N) (b : mword N) : bool :=
   Z.geb (uint a) (uint b).

(* Definition CapIsRepresentableFast (c : mword 129) (increment_name_arg : mword (63 - 0 + 1)) : bool :=
   let increment_name : bits CAP_VALUE_NUM_BITS := increment_name_arg in
   let B3 : bits (0 + (CAP_MW - 1 - (CAP_MW - 3) + 1)) := mword_of_int (Z.add 0 (Z.add (Z.sub (Z.sub (Z.add (Z.sub 79 64) 1) 1) (Z.sub (Z.add (Z.sub 79 64) 1) 3)) 1)) in 
   let R' : bits 16 := mword_of_int 0 in 
   let R3 : bits 3 := mword_of_int 0 in 
   let a_mid : bits (0 + (CAP_MW - 1 - 0 + 1)) := mword_of_int (Z.add 0 (Z.add (Z.sub (Z.sub (Z.add (Z.sub 79 64) 1) 1) 0) 1)) in 
   let diff : bits 16 := mword_of_int 0 in 
   let diff1 : bits 16 := mword_of_int 0 in 
   let i_mid : bits (0 + (CAP_MW - 1 - 0 + 1)) := mword_of_int (Z.add 0 (Z.add (Z.sub (Z.sub (Z.add (Z.sub 79 64) 1) 1) 0) 1)) in 
   let i_top : bits 64 := mword_of_int 0 in 
   let exp := CapGetExponent c in
   if (Z.geb exp (Z.sub CAP_MAX_EXPONENT 2)) then true
   else
      let a : bits CAP_VALUE_NUM_BITS := CapGetValue c in
      let a : bits CAP_VALUE_NUM_BITS := CapBoundsAddress a in
      let increment_name : bits CAP_VALUE_NUM_BITS := CapBoundsAddress increment_name in
      let i_top : bits 64 := arith_shiftr increment_name (Z.add exp CAP_MW) in
      let i_mid : bits (0 + (CAP_MW - 1 - 0 + 1)) :=
         subrange_vec_dec (shiftr increment_name exp) (Z.sub CAP_MW 1) 0 in
      let a_mid : bits (0 + (CAP_MW - 1 - 0 + 1)) :=
         subrange_vec_dec (shiftr a exp) (Z.sub CAP_MW 1) 0 in
      let B3 : bits (0 + (CAP_MW - 1 - (CAP_MW - 3) + 1)) :=
         subrange_vec_dec (CapGetBottom c) (Z.sub CAP_MW 1) (Z.sub CAP_MW 3) in
      let R3 : bits 3 := sub_vec B3 (('b"001")  : mword 3) in
      let R' : bits 16 := concat_vec R3 (Zeros (Z.sub CAP_MW 3)) in
      let diff : bits 16 := sub_vec R' a_mid in
      let diff1 : bits 16 := sub_vec_int diff 1 in
         if eq_bits_int i_top 0 then CapUnsignedLessThan i_mid diff1
         else if eq_vec i_top (Ones CAP_VALUE_NUM_BITS) then
                andb (CapUnsignedGreaterThanOrEqual i_mid diff) (neq_vec R' a_mid)
              else false. *)

(* Definition CapAdd (c : mword 129) (increment_name : mword (63 - 0 + 1)) : mword 129 :=
   let newc : bits 129 := c in
   let newc : bits 129 :=
     update_subrange_vec_dec newc CAP_VALUE_HI_BIT CAP_VALUE_LO_BIT
       (add_vec (CapGetValue c) increment_name) in
   let w_0 : bool := CapIsRepresentableFast c increment_name in
   let newc : mword 129 :=
     if (negb w_0) then update_vec_dec newc CAP_TAG_BIT (Bit (('b"0")  : mword 1))
     else newc in
   let newc : mword 129 :=
     if CapIsExponentOutOfRange c then update_vec_dec newc CAP_TAG_BIT (Bit (('b"0")  : mword 1))
     else newc in
   let newc : mword 129 :=
     if andb (CapBoundsUsesValue (CapGetExponent c))
          (neq_vec
             (vec_of_bits [access_vec_dec (CapGetValue c) (Z.sub CAP_FLAGS_LO_BIT 1)]  : mword 1)
             (vec_of_bits [access_vec_dec (CapGetValue newc) (Z.sub CAP_FLAGS_LO_BIT 1)]  : mword 1))
     then
       update_vec_dec newc CAP_TAG_BIT (Bit (('b"0")  : mword 1))
     else newc in
   newc. *)

Definition CapNull '(tt : unit) : mword 129 := Zeros 129.

Definition CapIsExecutePermitted (c : mword 129) : bool := CapCheckPermissions c CAP_PERM_EXECUTE.

Definition CapUnsignedLessThanOrEqual {N : Z} (a : mword N) (b : mword N) : bool :=
   Z.leb (uint a) (uint b).

Definition CapIsRangeInBounds (c : mword 129) (start_address : mword (63 - 0 + 1)) (length : mword (63 - 0 + 1 + 1)) : bool :=
   let base : bits CAP_BOUND_NUM_BITS := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let limit : bits CAP_BOUND_NUM_BITS := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let valid_name : bool := false in 
   let w_0 : (mword (63 - 0 + 1 + 1) * mword (63 - 0 + 1 + 1) * bool) := CapGetBounds c in
   let '(tup_0, tup_1, tup_2) := w_0  : (mword (63 - 0 + 1 + 1) * mword (63 - 0 + 1 + 1) * bool) in
   let base : bits CAP_BOUND_NUM_BITS := tup_0 in
   let limit : bits CAP_BOUND_NUM_BITS := tup_1 in
   let valid_name : bool := tup_2 in
   let start_ext : bits 65 := concat_vec (('b"0")  : mword 1) start_address in
   let limit_ext : bits 65 := add_vec start_ext length in
   andb (andb (CapUnsignedGreaterThanOrEqual start_ext base)
        (CapUnsignedLessThanOrEqual limit_ext limit)) valid_name.

Definition CapGetTag (c : mword 129) : mword 64 :=
   zero_extend (vec_of_bits [access_vec_dec c CAP_TAG_BIT]  : mword 1) 64.

Definition CapIsTagClear (c : mword 129) : bool :=
   eq_vec (vec_of_bits [access_vec_dec (CapGetTag c) 0]  : mword 1) (('b"0")  : mword 1).

Definition CapPermsInclude (perms : mword 64) (mask : mword 64) : bool :=
   eq_vec
     (and_vec (subrange_vec_dec perms (Z.sub CAP_PERMS_NUM_BITS 1) 0)
        (subrange_vec_dec mask (Z.sub CAP_PERMS_NUM_BITS 1) 0))
     (subrange_vec_dec mask (Z.sub CAP_PERMS_NUM_BITS 1) 0).

(* Definition CapGetBase (c : mword 129) : mword (63 - 0 + 1) :=
   let base : bits CAP_BOUND_NUM_BITS := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let '(_tup_0, _tup_1, _tup_2) := CapGetBounds c in
   let base : bits CAP_BOUND_NUM_BITS := _tup_0 in
   slice base 0 CAP_VALUE_NUM_BITS. *)

Definition CapClearPerms (c__arg : mword 129) (mask : mword 64) : mword 129 :=
   let c : bits 129 := c__arg in
   let old_perms : bits CAP_PERMS_NUM_BITS := CapGetPermissions c in
   let new_perms : bits CAP_PERMS_NUM_BITS :=
     and_vec old_perms (not_vec (subrange_vec_dec mask (Z.sub CAP_PERMS_NUM_BITS 1) 0)) in
   update_subrange_vec_dec c CAP_PERMS_HI_BIT CAP_PERMS_LO_BIT
     (subrange_vec_dec new_perms (Z.sub CAP_PERMS_NUM_BITS 1) 0).

Definition CapIsMutableLoadPermitted (c : mword 129) : bool :=
   CapCheckPermissions c CAP_PERM_MUTABLE_LOAD.

Definition CapIsTagSet (c : mword 129) : bool :=
   eq_vec (vec_of_bits [access_vec_dec (CapGetTag c) 0]  : mword 1) (('b"1")  : mword 1).

Definition CapSetObjectType (c__arg : mword 129) (o : mword 64) : mword 129 :=
   let c : bits 129 := c__arg in
   update_subrange_vec_dec c CAP_OTYPE_HI_BIT CAP_OTYPE_LO_BIT
     (subrange_vec_dec o (Z.sub CAP_OTYPE_NUM_BITS 1) 0).

Definition CapSetBounds (c : mword 129) (req_len : mword (63 - 0 + 1 + 1)) (exact : bool) : mword 129 :=
   let L_ie : bits 13 := mword_of_int 0 in 
   let obase : bits CAP_BOUND_NUM_BITS := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let olimit : bits CAP_BOUND_NUM_BITS := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let ovalid : bool := false in 
   let exp : Z :=
     Z.sub CAP_MAX_EXPONENT
       (count_leading_zeros (subrange_vec_dec req_len CAP_VALUE_NUM_BITS (Z.sub CAP_MW 1))) in
   let ie : bool :=
     orb (neq_int exp 0)
       (eq_vec (vec_of_bits [access_vec_dec req_len (Z.sub CAP_MW 2)]  : mword 1)
          (('b"1")
           : mword 1)) in
   let base : bits CAP_VALUE_NUM_BITS := CapGetValue c in
   let abase : bits CAP_VALUE_NUM_BITS :=
     if CapBoundsUsesValue (CapGetExponent c) then CapBoundsAddress base
     else base in
   let req_base : bits (CAP_VALUE_NUM_BITS + 2) := concat_vec (('b"00")  : mword 2) abase in
   let req_top : bits (CAP_VALUE_NUM_BITS + 2) :=
     add_vec req_base (concat_vec (('b"0")  : mword 1) req_len) in
   let Bbits : bits CAP_MW := subrange_vec_dec req_base (Z.sub CAP_MW 1) 0 in
   let TBits : bits CAP_MW := subrange_vec_dec req_top (Z.sub CAP_MW 1) 0 in
   let lostTop : bool := false in
   let lostBottom : bool := false in
   let incrementE_name : bool := false in
   let '(Bbits, TBits, exp, lostBottom, lostTop) :=
      (if ie then
         let B_ie : bits (CAP_MW - 3) := autocast (subrange_vec_dec req_base (Z.sub (Z.add exp CAP_MW) 1) (Z.add exp 3)) in
         let T_ie : bits (CAP_MW - 3) := autocast (subrange_vec_dec req_top (Z.sub (Z.add exp CAP_MW) 1) (Z.add exp 3)) in
         let maskLo : bits (CAP_VALUE_NUM_BITS + 2) := zero_extend (Ones (Z.add exp 3)) (Z.add CAP_VALUE_NUM_BITS 2) in
         let lostBottom : bool := neq_vec (and_vec req_base maskLo) (Zeros (Z.add CAP_VALUE_NUM_BITS 2)) in
         let lostTop : bool := neq_vec (and_vec req_top maskLo) (Zeros (Z.add CAP_VALUE_NUM_BITS 2)) in
         let T_ie : mword (79 - 64 + 1 - 3) :=
            if lostTop then add_vec_int T_ie 1
            else T_ie in
         let L_ie : bits 13 := sub_vec T_ie B_ie in
         let '(B_ie, T_ie, incrementE_name, lostBottom, lostTop) :=
         if eq_vec (vec_of_bits [access_vec_dec L_ie (Z.sub CAP_MW 4)]  : mword 1) (('b"1") : mword 1) then
            let incrementE_name : bool := true in
            let lostBottom : bool :=
            orb lostBottom (eq_vec (vec_of_bits [access_vec_dec B_ie 0]  : mword 1) (('b"1")  : mword 1)) in
            let lostTop : bool := orb lostTop (eq_vec (vec_of_bits [access_vec_dec T_ie 0]  : mword 1) (('b"1")  : mword 1)) in
            let B_ie : bits (CAP_MW - 3) := autocast (subrange_vec_dec req_base (Z.add exp CAP_MW) (Z.add exp 4)) in
            let T_ie : bits (CAP_MW - 3) := autocast (subrange_vec_dec req_top (Z.add exp CAP_MW) (Z.add exp 4)) in
            let T_ie : mword (79 - 64 + 1 - 3) :=
            if lostTop then add_vec_int T_ie 1
            else T_ie in
            (B_ie, T_ie, incrementE_name, lostBottom, lostTop)
         else 
            (B_ie, T_ie, incrementE_name, lostBottom, lostTop)
         in
         let exp : Z := if Bool.eqb incrementE_name true then Z.add exp 1 else exp in
         let Bbits : bits CAP_MW := concat_vec B_ie (('b"000")  : mword 3) in
         let TBits : bits CAP_MW := concat_vec T_ie (('b"000")  : mword 3) in
         (Bbits, TBits, exp, lostBottom, lostTop)
      else 
         (Bbits, TBits, exp, lostBottom, lostTop)
      ) in       
   let exp := exp in
   let newc : bits 129 := c in
   let w_0 : (mword (63 - 0 + 1 + 1) * mword (63 - 0 + 1 + 1) * bool) := CapGetBounds c in
   let '(tup_0, tup_1, tup_2) := w_0  : (mword (63 - 0 + 1 + 1) * mword (63 - 0 + 1 + 1) * bool) in
   let obase : bits CAP_BOUND_NUM_BITS := tup_0 in
   let olimit : bits CAP_BOUND_NUM_BITS := tup_1 in
   let ovalid : bool := tup_2 in
   let newc : mword 129 :=
     if (orb
          (orb (negb (CapUnsignedGreaterThanOrEqual (slice req_base 0 CAP_BOUND_NUM_BITS) obase))
             (negb (CapUnsignedLessThanOrEqual (slice req_top 0 CAP_BOUND_NUM_BITS) olimit)))
          (negb ovalid)) then
       update_vec_dec newc CAP_TAG_BIT (Bit (('b"0") : mword 1))
     else newc in
   let newc : mword 129 :=
     if ie then
       let newc : bits 129 := update_vec_dec newc CAP_IE_BIT (Bit (('b"0") : mword 1)) in
       let newc : bits 129 :=
         update_subrange_vec_dec newc CAP_BASE_EXP_HI_BIT CAP_BASE_LO_BIT
           (not_vec (integer_subrange exp 2 0)) in
       update_subrange_vec_dec newc CAP_LIMIT_EXP_HI_BIT CAP_LIMIT_LO_BIT
         (not_vec (integer_subrange exp 5 3))
     else
       let newc : bits 129 := update_vec_dec newc CAP_IE_BIT (Bit (('b"1") : mword 1)) in
       let newc : bits 129 :=
         update_subrange_vec_dec newc CAP_BASE_EXP_HI_BIT CAP_BASE_LO_BIT
           (subrange_vec_dec Bbits 2 0) in
       update_subrange_vec_dec newc CAP_LIMIT_EXP_HI_BIT CAP_LIMIT_LO_BIT
         (subrange_vec_dec TBits 2 0) in
   let newc : bits 129 :=
     update_subrange_vec_dec newc CAP_BASE_HI_BIT CAP_BASE_MANTISSA_LO_BIT
       (subrange_vec_dec Bbits (Z.sub CAP_MW 1) 3) in
   let newc : bits 129 :=
     update_subrange_vec_dec newc CAP_LIMIT_HI_BIT CAP_LIMIT_MANTISSA_LO_BIT
       (subrange_vec_dec TBits (Z.sub CAP_MW 3) 3) in
   let from_large : bool := negb (CapBoundsUsesValue (CapGetExponent c)) in
   let to_small : bool := CapBoundsUsesValue exp in
   let newc : mword 129 :=
     if (andb (andb from_large to_small)
          (neq_vec (sign_extend (subrange_vec_dec base (Z.sub CAP_FLAGS_LO_BIT 1) 0) 64) base)) then
       update_vec_dec newc CAP_TAG_BIT (Bit (('b"0") : mword 1))
     else newc in
   let newc : mword 129 :=
     if (andb exact (orb lostBottom lostTop)) then
       update_vec_dec newc CAP_TAG_BIT (Bit (('b"0") : mword 1))
     else newc in
   newc.

Definition CapGetRepresentableMask (len : mword (63 - 0 + 1)) : (mword (63 - 0 + 1)) :=
   let c : bits 129 := CapNull tt in
   let test_base : bits CAP_VALUE_NUM_BITS := sub_vec (Ones CAP_VALUE_NUM_BITS) len in
   let test_length : bits CAP_LENGTH_NUM_BITS := zero_extend len CAP_LENGTH_NUM_BITS in
   let c : bits 129 := update_subrange_vec_dec c CAP_VALUE_HI_BIT CAP_VALUE_LO_BIT test_base in
   let c : bits 129 := CapSetBounds c test_length false in 
   let exp1 : Z := 0 in
   let exp1 : Z := if CapIsInternalExponent c then Z.add (CapGetExponent c) 3 else exp1 in
   let '(exp1) := exp1 in
   autocast (concat_vec (Ones (Z.sub CAP_VALUE_NUM_BITS exp1)) (Zeros exp1)).

Definition CapWithTagSet (c : mword 129) : mword 129 :=
   CapSetTag c (zero_extend (('b"1")  : mword 1) 64).

(* Definition CapIsBaseAboveLimit (c : mword 129) : bool :=
   let base : (bits CAP_BOUND_NUM_BITS) := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let limit : (bits CAP_BOUND_NUM_BITS) := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let '(_tup_0, _tup_1, _) := CapGetBounds c in
   let base : bits CAP_BOUND_NUM_BITS := _tup_0 in
   let limit : bits CAP_BOUND_NUM_BITS := _tup_1 in
   CapUnsignedGreaterThan base limit. *)

Definition CapIsSubSetOf (a : mword 129) (b : mword 129) : bool :=
   let abase : bits CAP_BOUND_NUM_BITS := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let alimit : bits CAP_BOUND_NUM_BITS := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let avalid : bool := false in 
   let bbase : bits CAP_BOUND_NUM_BITS := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let blimit : bits CAP_BOUND_NUM_BITS := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let bvalid : bool := false in 
   let w_0 : (mword (63 - 0 + 1 + 1) * mword (63 - 0 + 1 + 1) * bool) := CapGetBounds a in
   let '(tup_0, tup_1, tup_2) := w_0  : (mword (63 - 0 + 1 + 1) * mword (63 - 0 + 1 + 1) * bool) in
   let abase : bits CAP_BOUND_NUM_BITS := tup_0 in
   let alimit : bits CAP_BOUND_NUM_BITS := tup_1 in
   let avalid : bool := tup_2 in
   let w_1 : (mword (63 - 0 + 1 + 1) * mword (63 - 0 + 1 + 1) * bool) := CapGetBounds b in
   let '(tup_0, tup_1, tup_2) := w_1  : (mword (63 - 0 + 1 + 1) * mword (63 - 0 + 1 + 1) * bool) in
   let bbase : bits CAP_BOUND_NUM_BITS := tup_0 in
   let blimit : bits CAP_BOUND_NUM_BITS := tup_1 in
   let bvalid : bool := tup_2 in
   let boundsSubset : bool :=
     andb (CapUnsignedGreaterThanOrEqual abase bbase) (CapUnsignedLessThanOrEqual alimit blimit) in
   let permsSubset : bool :=
     eq_vec (and_vec (CapGetPermissions a) (not_vec (CapGetPermissions b)))
       (Zeros CAP_PERMS_NUM_BITS) in
   andb (andb (andb boundsSubset permsSubset) avalid) bvalid.

Definition CapUnseal (c : mword 129) : mword 129 := CapSetObjectType c (Zeros 64).

Definition CapGetOffset (c : mword 129) : mword (63 - 0 + 1) :=
   let base : bits CAP_BOUND_NUM_BITS := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let '((_tup_0, _, _)) := CapGetBounds c in
   let base : bits CAP_BOUND_NUM_BITS := _tup_0 in
   let offset : bits 65 := sub_vec (concat_vec (('b"0")  : mword 1) (CapGetValue c)) base in
   slice offset 0 CAP_VALUE_NUM_BITS.

Definition CapGetLength (c : mword 129) : mword (63 - 0 + 1 + 1) :=
   let base : bits CAP_BOUND_NUM_BITS := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let limit : bits CAP_BOUND_NUM_BITS := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let '((_tup_0, _tup_1, _)) := CapGetBounds c in
   let base : bits CAP_BOUND_NUM_BITS := _tup_0 in
   let limit : bits CAP_BOUND_NUM_BITS := _tup_1 in
   sub_vec limit base.

Definition CapIsInBounds (c : mword 129) : bool :=
   let '(base, limit, valid_name) := CapGetBounds c in
   let value65_name : bits 65 := concat_vec (('b"0")  : mword 1) (CapGetValue c) in
   andb
      (andb (CapUnsignedGreaterThanOrEqual value65_name base)
         (CapUnsignedLessThan value65_name limit)) valid_name.

(* Definition CapSetOffset (c : mword 129) (offset : mword (63 - 0 + 1)) : mword 129 :=
   let base : bits CAP_BOUND_NUM_BITS := mword_of_int (Z.add (Z.add (Z.sub 63 0) 1) 1) in 
   let '((_tup_0, _, _)) := CapGetBounds c in
   let base : bits CAP_BOUND_NUM_BITS := _tup_0 in
   let newvalue : bits CAP_VALUE_NUM_BITS :=
     add_vec (subrange_vec_dec base (Z.sub CAP_VALUE_NUM_BITS 1) 0) offset in
   let increment_name : bits CAP_VALUE_NUM_BITS := sub_vec newvalue (CapGetValue c) in
   CapAdd c increment_name. *)

Definition CapIsLocal (c : mword 129) : bool := negb (CapCheckPermissions c CAP_PERM_GLOBAL).

Definition initialize_registers '(tt : unit) : unit := tt.
