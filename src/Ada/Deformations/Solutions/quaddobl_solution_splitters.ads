with text_io;                             use text_io;
with Standard_Integer_Numbers;            use Standard_Integer_Numbers;
with Standard_Floating_Numbers;           use Standard_Floating_Numbers;
with QuadDobl_Complex_Solutions;          use QuadDobl_Complex_Solutions;

package QuadDobl_Solution_Splitters is

-- DESCRIPTION :
--   A splitter divides a solution list in two, depending on
--    1) whether a solution has a zero slack variable; or
--    2) whether a solution is regular or singular.
--   The operations in this package are drivers to the filters
--   in Standard_Solution_Filters.

  procedure Filter_and_Split_Solutions
                ( file : in file_type; sols : in Solution_List;
                  n,k : in integer32; tol : in double_float;
                  sols0,sols1 : out Solution_List );

  procedure Filter_and_Split_Solutions
                ( sols : in Solution_List;
                  n,k : in integer32; tol : in double_float;
                  sols0,sols1 : out Solution_List );

  -- DESCRIPTION :
  --   Removes the spurious solutions from the list sols and splits it
  --   into two lists, depending on the (n+k)-th value to be zero.

  -- ON ENTRY :
  --   file       to write the results on, if omitted, then silent;
  --   sols       computed solutions at the end of the paths;
  --   n          original dimension;
  --   k          number of random slices and variables added;
  --   tol        everything that has absolute value less than tol is zero.

  -- ON RETURN :
  --   sols0      solutions with n-th component less than tol;
  --   sols1      solutions with n-th component larger than tol.

  procedure S_Singular_Filter
              ( sols : in Solution_List; tol : in double_float;
                sinsols,regsols : out Solution_List );

  procedure R_Singular_Filter
              ( file : in file_type;
                sols : in Solution_List; tol : in double_float;
                sinsols,regsols : out Solution_List );

  -- DESCRIPTION :
  --   Removes those solutions whose conditions number is too large.

  -- ON ENTRY :
  --   file     for intermediate output;
  --   sols     list of solutions;
  --   tol      tolerance on inverse condition number rco.

  -- ON RETURN :
  --   sinsols  solutions with rco <= tol.
  --   regsols  solutions with rco > tol.

end QuadDobl_Solution_Splitters;
