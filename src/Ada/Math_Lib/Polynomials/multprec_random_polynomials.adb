with Standard_Integer_Numbers;          use Standard_Integer_Numbers;
with Standard_Floating_Numbers;         use Standard_Floating_Numbers;
with Standard_Complex_Numbers;
with Multprec_Floating_Numbers;         use Multprec_Floating_Numbers;
with Standard_Random_Numbers;
with Standard_Natural_Vectors;          use Standard_Natural_Vectors;

package body Multprec_Random_Polynomials is

  function Random_Coefficient ( c : natural32 ) return Complex_Number is
 
    res : Complex_Number;
    stre_ranflt : double_float;
    stcp : Standard_Complex_Numbers.Complex_Number;
    mp_ranflt,mpre,mpim : Floating_Number;

  begin
    case c is
      when 1 => res := Create(integer(1));
      when 2 => stre_ranflt := Standard_Random_Numbers.Random;
                mp_ranflt := Create(stre_ranflt);
                res := Create(mp_ranflt);
                Clear(mp_ranflt);
      when others =>
        stcp := Standard_Random_Numbers.Random1;
        mpre := Create(Standard_Complex_Numbers.REAL_PART(stcp));
        mpim := Create(Standard_Complex_Numbers.IMAG_PART(stcp));
        res := Create(mpre,mpim);
        Clear(mpre); Clear(mpim);
    end case;
    return res;
  end Random_Coefficient;

  function Random_Monomial ( n,d : natural32 ) return Term is

    res : Term;
    deg,pos : integer32;

  begin
    res.cf := Create(integer(1));
    res.dg := new Vector'(1..integer32(n) => 0);
    for i in 1..d loop
      deg := Standard_Random_Numbers.Random(0,1);
      pos := Standard_Random_Numbers.Random(1,integer32(n));
      res.dg(pos) := res.dg(pos) + natural32(deg);
    end loop;
    return res;
  end Random_Monomial;

  function Random_Term ( n,d,c : natural32 ) return Term is

    res : Term := Random_Monomial(n,d);

  begin
    res.cf := Random_Coefficient(c);
    return res;
  end Random_Term;

  function Random_Dense_Poly ( n,d,c : natural32 ) return Poly is

    res : Poly := Null_Poly;
    t : Term;

    procedure Generate_Monomials
                ( accu : in out Term; k,sum : in natural32 ) is

    -- DESCRIPTION :
    --   Accumulating procedure to generate all monomials up to degree d.

    -- ON ENTRY :
    --   accu     accumulator contains the current exponent vector;
    --   k        current component;
    --   sum      sum of current entries in the accumulator.

    -- ON RETURN :
    --   accu     accumulator determined up to k component, k included.

    begin
      if k > n then
        accu.cf := Random_Coefficient(c);
        Add(res,accu);
      else
        for i in 0..d loop
          if sum + i <= d then
            accu.dg(integer32(k)) := i;
            Generate_Monomials(accu,k+1,sum+i);
            accu.dg(integer32(k)) := 0;
          end if;
        end loop;
      end if;
    end Generate_Monomials;

  begin
    t.dg := new Vector'(1..integer32(n) => 0);
    Generate_Monomials(t,1,0);
    return res;
  end Random_Dense_Poly;

  function Random_Sparse_Poly ( n,d,m,c : natural32 ) return Poly is

    res : Poly := Null_Poly;

  begin
    for i in 1..m loop
      declare
        rt : Term := Random_Term(n,d,c);
      begin
        Add(res,rt);
        Clear(rt);
      end;
    end loop;
    return res;
  end Random_Sparse_Poly;

end Multprec_Random_Polynomials;
