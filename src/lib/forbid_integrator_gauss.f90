!< FORbID integrator: provide the Gaussian quadrature formulas.
module FORbID_integrator_gauss
!-----------------------------------------------------------------------------------------------------------------------------------
!< FORbID integrator: provide the Gaussian quadrature formulas.
!<
!< Considering the following problem:
!<
!< $$ \int_a^b f(x) = ? $$
!<
!< where \(f(x)\), a generic integrand function, the problem is to perform its definite integral.
!< The n-point Gaussian quadrature rule is a quadrature rule constructed to yield an exact result for polynomials of degree 2n-1 or
!< less by a suitable choiche of the points $x_i$ and weights $w_i$, for i=1,...,n. The domain of integration for such a rule is
!< conventionally taken as [-1,1], so the rule is stated as
!<
!< $$ \int_{-1}^1 f(x) dx = \sum_{i=1}^n w_i f \left( x_i \right) $$
!< If the integrated function can be written as
!< $$ f(x) = \omega(x) g(x) $$
!< where \( g(x)$ \) is approximately polinomial and $\omega(x)$ is known, then the alternative weights \( w'_i \) and points $x'_i$ that
!< depend on the weighting function \( \omega(x) \) may give better results, where
!< $$ \int_{-1}^1 f(x) dx = \int_{-1}^1 \omega(x) g(x) dx \simeq \sum_{i=1}^n w'_i g(x'_i) $$
!< The integral over [a,b] can be changed into an integral over [-1,1] in the following way:
!< $$ \int_a^b f(x) dx = \frac{b-a}{2} \int_{-1}^1 f \left( \frac{b-a}{2}x + \frac{a+b}{2} \right) dx $$
!< As weighting functions there are:
!<
!<##### \( \omega = 1 \): Gauss-Legendre quadrature
!< + One point
!<    * \( x_i = 0 \)
!<    * \( w_i = 2 \)
!< + Two points
!<    * \( x_i =  \pm \sqrt{\frac{1}{3}} \)
!<    * \( w_i = 1 \)
!< + Three points
!<    * \( x_i =  0, \pm \sqrt{\frac{3}{5}} \)
!<    * \( w_i = \frac{8}{9}, \frac{5}{9} \)
!< + Four points
!<    * \( x_i = \pm \sqrt{\frac{3}{7} - \frac{2}{7}\sqrt{\frac{6}{5}}}, \pm \sqrt{\frac{3}{7} + \frac{2}{7}\sqrt{\frac{6}{5}}} \)
!<    * \( w_i = \frac{18 + \sqrt{30}}{36}, \frac{18 - \sqrt{30}}{36} \)
!< + Five points
!<    * \( x_i = 0, \pm \frac{1}{3} \sqrt{5 - 2\frac{10}{7}}, \pm \frac{1}{3} \sqrt{5 + 2\frac{10}{7}} \)
!<    * \( w_i = \frac{128}{225}, \frac{322 + 13\sqrt{70}}{900}, \frac{322 - 13\sqrt{70}}{900} \)
!< + Six points
!<    * \( x_i = \pm 0.2386191860831969, \pm 0.6612093864662645, \pm 0.9324695142031521 \)
!<    * \( w_i = 0.4679139345726910, 0.3607615730481386, 0.1713244923791704 \)
!< + Seven points
!<    * \( x_i = 0, \pm 0.4058451513773972, \pm 0.7415311855993945, \pm 0.9491079123427585 \)
!<    * \( w_i = 0.4179591836734694, 0.3818300505051189, 0.2797053914892766, 0.1294849661688697 \)
!< + Eight points
!<    * \( x_i = \pm 0.1834346424956498, \pm 0.5255324099163290, \pm 0.7966664774136267, \pm 0.9602898564975363 \)
!<    * \( w_i = 0.3626837833783620, 0.3137066458778873, 0.2223810344533745, 0.1012285362903763 \)
!< + Nine points
!<    * \( x_i = 0, \pm 0.3242534234038089, \pm 0.6133714327005904, \pm 0.8360311073266358, \pm 0.9681602395076261 \)
!<    * \( w_i = 0.3302393550012598, 0.3123470770400029, 0.2606106964029354, 0.1806481606948574, 0.0812743883615744 \)
!< + Ten points
!<    * \( x_i = \pm 0.1488743389816312, \pm 0.4333953941292472, \pm 0.6794095682990244, \pm 0.8650633666889845, \pm 0.9739065285171717 \)
!<    * \( w_i = 0.2955242247147529, 0.2692667193099963, 0.2190863625159820, 0.1494513491505806, 0.0666713443086881 \)
!< + Eleven points
!<    * \( x_i = 0, \pm 0.2695431559523450, \pm 0.5190961292068118, \pm 0.7301520055740494, \pm 0.8870625997680953, \pm 0.9782286581460570 \)
!<    * \( w_i = 0.2729250867779006, 0.2628045445102467, 0.2331937645919905, 0.1862902109277343, 0.1255803694649046, 0.0556685671161737 \)
!<
!-----------------------------------------------------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------------------------------------------------
use FORbID_kinds, only : R_P, I_P
use FORbID_adt_integrand, only : integrand
!-----------------------------------------------------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------------------------------------------------
implicit none
private
public :: gauss_integrator
!-----------------------------------------------------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------------------------------------------------
type :: gauss_integrator
  !< FORbID integrator: provide the Gaussian quadrature.
  !<
  !< @note The integrator must be initialized (initialize the coefficient and the weights) before used.
  character(3), allocatable :: q        !< Quadrature index: KRO -> Kronrod quad., LEG -> Legendre quad., CHE -> Chebyshev quad.
  integer(I_P)              :: n        !< Number of points of the quadrature.
  real(R_P), allocatable    :: w(:)     !< Integration weights.
  real(R_P), allocatable    :: x(:)     !< Integration nodes.
  contains
    procedure, pass(self), public :: init      !< Initialize the integrator.
    procedure, nopass,     public :: integrate !< Integrate integrand function.
