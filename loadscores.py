import argparse
import glob
import os
import inspect

import pandas as pd
import numpy as np
from tqdm import tqdm

"""
Example code on how to load all the computed scores to a pandas DataFrame.
"""

def root_path():
    # Assumes that the script is located in vlb-deteval
    res = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
    return res

def main():
    parser = argparse.ArgumentParser(description='Load all scores to Pandas DataFrame')
    parser.add_argument('expname', help='experiment name')
    parser.add_argument('--root_path', help='root path of vlb-deteval', default=root_path())
    opts = parser.parse_args()

    scores_path = os.path.join(opts.root_path, 'data', 'scores')
    result_files = [y for x in os.walk(scores_path) for y in glob.glob(os.path.join(x[0], '*.csv'))]
    # Filter out files of different experiments (might not work for suffixed exp-names)
    result_files = [x for x in result_files if x.startswith(os.path.join(scores_path, opts.expname))]
    
    results = (pd.read_csv(f, sep=',') for f in tqdm(result_files))
    results = pd.concat(results, sort=False)
    results['topn'] = results.benchmark.str.extract(r'(?P<topn>\d+)')
    print(results)

if __name__ == "__main__":
    main()
