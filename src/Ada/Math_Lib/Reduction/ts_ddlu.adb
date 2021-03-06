with text_io;                            use text_io;
with Communications_with_User;           use Communications_with_User;
with Timing_Package;                     use Timing_Package;
with Standard_Natural_Numbers;           use Standard_Natural_Numbers;
with Standard_Integer_Numbers;           use Standard_Integer_Numbers;
with Standard_Integer_Numbers_io;        use Standard_Integer_Numbers_io;
with Standard_Floating_Numbers;          use Standard_Floating_Numbers;
with Standard_Floating_Numbers_io;       use Standard_Floating_Numbers_io;
with Double_Double_Numbers;              use Double_Double_Numbers;
with Double_Double_Numbers_io;           use Double_Double_Numbers_io;
with Standard_Integer_Vectors;
with Standard_Floating_Vectors;
with Standard_Floating_Matrices;
with Standard_Floating_Norms_Equals;
with Standard_Complex_Vectors;
with Standard_Complex_Matrices;
with Standard_Complex_Norms_Equals;
with Standard_Random_Vectors;
with Standard_Random_Matrices;
with Double_Double_Vectors;
with Double_Double_Vectors_io;
with Double_Double_Vector_Norms;
with Double_Double_Matrices;
with DoblDobl_Complex_Vectors;
with DoblDobl_Complex_Vectors_io;
with DoblDobl_Complex_Vector_Norms;
with DoblDobl_Complex_Matrices;
with DoblDobl_Random_Vectors;
with DoblDobl_Random_Matrices;
with Standard_Floating_Linear_Solvers;
with Standard_Complex_Linear_Solvers;
with Double_Double_Linear_Solvers;
with DoblDobl_Complex_Linear_Solvers;
with Test_LU_Decompositions;

procedure ts_ddlu is

