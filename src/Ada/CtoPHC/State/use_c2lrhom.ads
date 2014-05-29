with Standard_Integer_Numbers;          use Standard_Integer_Numbers;
with C_Integer_Arrays;                  use C_Integer_Arrays;
with C_Double_Arrays;                   use C_Double_Arrays;

function use_c2lrhom ( job : integer32;
                       a : C_intarrs.Pointer;
		       b : C_intarrs.Pointer;
                       c : C_dblarrs.Pointer ) return integer32;

-- DESCRIPTION :
--   Provides a gateway from C to the Littlewood-Richardson homotopies.

-- ON ENTRY :
--   job =  0 : given in a the dimension of a general Schubert problem:
--              a[0] : the ambient dimension n of the space,
--              a[1] : the dimension k of the solution planes,
--              a[2] : the number c of intersection conditions,
--              and in a[3] is the verbose flag, 0 for silent, 1 for output;
--              in b are the brackets, as many integers as the dimension k
--              of the solution planes times c, the number of conditions.

-- ON RETURN :
--   0 if the operation was successful, otherwise something went wrong,
--   e.g.: job not in the right range.