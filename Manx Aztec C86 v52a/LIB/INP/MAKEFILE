INSTALL=../libs

.inp.out:
	ord $*.inp $*.out

$(LIB):	$(LIB).out
	lb $(INSTALL)/$(LIB).lib -f $(LIB).out
