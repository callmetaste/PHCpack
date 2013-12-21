with Standard_Natural_Numbers;          use Standard_Natural_Numbers;
with Standard_Integer_Numbers;          use Standard_Integer_Numbers;
with Standard_Floating_Numbers;         use Standard_Floating_Numbers;
with Standard_Natural_Vectors;          use Standard_Natural_Vectors;
with Standard_Natural_VecVecs;          use Standard_Natural_VecVecs;
with Standard_Complex_Solutions;        use Standard_Complex_Solutions;

package Monodromy_Permutations is

-- DESCRIPTION :
--   This package manages solution lists and slices
--   to determine permutations computed by monodromy.

  stay_silent : boolean := false;  -- no intermediate output if stay_silent

  procedure Initialize ( n,d,k : in integer32 );

  -- DESCRIPTION :
  --   Initializes the internal data structures with space
  --   for n monodromy loops or n+1 solution lists of length d,
  --   to factor a k-dimensional solution component.

  procedure Store ( sols : in Solution_List );

  -- DESCRIPTION :
  --   Stores a copy of the list of solutions.

  -- REQUIRED :  
  --   The first three solution lists define the "trace grid",
  --   needed to certify a decomposition using linear traces.
  --   The three solution lists are
  --     0. the original solution list from the given witness set;
  --     1. the solution list on slices parallel to the original slices;
  --     2. the solution list on a second set of parallel slices.

  function Retrieve ( k : integer32 ) return Solution_List;

  -- DESCRIPTION :
  --   Returns the k-th solution list stored in the grid.
  --   For k = 0, 1, 2, we obtain the solutions in the trace grid.

  procedure Trace_Grid_Diagnostics
              ( maximal_error,minimal_distance : out double_float );

  -- DESCRIPTION :
  --   After three solution lists have been stored, the "trace grid"
  --   is defined and we can query the numerical diagnostics.
  --   A trace grid is good if the maximal_error is close to machine
  --   precision and minimal distance is relatively large.

  -- ON RETURN :
  --   maximal_error is the maximal error of the samples in the grid;
  --   minimal_distance is the minimal distance between samples in the grid.

  function In_Slice ( label,slice : integer32 ) return integer32;

  -- DESCRIPTION :
  --   If there is a solution with multiplicity field equal to label
  --   stored at the number slice (original list stored as slice 0),
  --   then the position of the solution in that list is returned,
  --   otherwise 0 is returned.

  function Retrieve ( label,slice : integer32 ) return Link_to_Solution;

  -- DESCRIPTION :
  --   Returns the solution whose multiplicity field equals label
  --   on the given slice.

  function Match ( s : Link_to_Solution; slice : integer32;
                   tol : double_float ) return integer32;

  -- DESCRIPTION :
  --   Returns the label of the solution which matches to s
  --   for the given slice within the given tolerance tol.
  --   Returns zero if no solution matches with s.

  function Permutation return Vector;

  -- DESCRIPTION :
  --   Returns the permutation generated by the last stored
  --   list of solutions, compared with the first one stored.

  function Number_of_Irreducible_Factors return natural32;

  -- DESCRIPTION :
  --   Returns the number of irreducible factors in the current decomposition.

  function Component ( k : integer32 ) return Link_to_Vector;

  -- DESCRIPTION :
  --   Returns the labels of the points that span the k-th component
  --   in the current irreducible decomposition.

  -- REQUIRED : k is in the range 1..Number_of_Irreducible_Factors.

  function Decomposition return Link_to_VecVec;

  -- DESCRIPTION :
  --   Returns the current classification of witness points along
  --   the irreducible decomposition.

  procedure Update_Decomposition ( p : in Vector; nf0,nf1 : out natural32 );

  -- DESCRIPTION :
  --   Updates the decomposition with the permutation p.
  --   On return are in nf0 the initial number of groupings,
  --   and in nf1 the new number of groupings.

  function Trace_Sum_Difference ( f : Vector ) return double_float;

  -- DESCRIPTION :
  --   Returns the difference between the actual sum at the samples
  --   (from points defined by the labels in f) and the value at the
  --   linear trace.  If the number on return is small, then f defines
  --   a factor, otherwise f is not a factor.

  -- REQUIRED :
  --   The trace grid is initialized appropriatedly.

  function Certify_with_Linear_Trace return boolean;

  -- DESCRIPTION :
  --   Applies the linear trace test to each factor
  --   in the current monodromy breakup.
  --   Returns true if all factors are certified, returns false otherwise.

  procedure Clear;

  -- DESCRIPTION :
  --   Destruction of all internal data structures.

end Monodromy_Permutations;
