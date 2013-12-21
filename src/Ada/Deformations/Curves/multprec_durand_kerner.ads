with Standard_Natural_Numbers;           use Standard_Natural_Numbers;
with Standard_Floating_Numbers;          use Standard_Floating_Numbers;
with Multprec_Floating_Numbers;          use Multprec_Floating_Numbers;
with Multprec_Floating_Vectors;          use Multprec_Floating_Vectors;
with Multprec_Complex_Numbers;           use Multprec_Complex_Numbers;
with Multprec_Complex_Vectors;           use Multprec_Complex_Vectors;

package Multprec_Durand_Kerner is

-- DESCRIPTION :
--   This package offers a basic version of the method of Durand-Kerner,
--   (aka the method of Weierstrass) to find all complex roots of a polynomial
--   in one variable with standard complex coefficients.  The input polynomial
--   is assumed to be generic enough for this basic version to work well.

  function Horner ( p : Multprec_Complex_Vectors.Vector;
                    x : Complex_Number ) return Complex_Number;

  -- DESCRIPTION :
  --   Returns (..((p[n]*x + p[n-1])*x + p[n-2])*x + .. + p[1])*x + p[0],
  --   where n is the degree of the polynomial with coefficients in p.

  function Derivative ( p : Multprec_Complex_Vectors.Vector )
                      return Multprec_Complex_Vectors.Vector;

  -- DESCRIPTION :
  --   Returns the coefficient vector of the derivative of p.

  procedure Newton ( p,dp : in Multprec_Complex_Vectors.Vector;
                     z : in out Complex_Number;
                     err,rco,res : out Floating_Number );

  -- DESCRIPTION :
  --   Does one Newton step on every solution z of the polynomial p.
  --   Use this to validate the output of the Durand-Kerner method.

  -- ON ENTRY :
  --   p        a polynomial p is represented by its coefficient vector;
  --   dp       coefficient vector of the derivative of the polynomial;
  --   z        initial approximation of one root of p.

  -- ON RETURN :
  --   z        refined approximate root of p;
  --   err      magnitude of the correction term for z;
  --   rco      absolute value of the derivative at z measures
  --            the condition number of the root;
  --   res      residual of the polynomial p at the root.

  procedure Newton ( p,dp : in Multprec_Complex_Vectors.Vector;
                     z : in out Multprec_Complex_Vectors.Vector;
                     err,rco,res : out Multprec_Floating_Vectors.Vector );

  -- DESCRIPTION :
  --   Does one Newton step on every solution z of the polynomial p.
  --   Use this to validate the output of the Durand-Kerner method.

  -- ON ENTRY :
  --   p         a polynomial p is represented by its coefficient vector;
  --   dp        coefficient vector of the derivative of the polynomial;
  --   z         initial approximations of the roots of p.

  -- ON RETURN :
  --   z         refinements of the approximate roots of p;
  --   err       magnitude of the correction terms for z;
  --   rco       absolute values of the derivative at z measure
  --             the condition number of each root;
  --   res       residual of the polynomial p at each root.

  generic 

    with procedure Write
               ( step : in natural32;
                 z,res : in Multprec_Complex_Vectors.Vector );

    -- DESCRIPTION :
    --   This routine can write intermediate results after each iteration,
    --   such as the step number, the approximations z and the residuals res.

  procedure Reporting_Durand_Kerner
                 ( p : in Multprec_Complex_Vectors.Vector;
                   z,res : in out Multprec_Complex_Vectors.Vector;
                   maxsteps : in natural32; eps : in Floating_Number;
                   nb : out natural32; fail : out boolean );

  -- DESCRIPTION :
  --   This routine computes all roots of a given polynomial
  --   in one unknown, applying the method of Durand-Kerner.

  -- ON ENTRY :
  --   p           the polynomial defined by
  --                 p[k] + p[k+1]*x + p[k+2]*x^2 + .. + p[k+n]*x^n,
  --               with k = p'first;
  --   z           initial approximations for the roots;
  --   res         the residuals of the roots;
  --   maxsteps    is the maximum number of steps that are allowed;
  --   eps         the required accuracy.

  -- ON RETURN :
  --   z           the computed roots;
  --   res         the residuals of the roots;
  --   nb          the number of steps;
  --   fail        if true, then failed to reach accuracy within maxsteps.

  procedure Silent_Durand_Kerner
                 ( p : in Multprec_Complex_Vectors.Vector;
                   z,res : in out Multprec_Complex_Vectors.Vector;
                   maxsteps : in natural32; eps : in Floating_Number;
                   nb : out natural32; fail : out boolean );

  -- DESCRIPTION :
  --   Applies the method of Durand-Kerner, without any intermediate output.
  --   All parameters have the same meaning as the reporting version.

end Multprec_Durand_Kerner;