endtype gauss_integrator
!-----------------------------------------------------------------------------------------------------------------------------------
contains
  elemental subroutine init(self, q, n)
  !---------------------------------------------------------------------------------------------------------------------------------
  !< Create the Gaussian quadrature: initialize the weights and the roots
  !---------------------------------------------------------------------------------------------------------------------------------
  class(gauss_integrator), intent(INOUT) :: self   !< Gaussian integrator.
  character(*),            intent(IN)    :: q      !< Quadrature index.
  integer(I_P),            intent(IN)    :: n      !< Number of integration nodes.
  real(R_P),               parameter     :: pi=4._R_P * atan(1._R_P)
  self%q = q
  self%n = n
  select case(q)
  case('LEG')
    if (allocated(self%w)) deallocate(self%w); allocate(self%w(1:n)); self%w = 0._R_P
    if (allocated(self%x)) deallocate(self%x); allocate(self%x(1:n)); self%x = 0._R_P
    select case(n)
    case(1)
      self%x(1) =  0._R_P;                   self%w(1) = 2._R_P
    case(2)
      self%x(1) = -0.5773502691896257_R_P;   self%w(1) = 1._R_P
      self%x(2) =  0.5773502691896257_R_P;   self%w(2) = 1._R_P
    case(3)
      self%x(1) =  0._R_P;                   self%w(1) = 0.8888888888888889_R_P
      self%x(2) = -0.7745966692414834_R_P;   self%w(2) = 0.5555555555555556_R_P
      self%x(3) =  0.7745966692414834_R_P;   self%w(3) = 0.5555555555555556_R_P
    case(4)
      self%x(1) = -0.3399810435848563_R_P;   self%w(1) = 0.6521451548625461_R_P
      self%x(2) =  0.3399810435848563_R_P;   self%w(2) = 0.6521451548625461_R_P
      self%x(3) = -0.8611363115940526_R_P;   self%w(3) = 0.3478548451374538_R_P
      self%x(4) =  0.8611363115940526_R_P;   self%w(4) = 0.3478548451374538_R_P
    case(5)
      self%x(1) =  0._R_P;                   self%w(1) = 0.5688888888888889_R_P
      self%x(2) = -0.5384693101056831_R_P;   self%w(2) = 0.4786286704993665_R_P
      self%x(3) =  0.5384693101056831_R_P;   self%w(3) = 0.4786286704993665_R_P
      self%x(4) = -0.9061798459386640_R_P;   self%w(4) = 0.2369268850561891_R_P
      self%x(5) =  0.9061798459386640_R_P;   self%w(5) = 0.2369268850561891_R_P
    case(6)
      self%x(1) = -0.2386191860831969_R_P;   self%w(1) = 0.4679139345726910_R_P
      self%x(2) =  0.2386191860831969_R_P;   self%w(2) = 0.4679139345726910_R_P
      self%x(3) = -0.6612093864662645_R_P;   self%w(3) = 0.3607615730481386_R_P
      self%x(4) =  0.6612093864662645_R_P;   self%w(4) = 0.3607615730481386_R_P
      self%x(5) = -0.9324695142031521_R_P;   self%w(5) = 0.1713244923791704_R_P
      self%x(6) =  0.9324695142031521_R_P;   self%w(6) = 0.1713244923791704_R_P
    case(7)
      self%x(1) =  0._R_P;                   self%w(1) = 0.4179591836734694_R_P
      self%x(2) = -0.4058451513773972_R_P;   self%w(2) = 0.3818300505051189_R_P
      self%x(3) =  0.4058451513773972_R_P;   self%w(3) = 0.3818300505051189_R_P
      self%x(4) = -0.7415311855993945_R_P;   self%w(4) = 0.2797053914892766_R_P
      self%x(5) =  0.7415311855993945_R_P;   self%w(5) = 0.2797053914892766_R_P
      self%x(6) = -0.9491079123427585_R_P;   self%w(6) = 0.1294849661688697_R_P
      self%x(7) =  0.9491079123427585_R_P;   self%w(7) = 0.1294849661688697_R_P
    case(8)
      self%x(1) = -0.1834346424956498_R_P;   self%w(1) = 0.3626837833783620_R_P
      self%x(2) =  0.1834346424956498_R_P;   self%w(2) = 0.3626837833783620_R_P
      self%x(3) = -0.5255324099163290_R_P;   self%w(3) = 0.3137066458778873_R_P
      self%x(4) =  0.5255324099163290_R_P;   self%w(4) = 0.3137066458778873_R_P
      self%x(5) = -0.7966664774136267_R_P;   self%w(5) = 0.2223810344533745_R_P
      self%x(6) =  0.7966664774136267_R_P;   self%w(6) = 0.2223810344533745_R_P
      self%x(7) = -0.9602898564975363_R_P;   self%w(7) = 0.1012285362903763_R_P
      self%x(8) =  0.9602898564975363_R_P;   self%w(8) = 0.1012285362903763_R_P
    case(9)
      self%x(1) =  0._R_P;                   self%w(1) = 0.3302393550012598_R_P
      self%x(2) = -0.3242534234038089_R_P;   self%w(2) = 0.3123470770400029_R_P
      self%x(3) =  0.3242534234038089_R_P;   self%w(3) = 0.3123470770400029_R_P
      self%x(4) = -0.6133714327005904_R_P;   self%w(4) = 0.2606106964029354_R_P
      self%x(5) =  0.6133714327005904_R_P;   self%w(5) = 0.2606106964029354_R_P
      self%x(6) = -0.8360311073266358_R_P;   self%w(6) = 0.1806481606948574_R_P
      self%x(7) =  0.8360311073266358_R_P;   self%w(7) = 0.1806481606948574_R_P
      self%x(8) = -0.9681602395076261_R_P;   self%w(8) = 0.0812743883615744_R_P
      self%x(9) =  0.9681602395076261_R_P;   self%w(9) = 0.0812743883615744_R_P
    case(10)
      self%x(1 ) = -0.1488743389816312_R_P;  self%w(1 ) = 0.2955242247147529_R_P
      self%x(2 ) =  0.1488743389816312_R_P;  self%w(2 ) = 0.2955242247147529_R_P
      self%x(3 ) = -0.4333953941292472_R_P;  self%w(3 ) = 0.2692667193099963_R_P
      self%x(4 ) =  0.4333953941292472_R_P;  self%w(4 ) = 0.2692667193099963_R_P
      self%x(5 ) = -0.6794095682990244_R_P;  self%w(5 ) = 0.2190863625159820_R_P
      self%x(6 ) =  0.6794095682990244_R_P;  self%w(6 ) = 0.2190863625159820_R_P
      self%x(7 ) = -0.8650633666889845_R_P;  self%w(7 ) = 0.1494513491505806_R_P
      self%x(8 ) =  0.8650633666889845_R_P;  self%w(8 ) = 0.1494513491505806_R_P
      self%x(9 ) = -0.9739065285171717_R_P;  self%w(9 ) = 0.0666713443086881_R_P
      self%x(10) =  0.9739065285171717_R_P;  self%w(10) = 0.0666713443086881_R_P
    case(11)
      self%x(1 ) =  0._R_P;                  self%w(1 ) = 0.2729250867779006_R_P
      self%x(2 ) = -0.2695431559523450_R_P;  self%w(2 ) = 0.2628045445102467_R_P
      self%x(3 ) =  0.2695431559523450_R_P;  self%w(3 ) = 0.2628045445102467_R_P
      self%x(4 ) = -0.5190961292068118_R_P;  self%w(4 ) = 0.2331937645919905_R_P
      self%x(5 ) =  0.5190961292068118_R_P;  self%w(5 ) = 0.2331937645919905_R_P
      self%x(6 ) = -0.7301520055740494_R_P;  self%w(6 ) = 0.1862902109277343_R_P
      self%x(7 ) =  0.7301520055740494_R_P;  self%w(7 ) = 0.1862902109277343_R_P
      self%x(8 ) = -0.8870625997680953_R_P;  self%w(8 ) = 0.1255803694649046_R_P
      self%x(9 ) =  0.8870625997680953_R_P;  self%w(9 ) = 0.1255803694649046_R_P
      self%x(10) = -0.9782286581460570_R_P;  self%w(10) = 0.0556685671161737_R_P
      self%x(11) =  0.9782286581460570_R_P;  self%w(11) = 0.0556685671161737_R_P
    endselect
  case('KRO')
    if (allocated(self%w)) deallocate(self%w); allocate(self%w(1:2*n+1)); self%w = 0._R_P
    if (allocated(self%x)) deallocate(self%x); allocate(self%x(1:2*n+1)); self%x = 0._R_P
    select case(n)
    case(1)
      self%x(1) =  0._R_P;                   self%w(1) = 0.8888888888888889_R_P
      self%x(2) = -0.7745966692414834_R_P;   self%w(2) = 0.5555555555555556_R_P
      self%x(3) =  0.7745966692414834_R_P;   self%w(3) = 0.5555555555555556_R_P
    case(2)
      self%x(3) =  0._R_P;                   self%w(3) = 0.6222222222222222_R_P
      self%x(1) = -0.5773502691896257_R_P;   self%w(1) = 0.4909090909090909_R_P
      self%x(2) =  0.5773502691896257_R_P;   self%w(2) = 0.4909090909090909_R_P
      self%x(4) = -0.9258200997725515_R_P;   self%w(4) = 0.1979797979797979_R_P
      self%x(5) =  0.9258200997725515_R_P;   self%w(5) = 0.1979797979797979_R_P
    case(3)
      self%x(1) =  0._R_P;                   self%w(1) = 0.4509165386584741_R_P
      self%x(2) = -0.4342437493468026_R_P;   self%w(2) = 0.4013974147759622_R_P
      self%x(3) =  0.4342437493468026_R_P;   self%w(3) = 0.4013974147759622_R_P
      self%x(4) = -0.7745966692414834_R_P;   self%w(4) = 0.2684880898683334_R_P
      self%x(5) =  0.7745966692414834_R_P;   self%w(5) = 0.2684880898683334_R_P
      self%x(6) = -0.9604912687080203_R_P;   self%w(6) = 0.1046562260264673_R_P
      self%x(7) =  0.9604912687080203_R_P;   self%w(7) = 0.1046562260264673_R_P
    case(4)
      self%x(1) =  0._R_P;                   self%w(1) = 0.3464429818901364_R_P
      self%x(2) = -0.3399810435848563_R_P;   self%w(2) = 0.3269491896014516_R_P
      self%x(3) =  0.3399810435848563_R_P;   self%w(3) = 0.3269491896014516_R_P
      self%x(4) = -0.6402862174963000_R_P;   self%w(4) = 0.2667983404522844_R_P
      self%x(5) =  0.6402862174963000_R_P;   self%w(5) = 0.2667983404522844_R_P
      self%x(6) = -0.8611363115940526_R_P;   self%w(6) = 0.1700536053357227_R_P
      self%x(7) =  0.8611363115940526_R_P;   self%w(7) = 0.1700536053357227_R_P
      self%x(8) = -0.9765602507375731_R_P;   self%w(8) = 0.0629773736654730_R_P
      self%x(9) = -0.9765602507375731_R_P;   self%w(9) = 0.0629773736654730_R_P
    case(5)
      self%x(1 ) =  0._R_P;                  self%w(1 ) = 0.2829874178574912_R_P
      self%x(2 ) = -0.2796304131617832_R_P;  self%w(2 ) = 0.2728498019125589_R_P
      self%x(3 ) =  0.2796304131617832_R_P;  self%w(3 ) = 0.2728498019125589_R_P
      self%x(4 ) = -0.5384693101056831_R_P;  self%w(4 ) = 0.2410403392286476_R_P
      self%x(5 ) =  0.5384693101056831_R_P;  self%w(5 ) = 0.2410403392286476_R_P
      self%x(6 ) = -0.7541667265708492_R_P;  self%w(6 ) = 0.1868007965564926_R_P
      self%x(7 ) =  0.7541667265708492_R_P;  self%w(7 ) = 0.1868007965564926_R_P
      self%x(8 ) = -0.9061798459386640_R_P;  self%w(8 ) = 0.1152333166224734_R_P
      self%x(9 ) =  0.9061798459386640_R_P;  self%w(9 ) = 0.1152333166224734_R_P
      self%x(10) = -0.9840853600948425_R_P;  self%w(10) = 0.0425820367510818_R_P
      self%x(11) =  0.9840853600948425_R_P;  self%w(11) = 0.0425820367510818_R_P
    case(6)
      self%x(1 ) =  0._R_P;                  self%w(1 ) = 0.2410725801734648_R_P
      self%x(2 ) = -0.2386191860831969_R_P;  self%w(2 ) = 0.2337708641169944_R_P
      self%x(3 ) =  0.2386191860831969_R_P;  self%w(3 ) = 0.2337708641169944_R_P
      self%x(4 ) = -0.4631182124753046_R_P;  self%w(4 ) = 0.2132096522719622_R_P
      self%x(5 ) =  0.4631182124753046_R_P;  self%w(5 ) = 0.2132096522719622_R_P
      self%x(6 ) = -0.6612093864662645_R_P;  self%w(6 ) = 0.1810719943231376_R_P
      self%x(7 ) =  0.6612093864662645_R_P;  self%w(7 ) = 0.1810719943231376_R_P
      self%x(8 ) = -0.8213733408650279_R_P;  self%w(8 ) = 0.1373206046344469_R_P
      self%x(9 ) =  0.8213733408650279_R_P;  self%w(9 ) = 0.1373206046344469_R_P
      self%x(10) = -0.9324695142031521_R_P;  self%w(10) = 0.0836944404469066_R_P
      self%x(11) =  0.9324695142031521_R_P;  self%w(11) = 0.0836944404469066_R_P
      self%x(12) = -0.9887032026126789_R_P;  self%w(12) = 0.0303961541198198_R_P
      self%x(13) =  0.9887032026126789_R_P;  self%w(13) = 0.0303961541198198_R_P
    case(7)
      self%x(1 ) =  0._R_P;                  self%w(1 ) = 0.2094821410847278_R_P
      self%x(2 ) = -0.2077849550078985_R_P;  self%w(2 ) = 0.2044329400752989_R_P
      self%x(3 ) =  0.2077849550078985_R_P;  self%w(3 ) = 0.2044329400752989_R_P
      self%x(4 ) = -0.4058451513773972_R_P;  self%w(4 ) = 0.1903505780647854_R_P
      self%x(5 ) =  0.4058451513773972_R_P;  self%w(5 ) = 0.1903505780647854_R_P
      self%x(6 ) = -0.5860872354676911_R_P;  self%w(6 ) = 0.1690047266392679_R_P
      self%x(7 ) =  0.5860872354676911_R_P;  self%w(7 ) = 0.1690047266392679_R_P
      self%x(8 ) = -0.7415311855993945_R_P;  self%w(8 ) = 0.1406532597155259_R_P
      self%x(9 ) =  0.7415311855993945_R_P;  self%w(9 ) = 0.1406532597155259_R_P
      self%x(10) = -0.8648644233597691_R_P;  self%w(10) = 0.1047900103222502_R_P
      self%x(11) =  0.8648644233597691_R_P;  self%w(11) = 0.1047900103222502_R_P
      self%x(12) = -0.9491079123427585_R_P;  self%w(12) = 0.0630920926299786_R_P
      self%x(13) =  0.9491079123427585_R_P;  self%w(13) = 0.0630920926299786_R_P
      self%x(14) = -0.9914553711208126_R_P;  self%w(14) = 0.0229353220105292_R_P
      self%x(15) =  0.9914553711208126_R_P;  self%w(15) = 0.0229353220105292_R_P
    case(8)
      self%x(1 ) =  0._R_P;                  self%w(1 ) = 0.1844464057446916_R_P
      self%x(2 ) = -0.1834346424956498_R_P;  self%w(2 ) = 0.1814000250680346_R_P
      self%x(3 ) =  0.1834346424956498_R_P;  self%w(3 ) = 0.1814000250680346_R_P
      self%x(4 ) = -0.3607010979281320_R_P;  self%w(4 ) = 0.1720706085552113_R_P
      self%x(5 ) =  0.3607010979281320_R_P;  self%w(5 ) = 0.1720706085552113_R_P
      self%x(6 ) = -0.5255324099163290_R_P;  self%w(6 ) = 0.1566526061681884_R_P
      self%x(7 ) =  0.5255324099163290_R_P;  self%w(7 ) = 0.1566526061681884_R_P
      self%x(8 ) = -0.6723540709451587_R_P;  self%w(8 ) = 0.1362631092551722_R_P
      self%x(9 ) =  0.6723540709451587_R_P;  self%w(9 ) = 0.1362631092551722_R_P
      self%x(10) = -0.7966664774136267_R_P;  self%w(10) = 0.1116463708268396_R_P
      self%x(11) =  0.7966664774136267_R_P;  self%w(11) = 0.1116463708268396_R_P
      self%x(12) = -0.8941209068474564_R_P;  self%w(12) = 0.0824822989313583_R_P
      self%x(13) =  0.8941209068474564_R_P;  self%w(13) = 0.0824822989313583_R_P
      self%x(14) = -0.9602898564975363_R_P;  self%w(14) = 0.0494393950021393_R_P
      self%x(15) =  0.9602898564975363_R_P;  self%w(15) = 0.0494393950021393_R_P
      self%x(16) = -0.9933798758817162_R_P;  self%w(16) = 0.0178223833207104_R_P
      self%x(17) =  0.9933798758817162_R_P;  self%w(17) = 0.0178223833207104_R_P
    case(9)
      self%x(1 ) =  0._R_P;                  self%w(1 ) = 0.1648960128283494_R_P
      self%x(2 ) = -0.1642235636149868_R_P;  self%w(2 ) = 0.1628628274401151_R_P
      self%x(3 ) =  0.1642235636149868_R_P;  self%w(3 ) = 0.1628628274401151_R_P
      self%x(4 ) = -0.3242534234038089_R_P;  self%w(4 ) = 0.1564135277884839_R_P
      self%x(5 ) =  0.3242534234038089_R_P;  self%w(5 ) = 0.1564135277884839_R_P
      self%x(6 ) = -0.4754624791124599_R_P;  self%w(6 ) = 0.1452395883843662_R_P
      self%x(7 ) =  0.4754624791124599_R_P;  self%w(7 ) = 0.1452395883843662_R_P
      self%x(8 ) = -0.6133714327005904_R_P;  self%w(8 ) = 0.1300014068553412_R_P
      self%x(9 ) =  0.6133714327005904_R_P;  self%w(9 ) = 0.1300014068553412_R_P
      self%x(10) = -0.7344867651839338_R_P;  self%w(10) = 0.1117891346844183_R_P
      self%x(11) =  0.7344867651839338_R_P;  self%w(11) = 0.1117891346844183_R_P
      self%x(12) = -0.8360311073266358_R_P;  self%w(12) = 0.0907906816887264_R_P
      self%x(13) =  0.8360311073266358_R_P;  self%w(13) = 0.0907906816887264_R_P
      self%x(14) = -0.9149635072496779_R_P;  self%w(14) = 0.0665181559402741_R_P
      self%x(15) =  0.9149635072496779_R_P;  self%w(15) = 0.0665181559402741_R_P
      self%x(16) = -0.9681602395076261_R_P;  self%w(16) = 0.0396318951602613_R_P
      self%x(17) =  0.9681602395076261_R_P;  self%w(17) = 0.0396318951602613_R_P
      self%x(18) = -0.9946781606773402_R_P;  self%w(18) = 0.0143047756438389_R_P
      self%x(19) =  0.9946781606773402_R_P;  self%w(19) = 0.0143047756438389_R_P
    case(10)
      self%x(1 ) =  0._R_P;                  self%w(1 ) = 0.1494455540029169_R_P
      self%x(2 ) = -0.1488743389816312_R_P;  self%w(2 ) = 0.1477391049013385_R_P
      self%x(3 ) =  0.1488743389816312_R_P;  self%w(3 ) = 0.1477391049013385_R_P
      self%x(4 ) = -0.2943928627014602_R_P;  self%w(4 ) = 0.1427759385770601_R_P
      self%x(5 ) =  0.2943928627014602_R_P;  self%w(5 ) = 0.1427759385770601_R_P
      self%x(6 ) = -0.4333953941292472_R_P;  self%w(6 ) = 0.1347092173114733_R_P
      self%x(7 ) =  0.4333953941292472_R_P;  self%w(7 ) = 0.1347092173114733_R_P
      self%x(8 ) = -0.5627571346686047_R_P;  self%w(8 ) = 0.1234919762620658_R_P
      self%x(9 ) =  0.5627571346686047_R_P;  self%w(9 ) = 0.1234919762620658_R_P
      self%x(10) = -0.6794095682990244_R_P;  self%w(10) = 0.1093871588022976_R_P
      self%x(11) =  0.6794095682990244_R_P;  self%w(11) = 0.1093871588022976_R_P
      self%x(12) = -0.7808177265864169_R_P;  self%w(12) = 0.0931254545836976_R_P
      self%x(13) =  0.7808177265864169_R_P;  self%w(13) = 0.0931254545836976_R_P
      self%x(14) = -0.8650633666889845_R_P;  self%w(14) = 0.0750396748109199_R_P
      self%x(15) =  0.8650633666889845_R_P;  self%w(15) = 0.0750396748109199_R_P
      self%x(16) = -0.9301574913557082_R_P;  self%w(16) = 0.0547558965743520_R_P
      self%x(17) =  0.9301574913557082_R_P;  self%w(17) = 0.0547558965743520_R_P
      self%x(18) = -0.9739065285171717_R_P;  self%w(18) = 0.0325581623079647_R_P
      self%x(19) =  0.9739065285171717_R_P;  self%w(19) = 0.0325581623079647_R_P
      self%x(20) = -0.9956571630258081_R_P;  self%w(20) = 0.0116946388673719_R_P
      self%x(21) =  0.9956571630258081_R_P;  self%w(21) = 0.0116946388673719_R_P
    case(11)
      self%x(1 ) =  0._R_P;                  self%w(1 ) =  0.1365777947111183_R_P
      self%x(2 ) = -0.1361130007993618_R_P;  self%w(2 ) =  0.1351935727998845_R_P
      self%x(3 ) =  0.1361130007993618_R_P;  self%w(3 ) =  0.1351935727998845_R_P
      self%x(4 ) = -0.2695431559523450_R_P;  self%w(4 ) =  0.1312806842298056_R_P
      self%x(5 ) =  0.2695431559523450_R_P;  self%w(5 ) =  0.1312806842298056_R_P
      self%x(6 ) = -0.3979441409523776_R_P;  self%w(6 ) =  0.1251587991003195_R_P
      self%x(7 ) =  0.3979441409523776_R_P;  self%w(7 ) =  0.1251587991003195_R_P
      self%x(8 ) = -0.5190961292068118_R_P;  self%w(8 ) =  0.1167395024610473_R_P
      self%x(9 ) =  0.5190961292068118_R_P;  self%w(9 ) =  0.1167395024610473_R_P
      self%x(10) = -0.6305995201619651_R_P;  self%w(10) =  0.1058720744813894_R_P
      self%x(11) =  0.6305995201619651_R_P;  self%w(11) =  0.1058720744813894_R_P
      self%x(12) = -0.7301520055740494_R_P;  self%w(12) =  0.0929530985969008_R_P
      self%x(13) =  0.7301520055740494_R_P;  self%w(13) =  0.0929530985969008_R_P
      self%x(14) = -0.8160574566562209_R_P;  self%w(14) =  0.0786645719322273_R_P
      self%x(15) =  0.8160574566562209_R_P;  self%w(15) =  0.0786645719322273_R_P
      self%x(16) = -0.8870625997680953_R_P;  self%w(16) =  0.0630974247503749_R_P
      self%x(17) =  0.8870625997680953_R_P;  self%w(17) =  0.0630974247503749_R_P
      self%x(18) = -0.9416771085780680_R_P;  self%w(18) =  0.0458293785644264_R_P
      self%x(19) =  0.9416771085780680_R_P;  self%w(19) =  0.0458293785644264_R_P
      self%x(20) = -0.9782286581460570_R_P;  self%w(20) =  0.0271565546821043_R_P
      self%x(21) =  0.9782286581460570_R_P;  self%w(21) =  0.0271565546821043_R_P
      self%x(22) = -0.9963696138895426_R_P;  self%w(22) =  0.0097654410459608_R_P
      self%x(23) =  0.9963696138895426_R_P;  self%w(23) =  0.0097654410459608_R_P
    endselect
  case('CHE')
    if (allocated(self%w)) deallocate(self%w); allocate(self%w(1:n)); self%w = 0._R_P
    if (allocated(self%x)) deallocate(self%x); allocate(self%x(1:n)); self%x = 0._R_P
    do i=1,n
      self%x(i) = cos((2._R_P*i - 1._R_P)/(2._R_P*n)*pi)
      self%w(i) = (pi / n) * sqrt(1._R_P - (self%x(i))**2._R_P)
    enddo
  endselect
  endsubroutine init

  function integrate(self, f, a, b) result(integral)
  !---------------------------------------------------------------------------------------------------------------------------------
  !< Integrate function *f* with one of the Gauss quadrature chosed.
  !---------------------------------------------------------------------------------------------------------------------------------
  class(gauss_integrator), intent(IN) :: self     !< Actual Gaussian integrator.
  class(integrand),        intent(IN) :: f        !< Function to be integrated.
  real(R_P),               intent(IN) :: a        !< Lower bound.
  real(R_P),               intent(IN) :: b        !< Upper bound.
  real(R_P)                           :: integral !< Definite integral value.
  integer(I_P)                        :: i        !< Integration index.
  !---------------------------------------------------------------------------------------------------------------------------------

  !---------------------------------------------------------------------------------------------------------------------------------
  integral = 0._R_P
  do i=1,self%n
    integral = integral + self%w(i) * f%f(self%x(i)*(b-a)/2._R_P + (a+b)/2._R_P)
  enddo
  integral = integral * (b - a) / 2.0_R_P
  return
  !---------------------------------------------------------------------------------------------------------------------------------
  endfunction integrate
endmodule FORbID_integrator_gauss
