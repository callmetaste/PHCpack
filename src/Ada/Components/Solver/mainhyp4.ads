procedure mainhyp4 ( polyfile,logfile : in string );

-- DESCRIPTION :
--   Witness Set for Hypersurface cutting with Random Line,
--   called as phc -l4, for quad double precision.

-- ON ENTRY :
--   polyfile     file with one polynomial in several variables
--   logfile      file name to write diagnostics on.

-- ON RETURN :
--   polyfile_wk, a file with a witness set for the hypersurface,
--   with k the dimension of the hypersurface.