-- DESCRIPTION :
--   Tests solving linear systems of matrices of double doubles.
--   The second part of the code does a performance test.

  procedure Run_Double_Double_Linear_Solver
              ( A : in Double_Double_Matrices.Matrix;
                b : in Double_Double_Vectors.Vector ) is

  -- DESCRIPTION :
  --   Solves the system A*x = b.

    use Double_Double_Vectors,Double_Double_Vectors_io;
    use Double_Double_Matrices,Double_Double_Linear_Solvers;
    use Test_LU_Decompositions;

    AA : Matrix(A'range(1),A'range(2)) := A;
    n : constant integer32 := A'last(1);
    ipvt : Standard_Integer_Vectors.Vector(1..n);
    info : integer32;
    x : Vector(b'range) := b;
    res : Vector(b'range);
    tol : constant double_double := create(1.0E-16);
    maxerr : double_double;
    fail : boolean;

  begin
    new_line;
    lufac(AA,n,ipvt,info);
    put("info = "); put(info,1); new_line;
    lusolve(AA,n,ipvt,x);
    put_line("The solution :"); put_line(x);
    res := b - A*x;
    put_line("The residual :"); put_line(res);
    new_line;
    put_line("Testing the LU factorization ...");
    new_line;
    Test_Decomposition(n,A,AA,ipvt,tol,true,maxerr,fail);
    put("largest error : "); put(maxerr,3);
    put(" < "); put(tol,3); put(" ? ");
    if fail
     then put_line("bug!?");
     else put_line("okay.");
    end if;
  end Run_Double_Double_Linear_Solver;

  procedure Run_DoblDobl_Complex_Linear_Solver
              ( A : in DoblDobl_Complex_Matrices.Matrix;
                b : in DoblDobl_Complex_Vectors.Vector ) is

  -- DESCRIPTION :
  --   Solves the system A*x = b.

    use DoblDobl_Complex_Vectors,DoblDobl_Complex_Vectors_io;
    use DoblDobl_Complex_Matrices,DoblDobl_Complex_Linear_Solvers;
    use Test_LU_Decompositions;

    AA : Matrix(A'range(1),A'range(2)) := A;
    n : constant integer32 := A'last(1);
    ipvt : Standard_Integer_Vectors.Vector(1..n);
    info : integer32;
    x : Vector(b'range) := b;
    res : Vector(b'range);
    tol : constant double_double := create(1.0E-16);
    maxerr : double_double;
    fail : boolean;

  begin
    new_line;
    lufac(AA,n,ipvt,info);
    put("info = "); put(info,1); new_line;
    lusolve(AA,n,ipvt,x);
    put_line("The solution :"); put_line(x);
    res := b - A*x;
    put_line("The residual :"); put_line(res);
    new_line;
    put_line("Testing the LU factorization ...");
    new_line;
    Test_Decomposition(n,A,AA,ipvt,tol,true,maxerr,fail);
    put("largest error : "); put(maxerr,3);
    put(" < "); put(tol,3); put(" ? ");
    if fail
     then put_line("bug!?");
     else put_line("okay.");
    end if;
  end Run_DoblDobl_Complex_Linear_Solver;

  procedure Test_Double_Double_Linear_Solver is

  -- DESCRIPTION :
  --   Generates a random linear system and solves it.

    use Double_Double_Vectors,Double_Double_Matrices;

    n,m : integer32 := 0;

  begin
    new_line;
    put("Give the number of rows : "); get(n);
    put("Give the number of columns : "); get(m);
    declare
      A : constant Matrix(1..n,1..m)
        := DoblDobl_Random_Matrices.Random_Matrix(natural32(n),natural32(m));
      b : constant Vector(1..n)
        := DoblDobl_Random_Vectors.Random_Vector(1,n);
    begin
      Run_Double_Double_Linear_Solver(A,b);
    end;
  end Test_Double_Double_Linear_Solver;

  procedure Test_DoblDobl_Complex_Linear_Solver is

  -- DESCRIPTION :
  --   Generates a random linear system and solves it.

    use DoblDobl_Complex_Vectors,DoblDobl_Complex_Matrices;

    n,m : integer32 := 0;

  begin
    new_line;
    put("Give the number of rows : "); get(n);
    put("Give the number of columns : "); get(m);
    declare
      A : constant Matrix(1..n,1..m)
        := DoblDobl_Random_Matrices.Random_Matrix(natural32(n),natural32(m));
      b : constant Vector(1..n)
        := DoblDobl_Random_Vectors.Random_Vector(1,n);
    begin
      Run_DoblDobl_Complex_Linear_Solver(A,b);
    end;
  end Test_DoblDobl_Complex_Linear_Solver;

-- PERFORMANCE TESTERS :

  procedure Test_Performance_Standard_Float_Linear_Solver
              ( d,k : in integer32; output,solve : in boolean ) is

  -- DESCRIPTION :
  --   This routine is primarily to compare how much more double double
  --   arithmetic costs, compared to standard hardware arithmetic.
  --   Generates a random matrix and random right hand side vector
  --   of dimension d, solves the system and reports the residual.
  --   This is done k times.
  --   If output, then the residual is computed and its max norm shown.

    use Standard_Floating_Vectors,Standard_Floating_Matrices;
    use Standard_Floating_Linear_Solvers;

    A : constant Matrix(1..d,1..d)
      := Standard_Random_Matrices.Random_Matrix(natural32(d),natural32(d));
    b : constant Vector(1..d) := Standard_Random_Vectors.Random_Vector(1,d);
    ipvt : Standard_Integer_Vectors.Vector(1..d);
    info : integer32;
    AA : Matrix(1..d,1..d);
    x : Vector(1..d);

  begin
    for i in 1..k loop
      AA := A; x := b;
      lufac(AA,d,ipvt,info);
      if solve then
        lusolve(AA,d,ipvt,x);
        if output then
          declare
            res : Vector(1..d);
            nrm : double_float;
          begin  
            res := b - A*x;
            nrm := Standard_Floating_Norms_Equals.Max_Norm(res);
            put("Max norm of residual : "); put(nrm,3); new_line;
          end;
        end if;
      end if;
    end loop;
  end Test_Performance_Standard_Float_Linear_Solver;

  procedure Test_Performance_Standard_Complex_Linear_Solver
              ( d,k : in integer32; output,solve : in boolean ) is

  -- DESCRIPTION :
  --   This routine is primarily to compare how much more double double
  --   arithmetic costs, compared to standard hardware arithmetic.
  --   Generates a random matrix and random right hand side vector
  --   of dimension d, solves the system and reports the residual.
  --   This is done k times.
  --   If output, then the residual is computed and its max norm shown.

    use Standard_Complex_Vectors,Standard_Complex_Matrices;
    use Standard_Complex_Linear_Solvers;

    A : constant Matrix(1..d,1..d)
      := Standard_Random_Matrices.Random_Matrix(natural32(d),natural32(d));
    b : constant Vector(1..d) := Standard_Random_Vectors.Random_Vector(1,d);
    ipvt : Standard_Integer_Vectors.Vector(1..d);
    info : integer32;
    AA : Matrix(1..d,1..d);
    x : Vector(1..d);

  begin
    for i in 1..k loop
      AA := A; x := b;
      lufac(AA,d,ipvt,info);
      if solve then
        lusolve(AA,d,ipvt,x);
        if output then
          declare
            res : Vector(1..d);
            nrm : double_float;
          begin  
            res := b - A*x;
            nrm := Standard_Complex_Norms_Equals.Max_Norm(res);
            put("Max norm of residual : "); put(nrm,3); new_line;
          end;
        end if;
      end if;
    end loop;
  end Test_Performance_Standard_Complex_Linear_Solver;

  procedure Test_Performance_Double_Double_Linear_Solver
              ( d,k : in integer32; output,solve : in boolean ) is

  -- DESCRIPTION :
  --   Generates a random matrix and random right hand side vector
  --   of dimension d, solves the system and reports the residual.
  --   This is done k times.
  --   If output, then the residual is computed and its max norm shown.

    use Double_Double_Vectors,Double_Double_Matrices;
    use Double_Double_Linear_Solvers;

    A : constant Matrix(1..d,1..d)
      := DoblDobl_Random_Matrices.Random_Matrix(natural32(d),natural32(d));
    b : constant Vector(1..d) := DoblDobl_Random_Vectors.Random_Vector(1,d);
    ipvt : Standard_Integer_Vectors.Vector(1..d);
    info : integer32;
    AA : Matrix(1..d,1..d);
    x : Vector(1..d);

  begin
    for i in 1..k loop
      AA := A; x := b;
      lufac(AA,d,ipvt,info);
      if solve then
        lusolve(AA,d,ipvt,x);
        if output then
          declare
            res : Vector(1..d);
            nrm : double_double;
          begin  
            res := b - A*x;
            nrm := Double_Double_Vector_Norms.Max_Norm(res);
            put("Max norm of residual : "); put(nrm,3); new_line;
          end;
        end if;
      end if;
    end loop;
  end Test_Performance_Double_Double_Linear_Solver;

  procedure Test_Performance_DoblDobl_Complex_Linear_Solver
              ( d,k : in integer32; output,solve : in boolean ) is

  -- DESCRIPTION :
  --   Generates a random matrix and random right hand side vector
  --   of dimension d, solves the system and reports the residual.
  --   This is done k times.
  --   If output, then the residual is computed and its max norm shown.

    use DoblDobl_Complex_Vectors,DoblDobl_Complex_Matrices;
    use DoblDobl_Complex_Linear_Solvers;

    A : constant Matrix(1..d,1..d)
      := DoblDobl_Random_Matrices.Random_Matrix(natural32(d),natural32(d));
    b : constant Vector(1..d) := DoblDobl_Random_Vectors.Random_Vector(1,d);
    ipvt : Standard_Integer_Vectors.Vector(1..d);
    info : integer32;
    AA : Matrix(1..d,1..d);
    x : Vector(1..d);

  begin
    for i in 1..k loop
      AA := A; x := b;
      lufac(AA,d,ipvt,info);
      if solve then
        lusolve(AA,d,ipvt,x);
        if output then
          declare
            res : Vector(1..d);
            nrm : double_double;
          begin  
            res := b - A*x;
            nrm := DoblDobl_Complex_Vector_Norms.Max_Norm(res);
            put("Max norm of residual : "); put(nrm,3); new_line;
          end;
        end if;
      end if;
    end loop;
  end Test_Performance_DoblDobl_Complex_Linear_Solver;

  procedure Ask_Performance_Settings
              ( n,d : out integer32;
                output,outer,solve : out boolean ) is

  -- DESCRIPTION :
  --   Asks the user for the parameters of the performance tests:
  --     n : number of times to solve a linear system;
  --     d : dimension of the linear system to be solved;
  --     output : if the residual should be shown;
  --     outer : if a new random system should be generated each time.

    ans : character;

  begin
    put("Give number of times : "); n := 0; get(n);
    put("Give the dimension : "); d := 0; get(d);
    put("Do you want to solve (if not, LU only) ? (y/n) ");
    Ask_Yes_or_No(ans);
    solve := (ans = 'y');
    if solve then
      put("Do you want to the see the residual ? (y/n) ");
      Ask_Yes_or_No(ans);
      output := (ans = 'y');
    else
      output := false;
    end if;
    put("Generate new random matrix each time ? (y/n) ");
    Ask_Yes_or_No(ans);
    outer := (ans = 'y');
  end Ask_Performance_Settings;

  procedure Standard_Float_Performance_Test is

  -- DESCRIPTION :
  --   Generates a number of linear systems and solves.

    n,d : integer32;
    otp,outer,solve : boolean;
    timer : Timing_Widget;

  begin
    new_line;
    Ask_Performance_Settings(n,d,otp,outer,solve);
    tstart(timer);
    if outer then
      for i in 1..n loop
        Test_Performance_Standard_Float_Linear_Solver(d,1,otp,solve);
      end loop;
    else
      Test_Performance_Standard_Float_Linear_Solver(d,n,otp,solve);
    end if;
    tstop(timer);
    new_line;
    put("Solved "); put(n,1); put(" linear systems");
    put(" of dimension "); put(d,1); put_line("."); new_line;
    print_times(standard_output,timer,"performance test");
  end Standard_Float_Performance_Test;

  procedure Standard_Complex_Performance_Test is

  -- DESCRIPTION :
  --   Generates a number of linear systems and solves.

    n,d : integer32;
    otp,outer,solve : boolean;
    timer : Timing_Widget;

  begin
    new_line;
    Ask_Performance_Settings(n,d,otp,outer,solve);
    tstart(timer);
    if outer then
      for i in 1..n loop
        Test_Performance_Standard_Complex_Linear_Solver(d,1,otp,solve);
      end loop;
    else
      Test_Performance_Standard_Complex_Linear_Solver(d,n,otp,solve);
    end if;
    tstop(timer);
    new_line;
    put("Solved "); put(n,1); put(" linear systems");
    put(" of dimension "); put(d,1); put_line("."); new_line;
    print_times(standard_output,timer,"performance test");
  end Standard_Complex_Performance_Test;

  procedure Double_Double_Performance_Test is

  -- DESCRIPTION :
  --   Generates a number of linear systems of double doubles
  --   and solves.

    n,d : integer32;
    otp,outer,solve : boolean;
    timer : Timing_Widget;

  begin
    new_line;
    Ask_Performance_Settings(n,d,otp,outer,solve);
    tstart(timer);
    if outer then
      for i in 1..n loop
        Test_Performance_Double_Double_Linear_Solver(d,1,otp,solve);
      end loop;
    else
      Test_Performance_Double_Double_Linear_Solver(d,n,otp,solve);
    end if;
    tstop(timer);
    new_line;
    put("Solved "); put(n,1); put(" linear systems");
    put(" of dimension "); put(d,1); put_line("."); new_line;
    print_times(standard_output,timer,"performance test");
  end Double_Double_Performance_Test;

  procedure DoblDobl_Complex_Performance_Test is

  -- DESCRIPTION :
  --   Generates a number of linear systems and solves.

    n,d : integer32;
    otp,outer,solve : boolean;
    timer : Timing_Widget;

  begin
    new_line;
    Ask_Performance_Settings(n,d,otp,outer,solve);
    tstart(timer);
    if outer then
      for i in 1..n loop
        Test_Performance_DoblDobl_Complex_Linear_Solver(d,1,otp,solve);
      end loop;
    else
      Test_Performance_DoblDobl_Complex_Linear_Solver(d,n,otp,solve);
    end if;
    tstop(timer);
    new_line;
    put("Solved "); put(n,1); put(" linear systems");
    put(" of dimension "); put(d,1); put_line("."); new_line;
    print_times(standard_output,timer,"performance test");
  end DoblDobl_Complex_Performance_Test;

  procedure Main is

    ans : character;

  begin
    new_line;
    put_line("Interactive testing of double double LU factorization.");
    loop
      new_line;
      put_line("Choose one of the following : ");
      put_line("  0. exit this program;");
      put_line("  1. test double double linear solver;");
      put_line("  2. test double double complex linear solver;");
      put_line("  3. performance test on standard float arithmetic;");
      put_line("  4. performance test on standard complex arithmetic;");
      put_line("  5. performance test on double double arithmetic;");
      put_line("  6. performance test on double double complex arithmetic.");
      put("Make your choice (0, 1, 2, 3, 4, 5, or 6) : ");
      Ask_Alternative(ans,"0123456");
      exit when (ans = '0');
      case ans is
        when '1' => Test_Double_Double_Linear_Solver;
        when '2' => Test_DoblDobl_Complex_Linear_Solver;
        when '3' => Standard_Float_Performance_Test;
        when '4' => Standard_Complex_Performance_Test;
        when '5' => Double_Double_Performance_Test;
        when '6' => DoblDobl_Complex_Performance_Test;
        when others => null;
      end case;
    end loop;
  end Main;

begin
  Main;
end ts_ddlu;
