#!/bin/bash

# Script for setting up a cloud instance, for performing model training
# using kaldi together with CUDA

stage=2

. ./parse_options.sh

if [ $stage -le 0 ]; then
		# Install kaldi/training deps for debian 10
	sudo apt-get --yes install git vim g++ automake autoconf unzip wget sox \
		gfortran libtool subversion python2.7 python3 zlib1g-dev make python3-pandas

	# Install CUDA
	sudo apt-get install software-properties-common
	sudo add-apt-repository non-free
	sudo add-apt-repository contrib
	sudo apt-get install linux-headers-$(uname -r)
	sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/debian10/x86_64/7fa2af80.pub
	sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/debian10/x86_64/ /"
	sudo apt-get update
	sudo apt-get -y install cuda
fi

if [ $stage -le 1 ]; then
	# Fetch kaldi and install MKL
	git clone git@github.com:JohnDoe02/kaldi.git
	sudo kaldi/tools/extras/install_mkl.sh

	# Build kaldi
	cd kaldi
	git checkout private
	cd tools; make -j 8
	cd ../src; ./configure; make -j 8
	cd ../../
fi

if [ $stage -le 2 ]; then
	# Get personal speech dataset (note: this is a private repo!)
	git clone cloud_git:/var/git/speech-dataset
	cd speech-dataset
	./prepare_data.py
	cd ..

	cd kaldi/egs/rm/s5
	ln -s ../../../../speech-dataset dataset
	wget https://github.com/daanzu/kaldi-active-grammar/releases/download/v1.8.0/kaldi_model_daanzu_20200905_1ep-smalllm.zip
	unzip kaldi_model_daanzu_20200905_1ep-smalllm.zip
fi
