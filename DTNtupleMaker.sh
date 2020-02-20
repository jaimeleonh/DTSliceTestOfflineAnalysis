# Script to run t0 calculation (TPs run), ntuple production (for the Cs run), copy it to eos, plot and publish the standard plots - January 2020
# Written by Lourdes Urda 29/01/2020 (lourdes.urda@cern.ch)

#TPrun=$1
#CSrun=$2
#GlobalRun=$3

#source configForSliceTestAnalysis.sh

cd production/calib/

calibFile=t0i_run$1.txt

if [ -f "$calibFile" ] 
then
echo "Found t0i file. Remove file in order to rerun the T0 calibration"
else
cmsRun dtT0WireCalibration_cfg.py runNumber=$1 > t0i_run$1.txt
fi

ttrigFile=./Run$2-ttrig_timebox_v1/TimeBoxes/results/ttrig_timeboxes_Run$2_v1.db

if [ -f "$ttrigFile" ]
then 
echo "Found ttrig file. Remove file in order to rerun the ttrig calibration"
else
dtCalibration ttrig timeboxes all --run=$2 --trial=1 --label=ttrig_timebox --runselection=$2 --datasetpath=/Dummy/Dummy/RAW --globaltag=106X_dataRun3_Express_v2  --datasettype=Cosmics --run-on-RAW --phase2 --inputT0DB ./t0_run$1.db --input-files-local
fi

cd ..

ntupleFile=./DTDPGNtuple_run$2.root

if [ -f "$ntupleFile" ]
then 
echo "Found ntuple. Remove file in order to rerun the ntuple production"
else
cmsRun dtDpgNtuples_slicetest_cfg.py nEvents=-1 runNumber=$2 tTrigFilePh2=./calib/Run$2-ttrig_timebox_v1/TimeBoxes/results/ttrig_timeboxes_Run$2_v1.db t0FilePh2=./calib/t0_run$1.db
cp DTDPGNtuple_run$2.root /eos/cms/store/group/dpg_dt/comm_dt/commissioning_2019_data/ntuples/ST
fi

cd ../analyses/

root -b <<EOF
.x loadAllAnalyses.C
.L runAllAnalyses.C
runAllAnalyses("../production/DTDPGNtuple_run$2.root",$2)
EOF

./plotAndPublish.sh run$2

cd ..
