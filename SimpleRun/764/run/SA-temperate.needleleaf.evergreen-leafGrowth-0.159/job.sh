#!/bin/bash

# redirect output
exec 3>&1
exec &> "/fs/data3/hamzed/MultiSite_Project/RCode/764/out/SA-temperate.needleleaf.evergreen-leafGrowth-0.159/logfile.txt"

# host specific setup

echo 'prerun'

# create output folder
mkdir -p "/fs/data3/hamzed/MultiSite_Project/RCode/764/out/SA-temperate.needleleaf.evergreen-leafGrowth-0.159"

# see if application needs running
if [ ! -e "/fs/data3/hamzed/MultiSite_Project/RCode/764/out/SA-temperate.needleleaf.evergreen-leafGrowth-0.159/sipnet.out" ]; then
  cd "/fs/data3/hamzed/MultiSite_Project/RCode/764/run/SA-temperate.needleleaf.evergreen-leafGrowth-0.159"
  ln -s "/fs/data1/pecan.data/dbfiles/CRUNCEP_SIPNET_site_0-764/CRUNCEP.1980-01-01.2010-12-31.clim" sipnet.clim

  "/fs/data5/pecan.models/SIPNET/trunk/sipnet"
  STATUS=$?
  
  # copy output
  mv "/fs/data3/hamzed/MultiSite_Project/RCode/764/run/SA-temperate.needleleaf.evergreen-leafGrowth-0.159/sipnet.out" "/fs/data3/hamzed/MultiSite_Project/RCode/764/out/SA-temperate.needleleaf.evergreen-leafGrowth-0.159"

  # check the status
  if [ $STATUS -ne 0 ]; then
  	echo -e "ERROR IN MODEL RUN\nLogfile is located at '/fs/data3/hamzed/MultiSite_Project/RCode/764/out/SA-temperate.needleleaf.evergreen-leafGrowth-0.159/logfile.txt'" >&3
  	exit $STATUS
  fi

  # convert to MsTMIP
  echo "require (PEcAn.SIPNET)
    model2netcdf.SIPNET('/fs/data3/hamzed/MultiSite_Project/RCode/764/out/SA-temperate.needleleaf.evergreen-leafGrowth-0.159', 44.3157, -121.608, '1980/01/01', '2010/12/31', FALSE, 'r136')
    " | R --no-save
fi

# copy readme with specs to output
cp  "/fs/data3/hamzed/MultiSite_Project/RCode/764/run/SA-temperate.needleleaf.evergreen-leafGrowth-0.159/README.txt" "/fs/data3/hamzed/MultiSite_Project/RCode/764/out/SA-temperate.needleleaf.evergreen-leafGrowth-0.159/README.txt"

# run getdata to extract right variables

# host specific teardown

echo 'poststep'; sleep 60

# all done
echo -e "MODEL FINISHED\nLogfile is located at '/fs/data3/hamzed/MultiSite_Project/RCode/764/out/SA-temperate.needleleaf.evergreen-leafGrowth-0.159/logfile.txt'" >&3
