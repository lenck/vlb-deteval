import argparse
import glob
import os
import inspect
import json

import cv2
import pandas as pd
import numpy as np
from tqdm import tqdm


def root_path():
    # Assumes that the script is located in vlb-deteval/detect
    res = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
    return os.path.dirname(res)

def main():
    parser = argparse.ArgumentParser(description='Detect features with Python example')
    parser.add_argument('--root_path', help='root path of vlb-deteval', default=root_path())
    opts = parser.parse_args()
    info = det_info()

    imdbs = glob.glob(os.path.join(opts.root_path, 'imagelists', '*.csv'))
    for imdb in imdbs:
        print('Processing {}'.format(imdb))
        files = pd.read_csv(imdb, sep=';', names=['impath', 'dpath', 'dname'])
        with tqdm(total=files.shape[0]) as pbar:
            for index, row in files.iterrows():
                impath = os.path.join(opts.root_path, row['impath'])
                dest_dir = os.path.join(opts.root_path, row['dpath'], info['name'])
                if not os.path.exists(dest_dir):
                    os.makedirs(dest_dir)
                frames_path = os.path.join(dest_dir, row['dname'] + '.frames.csv')
                responses_path = os.path.join(dest_dir, row['dname'] + '.detresponses.csv')

                frames, responses = detect(impath)
                np.savetxt(frames_path, frames, delimiter=';')
                np.savetxt(responses_path, responses, delimiter=';')
                pbar.update(1)
    
    detdef_path = os.path.join(opts.root_path, 'expdefs', 'dets', info['name']+'.json')
    with open(detdef_path, 'w') as fd:
        json.dump(info, fd)
        print('Detector definition written to {}'.format(detdef_path))


################################################################################################
# Adjust the following two functions for your own detector
def det_info():
    # Set override to true if you want VLB to always recompute your results (do not cache scores)
    return {
        'name': 'cv-orb',
        'texname': 'CV-ORB',
        'color': [0.5, 0., 0.],
        'override': 0,
        'type': 'trinv'
        }

def detect(image_path):
    img = cv2.imread(image_path, 0)
    orb = cv2.ORB_create(2000)
    kpts = orb.detect(img, None)
    frames = np.zeros((len(kpts), 4))
    responses = np.zeros(len(kpts))
    for kpi, kp in enumerate(kpts):
        responses[kpi] = kp.response
        frames[kpi, 0] = kp.pt[0] + 1
        frames[kpi, 1] = kp.pt[1] + 1
        frames[kpi, 2] = kp.size / 2
        frames[kpi, 3] = kp.angle
    return frames, responses
################################################################################################


if __name__ == "__main__":
    main()
