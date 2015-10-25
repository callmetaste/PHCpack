with text_io;                            use text_io;
with Communications_with_User;           use Communications_with_User;
with String_Splitters;                   use String_Splitters;
with Standard_Natural_Numbers_io;        use Standard_Natural_Numbers_io;
with Standard_Integer_Numbers;           use Standard_Integer_Numbers;
with Standard_Floating_Numbers;          use Standard_Floating_Numbers;
with Standard_Complex_Numbers;           use Standard_Complex_Numbers;
with Standard_Complex_Polynomials;       use Standard_Complex_Polynomials;
with Standard_Complex_to_Real_Poly;
with Standard_Complex_Poly_Systems;    --  use Standard_Complex_Poly_Systems;
with Standard_Complex_Poly_Systems_io;   use Standard_Complex_Poly_Systems_io;
with Standard_Complex_Poly_SysFun;       use Standard_Complex_Poly_SysFun;
with Standard_Complex_Laurentials;       use Standard_Complex_Laurentials;
with Standard_Complex_Laur_Systems;
with Standard_Complex_Laur_Systems_io;   use Standard_Complex_Laur_Systems_io;
with Standard_Laur_Poly_Convertors;
with Standard_System_Readers;
with String_System_Readers;
with Symbol_Table;
with Standard_Complex_Laur_Strings;
with Standard_Homotopy;
with Standard_Complex_Solutions;         use Standard_Complex_Solutions;
with Standard_Complex_Solutions_io;      use Standard_Complex_Solutions_io;
with Multprec_Complex_Solutions;
with Projective_Transformations;         use Projective_Transformations;
with Standard_Root_Refiners;             use Standard_Root_Refiners;
with Drivers_for_Poly_Continuation;      use Drivers_for_Poly_Continuation;
with Standard_Parameter_Systems;         use Standard_Parameter_Systems;
with Parameter_Homotopy_Continuation;    use Parameter_Homotopy_Continuation;
with Multitasking_Continuation;
with Write_Seed_Number;
with Greeting_Banners;
--with Bye_Bye_Message;

