with text_io;                           use text_io;
with Standard_Integer_Numbers;          use Standard_Integer_Numbers;
with Standard_Complex_Vectors;          use Standard_Complex_Vectors;
with Standard_Complex_VecVecs;          use Standard_Complex_VecVecs;
with Standard_Complex_Poly_Systems;     use Standard_Complex_Poly_Systems;
with Standard_Complex_Solutions;        use Standard_Complex_Solutions;

package Witness_Sets_Formats is

-- DESCRIPTION :
--   This package offers routines to convert the intrinsic representation
--   of witness points into an intrinsic format.  A witness point is a
--   solution of a polynomial system which lies on generic hyperplanes,
--   The number of generic hyperplanes used to cut out the point from
--   a solution component equals the dimension of the solution component.
--   The number of witness points on one component cut out by a same set
--   of generic hyperplanes equals the degree of the solution component.
--   So the witness point set is a very compact and efficient description
--   of a positive dimensional solution component of a polynomial system.
--   The intrinsic format uses the generators of the affine planes,
--   while the extrinsic format uses the explicit linear equations.
--   The intrinsic representation is more efficient as it needs less
--   variables, while the extrinsic representation is closer to the
--   tools of PHCpack to deal with solutions of polynomial systems.

-- FROM INTRINSIC TO EXTRINSIC FORMATS :

  function Embedded_System
              ( n : integer32; b,v : Vector; p : Poly_Sys ) return Poly_Sys;

  -- DESCRIPTION :
  --   Returns the embedded polynomial cut by the line b + t*v, with the
  --   defining equations for the line added as last n-1 linear equations
  --   in their embedded form.

  -- WARNING : only designed to work if p is square...

  function Embedded_System
              ( n,k : integer32; b : Vector; v : VecVec; p : Poly_Sys )
              return Poly_Sys;

  -- DESCRIPTION :
  --   Returns the polynomial system, embedded with k slack variables,
  --   and the defining equations for the k-dimensional affine plane
  --   generated by offset vector b and directions v appended.

  -- WARNING : only designed to work if p is square...

  function Embedded_Extrinsic_Solutions
              ( n : integer32; b,v,sol : Vector ) return Solution_List;

  -- DESCRIPTION :
  --   Returns the solutions on the line b + t*v in extrinsic format,
  --   embedded with n-1 slack variables with zero value.

  function Embedded_Extrinsic_Solutions
              ( n,k : integer32; b : Vector; v : VecVec;
                sols : Solution_List ) return Solution_List;

  -- DESCRIPTION :
  --   Returns the extrinsic format of the solutions on the affine 
  --   k-plane generated by offset b and directions in v,
  --   embedded with k slack variables with zero value.

  procedure Write_Embedding
              ( file : in file_type; p : in Poly_Sys;
                n : in integer32; b,v : in Vector;
                sols : in Solution_List );

  -- DESCRIPTION :
  --   Writes the embedded polynomial system on file,
  --   along with the solution list in embedded extrinsic format.

  -- WARNING : only designed to work if p is square...

  procedure Write_Embedding
              ( file : in file_type; p : in Poly_Sys;
                n,k : in integer32; b : in Vector; v : in VecVec;
                sols : in Solution_List );

  -- DESCRIPTION :
  --   Writes the embedded polynomial system on file,
  --   along with the solution list in embedded extrinsic format.

  -- WARNING : only designed to work if p is square...

end Witness_Sets_Formats;
