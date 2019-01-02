function ratInfo = readRatInfoTable(csvfname)

ratInfo = readtable(csvfname);

ratInfo = cleanUpRatTable(ratInfo);
