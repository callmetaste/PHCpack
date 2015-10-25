// C++ function called by Ada routine to apply algorithmic differentiation for
// the evaluation to the tracking of one path

#include <iostream>
#include <iomanip>
#include "syscon.h"
#include "solcon.h"
#include "phcpack.h"
#include "ada_test.h"
#include "parameter.h"
#include "path_host.h"
#include "poly.h"
#include "adeonepath_d.h"

using namespace std;

extern "C" int adeonepath_d ( int verbose, double regamma, double imgamma )
{
   int fail;
   PolySys ps;
   PolySys qs;
   PolySolSet sols;

   fail = copy_target_system_to_container();

   if(verbose > 0)
   {
      int dim, len;

      cout << endl;
      cout << "Tracking one path ..." << endl;
      cout << "gamma = " << setprecision(16)
           << regamma << " + i* " << imgamma << endl;
      fail = syscon_number_of_standard_polynomials(&dim);
      cout << "number of polynomials : " << dim << endl;
      fail = solcon_number_of_solutions(&len);
      cout << "number of solutions : " << len << endl;
   }

   ada_read_sys(verbose,ps);

   fail = copy_start_system_to_container();

   ada_read_sys(verbose,qs);
   ada_read_sols(qs,sols);

   fail = track(verbose,regamma,imgamma,ps,qs,sols);

   if(verbose > 0)
      cout << "writing the solutions to the container ..." << endl;

   ada_write_sols(sols);

   return 0;
}

int track
 ( int verbose, double regamma, double imgamma,
   PolySys& p, PolySys& q, PolySolSet& s )
{
   double tpred,teval,tmgs;
   bool success;
   CT* sol = s.get_sol(0);
   CT alpha,t;
   CPUInstHom cpu_inst_hom;
   Workspace workspace_cpu;
   Parameter path_parameter(N_PREDICTOR, MAX_STEP, MAX_IT, MAX_DELTA_T, \
      MAX_DELTA_T_END, MIN_DELTA_T, ERR_MAX_RES, ERR_MAX_DELTA_X, \
      ERR_MAX_FIRST_DELTA_X, ERR_MIN_ROUND_OFF, MAX_IT_REFINE, \
      ERR_MIN_ROUND_OFF_REFINE, STEP_INCREASE, STEP_DECREASE);
  
   if(verbose > 0)
   {
      cout << "The first solution on input :" << endl;
      for(int k=0; k<p.dim; k++)
      {
         cout << k << " :";
         cout << setw(24) << scientific << setprecision(16) << sol[k];
      }
   }

   alpha = CT(regamma,imgamma);
   cpu_inst_hom.init(p,q,p.dim,p.n_eq,1,alpha,verbose);
   cpu_inst_hom.init_workspace(workspace_cpu);

   t = CT(0.0,0);
   workspace_cpu.init_x_t_idx();
   workspace_cpu.update_x_t_value(sol,t);
   workspace_cpu.update_x_t_idx();
   tpred = 0.0; teval = 0.0; tmgs = 0.0;
   if(verbose > 0) cout << "calling path_tracker ..." << endl;
   success = path_tracker(workspace_cpu,cpu_inst_hom,path_parameter,
                          tpred,teval,tmgs,0,verbose);
   if(verbose > 0) cout << "done with call to path_tracker." << endl;
   if(verbose > 0)
   {
      cout.precision(16);
      cout << "The first solution after CPU path tracker :" << endl;
      for(int k=0; k<p.dim; k++)
         cout << k << " :" << setw(24) << workspace_cpu.x_last[k];
   }

   s.change_sol(0,workspace_cpu.x_last);

   return 0;
}
