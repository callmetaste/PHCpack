with Standard_Natural_Numbers;           use Standard_Natural_Numbers;
with Lists_of_Integer_Vectors;           use Lists_of_Integer_Vectors;
with Arrays_of_Integer_Vector_Lists;     use Arrays_of_Integer_Vector_Lists;
with Trees_of_Vectors;                   use Trees_of_Vectors;

package Volumes is

-- DESCRIPTION :
--   This package contains a routine to compute the volume
--   of a polytope and two routines for computing the mixed volume.

  function Volume ( n : natural32; L : List ) return natural32;

  function Volume ( n : natural32; L : List;
                    tv : Tree_of_Vectors ) return natural32;

  procedure Volume ( n : in natural32; L : in List;
                     tv : in out Tree_of_Vectors; vlm : out natural32 );

  -- DESCRIPTION :
  --   Computes n! times the volume of the polytope generated
  --   by the points in l; n equals the dimension of the space.
  --   The tree of degrees tv maintains the directions used to 
  --   compute the volume.  Once tv has been constructed, the volume
  --   can be computed more efficiently.

  -- REMARK :
  --   The tree of vectors contains directions normal to the polytope
  --   generated by a list wl where the first element of the list
  --   consists of all zeroes; so eventually l has been shifted.

  function Mixed_Volume
             ( n : natural32; al : Array_of_Lists ) return natural32;

  function Mixed_Volume ( n : natural32; al : Array_of_Lists;
                          tv : Tree_of_Vectors ) return natural32;

  procedure Mixed_Volume ( n : in natural32; al : in Array_of_Lists;
                           tv : in out Tree_of_Vectors; mv : out natural32 );

  -- DESCRIPTION :
  --   Computes the mixed volume of the polytopes generated
  --   by the points in al; n equals the dimension of the space.
  --   The tree of vectors tv maintains the directions used to
  --   compute the mixed volume.  Once tv has been constructed,
  --   the mixed volume can be computed more efficiently.

end Volumes;
