with Communications_with_User;          use Communications_with_User;
with File_Scanning;                     use File_Scanning;
with Standard_Natural_Numbers;          use Standard_Natural_Numbers;
with Standard_Integer_Numbers_io;       use Standard_Integer_Numbers_io;
with DoblDobl_Complex_Numbers;          use DoblDobl_Complex_Numbers;
with Standard_Natural_Vectors;
with DoblDobl_Complex_Poly_Systems_io;  use DoblDobl_Complex_Poly_Systems_io;
with DoblDobl_Complex_Solutions_io;     use DoblDobl_Complex_Solutions_io;
with Standard_Parameter_Systems;

package body DoblDobl_Parameter_Systems is

  procedure Sort ( v : in out Standard_Integer_Vectors.Vector ) is
  begin
    Standard_Parameter_Systems.Sort(v);
  end Sort;

  procedure Read_Solution_Parameters
              ( infile : in file_type; outfile : out file_type;
                p : in DoblDobl_Complex_Poly_Systems.Poly_Sys;
                sols : out Solution_List;
                nb_equ,nb_unk,nb_par : out integer32 ) is

    found : boolean;

  begin
    nb_equ := integer32(p'last);
    nb_unk := integer32(DoblDobl_Complex_Polynomials.Number_of_Unknowns(p(1)));
    nb_par := nb_unk - nb_equ;
    Scan_and_Skip(infile,"THE SOLUTIONS",found);
    if found
     then get(infile,sols);
     else Read(sols);
    end if;
    new_line;
    put_line("Reading the name of the output file.");
    Read_Name_and_Create_File(outfile);
   -- put(outfile,natural32(nb_equ),natural32(nb_unk),p);
    put(outfile,p);
    new_line(outfile);
    put_line(outfile,"THE SOLUTIONS : ");
    put(outfile,Length_Of(sols),natural32(Head_Of(sols).n),sols);
  end Read_Solution_Parameters;

  procedure Read_Parameter_Homotopy
              ( outfile : out file_type;
                lp : out DoblDobl_Complex_Poly_Systems.Link_to_Poly_Sys;
                sols : out Solution_List;
                nb_equ,nb_unk,nb_par : out integer32 ) is

    infile : file_type;

  begin
    new_line;
    put_line("Reading the file name for a polynomial system.");
    Read_Name_and_Open_File(infile);
    get(infile,lp);
    Read_Solution_Parameters
      (infile,outfile,lp.all,sols,nb_equ,nb_unk,nb_par);
  end Read_Parameter_Homotopy;

  function Define_Parameters ( nb_equ,nb_unk,nb_par : integer32 )
                             return Standard_Integer_Vectors.Vector is
  begin
    return Standard_Parameter_Systems.Define_Parameters(nb_equ,nb_unk,nb_par);
  end Define_Parameters;

  function Complement ( n : integer32; v : Standard_Integer_Vectors.Vector )
                      return Standard_Integer_Vectors.Vector is
  begin
    return Standard_Parameter_Systems.Complement(n,v);
  end Complement;

  function Substitute
             ( t : DoblDobl_Complex_Polynomials.Term;
               pars : Standard_Integer_Vectors.Vector;
               vals : DoblDobl_Complex_Vectors.Vector )
             return DoblDobl_Complex_Polynomials.Term is

    use DoblDobl_Complex_Polynomials;

    res : Term;
    n : constant integer32 := t.dg'last - pars'last;
    ind_pars : integer32 := pars'first;
    ind_vars : integer32 := t.dg'first-1;

  begin
    res.cf := t.cf;
    res.dg := new Standard_Natural_Vectors.Vector(1..n);
    for i in t.dg'range loop
      if ((ind_pars > pars'last)
          or else (i < pars(ind_pars))) then 
        ind_vars := ind_vars + 1;
        res.dg(ind_vars) := t.dg(i);
      else -- i = pars(ind_pars)
        for j in 1..t.dg(pars(ind_pars)) loop
          res.cf := res.cf*vals(ind_pars);
        end loop;
        ind_pars := ind_pars + 1;
      end if;
    end loop;
    return res;
  end Substitute;

  function Substitute
             ( p : DoblDobl_Complex_Polynomials.Poly;
               pars : Standard_Integer_Vectors.Vector;
               vals : DoblDobl_Complex_Vectors.Vector )
             return DoblDobl_Complex_Polynomials.Poly is

    use DoblDobl_Complex_Polynomials;

    res : Poly := Null_Poly;

    procedure Substitute_Term ( t : in Term; continue : out boolean ) is

      st : constant Term := Substitute(t,pars,vals);

    begin
      Add(res,st);
      continue := true;
    end Substitute_Term;
    procedure Substitute_Terms is new Visiting_Iterator(Substitute_Term);

  begin
    Substitute_Terms(p);
    return res;
  end Substitute;

  function Substitute
             ( p : DoblDobl_Complex_Poly_Systems.Poly_Sys;
               pars : Standard_Integer_Vectors.Vector;
               vals : DoblDobl_Complex_Vectors.Vector )
             return DoblDobl_Complex_Poly_Systems.Poly_Sys is

    res : DoblDobl_Complex_Poly_Systems.Poly_Sys(p'range);

  begin
    for i in p'range loop
      res(i) := Substitute(p(i),pars,vals);
    end loop;
    return res;
  end Substitute;

end DoblDobl_Parameter_Systems; 
