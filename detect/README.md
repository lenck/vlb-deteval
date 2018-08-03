# Evaluating a new detector
To evaluate your detector, you need to first compute the keypoints with detector respones for all images of all datasets and store them in an appropriate location.

To simplify this process, this folder contains examples how to do so in MATLAB (`detect_matlab.m`) and Python (`detect_python.py`). You might need to first provision the dataset files with `de provision datasets`.

After computing your features you need to add the detector definition file (`expdefs/dets/<DETNAME>.json`) to the
experiment specification (e.g. `expdefs/bmvc_results.json`).

You can check whether your detections are stored correctly with:
```matlab
>> de checkdetections <DETNAME>
```

To compute the results and to generate the figures and tables, run:
```matlab
>> de results expdef/<EXPERIMENT_DEF>.json
```
which will store all the results in `./data/results/<EXPERIMENT_DEF>`.
Before running, make sure that you provision features
of other detectors (`de provision features`).

> When developing a new detector, it is sometimes useful to disable caching of the detector scores. To do so, change `override` to `1` in the detector definition file.

---

## Notes about the detection files' format and target location
In order to simplify the process, the image paths and target paths of keypoints are stored in TXT file
for each dataset `./imagelists/<datasetname>.csv`
which contains three fields per line, one line per dataset image:
```
<input image path>;<destination folder (without KP name)>;<destination file name>\n
``` 
For example, keypoint geometry frames are stored in `<dest. folder>/<det. name>/<dest. file name>.frames.csv`.

Keypoints are stored in simple CSV files with one keypoint per line.
The code supports multiple formats,
as specified by [vl_feat](http://www.vlfeat.org/matlab/vl_plotframe.html).

![Types of keypoints](./images/frame-types.png)

More information about the geometric frame definitions can be found [here](http://www.vlfeat.org/api/covdet-fundamentals.html).
Different parameters of a keypoint are separated by a semicolon.
The location of a keypoint is in standard image coordinates (column, row) and the center of the first pixel of an image has a coordinate `(1,1)`.

E.g. an output of a simple grid-like detector (all radius 10) would be:
```
1;1;10
1;2;10
1;3;10
...
```
Similarly, feature responses are also stored as one response per line.
It is assumed that keypoints with higher response value are obtained with a detector with higher selectivity.

Additionally, you can check if your features are exported correctly by plotting the detections with:
```matlab
>> de view detections <datasetname> <featsname> <imid>
```


---

## Notes about directories
Summary of the most important paths of this framework.

Path | Contents
--- | --- 
`bin` | Binary distribution for MATLAB SDK. Provisioned with `getbin.sh`.
`imagelists` | Precomputed list of images for each dataset. Generated with `de imagelist`.
`expdefs/*.json` | JSON files specifying separate experiments.
`expdefs/dets/*.json` |  JSON files specifying detector parameters.
`data/features` | Detection geometry frames and responses, in CSV format `./dataset/detector/imagename.[frames|detresponses].csv`. Can be provisioned with `de provision features`.
`data/scores` | Cached repeatability results, in CSV and MAT format `expname_N/dataset/detector/results.[csv|mat]`. Can be provisioned with `de provision scores-compat` (CSV files only) or `de provision scores-all` (CSV and MAT files).
`data/results` | Generated result figures and tables, in `exp_name` subfolder.
`vlb/datasets` | Location for dataset images, automatically provisioned on demand. All can be provisioned with `de provision dataset`.
`datasets.mat` | Cached dataset structures (meta-data), part of the git repo. Used to avoid downloading the datasets' data unneccessarily.
