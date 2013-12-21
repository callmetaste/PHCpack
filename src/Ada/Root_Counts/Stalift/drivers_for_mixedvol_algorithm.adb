with Timing_Package;                     use Timing_Package;
with Communications_with_User;           use Communications_with_User;
with Standard_Natural_Numbers_io;        use Standard_Natural_Numbers_io;
with Standard_Floating_Vectors;
with Standard_Complex_Vectors;
with Standard_Integer_VecVecs;
with Standard_Complex_VecVecs;
with Standard_Complex_Laur_Functions;    use Standard_Complex_Laur_Functions;
with Standard_Complex_Laur_SysFun;       use Standard_Complex_Laur_SysFun;
with Standard_Complex_Laur_Jacomats;     use Standard_Complex_Laur_Jacomats;
with Standard_Laur_Poly_Convertors;      use Standard_Laur_Poly_Convertors;
with Standard_Poly_Laur_Convertors;      use Standard_Poly_Laur_Convertors;
with Exponent_Vectors;                   use Exponent_Vectors;
with Standard_Complex_Solutions_io;      use Standard_Complex_Solutions_io;
with Standard_System_and_Solutions_io;
with Supports_of_Polynomial_Systems;
with Floating_Mixed_Subdivisions_io;     use Floating_Mixed_Subdivisions_io;
with Floating_Integer_Convertors;
with Floating_Lifting_Functions;
with Floating_Lifting_Utilities;
with Random_Coefficient_Systems;
with Drivers_for_Poly_Continuation;
with Floating_Polyhedral_Continuation;   use Floating_Polyhedral_Continuation;
with Stable_Polyhedral_Continuation;     use Stable_Polyhedral_Continuation;
with Drivers_for_Static_Lifting;         use Drivers_for_Static_Lifting;
with Cell_Stack;                         use Cell_Stack;
with MixedVol_Algorithm;                 use MixedVol_Algorithm;
with Multitasking_Polyhedral_Trackers;   use Multitasking_Polyhedral_Trackers;

