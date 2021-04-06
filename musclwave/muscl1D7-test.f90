module comvar
  implicit none
  !integer, parameter :: ndx=258,laststep=20000,ist=1,ien=2,svnum=200 !preiodic:ist=1,ien=2 , kotei:ist=2,ien=3 : ndx=130
  !integer, parameter :: ndx=130,laststep=10000,ist=1,ien=2,svnum=100 !preiodic:ist=1,ien=2 , kotei:ist=2,ien=3 : ndx=130
  !integer, parameter :: ndx=66,laststep=5000,ist=1,ien=2,svnum=50 !preiodic:ist=1,ien=2 , kotei:ist=2,ien=3 : ndx=130
  integer, parameter :: ndx=514,laststep=40000,ist=1,ien=2,svnum=400 !preiodic:ist=1,ien=2 , kotei:ist=2,ien=3 : ndx=130
  !double precision, parameter :: Lbox=1.0d2 , h=10.0d0 , hcen=50.0d0 , dinit1=1.29988444d0,w1=2.0d0
  DOUBLE PRECISION :: cg = 1.0d1 , dx != Lbox/dble(ndx-2) !, bcphi1 , bcphi2
  double precision :: Lbox=1.0d2 , h=10.0d0 , hcen=50.0d0 , dinit1=1.29988444d0,w1=2.0d0,p2dxdx,tint=0.d0,amp = 1.d-3
  !double precision :: G=1.11142d-4, G4pi=12.56637d0*G , coeff=0.90d0 ,  kappa=1.0d0/3.0d0
  double precision ::  G4pi=12.56637d0*1.11142d-4 , coeff=0.1d0,pi=3.1415926535d0 !,  kappa=1.0d0/3.0d0
  DOUBLE PRECISION , dimension(1:3) :: bcphi1 , bcphi2 ,bcphigrd1 , bcphigrd2
  character(70) :: dir='/Users/maeda/Desktop/Dropbox/analysis/telegraph-test-1D-1/2th/mesh512/'
end module comvar

module grvvar
  implicit none
  !integer, parameter :: ndx2=258 !パラメータ属性必要
  !integer, parameter :: ndx2=130
  !integer, parameter :: ndx2=66
  integer, parameter :: ndx2=514
  DOUBLE PRECISION , dimension(-1:ndx2) :: x , Phicgm ,rho, Phi1step , Phi2step ,Phicgp
  DOUBLE PRECISION , dimension(-1:ndx2) :: Phidt,Phigrd,Phiexa,Phi
end module grvvar

program muscl1D
  !implicit none まちがった位置
  use comvar
  use grvvar
  implicit none
  DOUBLE PRECISION :: dt=0.0d0
  integer :: i,sv=0,iws,ws=2


  call INITIAL()
  call BC(1)
  !call muslcslv1D(Phi,Phi1step,dt,13)

  do i=1,laststep
     call time(dt)
     write(*,*) i ,'step',dt

     if(mod(i,svnum)==0) then
        call saveu(sv)
     end if
     call BC(1)
     call muslcslv1D(Phicgp,Phi1step,dt,1)
     call muslcslv1D(Phicgm,Phi2step,dt,2)
     tint=tint+dt

  end do
!  call BC(3)
!  call BC(4)
!  call BC(1)
  call saveu(sv)
end program muscl1D


