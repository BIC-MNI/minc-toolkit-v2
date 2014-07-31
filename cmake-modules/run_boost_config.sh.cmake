#! /bin/sh

CXXFLAGS="@CXXFLAGS@" CFLAGS="@CFLAGS@" CC=@CC@ CXX=@CXX@ ./bootstrap.sh --without-libraries=atomic,chrono,context,date_time,exception,filesystem,graph,graph_parallel,iostreams,locale,log,math,mpi,program_options,python,random,regex,serialization,signals,test,timer,wave --prefix=@install_prefix@