package body Drivers_for_mixedvol_algorithm is

  procedure MixedVol_Algorithm_Info is

    i : array(1..6) of string(1..65);

  begin
    i(1) :="  The MixedVol Algorithm in PHCpack is an Ada translation of the ";
    i(2) :="program MixedVol developed by Tangan Gao, T. Y. Li, Mengnien Wu, ";
    i(3) :="and Li Xing, archived by ACM TOMS as Algorithm 846, see the paper";
    i(4) :="ACM Transactions on Mathematical Software, 31(4):555-560, 2005.  ";
    i(5) :="This algorithm computes mixed volumes much faster than the other ";
    i(6) :="lift-and-prune strategies, but only supports random liftings.    ";
    for k in i'range loop
      put_line(i(k));
    end loop;
  end MixedVol_Algorithm_Info;

  procedure Mixed_Volume_Computation
              ( n : in integer32; 
                s : in Arrays_of_Integer_Vector_Lists.Array_of_Lists;
                stlb : in double_float; r : out integer32;
                mix,perm : out Standard_Integer_Vectors.Link_to_Vector;
                sub : out Mixed_Subdivision; mixvol : out natural32;
                multprec_hermite : in boolean := false ) is

    m,size,nb : integer32;
    cnt,ind : Standard_Integer_Vectors.Vector(1..n);
    sup,mtype,idx : Standard_Integer_Vectors.Link_to_Vector;
    vtx : Standard_Integer_VecVecs.Link_to_VecVec;
    lft : Standard_Floating_Vectors.Link_to_Vector;
    cells : CellStack;

  begin
   -- put_line("inside Drivers_for_mixedvol_algorithm.MVC");
    Extract_Supports(n,s,m,ind,cnt,sup);
    mv(n,m,ind,cnt,sup.all,stlb,
       r,mtype,perm,idx,vtx,lft,size,nb,cells,mixvol,multprec_hermite);
   -- put("The mixed volume is "); put(mixvol,1); put_line(".");
   -- put("There are "); put(nb,1); put_line(" mixed cells.");
   -- put("Permutation of the supports : "); put(perm); new_line;
   -- put_line("Creating a regular mixed-cell configuration ...");
    if r < n
     then Create_Mixed_Cell_Configuration
            (n,r,size,nb,mtype,Vtx,lft,cells,sub);  -- why no perm ?? Dec 1st
           -- (n,r,size,nb,mtype,perm,Vtx,lft,cells,sub);
     else Create_Mixed_Cell_Configuration
            (n,r,size,nb,mtype,perm,Vtx,lft,cells,sub);
    end if;
    mix := new Standard_Integer_Vectors.Vector(1..r);
    for i in 1..r loop
      mix(i) := mtype(i-1);
    end loop;
  end Mixed_Volume_Computation;

  procedure Random_Coefficient_System
               ( nt,n : in integer32;
                 mix : in Standard_Integer_Vectors.Vector;
                 ls : in Arrays_of_Floating_Vector_Lists.Array_of_Lists;
                 sub : in Mixed_Subdivision;
                 q : out Poly_Sys; qsols : out Solution_List;
                 multprec_hermite : in boolean := false ) is

   -- fs : Arrays_of_Floating_Vector_Lists.Array_of_Lists(s'range)
   --    := Floating_Integer_Convertors.Convert(s);
   -- ls : Arrays_of_Floating_Vector_Lists.Array_of_Lists(mix'range)
   --    := Floating_Lifting_Utilities.Occurred_Lifting(n,mix,fs,sub);

    lq : Laur_Sys(1..n);
    hq : Eval_Coeff_Laur_Sys(1..n);
    expvec : Exponent_Vectors_Array(1..n);
    coeffv : Standard_Complex_VecVecs.VecVec(1..n);
    jacmat : Eval_Coeff_Jaco_Mat(q'range,q'first..q'last+1);
    mulfac : Mult_Factors(jacmat'range(1),jacmat'range(2));

  begin
    q := Random_Coefficient_Systems.Create(natural32(n),mix,ls);
   -- put_line("a random coefficient system "); put_line(q);
    lq := Polynomial_to_Laurent_System(q);
    hq := Create(lq);
    expvec := Create(q);
    for i in q'range loop
      declare
        c : constant Standard_Complex_Vectors.Vector := Coeff(lq(i));
      begin
        coeffv(i) := new Standard_Complex_Vectors.Vector(c'range);
        for j in c'range loop
          coeffv(i)(j) := c(j);
        end loop;
      end;
    end loop;
    Create(lq,jacmat,mulfac);
    if nt = 0 then
      Mixed_Solve(lq,ls,hq,coeffv,expvec,jacmat,mulfac,mix,sub,qsols,
                  multprec_hermite);
    else
      Silent_Multitasking_Path_Tracker
        (lq,nt,n,mix'last,mix,ls,sub,hq,coeffv,expvec,jacmat,mulfac,qsols);
    end if;
  end Random_Coefficient_System;

  procedure Random_Coefficient_System
               ( nt,n : in integer32;
                 mix : in Standard_Integer_Vectors.Vector;
                 ls : in Arrays_of_Floating_Vector_Lists.Array_of_Lists;
                 sub : in Mixed_Subdivision;
                 q : out Laur_Sys; qsols : out Solution_List;
                 multprec_hermite : in boolean := false ) is

   -- fs : Arrays_of_Floating_Vector_Lists.Array_of_Lists(s'range)
   --    := Floating_Integer_Convertors.Convert(s);
   -- ls : Arrays_of_Floating_Vector_Lists.Array_of_Lists(mix'range)
   --    := Floating_Lifting_Utilities.Occurred_Lifting(n,mix,fs,sub);
    hq : Eval_Coeff_Laur_Sys(1..n);
    expvec : Exponent_Vectors_Array(1..n);
    coeffv : Standard_Complex_VecVecs.VecVec(1..n);
    jacmat : Eval_Coeff_Jaco_Mat(q'range,q'first..q'last+1);
    mulfac : Mult_Factors(jacmat'range(1),jacmat'range(2));

  begin
    q := Random_Coefficient_Systems.Create(natural32(n),mix,ls);
    hq := Create(q);
    expvec := Create(q);
    for i in q'range loop
      declare
        c : constant Standard_Complex_Vectors.Vector := Coeff(q(i));
      begin
        coeffv(i) := new Standard_Complex_Vectors.Vector(c'range);
        for j in c'range loop
          coeffv(i)(j) := c(j);
        end loop;
      end;
    end loop;
    Create(q,jacmat,mulfac);
    if nt = 0 then
      Mixed_Solve(q,ls,hq,coeffv,expvec,jacmat,mulfac,mix,sub,qsols,
                  multprec_hermite);
    else
      Silent_Multitasking_Path_Tracker
        (q,nt,n,mix'last,mix,ls,sub,hq,coeffv,expvec,jacmat,mulfac,qsols);
    end if;
  end Random_Coefficient_System;

  procedure Random_Coefficient_System
               ( file : in file_type;
                 nt,n : in integer32;
                 mix : in Standard_Integer_Vectors.Vector;
                 ls : in Arrays_of_Floating_Vector_Lists.Array_of_Lists;
                 sub : in Mixed_Subdivision;
                 q : out Poly_Sys; qsols : out Solution_List;
                 multprec_hermite : in boolean := false ) is

   -- fs : Arrays_of_Floating_Vector_Lists.Array_of_Lists(s'range)
   --    := Floating_Integer_Convertors.Convert(s);
   -- ls : Arrays_of_Floating_Vector_Lists.Array_of_Lists(mix'range)
   --    := Floating_Lifting_Utilities.Occurred_Lifting(n,mix,fs,sub);
    lq : Laur_Sys(1..n);
    hq : Eval_Coeff_Laur_Sys(1..n);
    expvec : Exponent_Vectors_Array(1..n);
    coeffv : Standard_Complex_VecVecs.VecVec(1..n);
    jacmat : Eval_Coeff_Jaco_Mat(q'range,q'first..q'last+1);
    mulfac : Mult_Factors(jacmat'range(1),jacmat'range(2));

  begin
    q := Random_Coefficient_Systems.Create(natural32(n),mix,ls);
   -- put_line("a random coefficient system "); put_line(q);
    lq := Polynomial_to_Laurent_System(q);
    hq := Create(lq);
    expvec := Create(q);
    for i in q'range loop
      declare
        c : constant Standard_Complex_Vectors.Vector := Coeff(lq(i));
      begin
        coeffv(i) := new Standard_Complex_Vectors.Vector(c'range);
        for j in c'range loop
          coeffv(i)(j) := c(j);
        end loop;
      end;
    end loop;
    Create(lq,jacmat,mulfac);
    if nt = 0 then
      Mixed_Solve(file,lq,ls,hq,coeffv,expvec,jacmat,mulfac,mix,sub,qsols,
                  multprec_hermite);
    else
      Silent_Multitasking_Path_Tracker
        (lq,nt,n,mix'last,mix,ls,sub,hq,coeffv,expvec,jacmat,mulfac,qsols);
    end if;
  end Random_Coefficient_System;

  procedure Random_Coefficient_System
               ( file : in file_type;
                 nt,n : in integer32;
                 mix : in Standard_Integer_Vectors.Vector;
                 ls : in Arrays_of_Floating_Vector_Lists.Array_of_Lists;
                 sub : in Mixed_Subdivision;
                 q : out Laur_Sys; qsols : out Solution_List;
                 multprec_hermite : in boolean := false ) is

   -- fs : Arrays_of_Floating_Vector_Lists.Array_of_Lists(s'range)
   --    := Floating_Integer_Convertors.Convert(s);
   -- ls : Arrays_of_Floating_Vector_Lists.Array_of_Lists(mix'range)
   --    := Floating_Lifting_Utilities.Occurred_Lifting(n,mix,fs,sub);
    hq : Eval_Coeff_Laur_Sys(1..n);
    expvec : Exponent_Vectors_Array(1..n);
    coeffv : Standard_Complex_VecVecs.VecVec(1..n);
    jacmat : Eval_Coeff_Jaco_Mat(q'range,q'first..q'last+1);
    mulfac : Mult_Factors(jacmat'range(1),jacmat'range(2));

  begin
   -- put_line("inside random_coefficient_system ...");
   -- put_line("The lifted supports : "); 
   -- Floating_Mixed_Subdivisions_io.put(ls);
    q := Random_Coefficient_Systems.Create(natural32(n),mix,ls);
   -- put_line("a random coefficient system : "); put_line(q);
    hq := Create(q);
    expvec := Create(q);
    for i in q'range loop
      declare
        c : constant Standard_Complex_Vectors.Vector := Coeff(q(i));
      begin
        coeffv(i) := new Standard_Complex_Vectors.Vector(c'range);
        for j in c'range loop
          coeffv(i)(j) := c(j);
        end loop;
      end;
    end loop;
    Create(q,jacmat,mulfac);
    if nt = 0 then
      Mixed_Solve(file,q,ls,hq,coeffv,expvec,jacmat,mulfac,mix,sub,qsols,
                  multprec_hermite);
    else
      Silent_Multitasking_Path_Tracker
        (q,nt,n,mix'last,mix,ls,sub,hq,coeffv,expvec,jacmat,mulfac,qsols);
    end if;
  end Random_Coefficient_System;

  procedure Polyhedral_Homotopies
              ( cfile,qfile : in file_type; p : in Poly_Sys ) is 

    q,pq : Poly_Sys(p'range);
    n : constant integer32 := p'last;
    r : integer32;
    mixvol : natural32;
    mix,perm : Standard_Integer_Vectors.Link_to_Vector;
    sub : Mixed_Subdivision;
    s : constant Arrays_of_Integer_Vector_Lists.Array_of_Lists(p'range)
      := Supports_of_Polynomial_Systems.Create(p);
    fs : Arrays_of_Floating_Vector_Lists.Array_of_Lists(s'range);
    ps : Arrays_of_Integer_Vector_Lists.Array_of_Lists(p'range);
    qsols : Solution_List;

  begin
    Mixed_Volume_Computation(n,s,0.0,r,mix,perm,sub,mixvol);
    new_line;
    put_line("See the output file for a regular mixed-cell configuration ...");
    new_line;
    put(cfile,natural32(n),mix.all,sub);
    if r = n then
      fs := Floating_Integer_Convertors.Convert(s);
    else
      for i in s'range loop
        ps(i) := s(perm(i-1)+1);
      end loop;
      fs := Floating_Integer_Convertors.Convert(ps);
    end if;
    declare
      ls : Arrays_of_Floating_Vector_Lists.Array_of_Lists(mix'range);
    begin
      ls := Floating_Lifting_Utilities.Occurred_Lifting(n,mix.all,fs,sub);
     -- ls := Floating_Lifting_Utilities.Lifted_Supports(mix'last,sub);
      Random_Coefficient_System(0,n,mix.all,ls,sub,q,qsols);
    end;
    new_line;
    put_line("See the output file for a random coefficient start system ...");
    new_line;
    if r = n then
      Standard_System_and_Solutions_io.put_line(qfile,q,qsols);
    else
      for i in q'range loop
        pq(i) := q(perm(i-1)+1);
      end loop;
      Standard_System_and_Solutions_io.put_line(qfile,pq,qsols);
    end if;
  end Polyhedral_Homotopies;

  procedure Polyhedral_Homotopies
              ( cfile,qfile : in file_type; p : in Laur_Sys ) is 

    q,pq : Laur_Sys(p'range);
    n : constant integer32 := p'last;
    r : integer32;
    mixvol : natural32;
    mix,perm : Standard_Integer_Vectors.Link_to_Vector;
    sub : Mixed_Subdivision;
    s : constant Arrays_of_Integer_Vector_Lists.Array_of_Lists(p'range)
      := Supports_of_Polynomial_Systems.Create(p);
    ps : Arrays_of_Integer_Vector_Lists.Array_of_Lists(p'range);
    fs : Arrays_of_Floating_Vector_Lists.Array_of_Lists(s'range);
    qsols : Solution_List;

  begin
    Mixed_Volume_Computation(n,s,0.0,r,mix,perm,sub,mixvol);
    new_line;
    put_line("See the output file for a regular mixed-cell configuration ...");
    new_line;
    put(cfile,natural32(n),mix.all,sub);
    if r = n then
      fs := Floating_Integer_Convertors.Convert(s);
    else
      for i in s'range loop
        ps(i) := s(perm(i-1)+1);
      end loop;
      fs := Floating_Integer_Convertors.Convert(ps);
    end if;
    declare
      ls : Arrays_of_Floating_Vector_Lists.Array_of_Lists(mix'range);
    begin
      ls := Floating_Lifting_Utilities.Occurred_Lifting(n,mix.all,fs,sub);
     -- ls := Floating_Lifting_Utilities.Lifted_Supports(mix'last,sub);
      Random_Coefficient_System(0,n,mix.all,ls,sub,q,qsols);
    end;
    new_line;
    put_line("See the output file for a random coefficient start system ...");
    new_line;
    if r = n then
      Standard_System_and_Solutions_io.put_line(qfile,q,qsols);
    else
      for i in q'range loop
        pq(i) := q(perm(i-1)+1);
      end loop;
      Standard_System_and_Solutions_io.put_line(qfile,pq,qsols);
    end if;
  end Polyhedral_Homotopies;

  procedure Polyhedral_Continuation
              ( file : in file_type; nt : in integer32;
                stable,contrep : in boolean;
                n,r : in integer32; stlb : in double_float;
                mix,perm : in Standard_Integer_Vectors.Link_to_Vector;
                p : in Poly_Sys; 
                s : in Arrays_of_Integer_Vector_Lists.Array_of_Lists;
                sub,mcc,stbmcc : in Mixed_Subdivision;
               -- mcc,stbmcc : in Mixed_Subdivision;
                q : out Poly_Sys; qsols,qsols0 : out Solution_List;
                multprec_hermite : in boolean := false ) is

    timer : Timing_Widget;
    ps : Arrays_of_Integer_Vector_Lists.Array_of_Lists(p'range);
    fs : Arrays_of_Floating_Vector_Lists.Array_of_Lists(s'range);
    ls : Arrays_of_Floating_Vector_Lists.Array_of_Lists(mix'range);
    lq : Laur_Sys(q'range);

  begin
    tstart(timer);
    if r = n then
      fs := Floating_Integer_Convertors.Convert(s);
    else
      for i in s'range loop
        ps(i) := s(perm(i-1)+1);
      end loop;
      fs := Floating_Integer_Convertors.Convert(ps);
    end if;
    if stable then
      ls := Floating_Lifting_Utilities.Occurred_Lifting(n,mix.all,fs,sub);
    else
      ls := Floating_Lifting_Utilities.Occurred_Lifting(n,mix.all,fs,mcc);
    end if;
   -- if stable
   --  then ls := Floating_Lifting_Utilities.Lifted_Supports(mix'last,sub);
   --  else ls := Floating_Lifting_Utilities.Lifted_Supports(mix'last,mcc);
   -- end if;
    if contrep then
       Random_Coefficient_System
         (file,nt,n,mix.all,ls,mcc,q,qsols,multprec_hermite);
    else
       Random_Coefficient_System(nt,n,mix.all,ls,mcc,q,qsols,multprec_hermite);
    end if;
    if stable then
      lq := Polynomial_to_Laurent_System(q);
      if contrep then
        Reporting_Polyhedral_Continuation(file,lq,stlb,mix,ls,stbmcc,qsols0);
      else
        Silent_Polyhedral_Continuation(lq,stlb,mix,ls,stbmcc,qsols0);
      end if;
    end if;
    tstop(timer);
    new_line(file);
    print_times(file,timer,"Solving a random coefficient start system");
  end Polyhedral_Continuation;

  procedure Polyhedral_Continuation
              ( file : in file_type; nt : in integer32;
                stable,contrep : in boolean;
                n,r : in integer32; stlb : in double_float;
                mix,perm : in Standard_Integer_Vectors.Link_to_Vector;
                p : in Laur_Sys; 
                s : in Arrays_of_Integer_Vector_Lists.Array_of_Lists;
                sub,mcc,stbmcc : in Mixed_Subdivision;
               -- mcc,stbmcc : in Mixed_Subdivision;
                q : out Laur_Sys; qsols,qsols0 : out Solution_List;
                multprec_hermite : in boolean := false ) is

    timer : Timing_Widget;
    ps : Arrays_of_Integer_Vector_Lists.Array_of_Lists(p'range);
    fs : Arrays_of_Floating_Vector_Lists.Array_of_Lists(s'range);
    ls : Arrays_of_Floating_Vector_Lists.Array_of_Lists(mix'range);

  begin
   -- put("perm'first = "); put(perm'first,1);
   -- put("  perm'last = "); put(perm'last,1);
   -- put("  s'first = "); put(s'first,1);
   -- put("  s'last = "); put(s'last,1); new_line;
   -- put("fs'first = "); put(fs'first,1);
   -- put("  fs'last = "); put(fs'last,1);
   -- put("  ls'first = "); put(ls'first,1);
   -- put("  ls'last = "); put(ls'last,1); new_line;
   -- put("the permutation : "); put(perm.all);
   -- put("  type of mixture : "); put(mix.all); new_line;
   -- put_line("The original supports : ");
   -- Arrays_of_Integer_Vector_Lists_io.put(s);
    tstart(timer);
    if r = n then
      fs := Floating_Integer_Convertors.Convert(s);
    else
      for i in s'range loop
        ps(i) := s(perm(i-1)+1);
      end loop;
      fs := Floating_Integer_Convertors.Convert(ps);
    end if;
   -- put_line("The permuted supports : ");
   -- Floating_Mixed_Subdivisions_io.put(fs);
    if stable then
      ls := Floating_Lifting_Utilities.Occurred_Lifting(n,mix.all,fs,sub);
    else
      ls := Floating_Lifting_Utilities.Occurred_Lifting(n,mix.all,fs,mcc);
    end if;
   -- if stable
   --  then ls := Floating_Lifting_Utilities.Lifted_Supports(mix'last,sub);
   --  else ls := Floating_Lifting_Utilities.Lifted_Supports(mix'last,mcc);
   -- end if;
   -- put_line("The supports with lifting : ");
   -- Floating_Mixed_Subdivisions_io.put(ls);
   -- put_line("calling random_coefficient_system ...");
    if contrep then
       Random_Coefficient_System
         (file,nt,n,mix.all,ls,mcc,q,qsols,multprec_hermite);
    else
       Random_Coefficient_System(nt,n,mix.all,ls,mcc,q,qsols,multprec_hermite);
    end if;
    if stable then
      if contrep then
        Reporting_Polyhedral_Continuation(file,q,stlb,mix,ls,stbmcc,qsols0);
      else
        Silent_Polyhedral_Continuation(q,stlb,mix,ls,stbmcc,qsols0);
      end if;
    end if;
    tstop(timer);
    new_line(file);
    print_times(file,timer,"Solving a random coefficient start system");
  end Polyhedral_Continuation;

  procedure Polyhedral_Homotopies
              ( file,cfile,qfile : in file_type; nt : in integer32;
                stable,misufile,ranstart,contrep : in boolean;
                p : in Poly_Sys; mv,smv,tmv : out natural32;
                q : out Poly_Sys; qsols,qsols0 : out Solution_List;
                multprec_hermite : in boolean := false ) is

    timer : Timing_Widget;
   -- pq : Poly_Sys(p'range);
    n : constant integer32 := p'last;
    r : integer32;
    mix,perm : Standard_Integer_Vectors.Link_to_Vector;
    sub,mcc,stbmcc : Mixed_Subdivision;
    s : constant Arrays_of_Integer_Vector_Lists.Array_of_Lists(p'range)
      := Supports_of_Polynomial_Systems.Create(p);
    stlb : double_float;
    orgcnt,stbcnt : natural32;

  begin
    if stable
     then stlb := Floating_Lifting_Functions.Lifting_Bound(p);
     else stlb := 0.0;
    end if;
    tstart(timer);
    Mixed_Volume_Computation(n,s,stlb,r,mix,perm,sub,mv,multprec_hermite);
    tstop(timer);
    new_line(file);
    print_times(file,timer,"Running the MixedVol Algorithm");
    Floating_Volume_Computation
      (file,n,stlb,mix.all,sub,mv,smv,tmv,multprec_hermite);
    if misufile
     then put(cfile,natural32(n),mix.all,sub);
    end if;
    if ranstart then
      if stable then
        Split_Original_Cells(sub,stlb,mcc,stbmcc,orgcnt,stbcnt);
        new_line(file);
        put(file," Number of cells without artificial origin : ");
        put(file,orgcnt,1); new_line(file);
        put(file,"#extra stable cells with artificial origin : ");
        put(file,stbcnt,1); new_line(file);
      else
        mcc := sub;
      end if;
      Polyhedral_Continuation
         (file,nt,stable,contrep,n,r,stlb,mix,perm,p,s,
          sub,mcc,stbmcc,q,qsols,qsols0);
        --(file,stable,contrep,n,r,stlb,mix,perm,mcc,stbmcc,q,qsols,qsols0,
        -- multprec_hermite);
     -- if r = n then
        Standard_System_and_Solutions_io.put_line(qfile,q,qsols);
     -- else
     --   for i in q'range loop
     --     pq(perm(i-1)+1) := q(i);
     --   end loop;
     --   Standard_System_and_Solutions_io.put_line(qfile,pq,qsols);
       -- Standard_System_and_Solutions_io.put_line(qfile,q,qsols);
     --   for i in q'range loop
     --     q(i) := pq(i);
     --   end loop;
     -- end if;
    end if;
  end Polyhedral_Homotopies;

  procedure Polyhedral_Homotopies
              ( file,cfile,qfile : in file_type; nt : in integer32;
                stable,misufile,ranstart,contrep : in boolean;
                p : in Laur_Sys; mv,smv,tmv : out natural32;
                q : out Laur_Sys; qsols,qsols0 : out Solution_List;
                multprec_hermite : in boolean := false ) is

    timer : Timing_Widget;
   -- pq : Laur_Sys(p'range);
    n : constant integer32 := p'last;
    r : integer32;
    mix,perm : Standard_Integer_Vectors.Link_to_Vector;
    sub,mcc,stbmcc : Mixed_Subdivision;
    s : constant Arrays_of_Integer_Vector_Lists.Array_of_Lists(p'range)
      := Supports_of_Polynomial_Systems.Create(p);
    stlb : double_float;
    orgcnt,stbcnt : natural32;

  begin
    if stable
     then stlb := Floating_Lifting_Functions.Lifting_Bound(p);
     else stlb := 0.0;
    end if;
    tstart(timer);
    Mixed_Volume_Computation(n,s,stlb,r,mix,perm,sub,mv,multprec_hermite);
    tstop(timer);
    new_line(file);
    print_times(file,timer,"Running the MixedVol Algorithm");
    Floating_Volume_Computation
      (file,n,stlb,mix.all,sub,mv,smv,tmv,multprec_hermite);
    if misufile
     then put(cfile,natural32(n),mix.all,sub);
    end if;
    if ranstart then
      if stable then
        Split_Original_Cells(sub,stlb,mcc,stbmcc,orgcnt,stbcnt);
        new_line(file);
        put(file," Number of cells without artificial origin : ");
        put(file,orgcnt,1); new_line(file);
        put(file,"#extra stable cells with artificial origin : ");
        put(file,stbcnt,1); new_line(file);
      else
        mcc := sub;
      end if;
      Polyhedral_Continuation
        (file,nt,stable,contrep,n,r,stlb,mix,perm,p,s,
         sub,mcc,stbmcc,q,qsols,qsols0);
       -- (file,stable,contrep,n,r,stlb,mix,perm,mcc,stbmcc,q,qsols,qsols0,
       --  multprec_hermite);
     -- if r = n then
        Standard_System_and_Solutions_io.put_line(qfile,q,qsols);
     -- else
     --   for i in q'range loop
     --     pq(perm(i-1)+1) := q(i); 
     --   end loop;
     --   Standard_System_and_Solutions_io.put_line(qfile,pq,qsols);
     --  -- Standard_System_and_Solutions_io.put_line(qfile,q,qsols);
     --   for i in q'range loop
     --     q(i) := pq(i);
     --   end loop;
     -- end if;
      if not Is_Null(qsols0) then
        new_line(qfile);
        put_line(qfile,"THE SOLUTIONS WITH ZERO COMPONENTS : ");
        put(qfile,Length_Of(qsols0),natural32(Head_Of(qsols0).n),qsols0);
      end if;
    end if;
  end Polyhedral_Homotopies;

  procedure Driver_for_MixedVol_Algorithm
              ( file : in file_type; nt : in integer32;
                p : in Poly_Sys; byebye : in boolean;
                q : out Poly_Sys; qsols,qsols0 : out Solution_List;
                mv,smv,tmv : out natural32;
                multprec_hermite : in boolean := false ) is

    ans : character;
    cellfile,startfile : file_type;
    stable,misufile,ranstart,contrep : boolean;
    oc : natural32;

  begin
    new_line;
    put("Do you want stable mixed volumes ? (y/n) ");
    Ask_Yes_or_No(ans);
    stable := (ans = 'y');
    new_line;
    put("Do you wish the mixed-cell configuration on separate file ? (y/n) ");
    Ask_Yes_or_No(ans);
    misufile := (ans = 'y');
    if misufile then
      new_line;
      put_line("Reading the name of the file to write the cells ...");
      Read_Name_and_Create_File(cellfile);
    end if;
    new_line;
    put("Do you want a random coefficient start system ? (y/n) ");
    Ask_Yes_or_No(ans);
    ranstart := (ans = 'y');
    if ranstart then
      new_line;
      put_line("Reading the name of the file to write the start system ...");
      Read_Name_and_Create_File(startfile);
      new_line;
      Drivers_for_Poly_Continuation.Driver_for_Continuation_Parameters(file);
      new_line;
      Drivers_for_Poly_Continuation.Driver_for_Process_io(file,oc);
      contrep := (oc /= 0);
    end if;
    new_line;
    if byebye 
     then put_line("See the output file(s) for results ..."); new_line;
    end if;
    Polyhedral_Homotopies
      (file,cellfile,startfile,nt,stable,misufile,ranstart,contrep,
       p,mv,smv,tmv,q,qsols,qsols0,multprec_hermite);
    if ranstart then
      new_line(file);
      put_line(file,"THE RANDOM COEFFICIENT START SYSTEM :");
      Standard_System_and_Solutions_io.put_line(file,q,qsols);
    end if;
  end Driver_for_MixedVol_Algorithm;

  procedure Driver_for_MixedVol_Algorithm
              ( file : in file_type; nt : in integer32;
                p : in Laur_Sys; byebye : in boolean;
                q : out Laur_Sys; qsols,qsols0 : out Solution_List;
                mv,smv,tmv : out natural32;
                multprec_hermite : in boolean := false ) is

    ans : character;
    cellfile,startfile : file_type;
    stable,misufile,ranstart,contrep : boolean;
    oc : natural32;

  begin
    if Is_Genuine_Laurent(p) then
      stable := false;
    else
      new_line;
      put("Do you want stable mixed volumes ? (y/n) ");
      Ask_Yes_or_No(ans);
      stable := (ans = 'y');
    end if;
    new_line;
    put("Do you wish the mixed-cell configuration on separate file ? (y/n) ");
    Ask_Yes_or_No(ans);
    misufile := (ans = 'y');
    if misufile then
      new_line;
      put_line("Reading the name of the file to write the cells ...");
      Read_Name_and_Create_File(cellfile);
    end if;
    new_line;
    put("Do you want a random coefficient start system ? (y/n) ");
    Ask_Yes_or_No(ans);
    ranstart := (ans = 'y');
    if ranstart then
      new_line;
      put_line("Reading the name of the file to write the start system ...");
      Read_Name_and_Create_File(startfile);
      new_line;
      Drivers_for_Poly_Continuation.Driver_for_Continuation_Parameters(file);
      new_line;
      Drivers_for_Poly_Continuation.Driver_for_Process_io(file,oc);
      contrep := (oc /= 0);
    end if;
    new_line;
    if byebye 
     then put_line("See the output file(s) for results ..."); new_line;
    end if;
   -- put_line("calling polyhedral homotopies ...");
    Polyhedral_Homotopies
      (file,cellfile,startfile,nt,stable,misufile,ranstart,contrep,
       p,mv,smv,tmv,q,qsols,qsols0,multprec_hermite);
    if ranstart then
      new_line(file);
      put_line(file,"THE RANDOM COEFFICIENT START SYSTEM :");
      Standard_System_and_Solutions_io.put_line(file,q,qsols);
    end if;
  end Driver_for_MixedVol_Algorithm;

end Drivers_for_MixedVol_Algorithm;
