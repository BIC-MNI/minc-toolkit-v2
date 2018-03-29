# -*- coding: utf-8 -*-
#
# Copyright 2016 Erik Bernhardsson
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import pandas as pd

import matplotlib
matplotlib.use('Agg')

import argparse, dateutil.parser, itertools, json, numpy, seaborn, sys
from matplotlib import pyplot


def generate_n_colors(n):
    vs = numpy.linspace(0.4, 1.0, 7)
    colors = [(.9, .4, .4)]
    def euclidean(a, b):
        return sum((x-y)**2 for x, y in zip(a, b))
    while len(colors) < n:
        new_color = max(itertools.product(vs, vs, vs), key=lambda a: min(euclidean(a, b) for b in colors))
        colors.append(new_color)
    return colors


def stack_plot(fr, outfile, normalize=False, dont_stack=False, max_n=20):

    
    if len(fr.columns) > max_n: # reformat columns and group together nonsignificant ones
        
        js = sorted([ (c,fr[c].sum()) for c in fr.columns ], key=lambda j: j[1], reverse=True)
        top_js  = [ i[0] for i in js[:max_n]]
        rest_js = [ i[0] for i in js[max_n:]]
        # replace
        fr['Others']=fr[rest_js].sum(axis=1)
        # remove
        fr=fr.drop(rest_js, axis=1)
        labels = top_js+['Others']
    else:
        js = sorted([ (c,fr[c].sum()) for c in fr.columns ], key=lambda j: j[1], reverse=True)
        labels  = [ i[0] for i in js]
        
    pyplot.figure(figsize=(13, 8))
    
    colors = generate_n_colors(len(labels))
    if dont_stack:
        for color, label in zip(colors, labels):
            pyplot.plot(fr.index, fr[label], color=color, label=label, linewidth=2)
    else:
        pyplot.stackplot(fr.index, fr[labels].T, labels=labels)#, colors=colors
        #fr.plot(kind='area')
        
    pyplot.legend(loc=2)
    pyplot.ylabel('Lines of code')
    pyplot.tight_layout()
    pyplot.savefig(outfile)

if __name__ == '__main__':
    all_datasets = pd.HDFStore('statistics.h5')
    # plot 
    stack_plot(all_datasets['all_authors'],'minc_toolkit_v2_top10_authors.png',max_n=10)
    stack_plot(all_datasets['all_cohorts'],'minc_toolkit_v2_by_year.png',max_n=100)
    stack_plot(all_datasets['all_exts'],   'minc_toolkit_v2_exts.png',max_n=10)
    
    # plot libminc authors separately
    stack_plot(all_datasets['libminc'],'libminc_top10_authors.png',max_n=10)
    
    all_datasets.close()