with text_io;                              use text_io;
with Standard_Natural_Numbers;             use Standard_Natural_Numbers;
with Standard_Floating_Numbers;            use Standard_Floating_Numbers;
with Standard_Complex_VecVecs;             use Standard_Complex_VecVecs;
with Sample_Point_Lists;                   use Sample_Point_Lists;
with Standard_Stacked_Sample_Grids;
with Multprec_Stacked_Sample_Grids;

package Drivers_to_Grid_Creators is

-- DESCRIPTION :
--   This package provides drivers to the creators for rectangular
--   and stacked grids of sample points.  Besides creating the grids,
--   these routines also provides additional tests on the quality of
--   the grids.

-- REQUIRED :
--   The sampling machine must be properly initialized and tuned
--   for all creators to work.

  procedure Write_Errors ( file : in file_type;
                           sps : in Standard_Sample_List );
  procedure Write_Errors ( file : in file_type;
                           sps : in Multprec_Sample_List );

  -- DESCRIPTION :
  --   For every sample in the list, the error is written.

  procedure Standard_Rectangular_Grid_Creator
               ( file : in file_type; sps : in Standard_Sample_List;
                 m : in natural32; grid : out Array_of_Standard_Sample_Lists;
                 eps,dst : out double_float );
  procedure Standard_Triangular_Grid_Creator
               ( file : in file_type; sps : in Standard_Sample_List;
                 m : in natural32; grid : out Array_of_Standard_Sample_Lists;
                 eps,dst : out double_float );
  procedure Multprec_Rectangular_Grid_Creator
               ( file : in file_type; sps : in out Standard_Sample_List;
                 m,size : in natural32;
                 grid : out Array_of_Multprec_Sample_Lists;
                 eps,dst : out double_float );
  procedure Multprec_Triangular_Grid_Creator
               ( file : in file_type; sps : in out Standard_Sample_List;
                 m,size : in natural32;
                 grid : out Array_of_Multprec_Sample_Lists;
                 eps,dst : out double_float );

  -- DESCRIPTION :
  --   Creates a rectangular or triangular sample grid, where grid is of
  --   range 0..m, varying only the constant term on the slicing hyperplanes.

  -- ON ENTRY :
  --   file      for diagnostics;
  --   sps       list of samples from irreducible component;
  --   m         desired number of sample lists in the grid.

  -- ON RETURN :
  --   grid      array of range 0..m of sample lists;
  --   eps       maximal error on the samples in the grid, 
  --             as measure for the accuracy of the grid;
  --   dst       minimal distance between samples in one list in the grid,
  --             as measure for the conditioning of the grid.

  procedure Standard_Stacked_Grid_Creator
               ( file : in file_type; sps : in Standard_Sample_List;
                 full : in boolean;
                 grid : out Standard_Stacked_Sample_Grids.Stacked_Sample_Grid );
  procedure Multprec_Stacked_Grid_Creator
               ( file : in file_type; sps : in Standard_Sample_List;
                 full : in boolean; size : in natural32;
                 grid : out Multprec_Stacked_Sample_Grids.Stacked_Sample_Grid );

  -- DESCRIPTION :
  --   Creates a stacked grid of sample points, varying only
  --   the constant term on the slicing hyperplanes.

  -- ON ENTRY :
  --   file      for writing diagnostics and results of tests;
  --   sps       sample list to start the creation of the grid;
  --   full      if true, then a full grid will be generated;
  --             otherwise d samples are saved;
  --   size      size of the multi-precision numbers.

  -- ON RETURN :
  --   grid      stacked grid of samples with as many layers 
  --             as the number of slices in the samples.

  procedure Standard_Test_Samples
               ( file : in file_type; sps : in Standard_Sample_List;
                 sli : in Standard_Complex_VecVecs.VecVec;
                 testsps : out Standard_Sample_List );
  procedure Multprec_Test_Samples
               ( file : in file_type; sps : in Standard_Sample_List;
                 sli : in Standard_Complex_VecVecs.VecVec;
                 testsps : out Multprec_Sample_List );

  -- DESCRIPTION :
  --   Chooses new random constants in the slices and generates
  --   new sample points, starting at those points in sps.

end Drivers_to_Grid_Creators;