procedure mainpoco ( nt : in natural32; infilename,outfilename : in string ) is

  procedure Refine_Solutions
              ( outft : in file_type;
                p : in Standard_Complex_Poly_Systems.Poly_Sys;
                target : in Complex_Number;
                sols,refsols : in out Solution_List;
                solsfile : in boolean ) is

    epsxa,epsfa,tolsing : constant double_float := 10.0**(-8);
    nb : natural32 := 0;
    deflate : boolean := false;

    use Standard_Complex_Poly_Systems;

  begin
    if Head_Of(sols).n > p'last
     then Affine_Transformation(sols);
    end if;
    if target = Create(1.0) then
      if solsfile
       then Reporting_Root_Refiner
              (outft,p,sols,refsols,epsxa,epsfa,tolsing,nb,5,deflate,false);
       else Reporting_Root_Refiner
              (outft,p,sols,epsxa,epsfa,tolsing,nb,5,deflate,false);
      end if;
    else
      declare
        pt : Poly_Sys(p'range);
      begin
        pt := Standard_Homotopy.Eval(target);
        if solsfile 
         then Reporting_Root_Refiner
                (outft,pt,sols,refsols,epsxa,epsfa,tolsing,nb,5,deflate,false);
         else Reporting_Root_Refiner
                (outft,pt,sols,epsxa,epsfa,tolsing,nb,5,deflate,false);
        end if;
        Clear(pt);
      end;
    end if;
  end Refine_Solutions;

  procedure Secant_Homotopy
              ( p : in Standard_Complex_Poly_Systems.Poly_Sys;
                ls : in Link_to_Array_of_Strings ) is

  -- DESCRIPTION :
  --   Creates the output file and reads start system and start solutions
  --   for an artificial parameter homotopy for polynomial systems.

    solsft,outft : file_type;
    sols,refsols : Solution_List;
    mpsols : Multprec_Complex_Solutions.Solution_List;
    solsfile : boolean;
    len : natural32;
    ans : character;
    target : Complex_Number;

  begin
    Create_Output_File(outft,outfilename);
    put(outft,natural32(p'last),p); new_line(outft);
    new_line;
    put("Do you want the solutions on separate file ? (y/n) ");
    Ask_Yes_or_No(ans);
    if ans = 'y' then
      put_line("Reading the name of the file to write the solutions on.");
      Read_Name_and_Create_File(solsft);
      solsfile := true;
    else
      solsfile := false;
    end if;
    Driver_for_Polynomial_Continuation(outft,p,ls,sols,mpsols,target);
    if Length_Of(sols) > 0
     then Refine_Solutions(outft,p,target,sols,refsols,solsfile);
    end if;
    new_line(outft);
    Write_Seed_Number(outft);
    put_line(outft,Greeting_Banners.Version);
   -- put(outft,Bye_Bye_Message);
    Close(outft);
    if solsfile then
      len := Length_Of(refsols);
      if len > 0
       then put(solsft,len,natural32(Head_Of(refsols).n),refsols);
      end if;
      Close(solsft);
    end if;
  end Secant_Homotopy;

  procedure Secant_Homotopy
              ( p : in Standard_Complex_Laur_Systems.Laur_Sys ) is

  -- DESCRIPTION :
  --   Creates the output file and reads start system and start solutions
  --   for an artificial parameter homotopy for Laurent systems.

    solsft,outft : file_type;
    sols,refsols : Solution_List;
   -- mpsols : Multprec_Complex_Solutions.Solution_List;
    solsfile : boolean;
    len : natural32;
    ans : character;
    target : Complex_Number;

  begin
    Create_Output_File(outft,outfilename);
    put(outft,natural32(p'last),p); new_line(outft);
    new_line;
    put("Do you want the solutions on separate file ? (y/n) ");
    Ask_Yes_or_No(ans);
    if ans = 'y' then
      put_line("Reading the name of the file to write the solutions on.");
      Read_Name_and_Create_File(solsft);
      solsfile := true;
    else
      solsfile := false;
    end if;
    Driver_for_Laurent_Continuation(outft,p,sols,target);
   -- Driver_for_Laurent_Continuation(outft,p,sols,mpsols,target);
   -- if Length_Of(sols) > 0
   --  then Refine_Solutions(outft,p,target,sols,refsols,solsfile);
   -- end if;
    Write_Seed_Number(outft);
    put_line(outft,Greeting_Banners.Version);
   -- put(outft,Bye_Bye_Message);
    Close(outft);
    if solsfile then
      len := Length_Of(refsols);
      if len > 0
       then put(solsft,len,natural32(Head_Of(refsols).n),refsols);
      end if;
      Close(solsft);
    end if;
  end Secant_Homotopy;

  procedure Parameter_Homotopy
              ( infile : in file_type;
                p : in Standard_Complex_Poly_Systems.Poly_Sys ) is

  -- DESCRIPTION :
  --   Dispatches to the coefficient parameter polynomial continuation.

    outfile : file_type;
    sols : Solution_List;
    nb_equ,nb_unk,nb_par : integer32;

  begin
    Read_Solution_Parameters(infile,outfile,p,sols,nb_equ,nb_unk,nb_par);
    Coefficient_Parameter_Homotopy_Continuation
      (outfile,p,sols,nb_equ,nb_unk,nb_par);
  end Parameter_Homotopy;

  procedure Sweep_Homotopy
              ( infile : in file_type;
                p : in Standard_Complex_Poly_Systems.Poly_Sys ) is

  -- DESCRIPTION :
  --   Dispatches to the sweep homotopy.

    outfile : file_type;
    sols : Solution_List;
    nb_equ,nb_unk,nb_par : integer32;
    isreal : boolean := Standard_Complex_to_Real_Poly.Is_Real(p);

  begin
    Read_Solution_Parameters(infile,outfile,p,sols,nb_equ,nb_unk,nb_par);
    Sweep(outfile,isreal,p,sols,nb_equ,nb_unk,nb_par);
  end Sweep_Homotopy;

  procedure Multitasking_Secant_Homotopy
               ( p : in Standard_Complex_Poly_Systems.Poly_Sys;
                 ls : in Link_to_Array_of_Strings;
                 nt : in natural32 ) is

    outft : file_type;

  begin
    Create_Output_File(outft,outfilename);
    Multitasking_Continuation.Driver_to_Path_Tracker(outft,p,ls,integer32(nt));
  end Multitasking_Secant_Homotopy;

  procedure Multitasking_Secant_Homotopy
               ( p : in Standard_Complex_Laur_Systems.Laur_Sys;
                 nt : in natural32 ) is

    outft : file_type;

  begin
    Create_Output_File(outft,outfilename);
   -- Driver_to_Path_Tracker(outft,p,nt);
  end Multitasking_Secant_Homotopy;

  procedure Polynomial_Tracker
              ( inft : in out file_type;
                lp : in Standard_Complex_Poly_Systems.Link_to_Poly_Sys;
                ls : in Link_to_Array_of_Strings ) is

  -- DESCRIPTION :
  --   Main driver to call the path trackers
  --   on a regular polynomial system.

    nva,neq : natural32;
    ans : character;

  begin
    neq := natural32(lp'last);
    nva := Number_of_Unknowns(lp(lp'first));
    if nt = 0 then
      if nva = neq then
        close(inft);
        Secant_Homotopy(lp.all,ls);
      else
        new_line;
        put("Found "); put(neq,1);
        put(" equations in "); put(nva,1); put_line(" unknowns...");
        if nva < neq then
          put_line("Refuse to do homotopy on overdetermined system.");
        else
          ans := Parameter_Homotopy_Continuation.Show_Menu;
          if ans = '1'
           then Parameter_Homotopy(inft,lp.all);
           else Sweep_Homotopy(inft,lp.all);
          end if;
        end if;
      end if;
    else
      Multitasking_Secant_Homotopy(lp.all,ls,nt);
    end if;
  end Polynomial_Tracker;

  procedure Standard_Laurent_Tracker
              ( inft : in out file_type;
                p : in Standard_Complex_Laur_Systems.Laur_Sys ) is

  -- DESCRIPTION :
  --   Main driver to call the path trackers
  --   on a Laurent polynomial system.

    nva,neq : natural32;

  begin
    neq := natural32(p'last);
    nva := Number_of_Unknowns(p(p'first));
    if nt = 0 then
      if nva = neq then
        close(inft);
        Secant_Homotopy(p);
      else
        new_line;
        put("Found "); put(neq,1);
        put(" equations in "); put(nva,1); put_line(" unknowns...");
        put_line("Laurent homotopies not yet supported ...");
      end if;
    else
      Multitasking_Secant_Homotopy(p,nt);
    end if;
  end Standard_Laurent_Tracker;

  procedure Main_Dispatch
              ( inft : in out file_type;
                p : in Standard_Complex_Laur_Systems.Laur_Sys;
                ls : in Link_to_Array_of_Strings ) is

  -- DESCRIPTION :
  --   Decides whether the given system p is a genuine Laurent system,
  --   that is: if there are negative exponents, and then calls either
  --   the path trackers for Laurent systems (not as well developed),
  --   or the path trackers for regular polynomial systems.
  --   The general path trackers may run in higher precision and use
  --   the original formulation of the system as given in the strings ls.

  begin
    if Standard_Laur_Poly_Convertors.Is_Genuine_Laurent(p) then
      Standard_Laurent_Tracker(inft,p);
    else
      declare
        use Standard_Complex_Poly_Systems;
        use Standard_Laur_Poly_Convertors;
        lp : Link_to_Poly_Sys;
      begin
        lp := new Poly_Sys'(Positive_Laurent_Polynomial_System(p));
        Polynomial_Tracker(inft,lp,ls);
      end;
    end if;
  end Main_Dispatch;

  procedure Standard_Main is

  -- DESCRIPTION :
  --   Reads in the system as a Laurent system with standard
  --   double precision coefficients.
  --   This is the original main program...

    inft : file_type;
    lq : Standard_Complex_Laur_Systems.Link_to_Laur_Sys;
    ls : Link_to_Array_of_Strings := null;

    use Standard_Complex_Laur_Systems;

  begin
    Standard_System_Readers.Read_System(inft,infilename,lq);
    if lq = null then
      new_line;
      put_line("Reading the target polynomial system...");
      Read_Name_and_Open_File(inft);
      get(inft,lq);
    end if;
    Main_Dispatch(inft,lq.all,ls);
  end Standard_Main;

  procedure String_Main is

  -- DESCRIPTION :
  --   Reads in the system as a pointer to an array of strings
  --   and converts to a Laurent polynomial system with standard
  --   complex coefficients for a first dispatch.

    inft : file_type;
    ls : Link_to_Array_of_Strings;
    n,m : natural32;

  begin
    String_System_Readers.Read_System(inft,infilename,n,m,ls);
    if ls = null then
      new_line;
      put_line("Reading the target polynomial system...");
      Read_Name_and_Open_File(inft);
      String_Splitters.get(inft,natural(n),natural(m),ls);
    end if;
   -- put("number of equations, n = "); put(n,1); new_line;
   -- put("number of variables, m = "); put(m,1); new_line;
   -- put_line("the strings : ");
   -- for i in ls'range loop
   --   put_line(ls(i).all);
   -- end loop;
   -- put_line("parsing the strings into a Laurent system ...");
    Symbol_Table.Init(m);
    declare
      q : Standard_Complex_Laur_Systems.Laur_Sys(1..integer32(n))
         := Standard_Complex_Laur_Strings.Parse(m,ls.all);
    begin
     -- put_line("the Laurent polynomial system : "); put(q);
      Main_Dispatch(inft,q,ls);
    end;
  end String_Main;

begin
  String_Main; -- Standard_Main;
end mainpoco;
