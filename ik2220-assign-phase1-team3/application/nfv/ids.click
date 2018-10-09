Input_Eth1, Input_Eth3					:: AverageCounter;
Output_Eth1, Output_Eth2, Output_Eth3		:: AverageCounter; 
Blocked1                                        ::Counter
Blocked2				                  ::Counter
Blocked3				                  ::Counter
Blocked4				                  ::Counter
Blocked5				                  ::Counter
Blocked6				                  ::Counter
Blocked7				                  ::Counter



IPCounter                                       :: Counter
TestCounter1 :: Counter
TestCounter2 :: Counter
TestCounter3 :: Counter
TestCounter4 :: Counter
TestCounter5 :: Counter
TestCounter6 :: Counter
TestCounter7 :: Counter
TestCounter8 :: Counter
insw2_ids :: FromDevice(s6-eth1,METHOD LINUX, SNIFFER false);
inlb2_ids :: FromDevice(s6-eth3,METHOD LINUX, SNIFFER false);

outids_sw2 :: Queue->TestCounter6->Output_Eth1 -> ToDevice(s6-eth1);
outids_insp :: Queue->TestCounter7->Output_Eth2 -> ToDevice(s6-eth2);
outids_lb2 ::Queue->TestCounter8-> Output_Eth3 -> ToDevice(s6-eth3);

Http_class :: Classifier(
			 66/505554,    //PUT 
			 66/504F5354,  //POST
			 66/474554,    //GET
			 66/48454144,  //HEAD
			 66/4f5054494f4e53,//OPTIONS
			 66/5452414345, //TRACE
			 66/44454c455445,//DELETE
			 66/434f4e4e454354,//CONNECT
			 );
SQL_class :: Classifier(
			209/636174202f6574632f706173737764,    //cat /etc/passwd
			209/636174202f7661722f6c6f672f,        //cat /var/log/
			208/494e53455254,   //INSERT
			208/555044415445,   //UPDATE
			208/44454c455445,   //DELETE
			-);

insw2_ids->Input_Eth1->CheckIPHeader(14)->IPCounter->Http_class;
	    //PUT
		Http_class[0]->TestCounter1->SQL_class;
			SQL_class[0,1,2,3,4]->TestCounter2->Blocked1->outids_insp;
			SQL_class[5]->TestCounter5->outids_lb2;
		//POST
		Http_class[1]->TestCounter3->outids_lb2;
		//GET  HEAD OPTIONS TRACE DELETE CONNECT
		Http_class[2]->Blocked2->outids_insp;
		Http_class[3]->Blocked3->outids_insp;
		Http_class[4]->Blocked4->outids_insp;
		Http_class[5]->Blocked5->outids_insp;
		Http_class[6]->Blocked6->outids_insp;
		Http_class[7]->Blocked7->outids_insp;
			
inlb2_ids -> Input_Eth3->TestCounter4 ->outids_sw2;

//print report
DriverManager(wait 1sec, print >../results/ids.report "
=================== $Name Report ===================
Input Packet rate (pps):   	$(add $(Input_Eth1.rate) $(Input_Eth3.rate))
Output Packet rate (pps):  	$(add $(Output_Eth1.rate) $(Output_Eth2.rate) $(Output_Eth3.rate))
Blocked Packet rate (pps):	$(Output_Eth3.rate)

INPUT IP packets:             $(IPCounter.count)
Total # of input packets:  	$(add $(Input_Eth1.count) $(Input_Eth3.count))

Total # of allowed packets:	$(add $(Output_Eth1.count) $(Output_Eth3.count))
TestCount1:				$(TestCounter1.count)
TestCount2:				$(TestCounter2.count)
TestCount3:				$(TestCounter3.count)
TestCount4:				$(TestCounter4.count)
TestCount5:				$(TestCounter5.count)
TestCount6:				$(TestCounter6.count)
TestCount7:				$(TestCounter7.count)
TestCount8:				$(TestCounter8.count)

Blocked1:				$(Blocked1.count)
Blocked2:				$(Blocked2.count)
Blocked3:				$(Blocked3.count)
Blocked4:				$(Blocked4.count)
Blocked5:				$(Blocked5.count)
Blocked6:				$(Blocked6.count)
Blocked7:				$(Blocked7.count)




==================================================", loop );
