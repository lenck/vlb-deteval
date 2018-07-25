
# Evaluating your own detector
To evaluate your detector, you need to first compute the keypoints for all images of a dataset and store them in an appropriate location.
Afterwards, you can specify your own experiment by creating a new experiment definition JSON file.
With these, you can use the provided code to compute the results and generate the final figures.


## 1. New experiment definition
Create your own detector definition, e.g. by copying an existing detector:
```bash
$ cp ./expdefs/dets/detnet-s.json ./expdefs/dets/<featsname>.json
```
and simply update the `./expdefs/dets/<featsname>.json` file by specifying
LaTeX name, color and a target invariance of your detector.

Copy the existing BMVC experiment to a new json file, e.g.:
```bash
$ cp ./expdefs/bmvc_results.json ./expdefs/my_soa_results.json
```
and add your detector definition to the detectors section. Eventually, you
can redue the number of selected detectors.


## 2. Storing keypoints in a correct location
In order to do so, the keypoints and their feature responses has to be stored in an apropriate location in a CSV file.

### A. Storing keypoints in a CSV files
In order to simplify the process, the code can download the dataset and generate the appropriate paths for you
simply by running:
```maltab
>> de imagelist <featsname>
```
this will download all datasets (if not present) and create a set of files named
`./data/imagelists/<datasetname>-<featsname>.csv`
which contains three fields per line, one line per dataset image:
```
<input image path>;<target keypoint CSV path>;<target keypoint response path>\n
...

``` 
All paths are absolute paths.

Keypoints are stored in simple CSV files with one keypoint per line.
The code supports multiple formats,
as specified by [vl_feat](http://www.vlfeat.org/matlab/vl_plotframe.html).

![Types of keypoints](./images/frame-types.png)

More information about the geometric frame definitions can be found [here](http://www.vlfeat.org/api/covdet-fundamentals.html).
Different parameters of a keypoint are typically separated by a semicolon.

E.g. an output of a simple grid-like detector (all radius 10) would be:
```
0;0;10
0;1;10
0;2;10
...
```

Similarly, feature responses are also stored as one response per line.
It is assumed that keypoints with higher response value are obtained with a detector with higher selectivity.

You can check if your features are exported correctly by plotting the detections with:
```matlab
>> de view detections <datasetname> <featsname> <imid>
```
### B. Running a keypoint detector using MATLAB
For generating keypoints using MATLAB, you can also use directly the **VLB** tolbox (e.g. see a simple wrapper for [`vl_covdet`](https://github.com/lenck/vlb/blob/master/matlab/%2Bfeatures/%2Bdet/vlcovdet.m)), however make sure that your detector returns feature responses as well.

Once your detector is located at the appropriate location `vlb/matlab/+features/+det/DETNAME.m`, you can run the detector on all VLB-DetEval datasets by calling:

**TODO implement this...**
```matlab
>> de detect DETNAME addargs
```
This will overwrite the detector defition in `./expdef/dets/DETNAME.json` so it might be a good idea to version those using GIT.
 

## 3. Compute the results and generate figures
You can then compute your results simply with:
```matlab
>> de results expdef/my_soa_results.json
```
which will store all the results in `./data/results/my_soa_results`.
Please not that this might take a while as it recomputes all the results
from the BMVC experiment. Also make sure that you provision the features
of other detectors before continuing.