# Using VLB-DetEval with MATLAB Compiler Runtime

If you don't own a MATLAB license, you can use the binary distribution of this package. It is not as convenient as using MATLAB, however you should be able to use all functionality of this software. To start using VLB-DetEval follow these steps:

<a id=install-mcr></a>
### 1. Install MCR
The command line interface requires either MATLAB R2017a or the MATLAB Compiler Rumtime (MCR) installed. If you do not have MATLAB, you can download and install the MCR for free from [**here**](http://www.mathworks.com/products/compiler/mcr/). This package was developed with MATLAB 2017a.

Please note that more than 2GB of free space is required.

### 2. Get the binary distribution
To download the binary distribution of the VLB-Deteval, run:
```bash
$ ./get_bin.sh
```

### 3. Run the DE command line interface

Instead of calling just `de` (as shown in the main tutorial), use:
```
./bin/run_de.sh <MCR_ROOT> command
```
and replace the MCR_ROOT with the installation path of the MATLAB MCR.
For a simplicity, we would recommend to set up an alias to simplify the command:
```bash
$ alias de='./bin/run_de.sh <MCR_ROOT>'
```
as you can then use the `de` command directly from bash.