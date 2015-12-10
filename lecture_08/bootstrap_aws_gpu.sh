HERE IS MY AWESOME CHANGE

# AMI: ubuntu-trusty-14.04-amd64-server-20150506 (ami-76b2a71e)

tmux -S /tmp/mdagost new-session -s mdagost

sudo apt-get update
sudo apt-get install -y htop emacs git python-setuptools python-dev libatlas-dev libatlas-base-dev liblapack-dev g
# CUDA instructions here: https://github.com/BVLC/caffe/wiki/Install-Caffe-on-EC2-from-scratch-%28Ubuntu,-CUDA-7,-cuDNN%29
chmod +x cuda_7.0.28_linux.run
mkdir nvidia_installers
./cuda_7.0.28_linux.run -extract=`pwd`/nvidia_installers
sudo apt-get install -y linux-image-extra-virtual

echo -e "blacklist nouveau\nblacklist lbm-nouveau\noptions nouveau modeset=0\nalias nouveau off\nalias lbm-nouveau off" | sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf
echo options nouveau modeset=0 | sudo tee -a /etc/modprobe.d/nouveau-kms.conf
sudo update-initramfs -u

sudo reboot

sudo apt-get install -y linux-source
sudo apt-get install -y linux-headers-`uname -r`

cd nvidia_installers
sudo ./NVIDIA-Linux-x86_64-346.46.run

sudo modprobe nvidia
sudo apt-get install -y build-essential
sudo ./cuda-linux64-rel-7.0.28-19326674.run
sudo ./cuda-samples-linux-7.0.28-19326674.run

cd $HOME
echo -e "\nexport PATH=$PATH:/usr/local/cuda-7.0/bin\n\nexport LD_LIBRARY_PATH=:/usr/local/cuda-7.0/lib64" >> .bashrc  
source .bashrc

# to test the CUDA installation
# cd /usr/local/cuda-7.0/samples/1_Utilities/deviceQuery && sudo make && ./deviceQuery
# END CUDA

cd $HOME
mkdir nn_packages
cd nn_packages
git clone git@github.com:fchollet/keras.git
git clone git@github.com:aigamedev/scikit-neuralnetwork.git
git clone https://github.com/Lasagne/Lasagne.git

cd Lasagne
sudo pip install -r requirements.txt 
sudo python setup.py install

cd ../keras
sudo pip install cython
sudo python setup.py develop

cd ../scikit-neuralnetwork
sudo pip install -e git+https://github.com/lisa-lab/pylearn2.git#egg=Package
sudo python setup.py develop

sudo pip install seaborn 
sudo pip install jupyter tornado jinja2 pyzmq

# theano gpu check can be found here: http://deeplearning.net/software/theano/tutorial/using_gpu.html

# make sure /home/ubuntu/.local, /home/ubuntu/.theano,
# /home/ubuntu/.ipython, and /home/ubuntu/.ipynb_checkpoints are owned by ubuntu and not root

# also need to add a security rule to the instance to allow the notebook connection
# "Custom TCP Rule" to allow port 8888
cd $HOME
jupyter notebook --generate-config
emacs -nw /home/ubuntu/.jupyter/jupyter_notebook_config.py
jupyter notebook --no-browser --config=/home/ubuntu/.jupyter/jupyter_notebook_config.py

echo -e "[global]\nmode=FAST_RUN\ndevice=gpu\nfloatX=float32\n" > .theanorc
