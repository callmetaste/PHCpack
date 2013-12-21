with Standard_Natural_Numbers;           use Standard_Natural_Numbers;
with Standard_Integer_Numbers;           use Standard_Integer_Numbers;
with Standard_Floating_Numbers;          use Standard_Floating_Numbers;
with Standard_Complex_Numbers;           use Standard_Complex_Numbers;
with Standard_Integer_Vectors;
with Standard_Complex_Norms_Equals;      use Standard_Complex_Norms_Equals;
with Standard_Complex_Linear_Solvers;    use Standard_Complex_Linear_Solvers; 
with Standard_Complex_Polynomials;       use Standard_Complex_Polynomials;

package body Standard_Linear_Poly_Solvers is

  function Is_Linear ( p : Poly_Sys ) return boolean is
  begin
    for i in p'range loop
      if Degree(p(i)) > 1
       then return false;
      end if;
    end loop;
    return true;
  end Is_Linear;

  procedure Coefficients ( p : in Poly; k : in integer32;
                           A : out Matrix; b : out Vector ) is

  -- DESCRIPTION :
  --   Stores the coefficient of the k-th linear polynomial p
  --   in the k-th row of A and k-th place in b.

    procedure Store_Term ( t : in Term; continue : out boolean ) is

      done : boolean := false;

    begin
      for i in t.dg'range loop
        if t.dg(i) = 1
         then A(k,i) := t.cf; done := true;
        end if;
        exit when done;
      end loop;
      if not done
       then b(k) := -t.cf;
      end if;
      continue := true;
    end Store_Term;
    procedure Store_Terms is new Visiting_Iterator(Store_Term);

  begin
    Store_Terms(p);
  end Coefficients;

  procedure Coefficients ( p : in Poly_Sys;
                           A : out Matrix; b : out Vector ) is

  begin
    for i in p'range loop
      for j in A'range(2) loop
        A(i,j) := Create(0.0);
      end loop;
      b(i) := Create(0.0);
      Coefficients(p(i),i,A,b);
    end loop;
  end Coefficients;

  function Square_Solve ( A : Matrix; b : Vector ) return Solution is

    n : constant integer32 := b'last;
    s : Solution(n);
    wrk : Matrix(A'range(1),A'range(2)) := A;
    ipvt : Standard_Integer_Vectors.Vector(b'range);
    r : Vector(b'range);

  begin
    lufco(wrk,n,ipvt,s.rco);
    if s.rco = 0.0 then
      s.t := Create(0.0); s.m := 0;
    else
      s.t := Create(1.0); s.m := 1;
      s.v := b;
      lusolve(wrk,n,ipvt,s.v);
      r := b - A*s.v;
      s.res := Max_Norm(r);
      s.err := 2.0**(-52);
    end if;
    return s;
  end Square_Solve;

  procedure Solve ( p : in Poly_Sys; s : out Solution; 
                    fail : out boolean ) is

    n : constant integer32 := integer32(Number_of_Unknowns(p(p'first)));

  begin
    if p'last /= n then
      fail := true;
    else
      fail := not Is_Linear(p);
      if not fail then
        declare
          A : Matrix(p'range,1..n);
          b : Vector(p'range);
        begin
          Coefficients(p,A,b);
          s := Square_Solve(A,b);
        end;
      end if;
    end if;
  end Solve;

end Standard_Linear_Poly_Solvers;