subroutine INITIAL()
  use comvar
  use grvvar
  integer :: i
  !double precision :: amp,pi=3.1415926535d0,haba

  dinit1 = 2.0d0/G4pi/90.d0

  !----------x--------------
  dx = Lbox/dble(ndx-2)
  x(1) = dx/2.0d0
  x(0) = x(1) - dx
  x(-1) = x(0) - dx
  do i=2,ndx
     x(i) = x(i-1) + dx
  end do
  !----------x--------------


  !---------Phi-------------
  Phicgp(:)=0.0d0
  Phicgm(:)=0.0d0
  Phi(:)=0.0d0
  !---------Phi-------------

  !-------Phi1step-----------
  Phi1step(:)=0.0d0
  Phi2step(:)=0.0d0
  !-------Phi1step-----------

  !-------Phidt-----------
  Phidt(:)=0.0d0
  !-------Phdt-----------




  !---------rho-------------
  do i = -1,ndx
     if( dabs(x(i) - hcen) .le. h) then
        rho(i) = dinit1
        !rho(i) = 0.0d0
     else
        rho(i) = 0.0d0
        !rho(i) = dinit1*1.d-2
     end if
  end do
  rho(:) = dinit1
  !---------rho-------------



  !--------Phiexa-----------
  !goto 200
  open(142,file=dir//'phiexact.DAT')
  open(143,file=dir//'INIden.DAT')
  open(144,file=dir//'phigrd.DAT')
  do i= -1,ndx
     if( dabs(x(i) - hcen) .le. h ) then
        Phiexa(i) = G4pi/2.0d0 * dinit1 * (x(i) - hcen )**2
        write(142,*) sngl(x(i)) ,  sngl(G4pi/2.0d0 * dinit1 * (x(i) - hcen )**2)
     else
        Phiexa(i) = G4pi * dinit1 * h * dabs(x(i) - hcen)  - G4pi/2.0d0 * dinit1 * h**2
        write(142,*) sngl(x(i)) , sngl(G4pi * dinit1 * h * dabs(x(i) - hcen)  - G4pi/2.0d0 * dinit1 * h**2)
     end if
     write(143,*) sngl(rho(i))
  end do

  p2dxdx=G4pi * dinit1 * h * dabs(x(-1)-dx - hcen)  - G4pi/2.0d0 * dinit1 * h**2
  !do i= -1,ndx
  !   if( dabs(x(i) - hcen) .le. h ) then
  !      Phiexa(i) = -G4pi/2.0d0 * dinit1 * (x(i) - hcen )**2
  !      write(142,*) sngl(x(i)) ,  sngl(G4pi/2.0d0 * dinit1 * (x(i) - hcen )**2)
  !   else
  !      Phiexa(i) = -G4pi * dinit1 * h * dabs(x(i) - hcen)  - G4pi/2.0d0 * dinit1 * h**2
  !      write(142,*) sngl(x(i)) , sngl(G4pi * dinit1 * h * dabs(x(i) - hcen)  - G4pi/2.0d0 * dinit1 * h**2)
  !   end if
  !   write(143,*) sngl(rho(i))
  !end do


  !do i=0,ndx-1
  !   Phigrd(i)=(-Phiexa(i-1)+Phiexa(i+1))*0.5d0/dx
     !write(144,*) sngl(x(i)) , Phigrd(i) , Phiexa(i-1),Phiexa(i+1)
  !end do
  !Phigrd(-1)=(-Phiexa(0)+Phiexa(1))/dx
  !Phigrd(ndx)=(Phiexa(ndx-1)-Phiexa(ndx-2))/dx

  do i=0,ndx-1
     Phigrd(i)=-(-Phiexa(i-1)+Phiexa(i+1))*0.5d0/dx
     !write(144,*) sngl(x(i)) , Phigrd(i) , Phiexa(i-1),Phiexa(i+1)
  end do
  Phigrd(-1)=-(-Phiexa(0)+Phiexa(1))/dx
  Phigrd(ndx)=-(Phiexa(ndx-1)-Phiexa(ndx-2))/dx

  do i=-1,ndx
     write(144,*) sngl(x(i)) , Phigrd(i) !, Phiexa(i-1),Phiexa(i+1)
  end do

  bcphi1(1) = G4pi * dinit1 * h * dabs(x(1) - hcen)  - G4pi/2.0d0 * dinit1 * h**2
  bcphi2(1) = G4pi * dinit1 * h * dabs(x(ndx-2) - hcen)  - G4pi/2.0d0 * dinit1 * h**2

  bcphi1(2) = G4pi * dinit1 * h * dabs(x(0) - hcen)  - G4pi/2.0d0 * dinit1 * h**2
  bcphi2(2) = G4pi * dinit1 * h * dabs(x(ndx-1) - hcen)  - G4pi/2.0d0 * dinit1 * h**2

  bcphi1(3) = G4pi * dinit1 * h * dabs(x(-1) - hcen)  - G4pi/2.0d0 * dinit1 * h**2
  bcphi2(3) = G4pi * dinit1 * h * dabs(x(ndx) - hcen)  - G4pi/2.0d0 * dinit1 * h**2
  close(142)
  close(143)
  close(144)
  !200 continue
  !--------Phiexa-----------


  !---------wave--------
  !goto 201
  !do i = -1, ndx
  !   amp = 1.d-3
  !   Phi(i) =  amp*dsin(2.d0*pi*x(i)/Lbox)
  !   Phi1step(i) =  amp*dsin(2.d0*pi*x(i)/Lbox)
  !end do


  do i = -1, ndx
     amp = 1.d-3
     haba=10.0d0
     Phi(i) =  amp*dexp(-(x(i) - 0.5d0*Lbox)**2 /(2.0d0 * haba**2))
     Phidt(i) =  amp*dexp(-(x(i) - 0.5d0*Lbox)**2 /(2.0d0 * haba**2))
     !Phi1step(i) =  amp*dexp(-(x(i) - 0.5d0*Lbox)**2 /(2.0d0 * haba**2))
  end do
  !201 continue
  !---------wave--------


  !-------Phidt------------
  goto 302
  !Phi(1)= bcphi1(1)
  !Phi(0)= bcphi1(2)
  !Phi(-1)= bcphi1(3)
  !Phi(ndx-2)= bcphi2(1)
  !Phi(ndx-1)= bcphi2(2)
  !Phi(ndx)= bcphi2(3)
  302 continue
  !-------Phidt------------

  !--------const------------
  !---------Phi-------------
  Phicgp(:)=bcphi1(1)
  Phicgm(:)=bcphi1(1)
  !---------Phi-------------

  !-------Phidt-----------
  !Phidt(:)=bcphi1(1)
  Phi(:)=bcphi1(1)
  !Phi(:)=0.0d0
  !Phidt(:)=0.0d0
  Phidt(:)=0.0d0
  !-------Phdt-----------


  !-------Phi1step-----------
  !Phi1step(:)=bcphi1
  Phi1step(:)= Phigrd(-1)
  Phi2step(:)= Phigrd(-1)
  !-------Phi1step-----------
  !--------const------------

do i = -1, ndx
   !amp = 1.d-3
   !Phicgp(i) =  amp*dexp(-(x(i) - 0.5d0*Lbox)**2 /(2.0d0 * haba**2))
   Phicgp(i) =  amp*dsin(2.d0*pi*x(i)/Lbox)
   !Phicgm(i) =  amp*dexp(-(x(i) - 0.5d0*Lbox)**2 /(2.0d0 * haba**2))
   Phicgm(i) =  amp*dsin(2.d0*pi*x(i)/Lbox)
   !Phi1step(i) =  amp*dexp(-(x(i) - 0.5d0*Lbox)**2 /(2.0d0 * haba**2))
end do


end subroutine INITIAL



subroutine BC(mode)
  use comvar
  use grvvar
  integer :: i,mode
  double precision , dimension(1:2) :: pl,pr


  if(mode==1) then
     !---------perio-----------
     !---------Phi-------------
!     Phi(0)= Phi(ndx-2)
!     Phi(-1)= Phi(ndx-3)
!     Phi(ndx-1)= Phi(1)
!     Phi(ndx)= Phi(2)
     !---------Phi-------------

     !-------Phi1step-----------
     Phicgp(0)= Phicgp(ndx-2)
     Phicgp(-1)= Phicgp(ndx-3)
     Phicgp(ndx-1)= Phicgp(1)
     Phicgp(ndx)= Phicgp(2)
     Phicgm(0)= Phicgm(ndx-2)
     Phicgm(-1)= Phicgm(ndx-3)
     Phicgm(ndx-1)= Phicgm(1)
     Phicgm(ndx)= Phicgm(2)
     !-------Phi1step-----------
     !---------perio-----------
  end if


end subroutine BC


subroutine time(dt)
  use comvar
  use grvvar
  double precision :: dt
  dt = dx/cg * coeff
  write(*,*) 'time cg' , dt
end subroutine time


subroutine muslcslv1D(Phiv,source,dt,mode)
  use comvar
  double precision :: nu2 , w=6.0d0 , dt2 , dt , deltap,deltam !kappa -> comver  better?
  integer :: direction , mode , invdt , loopmode , dloop,cnt=0
  !DOUBLE PRECISION :: fluxf(-1:ndx,-1:ndy,-1:ndz),fluxg(-1:ndx,-1:ndy,-1:ndz)
  DOUBLE PRECISION, dimension(-1:ndx) :: Phigrad,Phipre,fluxphi,Phiv,source,Phi2dt,Phiu,sourcepre,sourcepri
  character(5) name

  nu2 = cg * dt / dx
  Phipre(:) = Phiv(:)
  !write(name,'(i5.5)') cnt



  !------------ul.solver.+cg-------------
  if(mode==1) then
     !write(name,'(i5.5)') cnt
     !open(201,file='/Users/maeda/Desktop/kaiseki/testcode2/1modepre'//name//'.dat')
     !write(name,'(i5.5)') cnt+1
     !open(202,file='/Users/maeda/Desktop/kaiseki/testcode2/1modepos'//name//'.dat')
     !do i=-1,ndx
     !   write(201,*) i, Phiv(i)
     !end do
     call fluxcal(Phipre,Phipre,Phiu,0.0d0,1.d0/3.0d0,10)
     !call fluxcal(Phipre,Phipre,Phiu,0.0d0,0.0d0,10)
     !------------calcurate dt/2------------
     do i=ist-1,ndx-ien+1 !一次なので大丈夫
        Phi2dt(i) = Phipre(i) - 0.5d0 * nu2 * ( Phiu(i) - Phiu(i-1))
     end do
     !------------calcurate dt/2------------
     call fluxcal(Phi2dt,Phipre,Phiu,1.0d0,1.d0/3.0d0,1)
     !call fluxcal(Phi2dt,Phipre,Phiu,1.0d0,-1.d0,1)
     !call fluxcal(Phi2dt,Phipre,Phiu,1.0d0,0.0d0,1)
     !write(*,*) Phiu(127),'127-2'
     do i = ist , ndx-ien
        Phiv(i) = Phipre(i) - nu2 * (Phiu(i) - Phiu(i-1))
     end do
     !write(*,*) Phiv(127),'127-3'
     !do i=-1,ndx
     !   write(202,*) i, Phiv(i)
     !end do
  end if
  !------------ul.solver.+cg-------------



  !------------ul.solver.-cg-------------
  if(mode==2) then
     !write(name,'(i5.5)') cnt
     !open(201,file='/Users/maeda/Desktop/kaiseki/testcode2/2modepre'//name//'.dat')
     !write(name,'(i5.5)') cnt+1
     !open(202,file='/Users/maeda/Desktop/kaiseki/testcode2/2modepos'//name//'.dat')
     !do i=-1,ndx
     !   write(201,*) i, Phiv(i)
     !end do

     call fluxcal(Phipre,Phipre,Phiu,0.0d0,1.d0/3.0d0,11)
     !call fluxcal(Phipre,Phipre,Phiu,0.0d0,0.0d0,11)
     !------------calcurate dt/2------------
     do i=ist-1,ndx-ien+1
        Phi2dt(i) = Phipre(i) + 0.5d0 * nu2 * ( Phiu(i+1) - Phiu(i))
     end do
     !------------calcurate dt/2------------
     call fluxcal(Phi2dt,Phipre,Phiu,1.0d0,1.d0/3.0d0,4)
     !call fluxcal(Phi2dt,Phipre,Phiu,1.0d0,-1.0d0,4)
     !call fluxcal(Phi2dt,Phipre,Phiu,1.0d0,0.0d0,4)

     do i = ist , ndx-ien
        Phiv(i) = Phipre(i) + nu2 * (Phiu(i+1) - Phiu(i))
     end do

     !do i=-1,ndx
     !   write(202,*) i, Phiv(i)
     !end do

  end if
  !------------ul.solver.-cg-------------


  !--------------source------------------
  if(mode==3) then
     !write(name,'(i5.5)') cnt
     !open(201,file='/Users/maeda/Desktop/kaiseki/testcode2/3modepre'//name//'.dat')
     !write(name,'(i5.5)') cnt+1
     !open(202,file='/Users/maeda/Desktop/kaiseki/testcode2/3modepos'//name//'.dat')
     !do i=-1,ndx
     !   write(201,*) i, Phiv(i)
     !end do
     !write(*,*) 'in1'
     do i=ist,ndx-ien
        Phiv(i) =  cg * G4pi * source(i) * dt + Phipre(i)
     end do

     !do i=-1,ndx
     !   write(202,*) i, Phiv(i)
     !end do
  end if

  if(mode==4) then
     !write(name,'(i5.5)') cnt
     !open(201,file='/Users/maeda/Desktop/kaiseki/testcode2/4modepre'//name//'.dat')
     !write(name,'(i5.5)') cnt+1
     !open(202,file='/Users/maeda/Desktop/kaiseki/testcode2/4modepos'//name//'.dat')
     !do i=-1,ndx
     !   write(201,*) i, Phiv(i)
     !end do
    !write(*,*) source(ndx-ien), dt , Phipre(ndx-ien),cg * source(ndx-ien) * dt + Phipre(ndx-ien),'mode4'
     do i=ist,ndx-ien
        Phiv(i) = -cg * source(i) * dt + Phipre(i)
     end do

     !do i=-1,ndx
     !   write(202,*) i, Phiv(i)
     !end do
  end if
  !--------------source------------------



  !--------------sourcetest------------------
  if(mode==5) then
     do i=ist,ndx-ien
        Phiv(i) = cg * 0.5d0* (source(i+1) + source(i-1)) * dt + Phipre(i)
     end do
  end if

  if(mode==6) then
     !write(*,*) source(ndx-ien), dt , Phipre(ndx-ien),cg * source(ndx-ien) * dt + Phipre(ndx-ien),'mode4'
     sourcepri(:)=source(:)
     do i=ist,ndx-ien
        Phiv(i) = cg * source(i) * dt + Phipre(i) - 0.5d0 * cg * cg * dt * (source(i) - sourcepre(i))
     end do
     sourcepre(:)=sourcepri(:)
  end if
  !--------------sourcetest------------------

  if(mode==13) then
     sourcepre(:)=0.0d0
  end if

  close(201)
  close(202)
  cnt=cnt+2
end subroutine muslcslv1D

!subroutine vanalbada(fg,gradfg,iwx,iwy,iwz)
subroutine vanalbada(Phipre,Phigrad)
  use comvar
  double precision :: delp , delm ,flmt,eps=1.0d-10
  !integer :: i , ip , im , flmt ,eps=1.0d-10
  integer :: i , ip , im
  DOUBLE PRECISION, dimension(-1:ndx) :: Phigrad,Phipre

  do i = ist-1 , ndx - ien + 1
     ip=i+1
     im=i-1

     delp = Phipre(ip)-Phipre(i)
     delm = Phipre(i)-Phipre(im)
     flmt = dmax1( 0.d0,(2.d0*delp*delm+eps)/(delp**2+delm**2+eps) )
     !flmt = (2.d0*delp*delm+eps)/(delp**2+delm**2+eps)
     !if(i==58) then
     !   write(*,*) delp , delm ,Phipre(ip),Phipre(i),Phipre(im) , flmt
     !end if
     flmt = (2.d0*delp*delm+eps)/(delp**2+delm**2+eps)
     Phigrad(i) = flmt
     !grdU(i,k) = flmt*( wave(ixp,jyp,kzp)-wave(ixm,jym,kzm) )/( dxx(i)+0.5d0*dxx(i-1)+0.5d0*dxx(i+1) )
     !Phigrad(i) = flmt*( Phipre(ip)-Phipre(im) )/( 2.0d0 * dx )
  end do
end subroutine vanalbada

subroutine saveu(in1)
  use comvar
  use grvvar
  integer :: i,in1
  character(5) name

  write(name,'(i5.5)') in1
  open(21,file=dir//'phi'//name//'.dat')
  do i=1,ndx-2
     !if(i==1 .or. i==ndx-2) then
     !   write(21,*) x(i), Phicgp(i),Phi1step(i) , Phicgm(i),Phi2step(i)! ,&
     !        (Phicgp(i)+Phicgm(i))*0.5d0,(Phi1step(i)-Phi2step(i))*0.5d0, (Phicgp(i)-Phicgm(i)),&
     !        (Phicgp(i)+Phicgm(i))*0.5d0+dabs(Phicgp(i)-Phicgm(i)),&
                                !-((Phicgp(i-1)+Phicgm(i-1))*0.5d0 - (Phicgp(i+1)+Phicgm(i+1))*0.5d0)*0.5d0/dx,&
                                !(Phicgp(i)+Phicgm(i))*0.5d0-Phiexa(i),&
                                !-((Phicgp(i-1)+Phicgm(i-1))*0.5d0 - (Phicgp(i+1)+Phicgm(i+1))*0.5d0)*0.5d0/dx-Phigrd(i),&
                                !(-((Phicgp(i-1)+Phicgm(i-1))*0.5d0 - (Phicgp(i+1)+Phicgm(i+1))*0.5d0)*0.5d0/dx-Phigrd(i))/&
                                !((Phicgp(i-1)+Phicgm(i-1))*0.5d0 - (Phicgp(i+1)+Phicgm(i+1))*0.5d0)*0.5d0/dx,&
                                !-((Phicgp(i)+Phicgp(i))*0.5d0 - (Phicgp(i)+Phicgp(i))*0.5d0)*0.5d0/dx,&
                                !-((Phicgm(i)+Phicgm(i))*0.5d0 - (Phicgm(i)+Phicgm(i))*0.5d0)*0.5d0/dx
                                !Phigrd(i),Phigrd(i)
     !        Phi1step(i),-Phi2step(i),-Phicgp(i)+Phicgp(i),-Phicgm(i)+Phicgm(i)
     !   write(*,*) Phi1step(i),-Phi2step(i),i,Phigrd(i)
     !else
!        write(21,*) x(i), Phicgp(i),Phi1step(i) , Phicgm(i),Phi2step(i) ,&
!             (Phicgp(i)+Phicgm(i))*0.5d0,(Phi1step(i)-Phi2step(i))*0.5d0, (Phicgp(i)-Phicgm(i)),&
!             (Phicgp(i)+Phicgm(i))*0.5d0+(Phicgp(i)-Phicgm(i)),&
                                !-((Phicgp(i-1)+Phicgm(i-1))*0.5d0 - (Phicgp(i+1)+Phicgm(i+1))*0.5d0)*0.5d0/dx,&
                                !(Phicgp(i)+Phicgm(i))*0.5d0-Phiexa(i),&
                                !-((Phicgp(i-1)+Phicgm(i-1))*0.5d0 - (Phicgp(i+1)+Phicgm(i+1))*0.5d0)*0.5d0/dx-Phigrd(i),&
                                !(-((Phicgp(i-1)+Phicgm(i-1))*0.5d0 - (Phicgp(i+1)+Phicgm(i+1))*0.5d0)*0.5d0/dx-Phigrd(i))/&
                                !((Phicgp(i-1)+Phicgm(i-1))*0.5d0 - (Phicgp(i+1)+Phicgm(i+1))*0.5d0)*0.5d0/dx,&
!             -((Phicgp(i-1)+Phicgp(i-1))*0.5d0)*0.5d0/dx + ((Phicgp(i+1)+Phicgp(i+1))*0.5d0)*0.5d0/dx,&
!             -((Phicgm(i-1)+Phicgm(i-1))*0.5d0)*0.5d0/dx + ((Phicgm(i+1)+Phicgm(i+1))*0.5d0)*0.5d0/dx,&
             !-((Phicgp(i-1)+Phicgp(i-1))*0.5d0)/dx + ((Phicgp(i+1)+Phicgp(i+1))*0.5d0)/dx,&
             !-((Phicgm(i-1)+Phicgm(i-1))*0.5d0)/dx + ((Phicgm(i+1)+Phicgm(i+1))*0.5d0)/dx,&
!             -Phicgp(i-1)+Phicgp(i+1),-Phicgm(i-1)+Phicgm(i+1),&!-Phicgp(i-1)+Phicgp(i),-Phicgm(i)+Phicgm(i+1)
!             (3.0d0*Phicgp(i)-4.0d0*Phicgp(i-1)+Phicgp(i-2))*0.5d0/dx,&
!             -(3.0d0*Phicgp(i)-4.0d0*Phicgp(i+1)+Phicgp(i+2))*0.5d0/dx,&
!             (3.0d0*Phicgm(i)-4.0d0*Phicgm(i-1)+Phicgm(i-2))*0.5d0/dx,&
     !             -(3.0d0*Phicgm(i)-4.0d0*Phicgm(i+1)+Phicgm(i+2))*0.5d0/dx
     !write(21,*) x(i) , Phi(i),Phiexa(i)
     !end if
 write(21,*) x(i),',',Phicgp(i),',',Phicgm(i),','&
,amp*dsin(2.d0*pi*(x(i)-tint*cg)/Lbox),',',amp*dsin(2.d0*pi*(x(i)+tint*cg)/Lbox)
  end do
  close(21)
   !i=1
   !write(*,*) Phi1step(i),-Phi2step(i),Phigrd(i)
  !i=1
  !write(*,*)-((Phicgp(i-1)+Phicgp(i-1))*0.5d0 - (Phicgp(i+1)+Phicgp(i+1))*0.5d0)*0.5d0/dx,&
  !     -((Phicgm(i-1)+Phicgm(i-1))*0.5d0 - (Phicgm(i+1)+Phicgm(i+1))*0.5d0)*0.5d0/dx,&
  !     Phigrd(i)
  in1=in1+1
end subroutine saveu



subroutine fluxcal(preuse,pre,u,ep,kappa,mode)
  use comvar
  double precision :: ep , kappa
  DOUBLE PRECISION , dimension(-1:ndx) :: ul,ur,pre,slop,preuse,u
  integer :: i,mode
  !u(:)=0.0d0
  call vanalbada(pre,slop)
  if(mode==1) then
     do i = ist-1,ndx-ien+1
        ul(i) = preuse(i) + 0.25d0 * ep * slop(i) &
             * ((1.0d0-slop(i)*kappa)*(pre(i)-pre(i-1)) + (1.0d0+slop(i)*kappa)*(pre(i+1) - pre(i))) !i+1/2
        u(i)=ul(i)
     end do
     write(*,*) slop(127),'127slop'
     !u(:)=ul(:)
  end if


  if(mode==4) then
     do i = ist-1,ndx-ien+1
        ur(i) = preuse(i) - 0.25d0 * ep * slop(i) &
             * ((1.0d0+slop(i)*kappa)*(pre(i)-pre(i-1)) + (1.0d0-slop(i)*kappa)*(pre(i+1) - pre(i))) !i-1/2
        u(i)=ur(i)
     end do
     !write(*,*) slop(127),'127slop'
     !write(*,*) slop(ndx-ien),ndx-ien,slop(ndx-ien+1)
     !write(*,*) u(2)
     !u(:)=ur(:)
  end if

  if(mode==10) then
     do i = ist-2,ndx-ien+2
        ul(i) = preuse(i)
        u(i)=ul(i)
     end do
  end if

  if(mode==11) then
     do i = ist-2,ndx-ien+2
        ur(i) = preuse(i)
        u(i)=ur(i)
     end do
  end if

  if(mode==12) then
     do i = ist-1,ndx-ien+1
        ur(i) = preuse(i+1)
        u(i)=ur(i)
     end do
  end if



  !-----------test--------------
  !goto 400
  !if(mode==2) then
  !   do i = ist-1,ndx-ien+1
  !      ur(i) = preuse(i+1) - 0.25d0 * ep * slop(i) &
  !           * ((1.0d0+slop(i)*kappa)*(pre(i+1)-pre(i)) + (1.0d0-slop(i)*kappa)*(pre(i+2) - pre(i+1))) !i+1/2
  !   end do
  !   u(:)=ur(:)
  !end if


  !if(mode==3) then
  !   do i = ist-1,ndx-ien+1
  !      ur(i) = preuse(i+1) - 0.25d0 * ep * slop(i+1) &
  !           * ((1.0d0+slop(i+1)*kappa)*(pre(i+1)-pre(i)) + (1.0d0-slop(i+1)*kappa)*(pre(i+2) - pre(i+1))) !i+1/2
  !   end do
  !   u(:)=ur(:)
  !end if
  !400 continue
  !-----------test--------------
end subroutine fluxcal
