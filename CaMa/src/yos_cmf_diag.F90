MODULE YOS_CMF_DIAG
!==========================================================
!* PURPOSE: Shared diagnostic variables for CaMa-Flood
! (C) D.Yamazaki & E. Dutra  (U-Tokyo/FCUL)  Aug 2019
    
! Modified by Zhongwang Wei @ SYSU 2022.11.20: add water re-infiltration calculation 

! Licensed under the Apache License, Version 2.0 (the "License");
!   You may not use this file except in compliance with the License.
!   You may obtain a copy of the License at: http://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software distributed under the License is 
!  distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
! See the License for the specific language governing permissions and limitations under the License.
!==========================================================
   USE PARKIND1, only: JPIM, JPRB, JPRM, JPRD
   IMPLICIT NONE
   SAVE
   !================================================
   !*** Inst. diagnostics 
   real(KIND=JPRB),allocatable,target :: D2DIAG(:,:,:)        !! Storage array for average diagnostics

   real(KIND=JPRB),pointer         :: D2RIVINF(:,:)           !! river      inflow   [m3/s] (from upstream)
   real(KIND=JPRB),pointer         :: D2RIVDPH(:,:)           !! river      depth    [m]
   real(KIND=JPRB),pointer         :: D2RIVVEL(:,:)           !! flow velocity       [m/s]

   real(KIND=JPRB),pointer         :: D2FLDINF(:,:)           !! floodplain inflow   [m3/s]
   real(KIND=JPRB),pointer         :: D2FLDDPH(:,:)           !! floodplain depth    [m]
   real(KIND=JPRB),pointer         :: D2FLDFRC(:,:)           !! flooded    fractipn [m2/m2]
   real(KIND=JPRB),pointer         :: D2FLDARE(:,:)           !! flooded    area     [m2]

   real(KIND=JPRB),pointer         :: D2PTHOUT(:,:)           !! flood path outflow   [m3/s]
   real(KIND=JPRB),pointer         :: D2PTHINF(:,:)           !! flood path inflow   [m3/s]

   real(KIND=JPRB),pointer         :: D2SFCELV(:,:)           !! water surface elev  [m]    (elevtn - rivhgt + rivdph)
   real(KIND=JPRB),pointer         :: D2OUTFLW(:,:)           !! total outflow       [m3/s] (rivout + fldout)
   real(KIND=JPRB),pointer         :: D2STORGE(:,:)           !! total storage       [m3]   (rivsto + fldsto)

   real(KIND=JPRB),pointer         :: D2OUTINS(:,:)           !! instantaneous discharge [m3/s] (unrouted runoff)
   real(KIND=JPRB),pointer         :: D2WEVAPEX(:,:)          !! Evaporation water extracted
   real(KIND=JPRB),pointer         :: D2WINFILTEX(:,:)          !! Infiltration water extracted

   integer(KIND=JPIM)              :: N2DIAG                  !! number of 2D diagnostics

   !================================================
   !*** Average diagnostics 
   real(KIND=JPRB),allocatable,target :: D2DIAG_AVG(:,:,:)    !! Storage array for average diagnostics (nseqmax,1,variable)

   real(KIND=JPRB),pointer         :: D2RIVOUT_AVG(:,:)       !! average river       discharge
   real(KIND=JPRB),pointer         :: D2OUTFLW_AVG(:,:)       !! average total outflow       [m3/s] (rivout + fldout)  !! bugfix v362
   real(KIND=JPRB),pointer         :: D2FLDOUT_AVG(:,:)       !! average floodplain  discharge
   real(KIND=JPRB),pointer         :: D2RIVVEL_AVG(:,:)       !! average flow velocity
   real(KIND=JPRB),pointer         :: D2PTHOUT_AVG(:,:)       !! flood pathway net outflow (2D)

   real(KIND=JPRB),pointer         :: D2GDWRTN_AVG(:,:)       !! average ground water return flow
   real(KIND=JPRB),pointer         :: D2RUNOFF_AVG(:,:)       !! average input runoff
   real(KIND=JPRB),pointer         :: D2ROFSUB_AVG(:,:)       !! average input sub-surface runoff
   real(KIND=JPRB),pointer         :: D2WEVAPEX_AVG(:,:)      !! average extracted water evaporation
   real(KIND=JPRB),pointer         :: D2WINFILTEX_AVG(:,:)    !! average extracted Infiltration water

   integer(KIND=JPIM)              :: N2DIAG_AVG              !! Number of 2D diagnostics averages
   real(KIND=JPRB)                 :: NADD                    !! sum DT to calculate average
   !*** Average diagnostics (1D)
   real(KIND=JPRB),allocatable  :: D1PTHFLW_AVG(:,:)          !! bifurcation channel flow (1D, not 2D variable)

   !================================================
   !*** Daily max diagnostics 
   real(KIND=JPRB),allocatable,target :: D2DIAG_MAX(:,:,:)    !! Storage array for maximum diagnostics (nseqmax,1,variable)

   real(KIND=JPRB),pointer         :: D2OUTFLW_MAX(:,:)       !! max total outflow       [m3/s] (rivout + fldout)
   real(KIND=JPRB),pointer         :: D2STORGE_MAX(:,:)       !! max total outflow       [m3/s] (rivout + fldout)
   real(KIND=JPRB),pointer         :: D2RIVDPH_MAX(:,:)       !! max total outflow       [m3/s] (rivout + fldout)

   integer(KIND=JPRB)              :: N2DIAG_MAX              !! Number of 2D diagnostics maximum

   !================================================
   !*** Global total
   ! discharge calculation budget
   real(KIND=JPRD)                 :: P0GLBSTOPRE              !! global water storage      [m3] (befre flow calculation)
   real(KIND=JPRD)                 :: P0GLBSTONXT              !! global water storage      [m3] (after flow calculation)
   real(KIND=JPRD)                 :: P0GLBSTONEW              !! global water storage      [m3] (after runoff input)
   real(KIND=JPRD)                 :: P0GLBRIVINF              !! global inflow             [m3] (rivinf + fldinf)
   real(KIND=JPRD)                 :: P0GLBRIVOUT              !! global outflow            [m3] (rivout + fldout)

   ! stage calculation budget
   real(KIND=JPRD)                 :: P0GLBSTOPRE2             !! global water storage      [m3] (befre stage calculation)
   real(KIND=JPRD)                 :: P0GLBSTONEW2             !! global water storage      [m3] (after stage calculation)
   real(KIND=JPRD)                 :: P0GLBRIVSTO              !! global river storage      [m3]
   real(KIND=JPRD)                 :: P0GLBFLDSTO              !! global floodplain storage [m3]
   real(KIND=JPRD)                 :: P0GLBLEVSTO              !! global protected-side storage [m3] (levee scheme)
   real(KIND=JPRD)                 :: P0GLBFLDARE              !! global flooded area       [m2]

   !================================================
   !*** dam variable
   real(KIND=JPRB),pointer         :: D2DAMINF_AVG(:,:)       !! average reservoir inflow [m3/s]  !!!added

   !================================================
   !!!*** levee variables
   real(KIND=JPRB),pointer         :: D2LEVDPH(:,:)           !! flood depth in protected side (water depth betwen river & levee)



END MODULE YOS_CMF_DIAG
