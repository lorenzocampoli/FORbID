!< Test FORbID with the integration of tangent function.
program integrate_tan
!-----------------------------------------------------------------------------------------------------------------------------------
!< Test FORbID with the integration of tangent function.
!-----------------------------------------------------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------------------------------------------------
use FORbID_kinds, only : R_P
use type_tan, only : tanf
use FORbID, only : trapezoidal_integrator
!-----------------------------------------------------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------------------------------------------------
implicit none
real(R_P), parameter         :: pi=4._R_P * atan(1._R_P)
type(tanf)                   :: tan_field
type(trapezoidal_integrator) :: integrator
real(R_P)                    :: integral
real(R_P)                    :: delta
integer, parameter           :: Ni=100
integer                      :: i
!-----------------------------------------------------------------------------------------------------------------------------------

!-----------------------------------------------------------------------------------------------------------------------------------
call tan_field%init(w=1._R_P)
integral = 0._R_P
delta = pi/Ni
do i=1, Ni
  integral = integral + integrator%integrate(f=tan_field, a=(i-1)*delta, b=i*delta)
enddo
print*, integral
stop
!-----------------------------------------------------------------------------------------------------------------------------------
endprogram integrate_tan
