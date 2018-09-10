#!/bin/bash

# redirect output
exec 3>&1
exec &> "/fs/data3/hamzed/MultiSite_Project/RCode/1000025731/out/ENS-00008-1000025731/logfile.txt"

# host specific setup

echo 'prerun'

# create output folder
mkdir -p "/fs/data3/hamzed/MultiSite_Project/RCode/1000025731/out/ENS-00008-1000025731"

# see if application needs running
if [ ! -e "/fs/data3/hamzed/MultiSite_Project/RCode/1000025731/out/ENS-00008-1000025731/sipnet.out" ]; then
  cd "/fs/data3/hamzed/MultiSite_Project/RCode/1000025731/run/ENS-00008-1000025731"
  ln -s "/fs/data1/pecan.data/dbfiles/CRUNCEP_SIPNET_site_1-25731/CRUNCEP.1980-01-01.2010-12-31.clim" sipnet.clim

  "/fs/data5/pecan.models/SIPNET/trunk/sipnet"
  STATUS=$?
  
  # copy output
  mv "/fs/data3/hamzed/MultiSite_Project/RCode/1000025731/run/ENS-00008-1000025731/sipnet.out" "/fs/data3/hamzed/MultiSite_Project/RCode/1000025731/out/ENS-00008-1000025731"

  # check the status
  if [ $STATUS -ne 0 ]; then
  	echo -e "ERROR IN MODEL RUN\nLogfile is located at '/fs/data3/hamzed/MultiSite_Project/RCode/1000025731/out/ENS-00008-1000025731/logfile.txt'" >&3
  	exit $STATUS
  fi

  # convert to MsTMIP
  echo "require (PEcAn.SIPNET)
    model2netcdf.SIPNET('/fs/data3/hamzed/MultiSite_Project/RCode/1000025731/out/ENS-00008-1000025731', 40.6658, -77.9041, '1980/01/01', '2010/12/31', FALSE, 'r136')
    " | R --no-save
fi

# copy readme with specs to output
cp  "/fs/data3/hamzed/MultiSite_Project/RCode/1000025731/run/ENS-00008-1000025731/README.txt" "/fs/data3/hamzed/MultiSite_Project/RCode/1000025731/out/ENS-00008-1000025731/README.txt"

# run getdata to extract right variables

# host specific teardown

echo 'poststep'; sleep 60

# all done
echo -e "MODEL FINISHED\nLogfile is located at '/fs/data3/hamzed/MultiSite_Project/RCode/1000025731/out/ENS-00008-1000025731/logfile.txt'" >&3
